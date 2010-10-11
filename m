Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 287F66B0071
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 16:40:12 -0400 (EDT)
Message-ID: <20101011203508.2063.qmail@kosh.dhis.org>
From: pacman@kosh.dhis.org
Subject: Re: PROBLEM: memory corrupting bug, bisected to 6dda9d55
Date: Mon, 11 Oct 2010 15:35:08 -0500 (GMT+5)
In-Reply-To: <20101011143022.GD30667@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Mel Gorman writes:
> 
> A corruption of 4 bytes could be consistent with a pointer value being
> written to an incorrect location.

The memory scribbles that I've looked at in detail and written down have
been 0x86520000, 0xea5b0000, and 0x1d5f0000. They don't look very pointerish.
The 2 low bytes being 0 in all 3 cases is an intriguing pattern though. That
may not matter though because...

> 
> I think there is a slight bug but but not one that would cause corruption.
> 
> 	if ((order < MAX_ORDER-1) && pfn_valid_within(page_to_pfn(buddy))) {

I think you found it. Think harder about how it might cause corruption.
Applying your suggested patch really seems to have fixed it. Starting from
v2.6.36-rc7-69-g6b0cd00 I applied your patch, booted 6 times, all clean.
Reverted your patch, booted once, and /sbin/e2fsck failed its md5sum check.
Sent a copy of the "bad" /sbin/e2fsck to another machine, rebooted with an
old good kernel, reapplied your patch to the new kernel, and got 6 more good
boots.

The bad copy of e2fsck differs from the good one in 2 separate locations,
each 4 bytes wide. The bogus values are the 0xea5b0000 and 0x1d5f0000 which I
mentioned already.

> That looks like it can result in checking the buddy for an order-(MAX_ORDER-1)
> page which is a bit bogus. Thing is, it should be harmless because there
> isn't an unusual write made. In case it's some weird compiler optimisation
> though, could you try this?
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 502a882..5b0eb8c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -530,7 +530,7 @@ static inline void __free_one_page(struct page *page,
>  	 * so it's less likely to be used soon and more likely to be merged
>  	 * as a higher order page
>  	 */
> -	if ((order < MAX_ORDER-1) && pfn_valid_within(page_to_pfn(buddy))) {
> +	if ((order < MAX_ORDER-2) && pfn_valid_within(page_to_pfn(buddy))) {
>  		struct page *higher_page, *higher_buddy;
>  		combined_idx = __find_combined_index(page_idx, order);
>  		higher_page = page + combined_idx - page_idx;
> 

It doesn't look like there are any optimization tricks involved. I did a
"make mm/page_alloc.s" before and after your patch, and the difference is
simply this:

--- mm/page_alloc.s.6b0cd00	2010-10-11 14:03:03.000000000 -0500
+++ mm/page_alloc.s.6b0cd00+mel	2010-10-11 14:03:49.000000000 -0500
@@ -3885,7 +3885,7 @@
 .L523:
 	mr 11,28	 # page_idx, page_idx.2227
 .L526:
-	cmplwi 7,29,9	 #, tmp222, order
+	cmplwi 7,29,8	 #, tmp222, order
 	lwz 0,0(30)	 #* page, tmp220
 	stw 29,12(30)	 # <variable>.D.6650.D.6646.private, order
 	oris 0,0,0x8	 #, tmp221, tmp220,
@@ -4337,7 +4337,7 @@
 	add 30,31,11	 # buddy, page, tmp197
 	ble+ 7,.L578	 #
 .L575:
-	cmplwi 7,27,9	 #, tmp226, order
+	cmplwi 7,27,8	 #, tmp226, order
 	lwz 0,0(31)	 #* page, tmp224
 	stw 27,12(31)	 # <variable>.D.6650.D.6646.private, order
 	oris 0,0,0x8	 #, tmp225, tmp224,

-- 
Alan Curry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
