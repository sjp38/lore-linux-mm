Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B499C6B0055
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 06:11:29 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n96ABRRM001159
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 6 Oct 2009 19:11:27 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0337445DE50
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 19:11:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D7F6B45DE4C
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 19:11:26 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C2D261DB803F
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 19:11:26 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BA9C1DB8038
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 19:11:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mlock use lru_add_drain_all_async()
In-Reply-To: <1254820131.21044.126.camel@laptop>
References: <20091006114052.5FAA.A69D9226@jp.fujitsu.com> <1254820131.21044.126.camel@laptop>
Message-Id: <20091006190507.126C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  6 Oct 2009 19:11:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Tue, 2009-10-06 at 11:41 +0900, KOSAKI Motohiro wrote:
> > Recently, Peter Zijlstra reported RT-task can lead to prevent mlock
> > very long time.
> > 
> >   Suppose you have 2 cpus, cpu1 is busy doing a SCHED_FIFO-99 while(1),
> >   cpu0 does mlock()->lru_add_drain_all(), which does
> >   schedule_on_each_cpu(), which then waits for all cpus to complete the
> >   work. Except that cpu1, which is busy with the RT task, will never run
> >   keventd until the RT load goes away.
> > 
> >   This is not so much an actual deadlock as a serious starvation case.
> > 
> > Actually, mlock() doesn't need to wait to finish lru_add_drain_all().
> > Thus, this patch replace it with lru_add_drain_all_async().
> > 
> > Cc: Oleg Nesterov <onestero@redhat.com>
> > Reported-by: Peter Zijlstra <a.p.zijlstra@chello.nl> 
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> It was actually Mike Galbraith who brought it to my attention.
> 
> Patch looks sane enough, altough I'm not sure I'd have split it in two
> like you did (leaves the first without a real changelog too).

Ah, yes. they shold be folded. thanks.
In my local patch queue, this patch series have another two caller.

  - lumpy reclaim: currently, PCP often cause failure large order allocation.
  - page migration: in almost case, PCP doesn't hold the migration target page.

but they are still testing.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
