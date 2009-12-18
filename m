Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C60316B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 13:13:07 -0500 (EST)
Date: Fri, 18 Dec 2009 12:12:43 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
In-Reply-To: <20091218171240.GB1354@elte.hu>
Message-ID: <alpine.DEB.2.00.0912181207010.26947@router.home>
References: <20091217085430.GG9804@basil.fritz.box> <20091217144551.GA6819@linux.vnet.ibm.com> <20091217175338.GL9804@basil.fritz.box> <20091217190804.GB6788@linux.vnet.ibm.com> <20091217195530.GM9804@basil.fritz.box> <alpine.DEB.2.00.0912171356020.4640@router.home>
 <1261080855.27920.807.camel@laptop> <alpine.DEB.2.00.0912171439380.4640@router.home> <20091218051754.GC417@elte.hu> <4B2BB52A.7050103@redhat.com> <20091218171240.GB1354@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Avi Kivity <avi@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andi Kleen <andi@firstfloor.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 18 Dec 2009, Ingo Molnar wrote:

> In reality updating the locking usage is never a big issue - it's almost
> mechanic and the compiler is our friend if we want to change semantics. Hiding
> the true nature and the true dependencies of the code, hiding the type of the
> lock is a bigger issue.

Which is exactly what the RT tree does with spinlocks by turning them into
mutexes. Spinlocks and the various derivates are very similar to what is
done here.

> We've been through this many times in the past within the kernel: many times
> when we hid some locking primitive within some clever wrapping scheme the
> quality of locking started to deteriorate. In most of the important cases we
> got rid of the indirection and went with an existing core kernel locking
> primitive which are all well known and have clear semantics and lead to more
> maintainable code.

The existing locking APIs are all hiding lock details at various levels.
We have various specific APIs for specialized locks already Page locking
etc.

How can we make progress on this if we cannot look at the mmap_sem
semantics in one place and then come up with viable replacements? mmap_sem
is used all over the place and having one place for the accessors allows
us to clarify lock semantics and tie loose things down. There are similar
RW semantics in various other places. This could result in another type of
RW lock that will ultimately allow us to move beyond the rw sem problems
of today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
