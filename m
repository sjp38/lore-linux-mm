Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AD78D6B007E
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 12:12:53 -0500 (EST)
Date: Fri, 18 Dec 2009 18:12:40 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
Message-ID: <20091218171240.GB1354@elte.hu>
References: <20091217085430.GG9804@basil.fritz.box>
 <20091217144551.GA6819@linux.vnet.ibm.com>
 <20091217175338.GL9804@basil.fritz.box>
 <20091217190804.GB6788@linux.vnet.ibm.com>
 <20091217195530.GM9804@basil.fritz.box>
 <alpine.DEB.2.00.0912171356020.4640@router.home>
 <1261080855.27920.807.camel@laptop>
 <alpine.DEB.2.00.0912171439380.4640@router.home>
 <20091218051754.GC417@elte.hu>
 <4B2BB52A.7050103@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B2BB52A.7050103@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andi Kleen <andi@firstfloor.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>


* Avi Kivity <avi@redhat.com> wrote:

> On 12/18/2009 07:17 AM, Ingo Molnar wrote:
> >
> >>It is not about naming. The accessors hide the locking mechanism for
> >>mmap_sem. Then you can change the locking in a central place.
> >>
> >>The locking may even become configurable later. Maybe an embedded solution
> >>will want the existing scheme but dual quad socket may want a distributed
> >>reference counter to avoid bouncing cachelines on faults.
> >Hiding the locking is pretty much the worst design decision one can make.
> >
> 
> It does allow incremental updates.  For example if we go with range locks, 
> the accessor turns into a range lock of the entire address space; users can 
> be converted one by one to use their true ranges in order of importance.

This has been brought up in favor of say the mmap_sem wrappers in the past 
(but also mentioned for other wrappers), but the supposed advantage never 
materialized.

In reality updating the locking usage is never a big issue - it's almost 
mechanic and the compiler is our friend if we want to change semantics. Hiding 
the true nature and the true dependencies of the code, hiding the type of the 
lock is a bigger issue.

We've been through this many times in the past within the kernel: many times 
when we hid some locking primitive within some clever wrapping scheme the 
quality of locking started to deteriorate. In most of the important cases we 
got rid of the indirection and went with an existing core kernel locking 
primitive which are all well known and have clear semantics and lead to more 
maintainable code.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
