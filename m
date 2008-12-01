Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mB1IF1CW020474
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 11:15:01 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB1IFe1x082786
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 11:15:40 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB1IFamR001570
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 11:15:40 -0700
Subject: Re: [RFC v10][PATCH 02/13] Checkpoint/restart: initial
	documentation
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20081128104554.GP28946@ZenIV.linux.org.uk>
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>
	 <1227747884-14150-3-git-send-email-orenl@cs.columbia.edu>
	 <20081128104554.GP28946@ZenIV.linux.org.uk>
Content-Type: text/plain
Date: Mon, 01 Dec 2008 10:15:32 -0800
Message-Id: <1228155332.2971.60.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Oren Laadan <orenl@cs.columbia.edu>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-11-28 at 10:45 +0000, Al Viro wrote:
> On Wed, Nov 26, 2008 at 08:04:33PM -0500, Oren Laadan wrote:
> > +Currently, namespaces are not saved or restored. They will be treated
> > +as a class of a shared object. In particular, it is assumed that the
> > +task's file system namespace is the "root" for the entire container.
> > +It is also assumed that the same file system view is available for the
> > +restart task(s). Otherwise, a file system snapshot is required.
> 
> That is to say, bindings are not handled at all.

Sadly, no.  I'm trying to convince Oren that this is important, but I've
been unable to do so thus far.  I'd appreciate any particularly
pathological cases you can think of.

There are two cases here that worry me.  One is the case where we're
checkpointing a container that has been off in its own mount namespace
doing bind mounts to its little heart's content.  We want to checkpoint
and restore the sucker on the same machine.  In this case, we almost
certainly want the kernel to be doing the restoration of the binds.

The other case is when we're checkpointing, and moving to a completely
different machine.  The new machine may have a completely different disk
layout and *need* the admin doing the sys_restore() to set up those
binds differently because of space constraints or whatever.

For now, we're completely assuming the second case, where the admin
(userspace) is responsible for it, and punting.  Do you think this is
something we should take care of now, early in the process?

> > +* What additional work needs to be done to it?
> 
> > +We know this design can work.  We have two commercial products and a
> > +horde of academic projects doing it today using this basic design.
> 
> May I use that for a t-shirt, please?  With that quote in foreground, and
> pus-yellow-greenish "MACH" serving as background.  With the names of products
> and projects dripping from it...

*Functionally* we know this design can work.  Practically, in Linux, I
have no freaking idea.  The hard part isn't getting it working, of
course.  The hard part is getting something that doesn't step on top of
everyone else's toes in the kernel and, at the same time, is actually
*maintainable*.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
