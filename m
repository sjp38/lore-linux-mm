Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A6D7E6B004D
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 11:00:10 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n6NEoA25021365
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 08:50:10 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6NEsdxA124794
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 08:54:44 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6NEsc9R004563
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 08:54:39 -0600
Date: Thu, 23 Jul 2009 09:54:38 -0500
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC v17][PATCH 22/60] c/r: external checkpoint of a task
	other than ourself
Message-ID: <20090723145438.GA12945@us.ibm.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com> <1248256822-23416-23-git-send-email-orenl@librato.com> <20090722175223.GA19389@us.ibm.com> <4A67E7D7.9060800@librato.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A67E7D7.9060800@librato.com>
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@librato.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Quoting Oren Laadan (orenl@librato.com):
> 
> 
> Serge E. Hallyn wrote:
> > Quoting Oren Laadan (orenl@librato.com):
> >> Now we can do "external" checkpoint, i.e. act on another task.
> > 
> > ...
> > 
> >>  long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
> >>  {
> >>  	long ret;
> >>
> >> +	ret = init_checkpoint_ctx(ctx, pid);
> >> +	if (ret < 0)
> >> +		return ret;
> >> +
> >> +	if (ctx->root_freezer) {
> >> +		ret = cgroup_freezer_begin_checkpoint(ctx->root_freezer);
> >> +		if (ret < 0)
> >> +			return ret;
> >> +	}
> > 
> > Self-checkpoint of a task in root freezer is now denied, though.
> > 
> > Was that intentional?
> 
> Yes.
> 
> "root freezer" is an arbitrary task in the checkpoint subtree or
> container. It is used to verify that all checkpointed tasks - except
> for current, if doing self-checkpoint - belong to the same freezer
> group.
> 
> Since current is busy calling checkpoint(2), and since we only permit
> checkpoint of (cgroup-) frozen tasks, then - by definition - it cannot
> possibly belong to the same group. If it did, it would itself be frozen
> like its fellows and unable to call checkpoint(2).
> 
> Oren.

Ok, well I don't know what was happening yesterday.  Today it's
restart that is failing, and as you pointed out on irc that's
on s390 only.  I'll send out a patch this afternoon to fix that.

Yesterday I must not have read the output right I guess...

thanks,
-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
