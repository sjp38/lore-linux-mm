Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 383446B003D
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 14:47:40 -0500 (EST)
Date: Thu, 19 Feb 2009 20:48:51 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/7] slab: introduce kzfree()
Message-ID: <20090219194851.GA2608@cmpxchg.org>
References: <499BE7F8.80901@csr.com> <1234954488.24030.46.camel@penberg-laptop> <20090219101336.9556.A69D9226@jp.fujitsu.com> <1235034817.29813.6.camel@penberg-laptop> <Pine.LNX.4.64.0902191616250.8594@blonde.anvils> <1235066556.3166.26.camel@calx> <Pine.LNX.4.64.0902191819060.28475@blonde.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0902191819060.28475@blonde.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Vrabel <david.vrabel@csr.com>, Andrew Morton <akpm@linux-foundation.org>, Chas Williams <chas@cmf.nrl.navy.mil>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 19, 2009 at 06:28:55PM +0000, Hugh Dickins wrote:
> On Thu, 19 Feb 2009, Matt Mackall wrote:
> > On Thu, 2009-02-19 at 16:34 +0000, Hugh Dickins wrote:
> > > On Thu, 19 Feb 2009, Pekka Enberg wrote:
> > > > On Thu, 2009-02-19 at 10:22 +0900, KOSAKI Motohiro wrote:
> > > > > 
> > > > > poisonig is transparent feature from caller.
> > > > > but the caller of kzfree() know to fill memory and it should know.
> > > > 
> > > > Debatable, sure, but doesn't seem like a big enough reason to make
> > > > kzfree() differ from kfree().
> > > 
> > > There may be more important things for us to worry about,
> > > but I do strongly agree with KOSAKI-san on this.
> > > 
> > > kzfree() already differs from kfree() by a "z": that "z" says please
> > > zero the buffer pointed to; "const" says it won't modify the buffer
> > > pointed to.  What sense does kzfree(const void *) make?  Why is
> > > keeping the declarations the same apart from the "z" desirable?
> > > 
> > > By all means refuse to add kzfree(), but please don't add it with const.
> > > 
> > > I can see that the "const" in kfree(const void *) is debatable
> > > [looks to see how userspace free() is defined: without a const],
> > > I can see that it might be nice to have some "goesaway" attribute
> > > for such pointers instead; but I don't see how you can argue for
> > > kzalloc(const void *).
>     ^^^^^^^^^^^^^^^^^^^^^
> (Of course I meant to say "kzfree(const void *)" there.)
> 
> > 
> > This is what Linus said last time this came up:
> > 
> > http://lkml.org/lkml/2008/1/16/227
> 
> Thanks for that, I remember it now.
> 
> Okay, that's some justification for kfree(const void *).
> 
> But I fail to see it as a justification for kzfree(const void *):
> if someone has "const char *string = kmalloc(size)" and then
> wants that string zeroed before it is freed, then I think it's
> quite right to cast out the const when calling kzfree().

You could argue that the pointer passed to kzfree() points to an
abstract slab object and kzfree() uses this to find the memory of that
object which it then zeroes.  The translation of course is a no-op as
the object pointer and the memory pointer coincide.

It depends on how transparent you want to make kzfree() for the
caller.  Is it 'zero out and then free the object' or is it 'free the
object, but note that it contains security-sensitive data, so make
sure that it never gets into the hands of somebody else'?

No strong opinion from me, though, I can not say which one feels
better.  I made it intuitively const, so I guess I would lean to the
more opaque version of the function.

> Hugh

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
