Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 091B482997
	for <linux-mm@kvack.org>; Fri, 22 May 2015 02:26:35 -0400 (EDT)
Received: by paza2 with SMTP id a2so2299075paz.3
        for <linux-mm@kvack.org>; Thu, 21 May 2015 23:26:34 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id cn10si1909191pac.193.2015.05.21.23.26.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 21 May 2015 23:26:34 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC v3 PATCH 04/10] mm/hugetlb: expose hugetlb fault mutex for
 use by fallocate
Date: Fri, 22 May 2015 06:23:45 +0000
Message-ID: <20150522062344.GB21526@hori1.linux.bs1.fc.nec.co.jp>
References: <1432223264-4414-1-git-send-email-mike.kravetz@oracle.com>
 <1432223264-4414-5-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1432223264-4414-5-git-send-email-mike.kravetz@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <6BFE24611483ED4C88169D16B37842D9@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>

On Thu, May 21, 2015 at 08:47:38AM -0700, Mike Kravetz wrote:
> hugetlb page faults are currently synchronized by the table of
> mutexes (htlb_fault_mutex_table).  fallocate code will need to
> synchronize with the page fault code when it allocates or
> deletes pages.  Expose interfaces so that fallocate operations
> can be synchronized with page faults.
>=20
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  include/linux/hugetlb.h |  3 +++
>  mm/hugetlb.c            | 23 ++++++++++++++++++++++-
>  2 files changed, 25 insertions(+), 1 deletion(-)
>=20
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index fd337f2..d0d033e 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -82,6 +82,9 @@ void putback_active_hugepage(struct page *page);
>  bool is_hugepage_active(struct page *page);
>  void free_huge_page(struct page *page);
>  void hugetlb_fix_reserve_counts(struct inode *inode, bool restore_reserv=
e);
> +u32 hugetlb_fault_mutex_shared_hash(struct address_space *mapping, pgoff=
_t idx);
> +void hugetlb_fault_mutex_lock(u32 hash);
> +void hugetlb_fault_mutex_unlock(u32 hash);
> =20
>  #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
>  pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *p=
ud);
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 620cc9e..df0d32a 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3183,7 +3183,8 @@ static u32 fault_mutex_hash(struct hstate *h, struc=
t mm_struct *mm,
>  	unsigned long key[2];
>  	u32 hash;
> =20
> -	if (vma->vm_flags & VM_SHARED) {
> +	/* !vma implies this was called from hugetlbfs fallocate code */
> +	if (!vma || vma->vm_flags & VM_SHARED) {
>  		key[0] =3D (unsigned long) mapping;
>  		key[1] =3D idx;
>  	} else {
> @@ -3209,6 +3210,26 @@ static u32 fault_mutex_hash(struct hstate *h, stru=
ct mm_struct *mm,
>  }
>  #endif
> =20
> +/*
> + * Interfaces to the fault mutex routines for use by hugetlbfs
> + * fallocate code.  Faults must be synchronized with page adds or
> + * deletes by fallocate.  fallocate only deals with shared mappings.
> + */
> +u32 hugetlb_fault_mutex_shared_hash(struct address_space *mapping, pgoff=
_t idx)
> +{
> +	return fault_mutex_hash(NULL, NULL, NULL, mapping, idx, 0);
> +}
> +
> +void hugetlb_fault_mutex_lock(u32 hash)
> +{
> +	mutex_lock(&htlb_fault_mutex_table[hash]);
> +}
> +
> +void hugetlb_fault_mutex_unlock(u32 hash)
> +{
> +	mutex_unlock(&htlb_fault_mutex_table[hash]);
> +}
> +
>  int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  			unsigned long address, unsigned int flags)
>  {

You introduce new lock/unlock interfaces, so how about making the existing
user of this lock (i.e. hugetlb_fault()) use them?

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
