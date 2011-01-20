Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1FCBC8D0069
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 15:57:14 -0500 (EST)
Received: from sim by peace.netnation.com with local (Exim 4.69)
	(envelope-from <sim@netnation.com>)
	id 1Pg1Z8-000435-OA
	for linux-mm@kvack.org; Thu, 20 Jan 2011 12:57:10 -0800
Date: Thu, 20 Jan 2011 12:57:10 -0800
From: Simon Kirby <sim@hostway.ca>
Subject: File and anon pages versus total counts in zoneinfo
Message-ID: <20110120205710.GC15647@hostway.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi!

I was trying to write a multigraph munin plugin to graph /proc/zoneinfo,
somewhere between the buddyinfo and memory plugins, to help get to the
bottom of the huge order-0 fragmentation that seems to be only happening
in the DMA32 zone on our servers (since at least 2.6.26).  I figured it
would make a nice stacked graph similar to the memory graph, where
everything could add up to the size of the zone (or total to the whole
system memory), but I'm having trouble finding out which page states can
overlap.

It seems that nr_inactive_anon and nr_active_anon never seem to add to
nr_anon_pages, and same with nr_inactive_file and nr_active_file to
nr_file_pages.  In the below random case from my desktop, it seems there
are more active and inactive anon pages than the actual nr_anon_pages,
so the error is happening both ways here.

I tried to dig through the kernel to find the paths that relate to how
file pages are allocated, but it seems like the LRU parts are separate
and a little confusing to follow.  Is there anything useful I could
follow here, or should I just give up and make it a regular line graph?

This graph is just the stacked output of /proc/zoneinfo for DMA32 on a
random server (in pages for now, not bytes).  It _almost_ looks like it
would add up to the same number if I just dropped nr_anon_pages and
nr_file_pages and made nr_dirty and nr_writeback lines instead of stacks,
but _not quite_.  (I excluded nr_vmscan_write, nr_dirtied, nr_written as
they seem to be counters.)

Simon-

Example from my desktop that doesn't add up for file or anon pages:

Node 0, zone    DMA32
  pages free     26961
        min      1426
        low      1782
        high     2139
        scanned  0
        spanned  520128
        present  513016
    nr_free_pages 26961
    nr_inactive_anon 8185
    nr_active_anon 130189
    nr_inactive_file 149021
    nr_active_file 153911
    nr_unevictable 1
    nr_mlock     1
    nr_anon_pages 137756
    nr_mapped    17376
    nr_file_pages 303551
    nr_dirty     51
    nr_writeback 0
    nr_slab_reclaimable 26394
    nr_slab_unreclaimable 4719
    nr_page_table_pages 2316
    nr_kernel_stack 248
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 346710
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     619
    nr_dirtied   25820454
    nr_written   17165935

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
