Received: from uow.edu.au (wumpus.its.uow.edu.au [130.130.68.12])
	by horus.its.uow.edu.au (8.9.3/8.9.3) with ESMTP id AAA08371
	for <linux-mm@kvack.org>; Thu, 15 Mar 2001 00:24:17 +1100 (EST)
Message-ID: <3AAF716E.1B776E31@uow.edu.au>
Date: Thu, 15 Mar 2001 00:26:06 +1100
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: it gets slower
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

After doing a huge amount of disk I/O the other day I noted
that a subsequent full kernel build took *ages*. I haven't
been able to reproduce the full extent of this, but..

Doing a build after boot takes 320 seconds.  After
copying two kernel trees and diffing them, an identical
full build takes 336 seconds.  Profiling each build says:

Before:

c01120b0 do_page_fault                              1453   1.2440
c0271a00 __generic_copy_to_user                     1741  29.0167
c0122c6c do_wp_page                                 1895   2.9609
c012da88 rmqueue                                    2245   3.7922
c0271a3c __generic_copy_from_user                   3593  59.8833
c01260f0 file_read_actor                            4490  41.5741
c0123388 do_anonymous_page                         11121  89.6855
c01071c0 default_idle                              21741 418.0962
00000000 total                                     71684   0.0469

After:

c0271a00 __generic_copy_to_user                     1696  28.2667
c0122c6c do_wp_page                                 1865   2.9141
c012da88 rmqueue                                    2226   3.7601
c0271a3c __generic_copy_from_user                   3584  59.7333
c01260f0 file_read_actor                            4529  41.9352
c0123388 do_anonymous_page                         11324  91.3226
c01071c0 default_idle                              34807 669.3654
00000000 total                                     90069   0.0590

This is a 1kHz profile, so we've spent an extra 13 seconds in
default_idle.  Doing I/O, presumably.  256 meg dual Celeron.

Why?



Also, we spent 12 seconds in do_anonymous_page and do_wp_page
madly memsetting.  Has anyone tried prezeroing some pages in
default_idle(), so they're ready to go?

Yes, I know it'll probably be cachely disadvantageous,
but has anyone actually tried and measured it?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
