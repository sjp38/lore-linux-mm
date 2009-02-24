Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CEA796B005A
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 23:41:18 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so42409fgg.4
        for <linux-mm@kvack.org>; Mon, 23 Feb 2009 20:41:15 -0800 (PST)
Date: Tue, 24 Feb 2009 07:47:52 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: Banning checkpoint (was: Re: What can OpenVZ do?)
Message-ID: <20090224044752.GB3202@x200.localdomain>
References: <20090217222319.GA10546@elte.hu> <1234909849.4816.9.camel@nimitz> <20090218003217.GB25856@elte.hu> <1234917639.4816.12.camel@nimitz> <20090218051123.GA9367@x200.localdomain> <20090218181644.GD19995@elte.hu> <1234992447.26788.12.camel@nimitz> <20090218231545.GA17524@elte.hu> <20090219190637.GA4846@x200.localdomain> <1235070714.26788.56.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1235070714.26788.56.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Nathan Lynch <nathanl@austin.ibm.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, hpa@zytor.com, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, tglx@linutronix.de, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 19, 2009 at 11:11:54AM -0800, Dave Hansen wrote:
> On Thu, 2009-02-19 at 22:06 +0300, Alexey Dobriyan wrote:
> > Inotify isn't supported yet? You do
> > 
> >         if (!list_empty(&inode->inotify_watches))
> >                 return -E;
> > 
> > without hooking into inotify syscalls.
> > 
> > ptrace(2) isn't supported -- look at struct task_struct::ptraced and
> > friends.
> > 
> > And so on.
> > 
> > System call (or whatever) does something with some piece of kernel
> > internals. We look at this "something" when walking data structures
> > and
> > abort if it's scary enough.
> > 
> > Please, show at least one counter-example.
> 
> Alexey, I agree with you here.  I've been fighting myself internally
> about these two somewhat opposing approaches.  Of *course* we can
> determine the "checkpointability" at sys_checkpoint() time by checking
> all the various bits of state.
> 
> The problem that I think Ingo is trying to address here is that doing it
> then makes it hard to figure out _when_ you went wrong.  That's the
> single most critical piece of finding out how to go address it.
> 
> I see where you are coming from.  Ingo's suggestion has the *huge*
> downside that we've got to go muck with a lot of generic code and hook
> into all the things we don't support.
> 
> I think what I posted is a decent compromise.  It gets you those
> warnings at runtime and is a one-way trip for any given process.  But,
> it does detect in certain cases (fork() and unshare(FILES)) when it is
> safe to make the trip back to the "I'm checkpointable" state again.

"Checkpointable" is not even per-process property.

Imagine, set of SAs (struct xfrm_state) and SPDs (struct xfrm_policy).
They are a) per-netns, b) persistent.

You can hook into socketcalls to mark process as uncheckpointable,
but since SAs and SPDs are persistent, original process already exited.
You're going to walk every process with same netns as SA adder and mark
it as uncheckpointable. Definitely doable, but ugly, isn't it?

Same for iptable rules.

"Checkpointable" is container property, OK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
