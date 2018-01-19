Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7021C6B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 09:24:58 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id g16so1124490wmg.6
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 06:24:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i2sor5888824edb.32.2018.01.19.06.24.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Jan 2018 06:24:56 -0800 (PST)
Date: Fri, 19 Jan 2018 17:24:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2] mm: make faultaround produce old ptes
Message-ID: <20180119142454.wa4gtkabrliyd6d6@node.shutemov.name>
References: <1516280210-5678-1-git-send-email-vinmenon@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1516280210-5678-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, ying.huang@intel.com, riel@redhat.com, dave.hansen@linux.intel.com, mgorman@suse.de, torvalds@linux-foundation.org, jack@suse.cz

On Thu, Jan 18, 2018 at 06:26:50PM +0530, Vinayak Menon wrote:
> Based on Kirill's patch [1].
> 
> Currently, faultaround code produces young pte.  This can screw up
> vmscan behaviour[2], as it makes vmscan think that these pages are hot
> and not push them out on first round.
> 
> During sparse file access faultaround gets more pages mapped and all of
> them are young. Under memory pressure, this makes vmscan swap out anon
> pages instead, or to drop other page cache pages which otherwise stay
> resident.
> 
> Modify faultaround to produce old ptes if sysctl 'want_old_faultaround_pte'
> is set, so they can easily be reclaimed under memory pressure.
> 
> This can to some extend defeat the purpose of faultaround on machines
> without hardware accessed bit as it will not help us with reducing the
> number of minor page faults.
> 
> Making the faultaround ptes old results in a unixbench regression for some
> architectures [3][4]. But on some architectures like arm64 it is not found
> to cause any regression.
> 
> unixbench shell8 scores on arm64 v8.2 hardware with CONFIG_ARM64_HW_AFDBM
> enabled  (5 runs min, max, avg):
> Base: (741,748,744)
> With this patch: (739,748,743)
> 
> So by default produce young ptes and provide a sysctl option to make the
> ptes old.
> 
> [1] http://lkml.kernel.org/r/1463488366-47723-1-git-send-email-kirill.shutemov@linux.intel.com
> [2] https://lkml.kernel.org/r/1460992636-711-1-git-send-email-vinmenon@codeaurora.org
> [3] https://marc.info/?l=linux-kernel&m=146582237922378&w=2
> [4] https://marc.info/?l=linux-mm&m=146589376909424&w=2
> 
> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
> ---
> 
> V2:
> 1. Removed the arch hook and want_old_faultaround_pte is made a sysctl
> 2. Renamed FAULT_FLAG_MKOLD to FAULT_FLAG_PREFAULT_OLD (suggested by Jan Kara)
> 3. Removed the saved fault address from vmf (suggested by Jan Kara)
> 
>  Documentation/sysctl/vm.txt | 22 ++++++++++++++++++++++
>  include/linux/mm.h          |  3 +++
>  kernel/sysctl.c             |  9 +++++++++
>  mm/filemap.c                | 10 ++++++++++
>  mm/memory.c                 |  4 ++++
>  5 files changed, 48 insertions(+)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 17256f2..e015940 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -63,6 +63,7 @@ Currently, these files are in /proc/sys/vm:
>  - vfs_cache_pressure
>  - watermark_scale_factor
>  - zone_reclaim_mode
> +- want_old_faultaround_pte
>  
>  ==============================================================
>  
> @@ -887,4 +888,25 @@ Allowing regular swap effectively restricts allocations to the local
>  node unless explicitly overridden by memory policies or cpuset
>  configurations.
>  
> +=============================================================
> +
> +want_old_faultaround_pte:
> +
> +By default faultaround code produces young pte. When want_old_faultaround_pte is
> +set to 1, faultaround produces old ptes.
> +
> +During sparse file access faultaround gets more pages mapped and when all of
> +them are young (default), under memory pressure, this makes vmscan swap out anon
> +pages instead, or to drop other page cache pages which otherwise stay resident.
> +Setting want_old_faultaround_pte to 1 avoids this.
> +
> +Making the faultaround ptes old can result in performance regression on some
> +architectures. This is due to cycles spent in micro-fault for TLB lookup of old
> +entry.

It's not for TLB lookup. Micro-fault would take page walk to set young bit in
the pte.

Otherwise patch looks good to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
