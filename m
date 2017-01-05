Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E33AC6B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 01:05:07 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g1so1420919151pgn.3
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 22:05:07 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id p62si74706711pfl.255.2017.01.04.22.05.05
        for <linux-mm@kvack.org>;
        Wed, 04 Jan 2017 22:05:06 -0800 (PST)
Date: Thu, 5 Jan 2017 15:04:58 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/7] mm, vmscan: show LRU name in mm_vmscan_lru_isolate
 tracepoint
Message-ID: <20170105060458.GC24371@bbox>
References: <20170104101942.4860-1-mhocko@kernel.org>
 <20170104101942.4860-5-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170104101942.4860-5-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, Jan 04, 2017 at 11:19:39AM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> mm_vmscan_lru_isolate currently prints only whether the LRU we isolate
> from is file or anonymous but we do not know which LRU this is.
> 
> It is useful to know whether the list is active or inactive, since we
> are using the same function to isolate pages from both of them and it's
> hard to distinguish otherwise.
> 
> Chaneges since v1
> - drop LRU_ prefix from names and use lowercase as per Vlastimil
> - move and convert show_lru_name to mmflags.h EM magic as per Vlastimil
> 
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> Acked-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/trace/events/mmflags.h |  8 ++++++++
>  include/trace/events/vmscan.h  | 12 ++++++------
>  mm/vmscan.c                    |  2 +-
>  3 files changed, 15 insertions(+), 7 deletions(-)
> 
> diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
> index aa4caa6914a9..6172afa2fd82 100644
> --- a/include/trace/events/mmflags.h
> +++ b/include/trace/events/mmflags.h
> @@ -240,6 +240,13 @@ IF_HAVE_VM_SOFTDIRTY(VM_SOFTDIRTY,	"softdirty"	)		\
>  	IFDEF_ZONE_HIGHMEM(	EM (ZONE_HIGHMEM,"HighMem"))	\
>  				EMe(ZONE_MOVABLE,"Movable")
>  
> +#define LRU_NAMES		\
> +		EM (LRU_INACTIVE_ANON, "inactive_anon") \
> +		EM (LRU_ACTIVE_ANON, "active_anon") \
> +		EM (LRU_INACTIVE_FILE, "inactive_file") \
> +		EM (LRU_ACTIVE_FILE, "active_file") \
> +		EMe(LRU_UNEVICTABLE, "unevictable")
> +
>  /*
>   * First define the enums in the above macros to be exported to userspace
>   * via TRACE_DEFINE_ENUM().
> @@ -253,6 +260,7 @@ COMPACTION_STATUS
>  COMPACTION_PRIORITY
>  COMPACTION_FEEDBACK
>  ZONE_TYPE
> +LRU_NAMES
>  
>  /*
>   * Now redefine the EM() and EMe() macros to map the enums to the strings
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index 36c999f806bf..7ec59e0432c4 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -277,9 +277,9 @@ TRACE_EVENT(mm_vmscan_lru_isolate,
>  		unsigned long nr_skipped,
>  		unsigned long nr_taken,
>  		isolate_mode_t isolate_mode,
> -		int file),
> +		int lru),

It may break trace-vmscan-postprocess.pl. Other than that,

Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
