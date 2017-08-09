Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA3926B02C3
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 17:50:45 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z53so10380037wrz.10
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 14:50:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 89si4016037wrn.107.2017.08.09.14.50.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 14:50:44 -0700 (PDT)
Date: Wed, 9 Aug 2017 14:50:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm -v4 1/5] mm, swap: Add swap readahead hit statistics
Message-Id: <20170809145042.46398074c40e95a8827b9bdf@linux-foundation.org>
In-Reply-To: <20170807054038.1843-2-ying.huang@intel.com>
References: <20170807054038.1843-1-ying.huang@intel.com>
	<20170807054038.1843-2-ying.huang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

On Mon,  7 Aug 2017 13:40:34 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:

> From: Huang Ying <ying.huang@intel.com>
> 
> The statistics for total readahead pages and total readahead hits are
> recorded and exported via the following sysfs interface.
> 
> /sys/kernel/mm/swap/ra_hits
> /sys/kernel/mm/swap/ra_total
> 
> With them, the efficiency of the swap readahead could be measured, so
> that the swap readahead algorithm and parameters could be tuned
> accordingly.
> 
> ...
>
> --- a/include/linux/vm_event_item.h
> +++ b/include/linux/vm_event_item.h
> @@ -106,6 +106,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  		VMACACHE_FIND_HITS,
>  		VMACACHE_FULL_FLUSHES,
>  #endif
> +		SWAP_RA,
> +		SWAP_RA_HIT,
>  		NR_VM_EVENT_ITEMS
>  };

swap_state.o isn't even compiled if CONFIG_SWAP=n so there doesn't seem
much point in displaying these?

--- a/include/linux/vm_event_item.h~mm-swap-add-swap-readahead-hit-statistics-fix
+++ a/include/linux/vm_event_item.h
@@ -106,8 +106,10 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 		VMACACHE_FIND_HITS,
 		VMACACHE_FULL_FLUSHES,
 #endif
+#ifdef CONFIG_SWAP
 		SWAP_RA,
 		SWAP_RA_HIT,
+#endif
 		NR_VM_EVENT_ITEMS
 };
 
--- a/mm/vmstat.c~mm-swap-add-swap-readahead-hit-statistics-fix
+++ a/mm/vmstat.c
@@ -1098,9 +1098,10 @@ const char * const vmstat_text[] = {
 	"vmacache_find_hits",
 	"vmacache_full_flushes",
 #endif
-
+#ifdef CONFIG_SWAP
 	"swap_ra",
 	"swap_ra_hit",
+#endif
 #endif /* CONFIG_VM_EVENTS_COUNTERS */
 };
 #endif /* CONFIG_PROC_FS || CONFIG_SYSFS || CONFIG_NUMA */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
