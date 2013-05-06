Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 74A606B00EC
	for <linux-mm@kvack.org>; Mon,  6 May 2013 15:08:23 -0400 (EDT)
Date: Mon, 6 May 2013 15:08:02 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RFC] mm: lru milestones, timestamps and ages
Message-ID: <20130506190802.GA16474@cmpxchg.org>
References: <20130430110214.22179.26139.stgit@zurg>
 <5183C49D.1010000@bitsync.net>
 <5184F6C9.4060506@openvz.org>
 <5185069A.1080306@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5185069A.1080306@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Zlatko Calusic <zcalusic@bitsync.net>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

Mel: we talked about this issue below in SFO, apparently I'm not the
only one who noticed :-)

Rik: a fix for the problem below is crucial for the refault
distance-based page cache sizing.  The unequal LRU aging is a problem
in itself, but it's compounded when we use the skewed non-resident
times to base reclaim decisions on

On Sat, May 04, 2013 at 05:01:14PM +0400, Konstantin Khlebnikov wrote:
> Hey! I can reproduce this:
> 
> Node 0, zone    DMA32
>     nr_inactive_anon 1
>     nr_active_anon 2368
>     nr_inactive_file 373642
>     nr_active_file 375462
>     nr_dirtied   2887369
>     nr_written   2887291
>   inactive_ratio:    5
>   avg_age_inactive_anon: 64942528
>   avg_age_active_anon:   64942528
>   avg_age_inactive_file: 389824
>   avg_age_active_file:   1330368
> Node 0, zone   Normal
>     nr_inactive_anon 376
>     nr_active_anon 17768
>     nr_inactive_file 534695
>     nr_active_file 533685
>     nr_dirtied   12071397
>     nr_written   11940007
>   inactive_ratio:    6
>   avg_age_inactive_anon: 65064192
>   avg_age_active_anon:   65064192
>   avg_age_inactive_file: 28074
>   avg_age_active_file:   1304800
> 
> I'm just copying huge files from one disk to another by rsync.
> 
> In /proc/vmstat pgsteal_kswapd_normal and pgscan_kswapd_normal are rising rapidly,
> other pgscan_* pgsteal_* are standing still. So, bug is somewhere in the kswapd.

There is a window where a steady stream of allocations and kswapd
cooperate in perfect unison and keep the Normal zone always between
the low and high watermarks.  Kswapd does not stop until the high
watermark is met, the allocator does not go to lower zones until the
low watermark is breached.  As a result, most allocations happen in
the Normal zone.

I'm playing around with a round-robin scheme on the page allocator
side to spread out file pages more evenly, but I'm torn on whether the
fix should actually be on the kswapd side, to enforce reclaim instead
of allocation more evenly.  Thoughts?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
