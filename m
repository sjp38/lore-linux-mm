Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B4D876B0093
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 17:12:30 -0500 (EST)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mBGMCTBs028863
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 15:12:29 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mBGME8tD209928
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 15:14:08 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mBGME7tw004190
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 15:14:08 -0700
Subject: Re: [RFC v11][PATCH 03/13] General infrastructure for checkpoint
	restart
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <49482394.10006@google.com>
References: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu>
	 <1228498282-11804-4-git-send-email-orenl@cs.columbia.edu>
	 <49482394.10006@google.com>
Content-Type: text/plain
Date: Tue, 16 Dec 2008 14:14:01 -0800
Message-Id: <1229465641.17206.350.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mike Waychison <mikew@google.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, jeremy@goop.org, arnd@arndb.de, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linux Torvalds <torvalds@osdl.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-12-16 at 13:54 -0800, Mike Waychison wrote:
> Oren Laadan wrote:
> > diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> > index 375129c..bd14ef9 100644
> > --- a/checkpoint/sys.c
> > +++ b/checkpoint/sys.c
> 
> > +/*
> > + * During checkpoint and restart the code writes outs/reads in data
> > + * to/from the checkpoint image from/to a temporary buffer (ctx->hbuf).
> > + * Because operations can be nested, use cr_hbuf_get() to reserve space
> > + * in the buffer, then cr_hbuf_put() when you no longer need that space.
> > + */
> 
> This seems a bit over-kill for buffer management no?  The only large 
> header seems to be cr_hdr_head and the blowup comes from utsinfo string 
> data (which could easily be moved out to be in it's own CR_HDR_STRING 
> blocks).
> 
> Wouldn't it be easier to use stack-local storage than balancing the 
> cr_hbuf_get/put routines?

I've asked the same question, so I'll give you Oren's response that I
remember:

cr_hbuf_get/put() are more of an API that we can use later.  For now,
those buffers really are temporary.  But, in a case where we want to do
a really fast checkpoint (to reduce "downtime" during the checkpoint) we
store the image entirely in kernel memory to be written out later.

In that case, cr_hbuf_put() stops doing anything at all because we keep
the memory around.

cr_hbuf_get() becomes, "I need some memory to write some checkpointy
things into".

cr_hbuf_put() becomes, "I'm done with this for now, only keep it if
someone else needs it."

This might all be a lot clearer if we just kept some more explicit
accounting around about who is using the objects.  Something like:

struct cr_buf {
	struct kref ref;
	int size;
	char buf[0];
};

/* replaces cr_hbuf_get() */
struct cr_buf *alloc_cr_buf(int size, gfp_t flags)
{
	struct cr_buf *buf;

	buf = kmalloc(sizeof(cr_buf) + size, flags);
	if (!buf)
		return NULL;
	buf->ref = 1; /* or whatever */
	buf->size = size;
	return buf;
}

int cr_kwrite(struct cr_buf *buf)
{
	if (writing_checkpoint_now) {
		// or whatever this write call was...
		vfs_write(&buf->buf[0], buf->size);
	} else if (deferring_write) {		
		kref_get(buf->kref);
	}
}

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
