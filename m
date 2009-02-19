Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D96126B003D
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 11:37:02 -0500 (EST)
Date: Thu, 19 Feb 2009 16:34:41 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 1/7] slab: introduce kzfree()
In-Reply-To: <1235034817.29813.6.camel@penberg-laptop>
Message-ID: <Pine.LNX.4.64.0902191616250.8594@blonde.anvils>
References: <499BE7F8.80901@csr.com>  <1234954488.24030.46.camel@penberg-laptop>
  <20090219101336.9556.A69D9226@jp.fujitsu.com> <1235034817.29813.6.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Vrabel <david.vrabel@csr.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Chas Williams <chas@cmf.nrl.navy.mil>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Feb 2009, Pekka Enberg wrote:
> On Wed, 2009-02-18 at 10:50 +0000, David Vrabel wrote:
> > > > Johannes Weiner wrote:
> > > > > +void kzfree(const void *p)
> > > > 
> > > > Shouldn't this be void * since it writes to the memory?
> > > 
> > > No. kfree() writes to the memory as well to update freelists, poisoning
> > > and such so kzfree() is not at all different from it.
> 
> On Thu, 2009-02-19 at 10:22 +0900, KOSAKI Motohiro wrote:
> > I don't think so. It's debetable thing.
> > 
> > poisonig is transparent feature from caller.
> > but the caller of kzfree() know to fill memory and it should know.
> 
> Debatable, sure, but doesn't seem like a big enough reason to make
> kzfree() differ from kfree().

There may be more important things for us to worry about,
but I do strongly agree with KOSAKI-san on this.

kzfree() already differs from kfree() by a "z": that "z" says please
zero the buffer pointed to; "const" says it won't modify the buffer
pointed to.  What sense does kzfree(const void *) make?  Why is
keeping the declarations the same apart from the "z" desirable?

By all means refuse to add kzfree(), but please don't add it with const.

I can see that the "const" in kfree(const void *) is debatable
[looks to see how userspace free() is defined: without a const],
I can see that it might be nice to have some "goesaway" attribute
for such pointers instead; but I don't see how you can argue for
kzalloc(const void *).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
