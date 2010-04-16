Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D8F426B020C
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 00:43:45 -0400 (EDT)
Received: from dastard (unverified [121.44.229.111])
	by mail.internode.on.net (SurgeMail 3.8f2) with ESMTP id 20825113-1927428
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 14:13:43 +0930 (CST)
Date: Fri, 16 Apr 2010 14:27:42 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 08/10] vmscan: Setup pagevec as late as possible in
 shrink_inactive_list()
Message-ID: <20100416042742.GA2493@dastard>
References: <1271352103-2280-1-git-send-email-mel@csn.ul.ie>
 <1271352103-2280-9-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1271352103-2280-9-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 06:21:41PM +0100, Mel Gorman wrote:
> shrink_inactive_list() sets up a pagevec to release unfreeable pages. It
> uses significant amounts of stack doing this. This patch splits
> shrink_inactive_list() to take the stack usage out of the main path so
> that callers to writepage() do not contain an unused pagevec on the
> stack.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/vmscan.c |   93 +++++++++++++++++++++++++++++++++-------------------------
>  1 files changed, 53 insertions(+), 40 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a232ad6..9bc1ede 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1120,6 +1120,54 @@ static int too_many_isolated(struct zone *zone, int file,
>  }
>  
>  /*
> + * TODO: Try merging with migrations version of putback_lru_pages
> + */
> +static noinline void putback_lru_pages(struct zone *zone,

noinline_for_stack

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
