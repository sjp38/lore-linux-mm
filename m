Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 115946B01E0
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 11:59:49 -0400 (EDT)
Date: Wed, 2 Jun 2010 01:59:43 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] forked kernel task and mm structures imbalanced on NUMA
Message-ID: <20100601155943.GA9453@laptop>
References: <20100601073343.GQ9453@laptop>
 <87wruiycsl.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87wruiycsl.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lee@firstfloor.org, Schermerh@firstfloor.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 01, 2010 at 05:48:10PM +0200, Andi Kleen wrote:
> Nick Piggin <npiggin@suse.de> writes:
> 
> > This isn't really a new problem, and I don't know how important it is,
> > but I recently came across it again when doing some aim7 testing with
> > huge numbers of tasks.
> 
> Seems reasonable. Of course you need to at least 
> save/restore the old CPU policy, and use a subset of it.

The mpolicy? My patch does that (mpol_prefer_cpu_start/end). The real
problem is that it can actually violate the parent's mempolicy. For
example MPOL_BIND and cpus_allowed set on a node outside the mempolicy.

What is needed is to execute with the existing mempolicy, but from
the point of view of the destination CPU. A bit more work on the
mpol code is required, but this is good enough for basic tests.
 

> Another approach would be to migrate this on touch, but that is probably
> slightly more difficult. The advantage would be that on multiple
> migrations it would follow. And it would be a bit slower for
> the initial case.

Migrate what on touch? Talking mainly about kernel memory structures,
task_struct, mm, vmas, page tables, kernel stack, etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
