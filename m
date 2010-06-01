Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2159F6B01E3
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 12:31:09 -0400 (EDT)
Date: Wed, 2 Jun 2010 02:31:03 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] forked kernel task and mm structures imbalanced on NUMA
Message-ID: <20100601163103.GB9453@laptop>
References: <20100601073343.GQ9453@laptop>
 <87wruiycsl.fsf@basil.nowhere.org>
 <20100601155943.GA9453@laptop>
 <20100601162024.GC30556@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100601162024.GC30556@basil.fritz.box>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 01, 2010 at 06:20:25PM +0200, Andi Kleen wrote:
> On Wed, Jun 02, 2010 at 01:59:43AM +1000, Nick Piggin wrote:
> > On Tue, Jun 01, 2010 at 05:48:10PM +0200, Andi Kleen wrote:
> > > Nick Piggin <npiggin@suse.de> writes:
> > > 
> > > > This isn't really a new problem, and I don't know how important it is,
> > > > but I recently came across it again when doing some aim7 testing with
> > > > huge numbers of tasks.
> > > 
> > > Seems reasonable. Of course you need to at least 
> > > save/restore the old CPU policy, and use a subset of it.
> > 
> > The mpolicy? My patch does that (mpol_prefer_cpu_start/end). The real
> > problem is that it can actually violate the parent's mempolicy. For
> > example MPOL_BIND and cpus_allowed set on a node outside the mempolicy.
> 
> I don't see where you store 'old', but maybe I missed it.

It's the argument returned by mpol_prefer_cpu_start. Yes this also
opens races for lost-write when we have concurrent mpol changes. So
I'm not claiming the code is right.

 
> > > slightly more difficult. The advantage would be that on multiple
> > > migrations it would follow. And it would be a bit slower for
> > > the initial case.
> > 
> > Migrate what on touch? Talking mainly about kernel memory structures,
> > task_struct, mm, vmas, page tables, kernel stack, etc.
> 
> Migrate task_struct, mm, vmas, page tables, kernel stack
> on reasonable touch. As long as they are not shared it shouldn't
> be too difficult.

Possible but that's a lot further off (considering we don't even migrate
user memory) and is complimentary to this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
