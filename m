Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 368856B00A8
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 09:02:06 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 1/7] slab: introduce kzfree()
Date: Tue, 24 Feb 2009 01:01:24 +1100
References: <499BE7F8.80901@csr.com> <499DB6EC.3020904@cs.helsinki.fi> <Pine.LNX.4.64.0902192022210.8254@blonde.anvils>
In-Reply-To: <Pine.LNX.4.64.0902192022210.8254@blonde.anvils>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902240101.26362.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Vrabel <david.vrabel@csr.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Chas Williams <chas@cmf.nrl.navy.mil>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Friday 20 February 2009 07:36:48 Hugh Dickins wrote:
> On Thu, 19 Feb 2009, Pekka Enberg wrote:

> > Quite frankly, I fail to see how kzfree() is fundamentally different from
> > kfree(). I don't see kzfree() as a memset() + kfree() but rather as a
> > kfree() "and make sure no one sees my data". So the zeroing happens
> > _after_ you've invalidated the pointer with kzfree() so there's no
> > "zeroing of buffer going on".
>
> Well, that would be one way of picturing it, yes.
> Imagine the "z" as for "zap" rather than "zero",
> and the mechanism as opaque as Hannes suggests.
>
> > So the way I see it, Linus' argument for having const for kfree() applies
> > to kzfree().
> >
> > That said, if you guys think it's a merge blocker, by all means remove
> > the const. I just want few less open-coded ksize() users, that's all.
>
> I wouldn't call it a merge blocker, no; though I still
> think it makes far more sense without the "const" there.

Well, the buffer is only non-modified in the case of one of the
allocators (SLAB). All others overwrite some of the data region
with their own metadata.

I think it is OK to use const, though. Because k(z)free has the
knowledge that the data will not be touched by the caller any
longer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
