Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 077D66B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 16:01:55 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id kp14so2213031pab.19
        for <linux-mm@kvack.org>; Mon, 21 Jan 2013 13:01:54 -0800 (PST)
Date: Mon, 21 Jan 2013 13:01:50 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2] mm: dmapool: use provided gfp flags for all
 dma_alloc_coherent() calls
Message-ID: <20130121210150.GA9184@kroah.com>
References: <20121119144826.f59667b2.akpm@linux-foundation.org>
 <201301192005.20093.arnd@arndb.de>
 <50FD5844.1010201@web.de>
 <201301211855.25455.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201301211855.25455.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Soeren Moch <smoch@web.de>, Jason Cooper <jason@lakedaemon.net>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Andrew Lunn <andrew@lunn.ch>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

On Mon, Jan 21, 2013 at 06:55:25PM +0000, Arnd Bergmann wrote:
> On Monday 21 January 2013, Soeren Moch wrote:
> > On 01/19/13 21:05, Arnd Bergmann wrote:
> > > from the distribution of the numbers, it seems that there is exactly 1 MB
> > > of data allocated between bus addresses 0x1f90000 and 0x1f9ffff, allocated
> > > in individual pages. This matches the size of your pool, so it's definitely
> > > something coming from USB, and no single other allocation, but it does not
> > > directly point to a specific line of code.
> > Very interesting, so this is no fragmentation problem nor something 
> > caused by sata or ethernet.
> 
> Right.
> 
> > > One thing I found was that the ARM dma-mapping code seems buggy in the way
> > > that it does a bitwise and between the gfp mask and GFP_ATOMIC, which does
> > > not work because GFP_ATOMIC is defined by the absence of __GFP_WAIT.
> > >
> > > I believe we need the patch below, but it is not clear to me if that issue
> > > is related to your problem or now.
> > Out of curiosity I checked include/linux/gfp.h. GFP_ATOMIC is defined as 
> > __GFP_HIGH (which means 'use emergency pool', and no wait), so this 
> > patch should not make any difference for "normal" (GPF_ATOMIC / 
> > GFP_KERNEL) allocations, only for gfp_flags accidentally set to zero. 
> 
> Yes, or one of the rare cases where someone intentionally does something like
> (GFP_ATOMIC & !__GFP_HIGH) or (GFP_KERNEL || __GFP_HIGH), which are both
> wrong.
> 
> > So, can a new test with this patch help to debug the pool exhaustion?
> 
> Yes, but I would not expect this to change much. It's a bug, but not likely
> the one you are hitting.
> 
> > > So even for a GFP_KERNEL passed into usb_submit_urb, the ehci driver
> > > causes the low-level allocation to be GFP_ATOMIC, because
> > > qh_append_tds() is called under a spinlock. If we have hundreds
> > > of URBs in flight, that will exhaust the pool rather quickly.
> > >
> > Maybe there are hundreds of URBs in flight in my application, I have no 
> > idea how to check this.
> 
> I don't know a lot about USB, but I always assumed that this was not
> a normal condition and that there are only a couple of URBs per endpoint
> used at a time. Maybe Greg or someone else with a USB background can
> shed some light on this.

There's no restriction on how many URBs a driver can have outstanding at
once, and if you have a system with a lot of USB devices running at the
same time, there could be lots of URBs in flight depending on the number
of host controllers and devices and drivers being used.

Sorry,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
