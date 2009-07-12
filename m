Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BDCC96B004F
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 01:02:13 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id l33so353046rvb.26
        for <linux-mm@kvack.org>; Sat, 11 Jul 2009 22:14:46 -0700 (PDT)
Date: Sun, 12 Jul 2009 13:14:42 +0800
From: Wu Fengguang <fengguang.wu@gmail.com>
Subject: Re: OOM killer in 2.6.31-rc2
Message-ID: <20090712051441.GA7903@localhost>
References: <200907061056.00229.gene.heskett@verizon.net> <200907101100.58110.gene.heskett@verizon.net> <20090711083551.GA6209@localhost> <200907110819.30337.gene.heskett@verizon.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200907110819.30337.gene.heskett@verizon.net>
Sender: owner-linux-mm@kvack.org
To: Gene Heskett <gene.heskett@verizon.net>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 11, 2009 at 08:19:30AM -0400, Gene Heskett wrote:
> On Saturday 11 July 2009, Wu Fengguang wrote:
> >On Fri, Jul 10, 2009 at 11:00:58AM -0400, Gene Heskett wrote:
> >> On Friday 10 July 2009, Wu Fengguang wrote:
> >> >> From dmesg:
> >> >> [    0.000000] TOM2: 0000000120000000 aka 4608M  <what is this?
> >> >
> >> >That 4608M includes memory hole I guess.
> >>
> >> Is this hole size not a known value?
> >>
> >> [...]
> >>
> >> >Most relevant ones:
> >> >
> >> >- 300+MB >4G memory is not reachable by kernel and user space
> >> >- 2.7GB high memory is not usable for slab caches and some other
> >> >  kernel users
> >>
> >> Can you expand on this, teach a dummy in other words?  I was under the
> >> impression that slab caches were placed in this high memory if
> >> either the 4G or 64G flags were set...
> >
> >No, slab pages are allocated from Normal, DMA, DMA32 zones, but not
> >HighMem zone. The kernel cannot access HighMem directly. The 4G/64G
> >flags only mean up to 4G/64G memory can be visited. But the kernel
> >only build page tables to visit the first 1G memory _directly_. The
> >other 3G address space is reserved for user space. When kernel want
> >to visit the HighMem memory, it must setup temporary page table
> >entries to point to the page it want to access.
> 
> So there can be an oom that exists only for SLAB et all while the system 
> itself has available memory.  Hummm.  Is this a hardware limitation of running 
> in 32 bit mode, one that goes away for 64 bit builds?

In theory the SLAB pages can mostly be reclaimed when memory is tight.
So your OOM happens either because the SLAB pages are not reclaimable,
or the reclaim algorithm didn't reclaim them as much as it should.

> 
> >> Is this a good excuse to revisit either SLUB or SLQB use?
> >
> >SLUB/SLQB/SLAB is equal in this aspect.
> >
> >> I did run SLUB for a while, but it did seem slower, so I switched
> >> back to SLAB a few months back.
> >
> >SLUB uses high order pages, the allocation of which is harder
> >than normal 1-page allocations, especially when you are already
> >tight in memory.
> >
> >Thanks,
> >Fengguang
> 
> Now at 18 hours of uptime, things still look and feel normal. 18 megs into 
> swap, 321 processes, 625 megs of memory used according to htop.  The top 
> section of slabtop:
> Active / Total Objects (% used)    : 509209 / 782668 (65.1%)
>  Active / Total Slabs (% used)      : 34397 / 34397 (100.0%)
>  Active / Total Caches (% used)     : 104 / 163 (63.8%)
>  Active / Total Size (% used)       : 108602.20K / 130401.10K (83.3%)
>  Minimum / Average / Maximum Object : 0.01K / 0.17K / 4096.00K
> 
> But I had to restart it with a -d 15 to get a good copy to paste, the refresh 
> rate was wiping my copy.  The -o or --once gives an empty return, and total 

slabtop does output something, and then the screen get cleared
immediately. It seems related to the alternate screen concept,
xterm has a resource 'titeInhibit' for it. Though I'm not sure
how the slabtop code can be fixed in a trivial way.

> slabs varies from 99% to 100%.
> 
> Just to complete the environmental info, there is one other item I changed, 
> not kernel related. Looking at my amanda.conf yesterday, I found I was telling 
> it it could use about 3G as buffers and reduced that to about 1G, which didn't 
> seem to effect it.  But I wonder if that was what was dirtying up the works as 
> the last crash was about 3 hours after the end of the amanda run.

Hmm not likely caused by amanda. It can use the HighMem pages so you
didn't see OOM when amanda uses up to 3G buffers.

> This 18 hours of uptime is a record by at least 3x what I've ever gotten from 
> this bios before.  On the one hand I am pleased, on the other the lack of 
> results so far has to be somewhat disappointing.

Don't be in a hurry. Just enjoy the current good state until OOM revisits :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
