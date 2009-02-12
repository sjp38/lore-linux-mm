Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 41FCF6B004F
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 15:48:45 -0500 (EST)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n1CKkSrJ018238
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 13:46:28 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1CKmg17206736
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 13:48:42 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1CKmgB6007302
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 13:48:42 -0700
Date: Thu, 12 Feb 2009 14:48:42 -0600
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC v13][PATCH 00/14] Kernel based checkpoint/restart
Message-ID: <20090212204842.GA16269@us.ibm.com>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu> <1234285547.30155.6.camel@nimitz> <20090211141434.dfa1d079.akpm@linux-foundation.org> <20090212091721.GB1888@elte.hu> <1234462283.30155.173.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1234462283.30155.173.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-api@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

Quoting Dave Hansen (dave@linux.vnet.ibm.com):
> Patch 12/14 is supposed to address this *concept*.  But, it hasn't been
> carried through so that it currently works.  My expectation was that we
> would go through and add things over time.  I'll go make sure I push it
> to the point that it actually works for at least the simple test
> programs that we have.
> 
> What I will probably do is something BKL-style.  Basically put a "this
> can't be checkpointed" marker over most everything I can think of and
> selectively remove it as we add features.  

So the question is: when can we unset the uncheckpointable flag?

In your patch you suggest clone(CLONE_NEWPID).  But that would
require that we at that point do a slew of checks for other
things like open files of a type which are not supported.

I'm wondering whether we should instead stick to calculating
whether a task is checkpointable or not at checkpoint time.
To help an application figure out whether it can be checkpointed,
we can hook /proc/$$/checkpointable to the same function, and
have the file output list all of the reasons the task is not
checkpointable.  i.e.

	mmap MAP_SHARED file which is not yet supported
	open file from another mounts namespace
	open TCP socket which is not yet supported
	open epoll fd which is not yet supported
	TASK NOT FROZEN

So now every time we do a checkpoint we have to do all these
checks, but that's better than at clone time.

You suggested on irc having a fops->is_checkpointable()
fn, which is imo a good idea to help implement the above.
The default value can be a fn returning false.  I suppose
we want to pass back a char* with the file type as well.

-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
