Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4E935440441
	for <linux-mm@kvack.org>; Sat,  6 Feb 2016 09:33:16 -0500 (EST)
Received: by mail-lb0-f173.google.com with SMTP id dx2so63590448lbd.3
        for <linux-mm@kvack.org>; Sat, 06 Feb 2016 06:33:16 -0800 (PST)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id l189si12028491lfd.157.2016.02.06.06.33.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Feb 2016 06:33:14 -0800 (PST)
Received: by mail-lf0-x244.google.com with SMTP id h198so3795230lfh.3
        for <linux-mm@kvack.org>; Sat, 06 Feb 2016 06:33:14 -0800 (PST)
From: Dmitry Monakhov <dmonlist@gmail.com>
Subject: Re: [PATCH v8 6/9] dax: add support for fsync/msync
In-Reply-To: <1452230879-18117-7-git-send-email-ross.zwisler@linux.intel.com>
References: <1452230879-18117-1-git-send-email-ross.zwisler@linux.intel.com> <1452230879-18117-7-git-send-email-ross.zwisler@linux.intel.com>
Date: Sat, 06 Feb 2016 17:33:07 +0300
Message-ID: <878u2xrjrw.fsf@openvz.org>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Ross Zwisler <ross.zwisler@linux.intel.com> writes:

