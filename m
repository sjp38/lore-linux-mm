Subject: [PATCH] 0/2 Buddy allocator with placement policy + prezeroing
Message-Id: <20050227134219.B4346ECE4@skynet.csn.ul.ie>
Date: Sun, 27 Feb 2005 13:42:19 +0000 (GMT)
From: mel@csn.ul.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

In the two following emails are the latest version of the placement policy
for the binary buddy allocator to reduce fragmentation and the prezeroing
patch. The changelogs are with the patches although the most significant change
to the placement policy is a fix for a bug in the usemap size calculation
(pointed out by Mike Kravetz). 

The placement policy is Even Better than previous versions and can allocate
over 100 2**10 blocks of pages under loads in excess of 30 so I still
consider it ready for inclusion to the mainline. The prezeroing patches
main contribution is a handy accounting scheme for the scrubbing daemon. The
patch records how many times blocks were zeroed and what size they were. I
found that order-0 is the most common size to zero because of the per-cpu
cache. For example, after the usual stress test completed, /proc/buddyinfo
reported the following;

Zeroblock count 1775307   7696   2048   1046   2577    871    164     17     18
8     39

That means that the majority of zeroing calls was for order-0 pages. What is
of greater concern is that the prezeroing patch seriously regresses how well
fragmentation is handled making it perform almost as badly as the standard
allocator. 

The patches were developed and tested heavily on 2.6.11-rc4 but are known
to patch cleanly and pass a stress test on 2.6.11-rc5.

-- 
Mel Gorman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
