Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 955166B003D
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 13:30:16 -0500 (EST)
Date: Thu, 19 Feb 2009 18:28:55 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 1/7] slab: introduce kzfree()
In-Reply-To: <1235066556.3166.26.camel@calx>
Message-ID: <Pine.LNX.4.64.0902191819060.28475@blonde.anvils>
References: <499BE7F8.80901@csr.com>  <1234954488.24030.46.camel@penberg-laptop>
  <20090219101336.9556.A69D9226@jp.fujitsu.com>  <1235034817.29813.6.camel@penberg-laptop>
  <Pine.LNX.4.64.0902191616250.8594@blonde.anvils> <1235066556.3166.26.camel@calx>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Vrabel <david.vrabel@csr.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Chas Williams <chas@cmf.nrl.navy.mil>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Feb 2009, Matt Mackall wrote:
> On Thu, 2009-02-19 at 16:34 +0000, Hugh Dickins wrote:
> > On Thu, 19 Feb 2009, Pekka Enberg wrote:
> > > On Thu, 2009-02-19 at 10:22 +0900, KOSAKI Motohiro wrote:
> > > > 
> > > > poisonig is transparent feature from caller.
> > > > but the caller of kzfree() know to fill memory and it should know.
> > > 
> > > Debatable, sure, but doesn't seem like a big enough reason to make
> > > kzfree() differ from kfree().
> > 
> > There may be more important things for us to worry about,
> > but I do strongly agree with KOSAKI-san on this.
> > 
> > kzfree() already differs from kfree() by a "z": that "z" says please
> > zero the buffer pointed to; "const" says it won't modify the buffer
> > pointed to.  What sense does kzfree(const void *) make?  Why is
> > keeping the declarations the same apart from the "z" desirable?
> > 
> > By all means refuse to add kzfree(), but please don't add it with const.
> > 
> > I can see that the "const" in kfree(const void *) is debatable
> > [looks to see how userspace free() is defined: without a const],
> > I can see that it might be nice to have some "goesaway" attribute
> > for such pointers instead; but I don't see how you can argue for
> > kzalloc(const void *).
    ^^^^^^^^^^^^^^^^^^^^^
(Of course I meant to say "kzfree(const void *)" there.)

> 
> This is what Linus said last time this came up:
> 
> http://lkml.org/lkml/2008/1/16/227

Thanks for that, I remember it now.

Okay, that's some justification for kfree(const void *).

But I fail to see it as a justification for kzfree(const void *):
if someone has "const char *string = kmalloc(size)" and then
wants that string zeroed before it is freed, then I think it's
quite right to cast out the const when calling kzfree().

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
