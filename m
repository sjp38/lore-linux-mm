Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id B1ADD6B0254
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 03:16:20 -0500 (EST)
Received: by igcto18 with SMTP id to18so32319795igc.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 00:16:20 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id rt1si4145070igb.69.2015.11.25.00.16.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 25 Nov 2015 00:16:20 -0800 (PST)
Date: Wed, 25 Nov 2015 17:16:45 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 6/9] mm, debug: introduce dump_gfpflag_names() for
 symbolic printing of gfp_flags
Message-ID: <20151125081645.GC10494@js1304-P5Q-DELUXE>
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
 <1448368581-6923-7-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448368581-6923-7-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

On Tue, Nov 24, 2015 at 01:36:18PM +0100, Vlastimil Babka wrote:
> It would be useful to convert gfp_flags into string representation when
> printing them in case of allocation failure, OOM etc. There's a script
> ./scripts/gfp-translate to make this simpler, but it needs the matching version
> of the sources to be accurate, and the flags have been undergoing some changes
> recently.
> 
> The ftrace framework already has this translation in the form of
> show_gfp_flags() defined in include/trace/events/gfpflags.h which defines the
> translation table internally. Allow reusing the table outside ftrace by putting
> it behind __def_gfpflag_names definition and introduce dump_gfpflag_names() to
> handle the printing.
> 
> While at it, also fill in the names for the flags and flag combinations that
> have been missing in the table. GFP_NOWAIT no longer equals to "no flags", so
> change the output for no flags to "none".
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  include/linux/mmdebug.h         |  1 +
>  include/trace/events/gfpflags.h | 14 +++++++++++---
>  mm/debug.c                      | 10 ++++++++++
>  3 files changed, 22 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
> index c447d80..3b77fab 100644
> --- a/include/linux/mmdebug.h
> +++ b/include/linux/mmdebug.h
> @@ -10,6 +10,7 @@ struct mm_struct;
>  extern void dump_page(struct page *page, const char *reason);
>  extern void dump_page_badflags(struct page *page, const char *reason,
>  			       unsigned long badflags);
> +extern void dump_gfpflag_names(unsigned long gfp_flags);
>  void dump_vma(const struct vm_area_struct *vma);
>  void dump_mm(const struct mm_struct *mm);
>  
> diff --git a/include/trace/events/gfpflags.h b/include/trace/events/gfpflags.h
> index dde6bf0..3d580fd 100644
> --- a/include/trace/events/gfpflags.h
> +++ b/include/trace/events/gfpflags.h
> @@ -8,8 +8,8 @@
>   *
>   * Thus most bits set go first.
>   */
> -#define show_gfp_flags(flags)						\
> -	(flags) ? __print_flags(flags, "|",				\
> +
> +#define __def_gfpflag_names						\
>  	{(unsigned long)GFP_TRANSHUGE,		"GFP_TRANSHUGE"},	\
>  	{(unsigned long)GFP_HIGHUSER_MOVABLE,	"GFP_HIGHUSER_MOVABLE"}, \
>  	{(unsigned long)GFP_HIGHUSER,		"GFP_HIGHUSER"},	\
> @@ -19,9 +19,13 @@
>  	{(unsigned long)GFP_NOFS,		"GFP_NOFS"},		\
>  	{(unsigned long)GFP_ATOMIC,		"GFP_ATOMIC"},		\
>  	{(unsigned long)GFP_NOIO,		"GFP_NOIO"},		\
> +	{(unsigned long)GFP_NOWAIT,		"GFP_NOWAIT"},		\
> +	{(unsigned long)__GFP_DMA,		"GFP_DMA"},		\
> +	{(unsigned long)__GFP_DMA32,		"GFP_DMA32"},		\
>  	{(unsigned long)__GFP_HIGH,		"GFP_HIGH"},		\
>  	{(unsigned long)__GFP_ATOMIC,		"GFP_ATOMIC"},		\
>  	{(unsigned long)__GFP_IO,		"GFP_IO"},		\
> +	{(unsigned long)__GFP_FS,		"GFP_FS"},		\
>  	{(unsigned long)__GFP_COLD,		"GFP_COLD"},		\
>  	{(unsigned long)__GFP_NOWARN,		"GFP_NOWARN"},		\
>  	{(unsigned long)__GFP_REPEAT,		"GFP_REPEAT"},		\
> @@ -36,8 +40,12 @@
>  	{(unsigned long)__GFP_RECLAIMABLE,	"GFP_RECLAIMABLE"},	\
>  	{(unsigned long)__GFP_MOVABLE,		"GFP_MOVABLE"},		\
>  	{(unsigned long)__GFP_NOTRACK,		"GFP_NOTRACK"},		\
> +	{(unsigned long)__GFP_WRITE,		"GFP_WRITE"},		\
>  	{(unsigned long)__GFP_DIRECT_RECLAIM,	"GFP_DIRECT_RECLAIM"},	\
>  	{(unsigned long)__GFP_KSWAPD_RECLAIM,	"GFP_KSWAPD_RECLAIM"},	\
>  	{(unsigned long)__GFP_OTHER_NODE,	"GFP_OTHER_NODE"}	\
> -	) : "GFP_NOWAIT"
>  
> +#define show_gfp_flags(flags)						\
> +	(flags) ? __print_flags(flags, "|",				\
> +	__def_gfpflag_names						\
> +	) : "none"

How about moving this to gfp.h or something?
Now, we use it in out of tracepoints so there is no need to keep it
in include/trace/events/xxx.

Thanks.


> diff --git a/mm/debug.c b/mm/debug.c
> index d9718fc..1a71a3b 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -9,6 +9,7 @@
>  #include <linux/mm.h>
>  #include <linux/trace_events.h>
>  #include <linux/memcontrol.h>
> +#include <trace/events/gfpflags.h>
>  
>  static const struct trace_print_flags pageflag_names[] = {
>  	{1UL << PG_locked,		"locked"	},
> @@ -46,6 +47,10 @@ static const struct trace_print_flags pageflag_names[] = {
>  #endif
>  };
>  
> +static const struct trace_print_flags gfpflag_names[] = {
> +	__def_gfpflag_names
> +};
> +
>  static void dump_flag_names(unsigned long flags,
>  			const struct trace_print_flags *names, int count)
>  {
> @@ -73,6 +78,11 @@ static void dump_flag_names(unsigned long flags,
>  	pr_cont(")\n");
>  }
>  
> +void dump_gfpflag_names(unsigned long gfp_flags)
> +{
> +	dump_flag_names(gfp_flags, gfpflag_names, ARRAY_SIZE(gfpflag_names));
> +}
> +
>  void dump_page_badflags(struct page *page, const char *reason,
>  		unsigned long badflags)
>  {
> -- 
> 2.6.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
