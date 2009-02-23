Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1A9C76B00B5
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 10:08:28 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 1/7] slab: introduce kzfree()
Date: Tue, 24 Feb 2009 02:07:52 +1100
References: <499BE7F8.80901@csr.com> <200902240101.26362.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0902231429360.28573@blonde.anvils>
In-Reply-To: <Pine.LNX.4.64.0902231429360.28573@blonde.anvils>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902240207.53590.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Vrabel <david.vrabel@csr.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Chas Williams <chas@cmf.nrl.navy.mil>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tuesday 24 February 2009 01:51:05 Hugh Dickins wrote:
> On Tue, 24 Feb 2009, Nick Piggin wrote:
> > Well, the buffer is only non-modified in the case of one of the
> > allocators (SLAB). All others overwrite some of the data region
> > with their own metadata.
> >
> > I think it is OK to use const, though. Because k(z)free has the
> > knowledge that the data will not be touched by the caller any
> > longer.
>
> Sorry, you're not adding anything new to the thread here.
>
> Yes, the caller is surrendering the buffer, so we can get
> away with calling the argument const; and Linus argues that's
> helpful in the case of kfree (to allow passing a const pointer
> without having to cast it).

(Yes, not that I agree his argument is strong enough to be able
to call libc's definition wrong)

> My contention is that kzfree(const void *ptr) is nonsensical
> because it says please zero this buffer without modifying it.
>
> But the change has gone in, I seem to be the only one still
> bothered by it, and I've conceded that the "z" might stand
> for zap rather than zero.
>
> So it may be saying please hide the contents of this buffer,
> rather than please zero it.  And then it can be argued that
> the modification is an implementation detail which happens
> (like other housekeeping internal to the sl?b allocator)
> only after the original buffer has been freed.
>
> Philosophy.

Hmm, well it better if kzfree is defined to zap rather than zero
anyway. zap is a better definition because it theoretically allows
the implementation to do something else (poision it with some
other value; mark it as zapped and don't reallocate it without
zeroing it; etc). And also it doesn't imply that the caller still
cares about what it actually gets filled with.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
