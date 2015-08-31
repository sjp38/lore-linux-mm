Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6134B6B0257
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 10:58:37 -0400 (EDT)
Received: by ioeu67 with SMTP id u67so18704783ioe.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 07:58:37 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0224.hostedemail.com. [216.40.44.224])
        by mx.google.com with ESMTP id kl5si9319149igb.2.2015.08.31.07.58.36
        for <linux-mm@kvack.org>;
        Mon, 31 Aug 2015 07:58:36 -0700 (PDT)
Date: Mon, 31 Aug 2015 10:58:34 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 2/3] mm, compaction: export tracepoints zone names to
 userspace
Message-ID: <20150831105834.34a5e69e@gandalf.local.home>
In-Reply-To: <1440689044-2922-2-git-send-email-vbabka@suse.cz>
References: <1440689044-2922-1-git-send-email-vbabka@suse.cz>
	<1440689044-2922-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>

On Thu, 27 Aug 2015 17:24:03 +0200
Vlastimil Babka <vbabka@suse.cz> wrote:

> Some compaction tracepoints use zone->name to print which zone is being
> compacted. This works for in-kernel printing, but not userspace trace printing
> of raw captured trace such as via trace-cmd report.
> 
> This patch uses zone_idx() instead of zone->name as the raw value, and when
> printing, converts the zone_type to string using the appropriate EM() macros
> and some ugly tricks to overcome the problem that half the values depend on
> CONFIG_ options and one does not simply use #ifdef inside of #define.
> 
> trace-cmd output before:
> transhuge-stres-4235  [000]   453.149280: mm_compaction_finished: node=0
> zone=ffffffff81815d7a order=9 ret=partial
> 
> after:
> transhuge-stres-4235  [000]   453.149280: mm_compaction_finished: node=0
> zone=Normal   order=9 ret=partial
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: David Rientjes <rientjes@google.com>
> ---
>  include/trace/events/compaction.h | 38 ++++++++++++++++++++++++++++++++------
>  1 file changed, 32 insertions(+), 6 deletions(-)
> 
> diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
> index 1275a55..8daa8fa 100644
> --- a/include/trace/events/compaction.h
> +++ b/include/trace/events/compaction.h
> @@ -18,6 +18,31 @@
>  	EM( COMPACT_NO_SUITABLE_PAGE,	"no_suitable_page")	\
>  	EMe(COMPACT_NOT_SUITABLE_ZONE,	"not_suitable_zone")
>  
> +#ifdef CONFIG_ZONE_DMA
> +#define IFDEF_ZONE_DMA(X) X
> +#else
> +#define IFDEF_ZONE_DMA(X)
> +#endif
> +
> +#ifdef CONFIG_ZONE_DMA32
> +#define IFDEF_ZONE_DMA32(X) X
> +#else
> +#define IFDEF_ZONE_DMA32(X)
> +#endif
> +
> +#ifdef CONFIG_ZONE_HIGHMEM_
> +#define IFDEF_ZONE_HIGHMEM(X) X
> +#else
> +#define IFDEF_ZONE_HIGHMEM(X)
> +#endif
> +
> +#define ZONE_TYPE						\
> +	IFDEF_ZONE_DMA(		EM (ZONE_DMA,	 "DMA"))	\
> +	IFDEF_ZONE_DMA32(	EM (ZONE_DMA32,	 "DMA32"))	\
> +				EM (ZONE_NORMAL, "Normal")	\
> +	IFDEF_ZONE_HIGHMEM(	EM (ZONE_HIGHMEM,"HighMem"))	\
> +				EMe(ZONE_MOVABLE,"Movable")
> +

Hmm, have you tried to compile this with CONFIG_ZONE_HIGHMEM disabled,
and CONFIG_ZONE_DMA and/or CONFIG_ZONE_DMA32 enabled?

The EMe() macro must come last, as it doesn't have the ending comma and
the __print_symbolic() can fail to compile due to it.

-- Steve


>  /*
>   * First define the enums in the above macros to be exported to userspace
>   * via TRACE_DEFINE_ENUM().
> @@ -28,6 +53,7 @@

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
