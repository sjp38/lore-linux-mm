Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 79FF96B02C7
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 20:43:32 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id o7-v6so8530963ioh.22
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 17:43:32 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id z18-v6si5822337iol.134.2018.10.25.17.43.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 17:43:30 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH RFC v2 1/1] hugetlbfs: use i_mmap_rwsem for pmd sharing
 and truncate/fault sync
Date: Fri, 26 Oct 2018 00:42:20 +0000
Message-ID: <20181026004220.GA8637@hori1.linux.bs1.fc.nec.co.jp>
References: <20181024045053.1467-1-mike.kravetz@oracle.com>
 <20181024045053.1467-2-mike.kravetz@oracle.com>
In-Reply-To: <20181024045053.1467-2-mike.kravetz@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <EC126A47AF18E3438874B0F13E115092@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>

Hi Mike,

On Tue, Oct 23, 2018 at 09:50:53PM -0700, Mike Kravetz wrote:
> hugetlbfs does not correctly handle page faults racing with truncation.
> In addition, shared pmds can cause additional issues.
>=20
> Without pmd sharing, issues can occur as follows:
>   A huegtlbfs file is mmap(MAP_SHARED) with a size of 4 pages.  At
>   mmap time, 4 huge pages are reserved for the file/mapping.  So,
>   the global reserve count is 4.  In addition, since this is a shared
>   mapping an entry for 4 pages is added to the file's reserve map.
>   The first 3 of the 4 pages are faulted into the file.  As a result,
>   the global reserve count is now 1.
>=20
>   Task A starts to fault in the last page (routines hugetlb_fault,
>   hugetlb_no_page).  It allocates a huge page (alloc_huge_page).
>   The reserve map indicates there is a reserved page, so this is
>   used and the global reserve count goes to 0.
>=20
>   Now, task B truncates the file to size 0.  It starts by setting
>   inode size to 0(hugetlb_vmtruncate).  It then unmaps all mapping
>   of the file (hugetlb_vmdelete_list).  Since task A's page table
>   lock is not held at the time, truncation is not blocked.  Truncation
>   removes the 3 pages from the file (remove_inode_hugepages).  When
>   cleaning up the reserved pages (hugetlb_unreserve_pages), it notices
>   the reserve map was for 4 pages.  However, it has only freed 3 pages.
>   So it assumes there is still (4 - 3) 1 reserved pages.  It then
>   decrements the global reserve count by 1 and it goes negative.
>=20
>   Task A then continues the page fault process and adds it's newly
>   acquired page to the page cache.  Note that the index of this page
>   is beyond the size of the truncated file (0).  The page fault process
>   then notices the file has been truncated and exits.  However, the
>   page is left in the cache associated with the file.
>=20
>   Now, if the file is immediately deleted the truncate code runs again.
>   It will find and free the one page associated with the file.  When
>   cleaning up reserves, it notices the reserve map is empty.  Yet, one
>   page freed.  So, the global reserve count is decremented by (0 - 1) -1.
>   This returns the global count to 0 as it should be.  But, it is
>   possible for someone else to mmap this file/range before it is deleted.
>   If this happens, a reserve map entry for the allocated page is created
>   and the reserved page is forever leaked.
>=20
> With pmd sharing, the situation is even worse.  Consider the following:
>   A task processes a page fault on a shared hugetlbfs file and calls
>   huge_pte_alloc to get a ptep.  Suppose the returned ptep points to a
>   shared pmd.
>=20
>   Now, anopther task truncates the hugetlbfs file.  As part of truncation=
,
>   it unmaps everyone who has the file mapped.  If a task has a shared pmd
>   in this range, huge_pmd_unshhare will be called.  If this is not the la=
st

(sorry, nitpicking ..) a few typos ("anophter" and "unshhare").

>   user sharing the pmd, huge_pmd_unshare will clear pud pointing to the
>   pmd.  For the task in the middle of the page fault, the ptep returned b=
y
>   huge_pte_alloc points to another task's page table or worse.  This lead=
s
>   to bad things such as incorrect page map/reference counts or invalid
>   memory references.
>=20
> i_mmap_rwsem is currently used for pmd sharing synchronization.  It is al=
so
> held during unmap and whenever a call to huge_pmd_unshare is possible.  I=
t
> is only acquired in write mode.  Expand and modify the use of i_mmap_rwse=
m
> as follows:
> - i_mmap_rwsem is held in write mode for the duration of truncate
>   processing.
> - i_mmap_rwsem is held in write mode whenever huge_pmd_share is called.

I guess you mean huge_pmd_unshare here, right?

