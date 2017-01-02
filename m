Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 425786B0069
	for <linux-mm@kvack.org>; Mon,  2 Jan 2017 03:38:34 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c85so43451847wmi.6
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 00:38:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m75si68760455wmi.84.2017.01.02.00.38.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Jan 2017 00:38:32 -0800 (PST)
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <bba4c707-c470-296c-edbe-b8a6d21152ad@suse.cz>
Date: Mon, 2 Jan 2017 09:38:30 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/22/2016 01:21 AM, David Rientjes wrote:
> Currently, when defrag is set to "madvise", thp allocations will direct
> reclaim.  However, when defrag is set to "defer", all thp allocations do
> not attempt reclaim regardless of MADV_HUGEPAGE.
> 
> This patch always directly reclaims for MADV_HUGEPAGE regions when defrag
> is not set to "never."  The idea is that MADV_HUGEPAGE regions really
> want to be backed by hugepages and are willing to endure the latency at
> fault as it was the default behavior prior to commit 444eb2a449ef ("mm:
> thp: set THP defrag by default to madvise and add a stall-free defrag
> option").
> 
> In this form, "defer" is a stronger, more heavyweight version of
> "madvise".
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

I'm late to the thread (I did read it fully though), so instead of
multiple responses, I'll just list my observations here:

- "defer", e.g. background kswapd+compaction is not a silver bullet, it
will also affect the system. Mel already mentioned extra reclaim.
Compaction also has CPU costs, just hides the accounting to a kernel
thread so it's not visible as latency. It also increases zone/node
lru_lock and lock pressure.

For the same reasons, admin might want to limit direct compaction for
THP, even for madvise() apps. It's also likely that "defer" might have
lower system overhead than "madvise", as with "defer",
reclaim/compaction is done by one per-node thread at a time, but there
might be multiple madvise() threads. So there might be sense in not
allowing madvise() apps to do direct reclaim/compaction on "defer".

- for overriding specific apps such as QEMU (including their madvise()
usage, AFAICS), we have PR_SET_THP_DISABLE prctl(), so no need to
LD_PRELOAD stuff IMO.

- I have wondered about exactly the issue here when Mel proposed the
defer option [1]. Mel responded that it doesn't seem needed at that
point. Now it seems it is. Too bad you didn't raise it then, but to be
fair you were not CC'd.

So would something like this be possible?

> echo "defer madvise" > /sys/kernel/mm/transparent_hugepage/defrag
> cat /sys/kernel/mm/transparent_hugepage/defrag
always [defer] [madvise] never

I'm not sure about the analogous kernel boot option though, I guess
those can't use spaces, so maybe comma-separated?

If that's not acceptable, then I would probably rather be for changing
"madvise" to include "defer", than the other way around. When we augment
kcompactd to be more proactive, it might easily be that it will
effectively act as "defer", even when defrag=none is set, anyway.

[1] http://marc.info/?l=linux-mm&m=145683613929750&w=2

> ---
>  Documentation/vm/transhuge.txt |  7 +++++--
>  mm/huge_memory.c               | 10 ++++++----
>  2 files changed, 11 insertions(+), 6 deletions(-)
> 
> diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
> --- a/Documentation/vm/transhuge.txt
> +++ b/Documentation/vm/transhuge.txt
> @@ -121,8 +121,11 @@ to utilise them.
>  
>  "defer" means that an application will wake kswapd in the background
>  to reclaim pages and wake kcompact to compact memory so that THP is
> -available in the near future. It's the responsibility of khugepaged
> -to then install the THP pages later.
> +available in the near future, unless it is for a region where
> +madvise(MADV_HUGEPAGE) has been used, in which case direct reclaim will be
> +used. Kcompactd will attempt to make hugepages available for allocation in
> +the near future and khugepaged will try to collapse existing memory into
> +hugepages later.
>  
>  "madvise" will enter direct reclaim like "always" but only for regions
>  that are have used madvise(MADV_HUGEPAGE). This is the default behaviour.
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -619,15 +619,17 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
>   */
>  static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
>  {
> -	bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
> +	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
>  
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG,
>  				&transparent_hugepage_flags) && vma_madvised)
>  		return GFP_TRANSHUGE;
>  	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
> -						&transparent_hugepage_flags))
> -		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
> -	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
> +						&transparent_hugepage_flags)) {
> +		return GFP_TRANSHUGE_LIGHT |
> +		       (vma_madvised ? __GFP_DIRECT_RECLAIM :
> +				       __GFP_KSWAPD_RECLAIM);
> +	} else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
>  						&transparent_hugepage_flags))
>  		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
