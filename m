Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id QAA09593
	for <linux-mm@kvack.org>; Sat, 21 Sep 2002 16:53:20 -0700 (PDT)
Message-ID: <3D8D066F.1B45E3EA@digeo.com>
Date: Sat, 21 Sep 2002 16:53:19 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: overcommit stuff
References: <3D8D0046.EF119E03@digeo.com> <Pine.LNX.4.44.0209220037110.2265-100000@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> 
> On Sat, 21 Sep 2002, Andrew Morton wrote:
> > Alan,
> >
> > running 10,000 tiobench threads I'm showing 23 gigs of
> > `Commited_AS'.  Is this right?  Those pages are shared,
> > and if they're not PROT_WRITEable then there's no way in
> > which they can become unshared?   Seems to be excessively
> > pessimistic?
> >
> > Or is 2.5 not up to date?
> 
> I don't think Alan can be held responsible for errors in the
> overcommit stuff rml ported to 2.5 and I then added fixes to.

Well I'm not saying it's an error.  It may be by design.

> I believe it is up to date in 2.5.

OK.
 
> Committed_AS certainly errs on the pessimistic side, that's
> what it's about.  How much swap do you have i.e. is 23GB
> committed impossible, or just surprising to you?  Does the
> number go back to what it started off from when you kill
> off the tests?  How are "those pages" allocated e.g. what
> mmap args?

I have 7G physical, 4G swap.

"those pages" were just used by some scruffy perl script 
running `./tiotest &' ten thousand times.  I assume it's
shared executable text.

It seems very unlikely (impossible?) that those pages will
ever become unshared.

Are they returned when the threads are killed?  Dunno - the
machine got a vists from the NMI watchdog in the scheduler
somewhere before I could tell.  Retesting...

Here's what I had when it died:

MemTotal:      7249608 kB
MemFree:          7180 kB
MemShared:           0 kB
Buffers:         29040 kB
Cached:        6879180 kB
SwapCached:      51216 kB
Active:          22672 kB
Inactive:      6950548 kB
HighTotal:     6422528 kB
HighFree:         2980 kB
LowTotal:       827080 kB
LowFree:          4200 kB
SwapTotal:     3951844 kB
SwapFree:      3829764 kB
Dirty:          658468 kB
Writeback:       10640 kB
Mapped:          57228 kB
Slab:            83188 kB
Committed_AS: 28417140 kB
PageTables:      58152 kB
ReverseMaps:     28455


nr_dirty 165433
nr_writeback 2663 
nr_pagecache 1739859
nr_page_table_pages 14538
nr_reverse_maps 28455
nr_mapped 14307
nr_slab 20802
pswpin 45
pswpout 30532
pgalloc 6671454
pgfree 6673245
pgactivate 74265
pgdeactivate 68457
pgfault 1261681
pgmajfault 714
pgscan 4640872
pgrefill 100136
pgsteal 4329474
kswapd_steal 1413013
pageoutrun 90269
allocstall 90269



       buffer_head:    25669KB    30953KB   82.92
       task_struct:    14648KB    15218KB   96.25
   radix_tree_node:    12337KB    12354KB   99.85
  ext2_inode_cache:     4058KB     4058KB  100.0 
    vm_area_struct:     2463KB     2475KB   99.52
          size-512:     1428KB     1428KB  100.0 
              filp:     1301KB     1301KB  100.0 
      dentry_cache:     1290KB     1290KB  100.0 
biovec-BIO_MAX_PAGES:      780KB      780KB  100.0 
       names_cache:      744KB      748KB   99.46
         biovec-64:      677KB      723KB   93.57
   blkdev_requests:      625KB      633KB   98.69
         size-4096:      556KB      556KB  100.0 
         pte_chain:      158KB      489KB   32.39
sgpool-MAX_PHYS_SEGMENTS:      420KB      480KB   87.50
        biovec-128:      390KB      390KB  100.0 
         size-2048:      352KB      352KB  100.0 
         size-1024:      348KB      348KB  100.0 
           size-32:      317KB      324KB   97.57
  ext3_inode_cache:      171KB      240KB   71.22
         sgpool-64:      213KB      232KB   91.93
        signal_act:      212KB      212KB  100.0
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
