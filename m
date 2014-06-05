Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 83C726B0035
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 09:37:50 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id n15so3485028wiw.14
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 06:37:50 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gk1si15044981wib.80.2014.06.05.06.37.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 06:37:49 -0700 (PDT)
Date: Thu, 5 Jun 2014 15:37:47 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Interactivity regression since v3.11 in mm/vmscan.c
Message-ID: <20140605133747.GB2942@dhcp22.suse.cz>
References: <53905594d284f_71f12992fc6a@nysa.notmuch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53905594d284f_71f12992fc6a@nysa.notmuch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Felipe Contreras <felipe.contreras@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

On Thu 05-06-14 06:33:40, Felipe Contreras wrote:
> Hi,

Hi,
 
> For a while I've noticed that my machine bogs down in certain
> situations, usually while doing heavy I/O operations, it is not just the
> I/O operations, but everything, including the graphical interface, even
> the mouse pointer.
> 
> As far as I can recall this did not happen in the past.
> 
> I noticed this specially on certain operations, for example updating a
> a game on Steam (to an exteranl USB 3.0 device), or copying TV episodes
> to a USB memory stick (probably flash-based).

We had a similar report for opensuse. The common part was that there was
an IO to a slow USB device going on.
 
> Today I decided to finally hunt down the problem, so I created a
> synthetic test that basically consists on copying a bunch of files from
> one drive to another (from an SSD to an external USB 3.0). This is
> pretty similar to what I noticed; the graphical interface slows down.
> 
> Then I bisected the issue and it turns out that indeed it wasn't
> happening in the past, it started happening in v3.11, and it was
> triggered by this commit:
> 
>   e2be15f (mm: vmscan: stall page reclaim and writeback pages based on
>   dirty/writepage pages encountered)
> 
> Then I went back to the latest stable version (v3.14.5), and commented
> out the line I think is causing the slow down:
> 
>   if (nr_unqueued_dirty == nr_taken || nr_immediate)
> 	  congestion_wait(BLK_RW_ASYNC, HZ/10);

Yes, I came to the same check. I didn't have any confirmation yet so
thanks for your confirmation. I've suggested to reduce this
congestion_wait only to kswapd:
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 32c661d66a45..ef6a1c0e788c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1566,7 +1566,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		 * implies that pages are cycling through the LRU faster than
 		 * they are written so also forcibly stall.
 		 */
-		if (nr_unqueued_dirty == nr_taken || nr_immediate)
+		if ((nr_unqueued_dirty == nr_taken || nr_immediate) && current_is_kswapd())
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 	}

But I am still not sure whether this is the right way to fix it. Direct
reclaimers can be throttled later on wait_iff_congested. I guess the
original intention was to throttle kswapd to not scan LRU full of dirty
pages like crazy. So I think it makes some sense to reduce the
congestion_wait only to kswapd.

 
> After that I don't notice the slow down any more.
> 
> Anybody has any ideas how to fix the issue properly?
> 
> -- 
> Felipe Contreras
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
