Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 47F4D6B0038
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 14:22:01 -0400 (EDT)
Received: by oibv126 with SMTP id v126so9738775oib.3
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 11:22:01 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id tt2si266384pbc.54.2015.08.04.11.22.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Aug 2015 11:22:00 -0700 (PDT)
Received: by pdco4 with SMTP id o4so7480256pdc.3
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 11:22:00 -0700 (PDT)
Date: Tue, 4 Aug 2015 11:21:59 -0700
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH] smaps: fill missing fields for vma(VM_HUGETLB)
Message-ID: <20150804182158.GH14335@Sligo.logfs.org>
References: <20150728183248.GB1406@Sligo.logfs.org>
 <55B7F0F8.8080909@oracle.com>
 <alpine.DEB.2.10.1507281509420.23577@chino.kir.corp.google.com>
 <20150728222654.GA28456@Sligo.logfs.org>
 <alpine.DEB.2.10.1507281622470.10368@chino.kir.corp.google.com>
 <20150729005332.GB17938@Sligo.logfs.org>
 <alpine.DEB.2.10.1507291205590.24373@chino.kir.corp.google.com>
 <55B95FDB.1000801@oracle.com>
 <20150804025530.GA13210@hori1.linux.bs1.fc.nec.co.jp>
 <20150804051339.GA24931@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150804051339.GA24931@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, Aug 04, 2015 at 05:13:39AM +0000, Naoya Horiguchi wrote:
> On Tue, Aug 04, 2015 at 02:55:30AM +0000, Naoya Horiguchi wrote:
> > 
> > One possible way to get hugetlb metric in per-task basis is to walk page
> > table via /proc/pid/pagemap, and counting page flags for each mapped page
> > (we can easily do this with tools/vm/page-types.c like "page-types -p <PID>
> > -b huge"). This is obviously slower than just storing the counter as
> > in-kernel data and just exporting it, but might be useful in some situation.

Maybe.  The current situation is a mess and I don't know the best way
out of it yet.

> BTW, currently smaps doesn't report any meaningful info for vma(VM_HUGETLB).
> I wrote the following patch, which hopefully is helpful for your purpose.
> 
> Thanks,
> Naoya Horiguchi
> 
> ---
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Subject: [PATCH] smaps: fill missing fields for vma(VM_HUGETLB)
> 
> Currently smaps reports many zero fields for vma(VM_HUGETLB), which is
> inconvenient when we want to know per-task or per-vma base hugetlb usage.
> This patch enables these fields by introducing smaps_hugetlb_range().
> 
> before patch:
> 
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
>   Swap:                  0 kB
>   KernelPageSize:     2048 kB
>   MMUPageSize:        2048 kB
>   Locked:                0 kB
>   VmFlags: rd wr mr mw me de ht
> 
> after patch:
> 
>   Size:              20480 kB
>   Rss:               18432 kB
>   Pss:               18432 kB
>   Shared_Clean:          0 kB
>   Shared_Dirty:          0 kB
>   Private_Clean:         0 kB
>   Private_Dirty:     18432 kB
>   Referenced:        18432 kB
>   Anonymous:         18432 kB
>   AnonHugePages:         0 kB
>   Swap:                  0 kB
>   KernelPageSize:     2048 kB
>   MMUPageSize:        2048 kB
>   Locked:                0 kB
>   VmFlags: rd wr mr mw me de ht

Nice!

> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  fs/proc/task_mmu.c | 27 +++++++++++++++++++++++++++
>  1 file changed, 27 insertions(+)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index ca1e091881d4..c7218603306d 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -610,12 +610,39 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
>  	seq_putc(m, '\n');
>  }
>  
> +#ifdef CONFIG_HUGETLB_PAGE
> +static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
> +				 unsigned long addr, unsigned long end,
> +				 struct mm_walk *walk)
> +{
> +	struct mem_size_stats *mss = walk->private;
> +	struct vm_area_struct *vma = walk->vma;
> +	struct page *page = NULL;
> +
> +	if (pte_present(*pte)) {
> +		page = vm_normal_page(vma, addr, *pte);
> +	} else if (is_swap_pte(*pte)) {
> +		swp_entry_t swpent = pte_to_swp_entry(*pte);
> +
> +		if (is_migration_entry(swpent))
> +			page = migration_entry_to_page(swpent);
> +	}
> +	if (page)
> +		smaps_account(mss, page, huge_page_size(hstate_vma(vma)),
> +			      pte_young(*pte), pte_dirty(*pte));
> +	return 0;
> +}
> +#endif /* HUGETLB_PAGE */
> +
>  static int show_smap(struct seq_file *m, void *v, int is_pid)
>  {
>  	struct vm_area_struct *vma = v;
>  	struct mem_size_stats mss;
>  	struct mm_walk smaps_walk = {
>  		.pmd_entry = smaps_pte_range,
> +#ifdef CONFIG_HUGETLB_PAGE
> +		.hugetlb_entry = smaps_hugetlb_range,
> +#endif

Not too fond of the #ifdef.  But I won't blame you, as there already is
an example of the same and - worse - a contradicting example that
unconditionally assigns and moved the #ifdef elsewhere.

Hugetlb is the unloved stepchild with 13 years of neglect and
half-measures.  It shows.

Patch looks good to me.

Acked-by: Jorn Engel <joern@logfs.org>

Jorn

--
Functionality is an asset, but code is a liability.
--Ted Dziuba

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
