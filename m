Received: from ucla.edu ([149.142.156.27])
	by serval.noc.ucla.edu (8.9.1a/8.9.1) with ESMTP id QAA22418
	for <linux-mm@kvack.org>; Sat, 1 Sep 2001 16:32:03 -0700 (PDT)
Message-ID: <3B916FF3.6040300@ucla.edu>
Date: Sat, 01 Sep 2001 16:32:03 -0700
From: Benjamin Redelings I <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: VM change in 2.4.10-pre3: don't call swap_out unless shortage
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi list,
	I saw this change in 2.4.10-pre3, which seems to have some disadvantages:

 >  static int do_try_to_free_pages(unsigned int gfp_mask, int user)
 >  {
 > -     /* Always walk at least the active queue when called */
 > -     int shortage = INACTIVE_SHORTAGE;
 > +     int shortage = 0;
 >       int maxtry;
 >
 > +     /* Always walk at least the active queue when called */
 > +     refill_inactive_scan(DEF_PRIORITY);

This avoids swapping when there is no shortage, but it ALSO avoids 
looking at any hardware accessed bits, since swap_out does that.

In fact, I thought that Linus was thinking of renaming swap_out to 
something like scan_pages, since it doesn't actually swap things out - 
it just moves them to the swap cache.  So, if the purpose of this change 
is to "avoid swapping when it is unnecessary" then isn't it doing the 
wrong thing?  Shouldn't it instead make the kernel less aggressive in 
moving pages to the swap cache when there is no shortage (since we can't 
look at the hardware accessed bits any-more) or delay write-out of 
swap-cached pages until there is a shortage?

On the other hand, perhaps the intension is to avoid doing swap-out when 
there is a free shortage, but no inactive shortage?  Or perhaps the 
intention is to avoid running swap_out every time kswapd runs?

I guess what I am really wondering is if there is some way that we could 
continue calling refill_inactive_scan while never calling swap_out (or 
only rarely).  Because in that case it seems that page age's would be 
fairly innaccurate, since this test would almost never be true:

                 /* Do aging on the pages. */
                 if (PageTestandClearReferenced(page)) {
                         age_page_up(page);

Anyway, thanks for any explanation of what I'm missing!

-BenRI, looking forwards to reverse mapping...
-- 
"At this time Frodo was still in his 'tweens', as the hobbits called
the irresponsible twenties between childhood and coming-of-age at
thirty three" - The Fellowship of the Ring, J.R.R. Tolkein
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
