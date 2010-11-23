Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D397B6B0088
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 02:49:56 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAN7nsQa004539
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 23 Nov 2010 16:49:54 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B65645DE60
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:49:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D3D7145DE70
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:49:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C003F1DB803E
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:49:53 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DF2A1DB803B
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:49:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] mlock: release mmap_sem every 256 faulted pages
In-Reply-To: <20101122215746.e847742d.akpm@linux-foundation.org>
References: <20101123050052.GA24039@google.com> <20101122215746.e847742d.akpm@linux-foundation.org>
Message-Id: <20101123164107.7BBC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 23 Nov 2010 16:49:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@kernel.dk>, Rik van Riel <riel@redhat.com>, Michael Rubin <mrubin@google.com>
List-ID: <linux-mm.kvack.org>

> On Mon, 22 Nov 2010 21:00:52 -0800 Michel Lespinasse <walken@google.com> wrote:
> 
> > Hi,
> > 
> > I'd like to sollicit comments on this proposal:
> > 
> > Currently mlock() holds mmap_sem in exclusive mode while the pages get
> > faulted in. In the case of a large mlock, this can potentially take a
> > very long time.
> 
> A more compelling description of why this problem needs addressing
> would help things along.

Michel, as far as I know, now Michael Rubin (now I'm ccing him) are trying
to make automatic MM test suit. So if possible, can you please make
test case which reproduce your workload?

http://code.google.com/p/samplergrapher/


I hope to join to solve your issue. and I also hope you help to understand
and reproduce your issue. 

Thanks.

> 
> > +		/*
> > +		 * Limit batch size to 256 pages in order to reduce
> > +		 * mmap_sem hold time.
> > +		 */
> > +		nfault = nstart + 256 * PAGE_SIZE;
> 
> It would be nicer if there was an rwsem API to ask if anyone is
> currently blocked in down_read() or down_write().  That wouldn't be too
> hard to do.  It wouldn't detect people polling down_read_trylock() or
> down_write_trylock() though.

Andrew, yes it is certinally optimal. But I doubt it improve mlock
performance a lot. because mlock is _very_ slooooooow syscall.
lock regrabing may be cheap than it. So, _IF_ you can allow, I hope
we take a simple method at first. personally I think Michel move 
forwarding right way. then I don't hope to make a hardest hurdle.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
