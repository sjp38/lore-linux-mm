Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 261FB6B00B9
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 10:52:32 -0500 (EST)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e5.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n1OFnc7G012670
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 10:49:38 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n1OFqRLM2859028
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 10:52:28 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1OFqE47023106
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 08:52:15 -0700
Date: Tue, 24 Feb 2009 09:43:51 -0600
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: Banning checkpoint (was: Re: What can OpenVZ do?)
Message-ID: <20090224154351.GD17294@us.ibm.com>
References: <20090218003217.GB25856@elte.hu> <1234917639.4816.12.camel@nimitz> <20090218051123.GA9367@x200.localdomain> <20090218181644.GD19995@elte.hu> <1234992447.26788.12.camel@nimitz> <20090218231545.GA17524@elte.hu> <20090219190637.GA4846@x200.localdomain> <1235070714.26788.56.camel@nimitz> <20090224044752.GB3202@x200.localdomain> <1235452285.26788.226.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1235452285.26788.226.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, hpa@zytor.com, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, Nathan Lynch <nathanl@austin.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, viro@zeniv.linux.org.uk, mpm@selenic.com, Ingo Molnar <mingo@elte.hu>, torvalds@linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Quoting Dave Hansen (dave@linux.vnet.ibm.com):
> On Tue, 2009-02-24 at 07:47 +0300, Alexey Dobriyan wrote:
> > > I think what I posted is a decent compromise.  It gets you those
> > > warnings at runtime and is a one-way trip for any given process.  But,
> > > it does detect in certain cases (fork() and unshare(FILES)) when it is
> > > safe to make the trip back to the "I'm checkpointable" state again.
> > 
> > "Checkpointable" is not even per-process property.
> > 
> > Imagine, set of SAs (struct xfrm_state) and SPDs (struct xfrm_policy).
> > They are a) per-netns, b) persistent.
> > 
> > You can hook into socketcalls to mark process as uncheckpointable,
> > but since SAs and SPDs are persistent, original process already exited.
> > You're going to walk every process with same netns as SA adder and mark
> > it as uncheckpointable. Definitely doable, but ugly, isn't it?
> > 
> > Same for iptable rules.
> > 
> > "Checkpointable" is container property, OK?
> 
> Ideally, I completely agree.
> 
> But, we don't currently have a concept of a true container in the
> kernel.  Do you have any suggestions for any current objects that we
> could use in its place for a while?

I think the main point is that it makes the concept of marking a task as
uncheckpointable unworkable.  So at sys_checkpoint() time or when we cat
/proc/$$/checkpointable, we can check for all of the uncheckpointable
state of both $$ and its container (including whether $$ is a container
init).  But we can't expect that (to use Alexey's example) when one task
in a netns does a certain sys_socketcall, all tasks in the container
will be marked uncheckpointable.  Or at least we don't want to.

Which means task->uncheckpointable can't be the big stick which I think
you were hoping it would be.

-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
