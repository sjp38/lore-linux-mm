Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e33.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mB1I0GZt024068
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 11:00:16 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB1I0WIe052224
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 11:00:32 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB1I0HMK031742
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 11:00:20 -0700
Subject: Re: [RFC v10][PATCH 05/13] Dump memory address space
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20081128105351.GQ28946@ZenIV.linux.org.uk>
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>
	 <1227747884-14150-6-git-send-email-orenl@cs.columbia.edu>
	 <20081128105351.GQ28946@ZenIV.linux.org.uk>
Content-Type: text/plain
Date: Mon, 01 Dec 2008 10:00:12 -0800
Message-Id: <1228154412.2971.44.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-11-28 at 10:53 +0000, Al Viro wrote:
> 
> > +static int cr_ctx_checkpoint(struct cr_ctx *ctx, pid_t pid)
> > +{
> > +     ctx->root_pid = pid;
> > +
> > +     /*
> > +      * assume checkpointer is in container's root vfs
> > +      * FIXME: this works for now, but will change with real containers
> > +      */
> > +     ctx->vfsroot = &current->fs->root;
> > +     path_get(ctx->vfsroot);
> 
> This is going to break as soon as you get another thread doing e.g. chroot(2)
> while you are in there.

Yeah, we do need at least a read_lock(&current->fs->lock) to keep people
from chroot()'ing underneath us.

> And it's a really, _really_ bad idea to take a
> pointer to shared object, increment refcount on the current *contents* of
> said object and assume that dropping refcount on the later contents of the
> same will balance out.

Absolutely.  I assume you mean get_fs_struct(current) instead of
path_get().

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
