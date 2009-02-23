Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B06306B003D
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 02:24:21 -0500 (EST)
Received: by fxm10 with SMTP id 10so1552884fxm.14
        for <linux-mm@kvack.org>; Sun, 22 Feb 2009 23:24:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1235344649-18265-14-git-send-email-mel@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
	 <1235344649-18265-14-git-send-email-mel@csn.ul.ie>
Date: Mon, 23 Feb 2009 09:24:19 +0200
Message-ID: <84144f020902222324i38de9a63hd112b90742c2ca8c@mail.gmail.com>
Subject: Re: [PATCH 13/20] Inline buffered_rmqueue()
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 23, 2009 at 1:17 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> buffered_rmqueue() is in the fast path so inline it. This incurs text
> bloat as there is now a copy in the fast and slow paths but the cost of
> the function call was noticeable in profiles of the fast path.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/page_alloc.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d8a6828..2383147 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1080,7 +1080,8 @@ void split_page(struct page *page, unsigned int order)
>  * we cheat by calling it from here, in the order > 0 path.  Saves a branch
>  * or two.
>  */
> -static struct page *buffered_rmqueue(struct zone *preferred_zone,
> +static inline
> +struct page *buffered_rmqueue(struct zone *preferred_zone,
>                        struct zone *zone, int order, gfp_t gfp_flags,
>                        int migratetype)
>  {

I'm not sure if this is changed now but at least in the past, you had
to use __always_inline to force GCC to do the inlining for all
configurations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
