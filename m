Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 262086B009C
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 16:46:43 -0500 (EST)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id nAOLkdpP028376
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:46:39 -0800
Received: from pxi40 (pxi40.prod.google.com [10.243.27.40])
	by wpaz24.hot.corp.google.com with ESMTP id nAOLkVHc022741
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:46:36 -0800
Received: by pxi40 with SMTP id 40so4736343pxi.13
        for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:46:36 -0800 (PST)
Date: Tue, 24 Nov 2009 13:46:34 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: lockdep complaints in slab allocator
In-Reply-To: <1259098552.4531.1857.camel@laptop>
Message-ID: <alpine.DEB.2.00.0911241336550.12339@chino.kir.corp.google.com>
References: <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com> <1258709153.11284.429.camel@laptop> <84144f020911200238w3d3ecb38k92ca595beee31de5@mail.gmail.com> <1258714328.11284.522.camel@laptop> <4B067816.6070304@cs.helsinki.fi>
 <1258729748.4104.223.camel@laptop> <1259002800.5630.1.camel@penberg-laptop> <1259003425.17871.328.camel@calx> <4B0ADEF5.9040001@cs.helsinki.fi> <1259080406.4531.1645.camel@laptop> <20091124170032.GC6831@linux.vnet.ibm.com> <1259082756.17871.607.camel@calx>
 <1259086459.4531.1752.camel@laptop> <1259090615.17871.696.camel@calx>  <1259095580.4531.1788.camel@laptop> <1259096004.17871.716.camel@calx> <1259096519.4531.1809.camel@laptop> <alpine.DEB.2.00.0911241302370.6593@chino.kir.corp.google.com>
 <1259097150.4531.1822.camel@laptop> <alpine.DEB.2.00.0911241313220.12339@chino.kir.corp.google.com> <1259098552.4531.1857.camel@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Matt Mackall <mpm@selenic.com>, paulmck@linux.vnet.ibm.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Nov 2009, Peter Zijlstra wrote:

> We should cull something, just merging more and more of them is useless
> and wastes everybody's time since you have to add features and
> interfaces to all of them.
> 

I agree, but it's difficult to get widespread testing or development 
interest in an allocator that is sitting outside of mainline.  I don't 
think any allocator could suddenly be merged as the kernel default, it 
seems like a prerequisite to go through the preliminary merging and 
development.  The severe netperf TCP_RR regression that slub has compared 
to slab was never found before it became the default allocator, otherwise 
there would probably have been more effort into its development as well.  
Unfortunately, slub's design is such that it will probably never be able 
to nullify the partial slab thrashing enough, even with the percpu counter 
speedup that is now available because of Christoph's work, to make TCP_RR 
perform as well as slab.

> Then maybe we should toss SLUB? But then there's people who say SLUB is
> better for them. Without forcing something to happen we'll be stuck with
> multiple allocators forever.
> 

Slub is definitely superior in diagnostics and is a much simpler design 
than slab.  I think it would be much easier to remove slub than slab, 
though, simply because there are no great slab performance degradations 
compared to slub.  I think the best candidate for removal might be slob, 
however, because it hasn't been compared to slub and usage may not be as 
widespread as expected for such a special case allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
