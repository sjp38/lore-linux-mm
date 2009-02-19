Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4877A6B0047
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 14:12:12 -0500 (EST)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e37.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n1JJBoJO013384
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 12:11:50 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1JJBwRe220586
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 12:11:59 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1JJBvoP024034
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 12:11:58 -0700
Subject: Re: Banning checkpoint (was: Re: What can OpenVZ do?)
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20090219190637.GA4846@x200.localdomain>
References: <20090213105302.GC4608@elte.hu>
	 <1234817490.30155.287.camel@nimitz> <20090217222319.GA10546@elte.hu>
	 <1234909849.4816.9.camel@nimitz> <20090218003217.GB25856@elte.hu>
	 <1234917639.4816.12.camel@nimitz> <20090218051123.GA9367@x200.localdomain>
	 <20090218181644.GD19995@elte.hu> <1234992447.26788.12.camel@nimitz>
	 <20090218231545.GA17524@elte.hu>  <20090219190637.GA4846@x200.localdomain>
Content-Type: text/plain
Date: Thu, 19 Feb 2009 11:11:54 -0800
Message-Id: <1235070714.26788.56.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, Nathan Lynch <nathanl@austin.ibm.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, hpa@zytor.com, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, tglx@linutronix.de, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-02-19 at 22:06 +0300, Alexey Dobriyan wrote:
> Inotify isn't supported yet? You do
> 
>         if (!list_empty(&inode->inotify_watches))
>                 return -E;
> 
> without hooking into inotify syscalls.
> 
> ptrace(2) isn't supported -- look at struct task_struct::ptraced and
> friends.
> 
> And so on.
> 
> System call (or whatever) does something with some piece of kernel
> internals. We look at this "something" when walking data structures
> and
> abort if it's scary enough.
> 
> Please, show at least one counter-example.

Alexey, I agree with you here.  I've been fighting myself internally
about these two somewhat opposing approaches.  Of *course* we can
determine the "checkpointability" at sys_checkpoint() time by checking
all the various bits of state.

The problem that I think Ingo is trying to address here is that doing it
then makes it hard to figure out _when_ you went wrong.  That's the
single most critical piece of finding out how to go address it.

I see where you are coming from.  Ingo's suggestion has the *huge*
downside that we've got to go muck with a lot of generic code and hook
into all the things we don't support.

I think what I posted is a decent compromise.  It gets you those
warnings at runtime and is a one-way trip for any given process.  But,
it does detect in certain cases (fork() and unshare(FILES)) when it is
safe to make the trip back to the "I'm checkpointable" state again.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
