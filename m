Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4CD216B0038
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 06:49:33 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so142016037wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 03:49:32 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id g10si7713176wjr.42.2015.08.20.03.49.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 03:49:31 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so142015273wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 03:49:30 -0700 (PDT)
Date: Thu, 20 Aug 2015 12:49:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 1/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/smaps
Message-ID: <20150820104929.GA4632@dhcp22.suse.cz>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
 <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1440059182-19798-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <1440059182-19798-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu 20-08-15 08:26:26, Naoya Horiguchi wrote:
> Currently /proc/PID/smaps provides no usage info for vma(VM_HUGETLB), whi=
ch
> is inconvenient when we want to know per-task or per-vma base hugetlb usa=
ge.
> To solve this, this patch adds a new line for hugetlb usage like below:
>=20
>   Size:              20480 kB
>   Rss:                   0 kB
>   Pss:                   0 kB
>   Shared_Clean:          0 kB
>   Shared_Dirty:          0 kB
>   Private_Clean:         0 kB
>   Private_Dirty:         0 kB
>   Referenced:            0 kB
>   Anonymous:             0 kB
>   AnonHugePages:         0 kB
>   HugetlbPages:      18432 kB
>   Swap:                  0 kB
>   KernelPageSize:     2048 kB
>   MMUPageSize:        2048 kB
>   Locked:                0 kB
>   VmFlags: rd wr mr mw me de ht

I have only now got to this thread. This is indeed very helpful. I would
just suggest to update Documentation/filesystems/proc.txt to be explicit
that Rss: doesn't count hugetlb pages for historical reasons.
=20
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Joern Engel <joern@logfs.org>
> Acked-by: David Rientjes <rientjes@google.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
> v3 -> v4:
> - suspend Acked-by tag because v3->v4 change is not trivial
> - I stated in previous discussion that HugetlbPages line can contain page
>   size info, but that's not necessary because we already have KernelPageS=
ize
>   info.
> - merged documentation update, where the current documentation doesn't me=
ntion
>   AnonHugePages, so it's also added.
> ---
>  Documentation/filesystems/proc.txt |  7 +++++--
>  fs/proc/task_mmu.c                 | 29 +++++++++++++++++++++++++++++
>  2 files changed, 34 insertions(+), 2 deletions(-)
>=20
> diff --git v4.2-rc4/Documentation/filesystems/proc.txt v4.2-rc4_patched/D=
ocumentation/filesystems/proc.txt
> index 6f7fafde0884..22e40211ef64 100644
> --- v4.2-rc4/Documentation/filesystems/proc.txt
> +++ v4.2-rc4_patched/Documentation/filesystems/proc.txt
> @@ -423,6 +423,8 @@ Private_Clean:         0 kB
>  Private_Dirty:         0 kB
>  Referenced:          892 kB
>  Anonymous:             0 kB
> +AnonHugePages:         0 kB
> +HugetlbPages:          0 kB
>  Swap:                  0 kB
>  KernelPageSize:        4 kB
>  MMUPageSize:           4 kB
> @@ -440,8 +442,9 @@ indicates the amount of memory currently marked as re=
ferenced or accessed.
>  "Anonymous" shows the amount of memory that does not belong to any file.=
  Even
>  a mapping associated with a file may contain anonymous pages: when MAP_P=
RIVATE
>  and a page is modified, the file page is replaced by a private anonymous=
 copy.
> -"Swap" shows how much would-be-anonymous memory is also used, but out on
> -swap.
> +"AnonHugePages" shows the ammount of memory backed by transparent hugepa=
ge.
> +"HugetlbPages" shows the ammount of memory backed by hugetlbfs page.
> +"Swap" shows how much would-be-anonymous memory is also used, but out on=
 swap.
> =20
>  "VmFlags" field deserves a separate description. This member represents =
the kernel
>  flags associated with the particular virtual memory area in two letter e=
ncoded
> diff --git v4.2-rc4/fs/proc/task_mmu.c v4.2-rc4_patched/fs/proc/task_mmu.c
> index ca1e091881d4..2c37938b82ee 100644
> --- v4.2-rc4/fs/proc/task_mmu.c
> +++ v4.2-rc4_patched/fs/proc/task_mmu.c
> @@ -445,6 +445,7 @@ struct mem_size_stats {
>  	unsigned long anonymous;
>  	unsigned long anonymous_thp;
>  	unsigned long swap;
> +	unsigned long hugetlb;
>  	u64 pss;
>  };
> =20
> @@ -610,12 +611,38 @@ static void show_smap_vma_flags(struct seq_file *m,=
 struct vm_area_struct *vma)
>  	seq_putc(m, '\n');
>  }
> =20
> +#ifdef CONFIG_HUGETLB_PAGE
> +static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
> +				 unsigned long addr, unsigned long end,
> +				 struct mm_walk *walk)
> +{
> +	struct mem_size_stats *mss =3D walk->private;
> +	struct vm_area_struct *vma =3D walk->vma;
> +	struct page *page =3D NULL;
> +
> +	if (pte_present(*pte)) {
> +		page =3D vm_normal_page(vma, addr, *pte);
> +	} else if (is_swap_pte(*pte)) {
> +		swp_entry_t swpent =3D pte_to_swp_entry(*pte);
> +
> +		if (is_migration_entry(swpent))
> +			page =3D migration_entry_to_page(swpent);
> +	}
> +	if (page)
> +		mss->hugetlb +=3D huge_page_size(hstate_vma(vma));
> +	return 0;
> +}
> +#endif /* HUGETLB_PAGE */
> +
>  static int show_smap(struct seq_file *m, void *v, int is_pid)
>  {
>  	struct vm_area_struct *vma =3D v;
>  	struct mem_size_stats mss;
>  	struct mm_walk smaps_walk =3D {
>  		.pmd_entry =3D smaps_pte_range,
> +#ifdef CONFIG_HUGETLB_PAGE
> +		.hugetlb_entry =3D smaps_hugetlb_range,
> +#endif
>  		.mm =3D vma->vm_mm,
>  		.private =3D &mss,
>  	};
> @@ -637,6 +664,7 @@ static int show_smap(struct seq_file *m, void *v, int=
 is_pid)
>  		   "Referenced:     %8lu kB\n"
>  		   "Anonymous:      %8lu kB\n"
>  		   "AnonHugePages:  %8lu kB\n"
> +		   "HugetlbPages:   %8lu kB\n"
>  		   "Swap:           %8lu kB\n"
>  		   "KernelPageSize: %8lu kB\n"
>  		   "MMUPageSize:    %8lu kB\n"
> @@ -651,6 +679,7 @@ static int show_smap(struct seq_file *m, void *v, int=
 is_pid)
>  		   mss.referenced >> 10,
>  		   mss.anonymous >> 10,
>  		   mss.anonymous_thp >> 10,
> +		   mss.hugetlb >> 10,
>  		   mss.swap >> 10,
>  		   vma_kernel_pagesize(vma) >> 10,
>  		   vma_mmu_pagesize(vma) >> 10,
> --=20
> 2.4.3
> N?????r??y????b?X??=C7=A7v?^?)=DE=BA{.n?+????{????zX??=17??=DC=A8}???=C6=
=A0z?&j:+v???=07????zZ+??+zf???h???~????i???z?=1E?w?????????&?)=DF=A2=1Bf??=
^j=C7=ABy?m??@A?a??=7F?=0C0??h?=0F??i=7F

--=20
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
