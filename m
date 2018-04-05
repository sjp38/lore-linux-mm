Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3E08C6B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 16:16:00 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id d14-v6so20503732plj.4
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 13:16:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 35-v6si9261623pla.733.2018.04.05.13.15.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 05 Apr 2018 13:15:58 -0700 (PDT)
Date: Thu, 5 Apr 2018 13:15:57 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: __GFP_LOW
Message-ID: <20180405201557.GA3666@bombadil.infradead.org>
References: <20180404142329.GI6312@dhcp22.suse.cz>
 <20180404114730.65118279@gandalf.local.home>
 <20180405025841.GA9301@bombadil.infradead.org>
 <CAJWu+oqP64QzvPM6iHtzowek6s4p+3rb7WDXs1z51mwW-9mLbA@mail.gmail.com>
 <20180405142258.GA28128@bombadil.infradead.org>
 <20180405142749.GL6312@dhcp22.suse.cz>
 <20180405151359.GB28128@bombadil.infradead.org>
 <20180405153240.GO6312@dhcp22.suse.cz>
 <20180405161501.GD28128@bombadil.infradead.org>
 <20180405185444.GQ6312@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405185444.GQ6312@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Thu, Apr 05, 2018 at 08:54:44PM +0200, Michal Hocko wrote:
> On Thu 05-04-18 09:15:01, Matthew Wilcox wrote:
> > > well, hardcoded GFP_KERNEL from vmalloc guts is yet another, ehm,
> > > herritage that you are not so proud of.
> > 
> > Certainly not, but that's not what I'm concerned about; I'm concerned
> > about the allocation of the pages, not the allocation of the array
> > containing the page pointers.
> 
> Those pages will use the gfp flag you give to vmalloc IIRC. It is page
> tables that are GFP_KERNEL unconditionally.

Right.  But if I call vmalloc(1UL << 40, GFP_KERNEL) on a machine with
only half a terabyte of RAM, it will OOM in the exact same way that
Steven is reporting.

> > > > We could also have a GFP flag that says to only succeed if we're further
> > > > above the existing watermark than normal.  __GFP_LOW (==ALLOC_LOW),
> > > > if you like.  That would give us the desired behaviour of trying all of
> > > > the reclaim methods that GFP_KERNEL would, but not being able to exhaust
> > > > all the memory that GFP_KERNEL allocations would take.
> > > 
> > > Well, I would be really careful with yet another gfp mask. They are so
> > > incredibly hard to define properly and then people kinda tend to screw
> > > your best intentions with their usecases ;)
> > > Failing on low wmark is very close to __GFP_NORETRY or even
> > > __GFP_NOWAIT, btw. So let's try to not overthink this...
> > 
> > Oh, indeed.  We must be able to clearly communicate to users when they
> > should use this flag.  I have in mind something like this:
> > 
> >  * __GFP_HIGH indicates that the caller is high-priority and that granting
> >  *   the request is necessary before the system can make forward progress.
> >  *   For example, creating an IO context to clean pages.
> >  *
> >  * __GFP_LOW indicates that the caller is low-priority and that it should
> >  *   not be allocated pages that would cause the system to get into an
> >  *   out-of-memory situation.  For example, allocating multiple individual
> >  *   pages in order to satisfy a larger request.
> 
> So how exactly the low fits into GFP_NOWAIT, GFP_NORETRY and
> GFP_RETRY_MAFAIL? We _do_have several levels of how hard to try and we
> have users relying on that. And do not forget about costly vs.
> non-costly sizes.
> 
> That being said, we should not hijack this thread more and further
> enhancements should be discussed separatelly. I am all for making the
> whole allocation api less obscure but keep in mind that we have really
> hard historical restrictions.

Dropping the non-mm participants ...

>From a "user guide" perspective:

When allocating memory, you can choose:

 - What kind of memory to allocate (DMA, NORMAL, HIGHMEM)
 - Where to get the pages from
   - Local node only (THISNODE)
   - Only in compliance with cpuset policy (HARDWALL)
   - Spread the pages between zones (WRITE)
   - The movable zone (MOVABLE)
   - The reclaimable zone (RECLAIMABLE)
 - What you are willing to do if no free memory is available:
   - Nothing at all (NOWAIT)
   - Use my own time to free memory (DIRECT_RECLAIM)
     - But only try once (NORETRY)
     - Can call into filesystems (FS)
     - Can start I/O (IO)
     - Can sleep (!ATOMIC)
   - Steal time from other processes to free memory (KSWAPD_RECLAIM)
   - Kill other processes to get their memory (!RETRY_MAYFAIL)
   - All of the above, and wait forever (NOFAIL)
   - Take from emergency reserves (HIGH)
   - ... but not the last parts of the regular reserves (LOW)

How does that look as an overview?
