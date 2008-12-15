Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 15 Dec 2008 15:16:47 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] SLQB slab allocator
Message-ID: <20081215141647.GC30163@wotan.suse.de>
References: <20081212002518.GH8294@wotan.suse.de> <Pine.LNX.4.64.0812122013390.15781@quilx.com> <20081214230407.GB7318@wotan.suse.de> <Pine.LNX.4.64.0812150758020.16821@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0812150758020.16821@quilx.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, bcrl@kvack.org, list-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 15, 2008 at 08:02:47AM -0600, Christoph Lameter wrote:
> On Mon, 15 Dec 2008, Nick Piggin wrote:
> 
> > > Does this mean that SLQB is less efficient than SLUB for off node
> > > allocations? SLUB can do off node allocations from the per cpu objects. It
> > > does not need to make the distinction for allocation.
> >
> > I haven't measured them, but that could be the case. However I haven't
> > found a workload that does a lot of off-node allocations (short lived
> > allocations are better on-node, and long lived ones are not going to
> > be so numerous).
> 
> A memoryless node is a case where all allocations will be like that.

Yes. Can the memoryless node revert to a default (closest) memory node?

 
> > That's more complexity, though. Given that objects are often hot when
> > they are freed, and need to be touched after they are allocated anyway,
> > the simple queue seems to be reasonable.
> 
> Yup.
> 
> > This case does improve the database score by around 1.5-2%, yes. I
> > don't know what you mean exactly, though. What case, and what do you
> > mean by bad cache unfriendly programming? I would be very interested
> > in improving that benchmark of course, but I don't know what you
> > suggest by keeping cachelines hot in the right way?
> 
> What I was told about the database test is that it collects lists of
> objects from various processors that are then freed on a different
> processor. This means all objects are cache cold.

Well it's running an unmodified kernel... the database itself I guess
is just submitting direct-IO requests from multiple processes to
multiple disks. The objects should be pretty warm on the freeing CPU,
but yes it would take a cacheline transfer at some level I guess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
