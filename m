Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id BEAE86B0038
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 22:14:23 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id o1so70645164ito.7
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 19:14:23 -0800 (PST)
Received: from mail-it0-x22b.google.com (mail-it0-x22b.google.com. [2607:f8b0:4001:c0b::22b])
        by mx.google.com with ESMTPS id z72si14477786iof.248.2016.11.14.19.14.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 19:14:22 -0800 (PST)
Received: by mail-it0-x22b.google.com with SMTP id c20so122655496itb.0
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 19:14:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <147881591739.39198.1358237993213024627.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <147881591739.39198.1358237993213024627.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 14 Nov 2016 19:14:22 -0800
Message-ID: <CAPcyv4hTchhsNXhKx6WpUWsvFyZjzJ4sx1emLCSU2iDKSMG1hA@mail.gmail.com>
Subject: Re: [PATCH] mm: add ZONE_DEVICE statistics to smaps
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dave Hansen <dave.hansen@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Nov 10, 2016 at 2:11 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> ZONE_DEVICE pages are mapped into a process via the filesystem-dax and
> device-dax mechanisms.  There are also proposals to use ZONE_DEVICE
> pages for other usages outside of dax.  Add statistics to smaps so
> applications can debug that they are obtaining the mappings they expect,
> or otherwise accounting them.
>
> Cc: Christoph Hellwig <hch@lst.de>

Christoph,

Wanted to get your opinion on this given your earlier concerns about
the VM_DAX flag.

This instead lets an application know how much of a vma is backed by
ZONE_DEVICE pages, but does not make any indications about the vma
having DAX semantics or not.  I.e. it is possible that 'device' and
'device_huge' are non-zero *and* vma_is_dax() is false.  So, it is
purely accounting the composition of the present pages in the vma.

Another option is to have something like 'shared_thp' just to account
for file backed huge pages that dax can map.  However if ZONE_DEVICE
is leaking into other use cases I think it makes sense to have it be a
first class-citizen with respect to accounting alongside
'anonymous_thp'.

> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  fs/proc/task_mmu.c |   10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
>
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 35b92d81692f..6765cafcf057 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -445,6 +445,8 @@ struct mem_size_stats {
>         unsigned long swap;
>         unsigned long shared_hugetlb;
>         unsigned long private_hugetlb;
> +       unsigned long device;
> +       unsigned long device_huge;
>         u64 pss;
>         u64 swap_pss;
>         bool check_shmem_swap;
> @@ -458,6 +460,8 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
>
>         if (PageAnon(page))
>                 mss->anonymous += size;
> +       else if (is_zone_device_page(page))
> +               mss->device += size;
>
>         mss->resident += size;
>         /* Accumulate the size in pages that have been accessed. */
> @@ -575,7 +579,7 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
>         else if (PageSwapBacked(page))
>                 mss->shmem_thp += HPAGE_PMD_SIZE;
>         else if (is_zone_device_page(page))
> -               /* pass */;
> +               mss->device_huge += HPAGE_PMD_SIZE;
>         else
>                 VM_BUG_ON_PAGE(1, page);
>         smaps_account(mss, page, true, pmd_young(*pmd), pmd_dirty(*pmd));
> @@ -774,6 +778,8 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>                    "ShmemPmdMapped: %8lu kB\n"
>                    "Shared_Hugetlb: %8lu kB\n"
>                    "Private_Hugetlb: %7lu kB\n"
> +                  "Device:         %8lu kB\n"
> +                  "DeviceHugePages: %7lu kB\n"
>                    "Swap:           %8lu kB\n"
>                    "SwapPss:        %8lu kB\n"
>                    "KernelPageSize: %8lu kB\n"
> @@ -792,6 +798,8 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>                    mss.shmem_thp >> 10,
>                    mss.shared_hugetlb >> 10,
>                    mss.private_hugetlb >> 10,
> +                  mss.device >> 10,
> +                  mss.device_huge >> 10,
>                    mss.swap >> 10,
>                    (unsigned long)(mss.swap_pss >> (10 + PSS_SHIFT)),
>                    vma_kernel_pagesize(vma) >> 10,
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
