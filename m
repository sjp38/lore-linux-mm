Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D7E1D6B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 00:56:43 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] mm fix page writeback accounting to fix oom condition under heavy I/O
Date: Tue, 10 Feb 2009 16:56:13 +1100
References: <20090120122855.GF30821@kernel.dk> <20090210033652.GA28435@Krystal> <alpine.LFD.2.00.0902092120450.3048@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.0902092120450.3048@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902101656.13792.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jens Axboe <jens.axboe@oracle.com>, akpm@linux-foundation.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>, thomas.pi@arcor.dea, Yuriy Lalym <ylalym@gmail.com>, ltt-dev@lists.casi.polymtl.ca, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 10 February 2009 16:23:56 Linus Torvalds wrote:
> On Mon, 9 Feb 2009, Mathieu Desnoyers wrote:
> > So this patch fixes this behavior by only decrementing the page
> > accounting _after_ the block I/O writepage has been done.
>
> This makes no sense, really.
>
> Or rather, I don't mind the notion of updating the counters only after IO
> per se, and _that_ part of it probably makes sense. But why is it that you
> only then fix up two of the call-sites. There's a lot more call-sites than
> that for this function.

Well if you do that, then I'd think you also have to change some
calculations that today use dirty+writeback.

In some ways it does make sense, but OTOH it is natural in the
pagecache since it was introduced to treat writeback as basically
equivalent to dirty. So writeback && !dirty pages shouldn't cause
things to blow up, or if it does then hopefully it is a simple
bug somewhere.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
