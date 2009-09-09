Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B02F86B004D
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 19:43:55 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n89Nhw7p031060
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 10 Sep 2009 08:43:58 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DDF0A45DE4E
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 08:43:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BBEDB45DE51
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 08:43:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A46F71DB8041
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 08:43:57 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3EB341DB803F
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 08:43:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [rfc] lru_add_drain_all() vs isolation
In-Reply-To: <alpine.DEB.1.10.0909091005010.28070@V090114053VZO-1>
References: <20090909131945.0CF5.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0909091005010.28070@V090114053VZO-1>
Message-Id: <20090910083340.9CB7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 10 Sep 2009 08:43:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <onestero@redhat.com>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> On Wed, 9 Sep 2009, KOSAKI Motohiro wrote:
> 
> > Christoph, I'd like to discuss a bit related (and almost unrelated) thing.
> > I think page migration don't need lru_add_drain_all() as synchronous, because
> > page migration have 10 times retry.
> 
> True this is only an optimization that increases the chance of isolation
> being successful. You dont need draining at all.
> 
> > Then asynchronous lru_add_drain_all() cause
> >
> >   - if system isn't under heavy pressure, retry succussfull.
> >   - if system is under heavy pressure or RT-thread work busy busy loop, retry failure.
> >
> > I don't think this is problematic bahavior. Also, mlock can use asynchrounous lru drain.
> >
> > What do you think?
> 
> The retries can be very fast if the migrate pages list is small. The
> migrate attempts may be finished before the IPI can be processed by the
> other cpus.

Ah, I see. Yes, my last proposal is not good. small migration might be fail.

How about this?
  - pass 1-2,  lru_add_drain_all_async()
  - pass 3-10, lru_add_drain_all()

this scheme might save RT-thread case and never cause regression. (I think)

The last remain problem is, if RT-thread binding cpu's pagevec has migrate
targetted page, migration still face the same issue.
but we can't solve it...
RT-thread must use /proc/sys/vm/drop_caches properly.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
