Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 27FA76B006E
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 07:56:12 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id b13so3428175wgh.34
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 04:56:11 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.194])
        by mx.google.com with ESMTP id k1si1562516wiz.26.2014.10.22.04.56.10
        for <linux-mm@kvack.org>;
        Wed, 22 Oct 2014 04:56:10 -0700 (PDT)
Date: Wed, 22 Oct 2014 14:55:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC][PATCH 0/6] Another go at speculative page faults
Message-ID: <20141022115540.GB31486@node.dhcp.inet.fi>
References: <20141020215633.717315139@infradead.org>
 <1413963289.26628.3.camel@linux-t7sj.site>
 <20141022112925.GH30588@node.dhcp.inet.fi>
 <20141022114558.GC21513@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141022114558.GC21513@worktop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Davidlohr Bueso <dave@stgolabs.net>, torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, laijs@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 22, 2014 at 01:45:58PM +0200, Peter Zijlstra wrote:
> On Wed, Oct 22, 2014 at 02:29:25PM +0300, Kirill A. Shutemov wrote:
> > On Wed, Oct 22, 2014 at 12:34:49AM -0700, Davidlohr Bueso wrote:
> > > On Mon, 2014-10-20 at 23:56 +0200, Peter Zijlstra wrote:
> > > > Hi,
> > > > 
> > > > I figured I'd give my 2010 speculative fault series another spin:
> > > > 
> > > >   https://lkml.org/lkml/2010/1/4/257
> > > > 
> > > > Since then I think many of the outstanding issues have changed sufficiently to
> > > > warrant another go. In particular Al Viro's delayed fput seems to have made it
> > > > entirely 'normal' to delay fput(). Lai Jiangshan's SRCU rewrite provided us
> > > > with call_srcu() and my preemptible mmu_gather removed the TLB flushes from
> > > > under the PTL.
> > > > 
> > > > The code needs way more attention but builds a kernel and runs the
> > > > micro-benchmark so I figured I'd post it before sinking more time into it.
> > > > 
> > > > I realize the micro-bench is about as good as it gets for this series and not
> > > > very realistic otherwise, but I think it does show the potential benefit the
> > > > approach has.
> > > > 
> > > > (patches go against .18-rc1+)
> > > 
> > > I think patch 2/6 is borken:
> > > 
> > > error: patch failed: mm/memory.c:2025
> > > error: mm/memory.c: patch does not apply
> > > 
> > > and related, as you mention, I would very much welcome having the
> > > introduction of 'struct faut_env' as a separate cleanup patch. May I
> > > suggest renaming it to fault_cxt?
> > 
> > What about extend start using 'struct vm_fault' earlier by stack?
> 
> I'm not sure we should mix the environment for vm_ops::fault, which
> acquires the page, and the fault path, which deals with changing the
> PTE. Ideally we should not expose the page-table information to file
> ops, its a layering violating if nothing else, drivers should not have
> access to the page tables.

We already have this for ->map_pages() :-P
I have asked if it's considered layering violation and seems nobody
cares...

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
