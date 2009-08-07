Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BE5F76B004D
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 10:36:07 -0400 (EDT)
Subject: Re: [RFC][PATCH] mm: stop balance_dirty_pages doing too much work
From: Richard Kennedy <richard@rsk.demon.co.uk>
In-Reply-To: <1249647601.32113.700.camel@twins>
References: <1245839904.3210.85.camel@localhost.localdomain>
	 <1249647601.32113.700.camel@twins>
Content-Type: text/plain
Date: Fri, 07 Aug 2009 15:36:01 +0100
Message-Id: <1249655761.2719.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-08-07 at 14:20 +0200, Peter Zijlstra wrote:
> On Wed, 2009-06-24 at 11:38 +0100, Richard Kennedy wrote:
...
> OK, so Chris ran into this bit yesterday, complaining that he'd only get
> very few write requests and couldn't saturate his IO channel.
> 
> Now, since writing out everything once there's something to do sucks for
> Richard, but only writing out stuff when we're over the limit sucks for
> Chris (since we can only be over the limit a little), the best thing
> would be to only write out when we're over the background limit. Since
> that is the low watermark we use for throttling it makes sense that we
> try to write out when above that.
> 
> However, since there's a lack of bdi_background_thresh, and I don't
> think introducing one just for this is really justified. How about the
> below?
> 
> Chris how did this work for you? Richard, does this make things suck for
> you again?
> 
> ---
>  mm/page-writeback.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 81627eb..92f42d6 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -545,7 +545,7 @@ static void balance_dirty_pages(struct address_space *mapping)
>  		 * threshold otherwise wait until the disk writes catch
>  		 * up.
>  		 */
> -		if (bdi_nr_reclaimable > bdi_thresh) {
> +		if (bdi_nr_reclaimable > bdi_thresh/2) {
>  			writeback_inodes(&wbc);
>  			pages_written += write_chunk - wbc.nr_to_write;
>  			get_dirty_limits(&background_thresh, &dirty_thresh,
> 
> 
I'll run some tests and let you know :)

But what if someone has changed the vm settings?
Maybe something like 
	(bdi_thresh * dirty_background_ratio / dirty_ratio)
might be better ?

Chris, what sort of workload are you having problems with?

regards
Richard


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