> - i_mmap_rwsem is held in read mode whenever huge_pmd_share is called.
>   Today that is only via huge_pte_alloc.
> - i_mmap_rwsem is held in read mode after huge_pte_alloc, until the calle=
r
>   is finished with the returned ptep.
>=20
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  fs/hugetlbfs/inode.c | 21 ++++++++++----
>  mm/hugetlb.c         | 65 +++++++++++++++++++++++++++++++++-----------
>  mm/rmap.c            | 10 +++++++
>  mm/userfaultfd.c     | 11 ++++++--
>  4 files changed, 84 insertions(+), 23 deletions(-)
>=20
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 32920a10100e..6ee97622a231 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -426,10 +426,16 @@ static void remove_inode_hugepages(struct inode *in=
ode, loff_t lstart,
>  			u32 hash;
> =20
>  			index =3D page->index;
> -			hash =3D hugetlb_fault_mutex_hash(h, current->mm,
> +			/*
> +			 * No need to take fault mutex for truncation as we
> +			 * are synchronized via i_mmap_rwsem.
> +			 */
> +			if (!truncate_op) {
> +				hash =3D hugetlb_fault_mutex_hash(h, current->mm,
>  							&pseudo_vma,
>  							mapping, index, 0);
> -			mutex_lock(&hugetlb_fault_mutex_table[hash]);
> +				mutex_lock(&hugetlb_fault_mutex_table[hash]);
> +			}
> =20
>  			/*
>  			 * If page is mapped, it was faulted in after being
> @@ -470,7 +476,8 @@ static void remove_inode_hugepages(struct inode *inod=
e, loff_t lstart,
>  			}
> =20
>  			unlock_page(page);
> -			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
> +			if (!truncate_op)
> +				mutex_unlock(&hugetlb_fault_mutex_table[hash]);
>  		}
>  		huge_pagevec_release(&pvec);
>  		cond_resched();
> @@ -505,8 +512,8 @@ static int hugetlb_vmtruncate(struct inode *inode, lo=
ff_t offset)
>  	i_mmap_lock_write(mapping);
>  	if (!RB_EMPTY_ROOT(&mapping->i_mmap.rb_root))
>  		hugetlb_vmdelete_list(&mapping->i_mmap, pgoff, 0);
> -	i_mmap_unlock_write(mapping);
>  	remove_inode_hugepages(inode, offset, LLONG_MAX);
> +	i_mmap_unlock_write(mapping);

I just have an impression that hugetlbfs_punch_hole() could have the
similar race and extending lock range there could be an improvement,
although I might miss something as always.

>  	return 0;
>  }
> =20
> @@ -624,7 +631,11 @@ static long hugetlbfs_fallocate(struct file *file, i=
nt mode, loff_t offset,
>  		/* addr is the offset within the file (zero based) */
>  		addr =3D index * hpage_size;
> =20
> -		/* mutex taken here, fault path and hole punch */
> +		/*
> +		 * fault mutex taken here, protects against fault path
> +		 * and hole punch.  inode_lock previously taken protects
> +		 * against truncation.
> +		 */
>  		hash =3D hugetlb_fault_mutex_hash(h, mm, &pseudo_vma, mapping,
>  						index, addr);
>  		mutex_lock(&hugetlb_fault_mutex_table[hash]);
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 7b5c0ad9a6bd..e9da3eee262f 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3252,18 +3252,33 @@ int copy_hugetlb_page_range(struct mm_struct *dst=
, struct mm_struct *src,
> =20
>  	for (addr =3D vma->vm_start; addr < vma->vm_end; addr +=3D sz) {
>  		spinlock_t *src_ptl, *dst_ptl;
> +		struct vm_area_struct *dst_vma;
> +		struct address_space *mapping;
> +
>  		src_pte =3D huge_pte_offset(src, addr, sz);
>  		if (!src_pte)
>  			continue;
> +
> +		/*
> +		 * i_mmap_rwsem must be held to call huge_pte_alloc.
> +		 * Continue to hold until finished with dst_pte, otherwise
> +		 * it could go away if part of a shared pmd.
> +		 */
> +		dst_vma =3D find_vma(dst, addr);
> +		mapping =3D dst_vma->vm_file->f_mapping;

If vma->vm_file->f_mapping gives the same mapping, you may omit the find_vm=
a()?

> +		i_mmap_lock_read(mapping);
>  		dst_pte =3D huge_pte_alloc(dst, addr, sz);
>  		if (!dst_pte) {
> +			i_mmap_unlock_read(mapping);
>  			ret =3D -ENOMEM;
>  			break;
>  		}
> =20
>  		/* If the pagetables are shared don't copy or take references */
> -		if (dst_pte =3D=3D src_pte)
> +		if (dst_pte =3D=3D src_pte) {
> +			i_mmap_unlock_read(mapping);
>  			continue;
> +		}
> =20
>  		dst_ptl =3D huge_pte_lock(h, dst, dst_pte);
>  		src_ptl =3D huge_pte_lockptr(h, src, src_pte);

[...]

> diff --git a/mm/rmap.c b/mm/rmap.c
> index 1e79fac3186b..db49e734dda8 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1347,6 +1347,7 @@ static bool try_to_unmap_one(struct page *page, str=
uct vm_area_struct *vma,
>  	bool ret =3D true;
>  	unsigned long start =3D address, end;
>  	enum ttu_flags flags =3D (enum ttu_flags)arg;
> +	bool pmd_sharing_possible =3D false;
> =20
>  	/* munlock has nothing to gain from examining un-locked vmas */
>  	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
> @@ -1376,8 +1377,15 @@ static bool try_to_unmap_one(struct page *page, st=
ruct vm_area_struct *vma,
>  		 * accordingly.
>  		 */
>  		adjust_range_if_pmd_sharing_possible(vma, &start, &end);
> +		if ((end - start) > (PAGE_SIZE << compound_order(page)))
> +			pmd_sharing_possible =3D true;

Maybe the similar check is done in adjust_range_if_pmd_sharing_possible()
as the function name claims, so does it make more sense to get this bool
value via the return value?

Thanks,
Naoya Horiguchi=