> To properly handle fsync/msync in an efficient way DAX needs to track dir=
ty
> pages so it is able to flush them durably to media on demand.
Please see coments below
>
> The tracking of dirty pages is done via the radix tree in struct
> address_space.  This radix tree is already used by the page writeback
> infrastructure for tracking dirty pages associated with an open file, and
> it already has support for exceptional (non struct page*) entries.  We
> build upon these features to add exceptional entries to the radix tree for
> DAX dirty PMD or PTE pages at fault time.
>
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  fs/dax.c            | 194 ++++++++++++++++++++++++++++++++++++++++++++++=
++++--
>  include/linux/dax.h |   2 +
>  mm/filemap.c        |   6 ++
>  3 files changed, 196 insertions(+), 6 deletions(-)
>
> diff --git a/fs/dax.c b/fs/dax.c
> index 5b84a46..0db21ea 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -24,6 +24,7 @@
>  #include <linux/memcontrol.h>
>  #include <linux/mm.h>
>  #include <linux/mutex.h>
> +#include <linux/pagevec.h>
>  #include <linux/pmem.h>
>  #include <linux/sched.h>
>  #include <linux/uio.h>
> @@ -324,6 +325,174 @@ static int copy_user_bh(struct page *to, struct ino=
de *inode,
>  	return 0;
>  }
>=20=20
> +#define NO_SECTOR -1
> +
> +static int dax_radix_entry(struct address_space *mapping, pgoff_t index,
IMHO it would be sane to call that function as dax_radix_entry_insert()=20
> +		sector_t sector, bool pmd_entry, bool dirty)
> +{
> +	struct radix_tree_root *page_tree =3D &mapping->page_tree;
> +	int type, error =3D 0;
> +	void *entry;
> +
> +	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
> +
> +	spin_lock_irq(&mapping->tree_lock);
> +	entry =3D radix_tree_lookup(page_tree, index);
> +
> +	if (entry) {
> +		type =3D RADIX_DAX_TYPE(entry);
> +		if (WARN_ON_ONCE(type !=3D RADIX_DAX_PTE &&
> +					type !=3D RADIX_DAX_PMD)) {
> +			error =3D -EIO;
> +			goto unlock;
> +		}
> +
> +		if (!pmd_entry || type =3D=3D RADIX_DAX_PMD)
> +			goto dirty;
> +		radix_tree_delete(&mapping->page_tree, index);
> +		mapping->nrexceptional--;
> +	}
> +
> +	if (sector =3D=3D NO_SECTOR) {
> +		/*
> +		 * This can happen during correct operation if our pfn_mkwrite
> +		 * fault raced against a hole punch operation.  If this
> +		 * happens the pte that was hole punched will have been
> +		 * unmapped and the radix tree entry will have been removed by
> +		 * the time we are called, but the call will still happen.  We
> +		 * will return all the way up to wp_pfn_shared(), where the
> +		 * pte_same() check will fail, eventually causing page fault
> +		 * to be retried by the CPU.
> +		 */
> +		goto unlock;
> +	}
> +
> +	error =3D radix_tree_insert(page_tree, index,
> +			RADIX_DAX_ENTRY(sector, pmd_entry));
> +	if (error)
> +		goto unlock;
> +
> +	mapping->nrexceptional++;
> + dirty:
> +	if (dirty)
> +		radix_tree_tag_set(page_tree, index, PAGECACHE_TAG_DIRTY);
> + unlock:
> +	spin_unlock_irq(&mapping->tree_lock);
> +	return error;
> +}
> +
> +static int dax_writeback_one(struct block_device *bdev,
> +		struct address_space *mapping, pgoff_t index, void *entry)
> +{
> +	struct radix_tree_root *page_tree =3D &mapping->page_tree;
> +	int type =3D RADIX_DAX_TYPE(entry);
> +	struct radix_tree_node *node;
> +	struct blk_dax_ctl dax;
> +	void **slot;
> +	int ret =3D 0;
> +
> +	spin_lock_irq(&mapping->tree_lock);
> +	/*
> +	 * Regular page slots are stabilized by the page lock even
> +	 * without the tree itself locked.  These unlocked entries
> +	 * need verification under the tree lock.
> +	 */
> +	if (!__radix_tree_lookup(page_tree, index, &node, &slot))
> +		goto unlock;
> +	if (*slot !=3D entry)
> +		goto unlock;
> +
> +	/* another fsync thread may have already written back this entry */
> +	if (!radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE))
> +		goto unlock;
> +
> +	radix_tree_tag_clear(page_tree, index, PAGECACHE_TAG_TOWRITE);
> +
> +	if (WARN_ON_ONCE(type !=3D RADIX_DAX_PTE && type !=3D RADIX_DAX_PMD)) {
> +		ret =3D -EIO;
> +		goto unlock;
> +	}
> +
> +	dax.sector =3D RADIX_DAX_SECTOR(entry);
> +	dax.size =3D (type =3D=3D RADIX_DAX_PMD ? PMD_SIZE : PAGE_SIZE);
> +	spin_unlock_irq(&mapping->tree_lock);
> +
> +	/*
> +	 * We cannot hold tree_lock while calling dax_map_atomic() because it
> +	 * eventually calls cond_resched().
> +	 */
> +	ret =3D dax_map_atomic(bdev, &dax);
> +	if (ret < 0)
> +		return ret;
> +
> +	if (WARN_ON_ONCE(ret < dax.size)) {
> +		ret =3D -EIO;
> +		goto unmap;
> +	}
> +
> +	wb_cache_pmem(dax.addr, dax.size);
> + unmap:
> +	dax_unmap_atomic(bdev, &dax);
> +	return ret;
> +
> + unlock:
> +	spin_unlock_irq(&mapping->tree_lock);
> +	return ret;
> +}
> +
> +/*
> + * Flush the mapping to the persistent domain within the byte range of [=
start,
> + * end]. This is required by data integrity operations to ensure file da=
ta is
> + * on persistent storage prior to completion of the operation.
> + */
> +int dax_writeback_mapping_range(struct address_space *mapping, loff_t st=
art,
> +		loff_t end)
> +{
> +	struct inode *inode =3D mapping->host;
> +	struct block_device *bdev =3D inode->i_sb->s_bdev;
> +	pgoff_t indices[PAGEVEC_SIZE];
> +	pgoff_t start_page, end_page;
> +	struct pagevec pvec;
> +	void *entry;
> +	int i, ret =3D 0;
> +
> +	if (WARN_ON_ONCE(inode->i_blkbits !=3D PAGE_SHIFT))
> +		return -EIO;
> +
> +	rcu_read_lock();
> +	entry =3D radix_tree_lookup(&mapping->page_tree, start & PMD_MASK);
> +	rcu_read_unlock();
> +
> +	/* see if the start of our range is covered by a PMD entry */
> +	if (entry && RADIX_DAX_TYPE(entry) =3D=3D RADIX_DAX_PMD)
> +		start &=3D PMD_MASK;
> +
> +	start_page =3D start >> PAGE_CACHE_SHIFT;
> +	end_page =3D end >> PAGE_CACHE_SHIFT;
> +
> +	tag_pages_for_writeback(mapping, start_page, end_page);
> +
> +	pagevec_init(&pvec, 0);
> +	while (1) {
> +		pvec.nr =3D find_get_entries_tag(mapping, start_page,
> +				PAGECACHE_TAG_TOWRITE, PAGEVEC_SIZE,
> +				pvec.pages, indices);
> +
> +		if (pvec.nr =3D=3D 0)
> +			break;
> +
> +		for (i =3D 0; i < pvec.nr; i++) {
> +			ret =3D dax_writeback_one(bdev, mapping, indices[i],
> +					pvec.pages[i]);
> +			if (ret < 0)
> +				return ret;
> +		}
I think it would be more efficient to use batched locking like follows:
                spin_lock_irq(&mapping->tree_lock);
		for (i =3D 0; i < pvec.nr; i++) {
                    struct blk_dax_ctl dax[PAGEVEC_SIZE];=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20
                    radix_tree_tag_clear(page_tree, indices[i], PAGECACHE_T=
AG_TOWRITE);
                    /* It is also reasonable to merge adjacent dax
                     * regions in to one */
                    dax[i].sector =3D RADIX_DAX_SECTOR(entry);
                    dax[i].size =3D (type =3D=3D RADIX_DAX_PMD ? PMD_SIZE :=
 PAGE_SIZE);=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20

                }
                spin_unlock_irq(&mapping->tree_lock);
               	if (blk_queue_enter(q, true) !=3D 0)
                    goto error;
                for (i =3D 0; i < pvec.nr; i++) {
                    rc =3D bdev_direct_access(bdev, dax[i]);
                    wb_cache_pmem(dax[i].addr, dax[i].size);
                }
                ret =3D blk_queue_exit(q, true)
> +	}
> +	wmb_pmem();
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(dax_writeback_mapping_range);
> +
>  static int dax_insert_mapping(struct inode *inode, struct buffer_head *b=
h,
>  			struct vm_area_struct *vma, struct vm_fault *vmf)
>  {
> @@ -363,6 +532,11 @@ static int dax_insert_mapping(struct inode *inode, s=
truct buffer_head *bh,
>  	}
>  	dax_unmap_atomic(bdev, &dax);
>=20=20
> +	error =3D dax_radix_entry(mapping, vmf->pgoff, dax.sector, false,
> +			vmf->flags & FAULT_FLAG_WRITE);
> +	if (error)
> +		goto out;
> +
>  	error =3D vm_insert_mixed(vma, vaddr, dax.pfn);
>=20=20
>   out:
> @@ -487,6 +661,7 @@ int __dax_fault(struct vm_area_struct *vma, struct vm=
_fault *vmf,
>  		delete_from_page_cache(page);
>  		unlock_page(page);
>  		page_cache_release(page);
> +		page =3D NULL;
>  	}
I've realized that I do not understand why dax_fault code works at all.
During dax_fault we want to remove page from mapping and insert dax-entry
 Basically code looks like follows:
0 page =3D find_get_page()
1 lock_page(page)
2 delete_from_page_cache(page);
3 unlock_page(page);
4 dax_insert_mapping(inode, &bh, vma, vmf);

BUT what on earth protects us from other process to reinsert page again
after step(2) but before (4)?
Imagine we do write to file-hole which result in to dax_fault(write), but
another task also does read fault and reinsert deleted page via dax_hole_lo=
ad
As result dax_tree_entry will fail with EIO
Testcase looks very trivial, but i can not reproduce this.
>=20=20
>  	/*
> @@ -591,7 +766,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsig=
ned long address,
>  	pgoff_t size, pgoff;
>  	loff_t lstart, lend;
>  	sector_t block;
> -	int result =3D 0;
> +	int error, result =3D 0;
>=20=20
>  	/* dax pmd mappings require pfn_t_devmap() */
>  	if (!IS_ENABLED(CONFIG_FS_DAX_PMD))
> @@ -733,6 +908,16 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsi=
gned long address,
>  		}
>  		dax_unmap_atomic(bdev, &dax);
>=20=20
> +		if (write) {
> +			error =3D dax_radix_entry(mapping, pgoff, dax.sector,
> +					true, true);
> +			if (error) {
> +				dax_pmd_dbg(&bh, address,
> +						"PMD radix insertion failed");
> +				goto fallback;
> +			}
> +		}
> +
>  		dev_dbg(part_to_dev(bdev->bd_part),
>  				"%s: %s addr: %lx pfn: %lx sect: %llx\n",
>  				__func__, current->comm, address,
> @@ -791,15 +976,12 @@ EXPORT_SYMBOL_GPL(dax_pmd_fault);
>   * dax_pfn_mkwrite - handle first write to DAX page
>   * @vma: The virtual memory area where the fault occurred
>   * @vmf: The description of the fault
> - *
>   */
>  int dax_pfn_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
>  {
> -	struct super_block *sb =3D file_inode(vma->vm_file)->i_sb;
> +	struct file *file =3D vma->vm_file;
>=20=20
> -	sb_start_pagefault(sb);
> -	file_update_time(vma->vm_file);
> -	sb_end_pagefault(sb);
> +	dax_radix_entry(file->f_mapping, vmf->pgoff, NO_SECTOR, false, true);
>  	return VM_FAULT_NOPAGE;
>  }
>  EXPORT_SYMBOL_GPL(dax_pfn_mkwrite);
> diff --git a/include/linux/dax.h b/include/linux/dax.h
> index e9d57f68..8204c3d 100644
> --- a/include/linux/dax.h
> +++ b/include/linux/dax.h
> @@ -41,4 +41,6 @@ static inline bool dax_mapping(struct address_space *ma=
pping)
>  {
>  	return mapping->host && IS_DAX(mapping->host);
>  }
> +int dax_writeback_mapping_range(struct address_space *mapping, loff_t st=
art,
> +		loff_t end);
>  #endif
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 1e215fc..2e7c8d9 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -482,6 +482,12 @@ int filemap_write_and_wait_range(struct address_spac=
e *mapping,
>  {
>  	int err =3D 0;
>=20=20
> +	if (dax_mapping(mapping) && mapping->nrexceptional) {
> +		err =3D dax_writeback_mapping_range(mapping, lstart, lend);
> +		if (err)
> +			return err;
> +	}
> +
>  	if (mapping->nrpages) {
>  		err =3D __filemap_fdatawrite_range(mapping, lstart, lend,
>  						 WB_SYNC_ALL);
> --=20
> 2.5.0
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBCgAGBQJWtgQjAAoJELhyPTmIL6kBCwAIAJYQRJRSwkbJDZpwrfftBqwe
mda1iK6TNeMcEqmObR8SUVr1wxAdEBRJPgPfbNZslKnTwISSqMh3TJIW1sG9uNq/
6G8n7hxSFloCDz24dL6NLz6rmNHFkE6QPRCmhxjYoVY33tvc6UJUKk+F8BsQzIBH
U8wY6ljtEkto8FZCbvs4RQyua8lf/pGfk5t8gZKhXPwpQNhUIe8fvfpwyuX+xcOV
DMrHpKjz+PTksXn5bAGfgOfxPy+9aGHGa/f20n2galOe2o7HyO6kKVJZWfQ4ihA1
D0sG3MEPmRpk0JCB9z1E301s6CLZrg++ZEGuac2TrxYSWKjrLxBh17+ldfzbRzE=
=tCyF
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
