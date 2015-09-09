Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4AD6B0254
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 11:12:13 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so159242334wic.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 08:12:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bl8si5166525wib.33.2015.09.09.08.12.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Sep 2015 08:12:12 -0700 (PDT)
Subject: Re: [PATCH v5 1/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/smaps
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
 <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1440059182-19798-2-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55F04C48.7070105@suse.cz>
Date: Wed, 9 Sep 2015 17:12:08 +0200
MIME-Version: 1.0
In-Reply-To: <1440059182-19798-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, =?UTF-8?Q?J=c3=b6rn_Engel?= <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 08/20/2015 10:26 AM, Naoya Horiguchi wrote:
> Currently /proc/PID/smaps provides no usage info for vma(VM_HUGETLB), which
> is inconvenient when we want to know per-task or per-vma base hugetlb usage.
> To solve this, this patch adds a new line for hugetlb usage like below:
>
>    Size:              20480 kB
>    Rss:                   0 kB
>    Pss:                   0 kB
>    Shared_Clean:          0 kB
>    Shared_Dirty:          0 kB
>    Private_Clean:         0 kB
>    Private_Dirty:         0 kB
>    Referenced:            0 kB
>    Anonymous:             0 kB
>    AnonHugePages:         0 kB
>    HugetlbPages:      18432 kB
>    Swap:                  0 kB
>    KernelPageSize:     2048 kB
>    MMUPageSize:        2048 kB
>    Locked:                0 kB
>    VmFlags: rd wr mr mw me de ht
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Joern Engel <joern@logfs.org>
> Acked-by: David Rientjes <rientjes@google.com>

Sorry for coming late to this thread. It's a nice improvement, but I 
find it somewhat illogical that the per-process stats (status) are more 
detailed than the per-mapping stats (smaps) with respect to the size 
breakdown. I would expect it to be the other way around. That would 
simplify the per-process accounting (I realize this has been a hot topic 
already), and allow those who really care to look at smaps.

I'm just not sure about the format in that case. In smaps, a line per 
size would probably make more sense. Even in status, the extra 
information in parentheses looks somewhat out of place. But of course, 
adding shared/private breakdown as suggested would lead to an explosion 
of number of lines in that case...

> ---
> v3 -> v4:
> - suspend Acked-by tag because v3->v4 change is not trivial
> - I stated in previous discussion that HugetlbPages line can contain page
>    size info, but that's not necessary because we already have KernelPageSize
>    info.
> - merged documentation update, where the current documentation doesn't mention
>    AnonHugePages, so it's also added.
> ---
>   Documentation/filesystems/proc.txt |  7 +++++--
>   fs/proc/task_mmu.c                 | 29 +++++++++++++++++++++++++++++
>   2 files changed, 34 insertions(+), 2 deletions(-)
>
> diff --git v4.2-rc4/Documentation/filesystems/proc.txt v4.2-rc4_patched/Documentation/filesystems/proc.txt
> index 6f7fafde0884..22e40211ef64 100644
> --- v4.2-rc4/Documentation/filesystems/proc.txt
> +++ v4.2-rc4_patched/Documentation/filesystems/proc.txt
> @@ -423,6 +423,8 @@ Private_Clean:         0 kB
>   Private_Dirty:         0 kB
>   Referenced:          892 kB
>   Anonymous:             0 kB
> +AnonHugePages:         0 kB
> +HugetlbPages:          0 kB
>   Swap:                  0 kB
>   KernelPageSize:        4 kB
>   MMUPageSize:           4 kB
> @@ -440,8 +442,9 @@ indicates the amount of memory currently marked as referenced or accessed.
>   "Anonymous" shows the amount of memory that does not belong to any file.  Even
>   a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
>   and a page is modified, the file page is replaced by a private anonymous copy.
> -"Swap" shows how much would-be-anonymous memory is also used, but out on
> -swap.
> +"AnonHugePages" shows the ammount of memory backed by transparent hugepage.
> +"HugetlbPages" shows the ammount of memory backed by hugetlbfs page.
> +"Swap" shows how much would-be-anonymous memory is also used, but out on swap.
>
>   "VmFlags" field deserves a separate description. This member represents the kernel
>   flags associated with the particular virtual memory area in two letter encoded
> diff --git v4.2-rc4/fs/proc/task_mmu.c v4.2-rc4_patched/fs/proc/task_mmu.c
> index ca1e091881d4..2c37938b82ee 100644
> --- v4.2-rc4/fs/proc/task_mmu.c
> +++ v4.2-rc4_patched/fs/proc/task_mmu.c
> @@ -445,6 +445,7 @@ struct mem_size_stats {
>   	unsigned long anonymous;
>   	unsigned long anonymous_thp;
>   	unsigned long swap;
> +	unsigned long hugetlb;
>   	u64 pss;
>   };
>
> @@ -610,12 +611,38 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
>   	seq_putc(m, '\n');
>   }
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
> +		mss->hugetlb += huge_page_size(hstate_vma(vma));
> +	return 0;
> +}
> +#endif /* HUGETLB_PAGE */
> +
>   static int show_smap(struct seq_file *m, void *v, int is_pid)
>   {
>   	struct vm_area_struct *vma = v;
>   	struct mem_size_stats mss;
>   	struct mm_walk smaps_walk = {
>   		.pmd_entry = smaps_pte_range,
> +#ifdef CONFIG_HUGETLB_PAGE
> +		.hugetlb_entry = smaps_hugetlb_range,
> +#endif
>   		.mm = vma->vm_mm,
>   		.private = &mss,
>   	};
> @@ -637,6 +664,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>   		   "Referenced:     %8lu kB\n"
>   		   "Anonymous:      %8lu kB\n"
>   		   "AnonHugePages:  %8lu kB\n"
> +		   "HugetlbPages:   %8lu kB\n"
>   		   "Swap:           %8lu kB\n"
>   		   "KernelPageSize: %8lu kB\n"
>   		   "MMUPageSize:    %8lu kB\n"
> @@ -651,6 +679,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>   		   mss.referenced >> 10,
>   		   mss.anonymous >> 10,
>   		   mss.anonymous_thp >> 10,
> +		   mss.hugetlb >> 10,
>   		   mss.swap >> 10,
>   		   vma_kernel_pagesize(vma) >> 10,
>   		   vma_mmu_pagesize(vma) >> 10,
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
