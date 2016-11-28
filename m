Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8676B02CE
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 15:55:13 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id m203so262957900iom.6
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 12:55:13 -0800 (PST)
Received: from mail1.merlins.org (magic.merlins.org. [209.81.13.136])
        by mx.google.com with ESMTPS id a82si3482390ita.38.2016.11.28.12.55.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 28 Nov 2016 12:55:12 -0800 (PST)
Date: Mon, 28 Nov 2016 12:55:08 -0800
From: Marc MERLIN <marc@merlins.org>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of RAM that should be free
Message-ID: <20161128205508.GW13371@merlins.org>
References: <20161121154336.GD19750@merlins.org> <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz> <20161121215639.GF13371@merlins.org> <20161122160629.uzt2u6m75ash4ved@merlins.org> <48061a22-0203-de54-5a44-89773bff1e63@suse.cz> <CA+55aFweND3KoV=00onz0Y5W9ViFedd-nvfCuB+phorc=75tpQ@mail.gmail.com> <20161123063410.GB2864@dhcp22.suse.cz> <20161128072315.GC14788@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="X1bOJ3K7DJ5YkBrT"
Content-Disposition: inline
In-Reply-To: <20161128072315.GC14788@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>


--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Nov 28, 2016 at 08:23:15AM +0100, Michal Hocko wrote:
> Marc, could you try this patch please? I think it should be pretty clear
> it should help you but running it through your use case would be more
> than welcome before I ask Greg to take this to the 4.8 stable tree.
 
This will take a little while, the whole copy took 5 days to finish and I'm a
bit hesitant about blowing it away and starting over :)
Let me see if I can come up with maybe another disk array for another test.

For now, as a reminder, I'm running that attached patch, and it works fine
I'll report back as soon as I can.

Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  

--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="4.8.8-mem2.patch"

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a2214c64ed3c..9b3b3a79c58a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3347,17 +3347,24 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 					ac->nodemask) {
 		unsigned long available;
 		unsigned long reclaimable;
+		int check_order = order;
+		unsigned long watermark = min_wmark_pages(zone);
 
 		available = reclaimable = zone_reclaimable_pages(zone);
 		available -= DIV_ROUND_UP(no_progress_loops * available,
 					  MAX_RECLAIM_RETRIES);
 		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
 
+		if (order > 0 && order <= PAGE_ALLOC_COSTLY_ORDER) {
+			check_order = 0;
+			watermark += 1UL << order;
+		}
+
 		/*
 		 * Would the allocation succeed if we reclaimed the whole
 		 * available?
 		 */
-		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
+		if (__zone_watermark_ok(zone, check_order, watermark,
 				ac_classzone_idx(ac), alloc_flags, available)) {
 			/*
 			 * If we didn't make any progress and have a lot of


--X1bOJ3K7DJ5YkBrT--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
