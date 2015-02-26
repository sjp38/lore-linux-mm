Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id D2E7D6B006E
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 10:00:00 -0500 (EST)
Received: by qcvs11 with SMTP id s11so8762128qcv.8
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 07:00:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 142si955372qhr.25.2015.02.26.06.59.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Feb 2015 07:00:00 -0800 (PST)
Message-ID: <54EF34C5.1090007@redhat.com>
Date: Thu, 26 Feb 2015 15:59:17 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] mm, shmem: Add shmem resident memory accounting
References: <1424958666-18241-1-git-send-email-vbabka@suse.cz> <1424958666-18241-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1424958666-18241-4-git-send-email-vbabka@suse.cz>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="W5VSd93o9jcgmHBUTaPRSBjTJ215cngGm"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--W5VSd93o9jcgmHBUTaPRSBjTJ215cngGm
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 02/26/2015 02:51 PM, Vlastimil Babka wrote:
> From: Jerome Marchand <jmarchan@redhat.com>
>=20
> Currently looking at /proc/<pid>/status or statm, there is no way to
> distinguish shmem pages from pages mapped to a regular file (shmem
> pages are mapped to /dev/zero), even though their implication in
> actual memory use is quite different.
> This patch adds MM_SHMEMPAGES counter to mm_rss_stat to account for
> shmem pages instead of MM_FILEPAGES.
>=20
> [vbabka@suse.cz: port to 4.0, add #ifdefs, mm_counter_file() variant]
> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  arch/s390/mm/pgtable.c   |  5 +----
>  fs/proc/task_mmu.c       |  4 +++-
>  include/linux/mm.h       | 28 ++++++++++++++++++++++++++++
>  include/linux/mm_types.h |  9 ++++++---
>  kernel/events/uprobes.c  |  2 +-
>  mm/memory.c              | 30 ++++++++++--------------------
>  mm/oom_kill.c            |  5 +++--
>  mm/rmap.c                | 15 ++++-----------
>  8 files changed, 56 insertions(+), 42 deletions(-)
>=20
> diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
> index b2c1542..5bffd5d 100644
> --- a/arch/s390/mm/pgtable.c
> +++ b/arch/s390/mm/pgtable.c
> @@ -617,10 +617,7 @@ static void gmap_zap_swap_entry(swp_entry_t entry,=
 struct mm_struct *mm)
>  	else if (is_migration_entry(entry)) {
>  		struct page *page =3D migration_entry_to_page(entry);
> =20
> -		if (PageAnon(page))
> -			dec_mm_counter(mm, MM_ANONPAGES);
> -		else
> -			dec_mm_counter(mm, MM_FILEPAGES);
> +		dec_mm_counter(mm, mm_counter(page));
>  	}
>  	free_swap_and_cache(entry);
>  }
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 0410309..d70334c 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -81,7 +81,8 @@ unsigned long task_statm(struct mm_struct *mm,
>  			 unsigned long *shared, unsigned long *text,
>  			 unsigned long *data, unsigned long *resident)
>  {
> -	*shared =3D get_mm_counter(mm, MM_FILEPAGES);
> +	*shared =3D get_mm_counter(mm, MM_FILEPAGES) +
> +		get_mm_counter(mm, MM_SHMEMPAGES);
>  	*text =3D (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK))
>  								>> PAGE_SHIFT;
>  	*data =3D mm->total_vm - mm->shared_vm;
> @@ -501,6 +502,7 @@ static void smaps_pte_entry(pte_t *pte, unsigned lo=
ng addr,
>  					pte_none(*pte) && vma->vm_file) {
>  		struct address_space *mapping =3D
>  			file_inode(vma->vm_file)->i_mapping;
> +		pgoff_t pgoff =3D linear_page_index(vma, addr);
> =20
>  		/*
>  		 * shmem does not use swap pte's so we have to consult
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 47a9392..adfbb5b 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1364,6 +1364,16 @@ static inline unsigned long get_mm_counter(struc=
t mm_struct *mm, int member)
>  	return (unsigned long)val;
>  }
> =20
> +/* A wrapper for the CONFIG_SHMEM dependent counter */
> +static inline unsigned long get_mm_counter_shmem(struct mm_struct *mm)=

> +{
> +#ifdef CONFIG_SHMEM
> +	return get_mm_counter(mm, MM_SHMEMPAGES);
> +#else
> +	return 0;
> +#endif
> +}
> +
>  static inline void add_mm_counter(struct mm_struct *mm, int member, lo=
ng value)
>  {
>  	atomic_long_add(value, &mm->rss_stat.count[member]);
> @@ -1379,9 +1389,27 @@ static inline void dec_mm_counter(struct mm_stru=
ct *mm, int member)
>  	atomic_long_dec(&mm->rss_stat.count[member]);
>  }
> =20
> +/* Optimized variant when page is already known not to be PageAnon */
> +static inline int mm_counter_file(struct page *page)

Just a nitpick, but I don't like that name as it keeps the confusion we
currently have between shmem and file backed pages. I'm not sure what
other name to use though. mm_counter_shared() maybe? I'm not sure it is
less confusing...

Jerome

> +{
> +#ifdef CONFIG_SHMEM
> +	if (PageSwapBacked(page))
> +		return MM_SHMEMPAGES;
> +#endif
> +	return MM_FILEPAGES;
> +}
> +
> +static inline int mm_counter(struct page *page)
> +{
> +	if (PageAnon(page))
> +		return MM_ANONPAGES;
> +	return mm_counter_file(page);
> +}
> +
>  static inline unsigned long get_mm_rss(struct mm_struct *mm)
>  {
>  	return get_mm_counter(mm, MM_FILEPAGES) +
> +		get_mm_counter_shmem(mm) +
>  		get_mm_counter(mm, MM_ANONPAGES);
>  }
> =20
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 199a03a..d3c2372 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -327,9 +327,12 @@ struct core_state {
>  };
> =20
>  enum {
> -	MM_FILEPAGES,
> -	MM_ANONPAGES,
> -	MM_SWAPENTS,
> +	MM_FILEPAGES,	/* Resident file mapping pages */
> +	MM_ANONPAGES,	/* Resident anonymous pages */
> +	MM_SWAPENTS,	/* Anonymous swap entries */
> +#ifdef CONFIG_SHMEM
> +	MM_SHMEMPAGES,	/* Resident shared memory pages */
> +#endif
>  	NR_MM_COUNTERS
>  };
> =20
> diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
> index cb346f2..0a08fdd 100644
> --- a/kernel/events/uprobes.c
> +++ b/kernel/events/uprobes.c
> @@ -188,7 +188,7 @@ static int __replace_page(struct vm_area_struct *vm=
a, unsigned long addr,
>  	lru_cache_add_active_or_unevictable(kpage, vma);
> =20
>  	if (!PageAnon(page)) {
> -		dec_mm_counter(mm, MM_FILEPAGES);
> +		dec_mm_counter(mm, mm_counter_file(page));
>  		inc_mm_counter(mm, MM_ANONPAGES);
>  	}
> =20
> diff --git a/mm/memory.c b/mm/memory.c
> index 8068893..f145d9e 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -832,10 +832,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_s=
truct *src_mm,
>  		} else if (is_migration_entry(entry)) {
>  			page =3D migration_entry_to_page(entry);
> =20
> -			if (PageAnon(page))
> -				rss[MM_ANONPAGES]++;
> -			else
> -				rss[MM_FILEPAGES]++;
> +			rss[mm_counter(page)]++;
> =20
>  			if (is_write_migration_entry(entry) &&
>  					is_cow_mapping(vm_flags)) {
> @@ -874,10 +871,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_s=
truct *src_mm,
>  	if (page) {
>  		get_page(page);
>  		page_dup_rmap(page);
> -		if (PageAnon(page))
> -			rss[MM_ANONPAGES]++;
> -		else
> -			rss[MM_FILEPAGES]++;
> +		rss[mm_counter(page)]++;
>  	}
> =20
>  out_set_pte:
> @@ -1113,9 +1107,8 @@ again:
>  			tlb_remove_tlb_entry(tlb, pte, addr);
>  			if (unlikely(!page))
>  				continue;
> -			if (PageAnon(page))
> -				rss[MM_ANONPAGES]--;
> -			else {
> +
> +			if (!PageAnon(page)) {
>  				if (pte_dirty(ptent)) {
>  					force_flush =3D 1;
>  					set_page_dirty(page);
> @@ -1123,8 +1116,8 @@ again:
>  				if (pte_young(ptent) &&
>  				    likely(!(vma->vm_flags & VM_SEQ_READ)))
>  					mark_page_accessed(page);
> -				rss[MM_FILEPAGES]--;
>  			}
> +			rss[mm_counter(page)]--;
>  			page_remove_rmap(page);
>  			if (unlikely(page_mapcount(page) < 0))
>  				print_bad_pte(vma, addr, ptent, page);
> @@ -1146,11 +1139,7 @@ again:
>  			struct page *page;
> =20
>  			page =3D migration_entry_to_page(entry);
> -
> -			if (PageAnon(page))
> -				rss[MM_ANONPAGES]--;
> -			else
> -				rss[MM_FILEPAGES]--;
> +			rss[mm_counter(page)]--;
>  		}
>  		if (unlikely(!free_swap_and_cache(entry)))
>  			print_bad_pte(vma, addr, ptent, NULL);
> @@ -1460,7 +1449,7 @@ static int insert_page(struct vm_area_struct *vma=
, unsigned long addr,
> =20
>  	/* Ok, finally just insert the thing.. */
>  	get_page(page);
> -	inc_mm_counter_fast(mm, MM_FILEPAGES);
> +	inc_mm_counter_fast(mm, mm_counter_file(page));
>  	page_add_file_rmap(page);
>  	set_pte_at(mm, addr, pte, mk_pte(page, prot));
> =20
> @@ -2174,7 +2163,8 @@ gotten:
>  	if (likely(pte_same(*page_table, orig_pte))) {
>  		if (old_page) {
>  			if (!PageAnon(old_page)) {
> -				dec_mm_counter_fast(mm, MM_FILEPAGES);
> +				dec_mm_counter_fast(mm,
> +						mm_counter_file(old_page));
>  				inc_mm_counter_fast(mm, MM_ANONPAGES);
>  			}
>  		} else
> @@ -2703,7 +2693,7 @@ void do_set_pte(struct vm_area_struct *vma, unsig=
ned long address,
>  		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
>  		page_add_new_anon_rmap(page, vma, address);
>  	} else {
> -		inc_mm_counter_fast(vma->vm_mm, MM_FILEPAGES);
> +		inc_mm_counter_fast(vma->vm_mm, mm_counter_file(page));
>  		page_add_file_rmap(page);
>  	}
>  	set_pte_at(vma->vm_mm, address, pte, entry);
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 642f38c..a5ee3a2 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -573,10 +573,11 @@ void oom_kill_process(struct task_struct *p, gfp_=
t gfp_mask, int order,
>  	/* mm cannot safely be dereferenced after task_unlock(victim) */
>  	mm =3D victim->mm;
>  	mark_tsk_oom_victim(victim);
> -	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-r=
ss:%lukB\n",
> +	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-r=
ss:%lukB, shmem-rss:%lukB\n",
>  		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
>  		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
> -		K(get_mm_counter(victim->mm, MM_FILEPAGES)));
> +		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
> +		K(get_mm_counter_shmem(victim->mm)));
>  	task_unlock(victim);
> =20
>  	/*
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 5e3e090..e3c4392 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1216,12 +1216,8 @@ static int try_to_unmap_one(struct page *page, s=
truct vm_area_struct *vma,
>  	update_hiwater_rss(mm);
> =20
>  	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
> -		if (!PageHuge(page)) {
> -			if (PageAnon(page))
> -				dec_mm_counter(mm, MM_ANONPAGES);
> -			else
> -				dec_mm_counter(mm, MM_FILEPAGES);
> -		}
> +		if (!PageHuge(page))
> +			dec_mm_counter(mm, mm_counter(page));
>  		set_pte_at(mm, address, pte,
>  			   swp_entry_to_pte(make_hwpoison_entry(page)));
>  	} else if (pte_unused(pteval)) {
> @@ -1230,10 +1226,7 @@ static int try_to_unmap_one(struct page *page, s=
truct vm_area_struct *vma,
>  		 * interest anymore. Simply discard the pte, vmscan
>  		 * will take care of the rest.
>  		 */
> -		if (PageAnon(page))
> -			dec_mm_counter(mm, MM_ANONPAGES);
> -		else
> -			dec_mm_counter(mm, MM_FILEPAGES);
> +		dec_mm_counter(mm, mm_counter(page));
>  	} else if (PageAnon(page)) {
>  		swp_entry_t entry =3D { .val =3D page_private(page) };
>  		pte_t swp_pte;
> @@ -1276,7 +1269,7 @@ static int try_to_unmap_one(struct page *page, st=
ruct vm_area_struct *vma,
>  		entry =3D make_migration_entry(page, pte_write(pteval));
>  		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
>  	} else
> -		dec_mm_counter(mm, MM_FILEPAGES);
> +		dec_mm_counter(mm, mm_counter_file(page));
> =20
>  	page_remove_rmap(page);
>  	page_cache_release(page);
>=20



--W5VSd93o9jcgmHBUTaPRSBjTJ215cngGm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJU7zTFAAoJEHTzHJCtsuoCAHMH/RkeEbRl8sKit84ddvhGjsyc
KiNR4Y2Z04K2+MmysIWG234K3BdmZNug3rOu67fmGavzxP8u7YprTkmbtbMP8Lvy
CptK9f9AwJvjEiJkHzcDqGzJv0NZPAsvQpQ+HFEPhHpvhaNYbnsJHrXn7Ct7I1zx
EI450QPDWt78UeQUKpyCkjsMjMcldASK8Q2KAdd8FX52pfmCW2XOQSV45SSfFHmf
zCrtx2ZCaKGSXXDp7krc+joe4HGcnw0OPFUXzqjxjrNqXs+uQWTNWgUDQWeYzmtQ
bhfXS2tFQiTXyi89343qRRkfSVP4+edAqspltH0As0+0RYmSLzUUS/in+BXvBfI=
=A3Uv
-----END PGP SIGNATURE-----

--W5VSd93o9jcgmHBUTaPRSBjTJ215cngGm--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
