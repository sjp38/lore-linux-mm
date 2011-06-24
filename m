Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id EC14F900194
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 02:23:12 -0400 (EDT)
Received: by pzk4 with SMTP id 4so2011550pzk.14
        for <linux-mm@kvack.org>; Thu, 23 Jun 2011 23:23:10 -0700 (PDT)
MIME-Version: 1.0
From: Andrew Lutomirski <luto@mit.edu>
Date: Fri, 24 Jun 2011 02:22:50 -0400
Message-ID: <BANLkTik7ubq9ChR6UEBXOo5D9tn3mMb1Yw@mail.gmail.com>
Subject: Root-causing kswapd spinning on Sandy Bridge laptops?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org

I'm back :-/

I just triggered the kswapd bug on 2.6.39.1, which has the
cond_resched in shrink_slab.  This time my system's still usable (I'm
tying this email on it), but kswapd0 is taking 100% cpu.  It *does*
schedule (tested by setting its affinity the same as another CPU hog
and confirming that each one gets 50%).

It appears to be calling i915_gem_inactive_shrink in a loop.  I have
probes on entry and return of i915_gem_inactive_shrink and on return
of shrink_slab.  I see:

         kswapd0    47 [000] 59599.956573: mm_vmscan_kswapd_wake: nid=0 order=0
         kswapd0    47 [000] 59599.956575: shrink_zone:
(ffffffff810c848c) priority=12 zone=ffff8801005fe000
         kswapd0    47 [000] 59599.956576: shrink_zone_return:
(ffffffff810c848c <- ffffffff810c96c6) arg1=0
         kswapd0    47 [000] 59599.956578: i915_gem_inactive_shrink:
(ffffffffa0081e48) gfp_mask=d0 nr_to_scan=0
         kswapd0    47 [000] 59599.956589: shrink_return:
(ffffffffa0081e48 <- ffffffff810c6a62) arg1=320
         kswapd0    47 [000] 59599.956589: shrink_slab_return:
(ffffffff810c69f5 <- ffffffff810c96ec) arg1=0
         kswapd0    47 [000] 59599.956592: i915_gem_inactive_shrink:
(ffffffffa0081e48) gfp_mask=d0 nr_to_scan=0
         kswapd0    47 [000] 59599.956602: shrink_return:
(ffffffffa0081e48 <- ffffffff810c6a62) arg1=320
         kswapd0    47 [000] 59599.956603: shrink_slab_return:
(ffffffff810c69f5 <- ffffffff810c96ec) arg1=0
         kswapd0    47 [000] 59599.956605: shrink_zone:
(ffffffff810c848c) priority=12 zone=ffff8801005fee00
         kswapd0    47 [000] 59599.956606: shrink_zone_return:
(ffffffff810c848c <- ffffffff810c96c6) arg1=0
         kswapd0    47 [000] 59599.956608: i915_gem_inactive_shrink:
(ffffffffa0081e48) gfp_mask=d0 nr_to_scan=0
         kswapd0    47 [000] 59599.956609: shrink_return:
(ffffffffa0081e48 <- ffffffff810c6a62) arg1=0
         kswapd0    47 [000] 59599.956610: shrink_slab_return:
(ffffffff810c69f5 <- ffffffff810c96ec) arg1=0
         kswapd0    47 [000] 59599.956611: mm_vmscan_kswapd_wake: nid=0 order=0
         kswapd0    47 [000] 59599.956612: shrink_zone:
(ffffffff810c848c) priority=12 zone=ffff8801005fe000
         kswapd0    47 [000] 59599.956614: shrink_zone_return:
(ffffffff810c848c <- ffffffff810c96c6) arg1=0
         kswapd0    47 [000] 59599.956616: i915_gem_inactive_shrink:
(ffffffffa0081e48) gfp_mask=d0 nr_to_scan=0
         kswapd0    47 [000] 59599.956617: shrink_return:
(ffffffffa0081e48 <- ffffffff810c6a62) arg1=0
         kswapd0    47 [000] 59599.956618: shrink_slab_return:
(ffffffff810c69f5 <- ffffffff810c96ec) arg1=0
         kswapd0    47 [000] 59599.956620: i915_gem_inactive_shrink:
(ffffffffa0081e48) gfp_mask=d0 nr_to_scan=0
         kswapd0    47 [000] 59599.956621: shrink_return:
(ffffffffa0081e48 <- ffffffff810c6a62) arg1=0
         kswapd0    47 [000] 59599.956621: shrink_slab_return:
(ffffffff810c69f5 <- ffffffff810c96ec) arg1=0
         kswapd0    47 [000] 59599.956623: shrink_zone:
(ffffffff810c848c) priority=12 zone=ffff8801005fee00
         kswapd0    47 [000] 59599.956624: shrink_zone_return:
(ffffffff810c848c <- ffffffff810c96c6) arg1=0
         kswapd0    47 [000] 59599.956626: i915_gem_inactive_shrink:
(ffffffffa0081e48) gfp_mask=d0 nr_to_scan=0
         kswapd0    47 [000] 59599.956627: shrink_return:
(ffffffffa0081e48 <- ffffffff810c6a62) arg1=0
         kswapd0    47 [000] 59599.956628: shrink_slab_return:
(ffffffff810c69f5 <- ffffffff810c96ec) arg1=0
         kswapd0    47 [000] 59599.956629: mm_vmscan_kswapd_wake: nid=0 order=0

The command was:

perf record -g -aR -p 47 -e probe:i915_gem_inactive_shrink -e
probe:shrink_return -e probe:shrink_slab_return -e probe:shrink_zone
-e probe:shrink_zone_return -e probe:kswapd_try_to_sleep -e
vmscan:mm_vmscan_kswapd_sleep -e vmscan:mm_vmscan_kswapd_wake -e
vmscan:mm_vmscan_wakeup_kswapd -e vmscan:mm_vmscan_lru_shrink_inactive
-e probe:wakeup_kswapd; perf script

(shrink_return is i915_gem_inactive_shrink's return.  sorry, badly named.)

It looks like something kswapd_try_to_sleep is not getting called.

I do not know how to reproduce this, but I'll leave it running overnight.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
