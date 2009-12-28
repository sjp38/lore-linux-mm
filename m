Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 70F9F60021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 20:08:27 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBS18OUH030846
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Dec 2009 10:08:24 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C998F45DE52
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 10:08:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A963445DE50
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 10:08:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AC961DB8042
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 10:08:23 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 37E741DB803B
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 10:08:23 +0900 (JST)
Date: Mon, 28 Dec 2009 10:05:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC PATCH] asynchronous page fault.
Message-Id: <20091228100514.ec6f9949.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091228005746.GE3601@balbir.in.ibm.com>
References: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
	<1261912796.15854.25.camel@laptop>
	<20091228005746.GE3601@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Dec 2009 06:27:46 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * Peter Zijlstra <peterz@infradead.org> [2009-12-27 12:19:56]:
> 
> > Your changelog states as much.
> > 
> > "Even if RB-tree rotation occurs while we walk tree for look-up, we just
> > miss vma without oops."
> > 
> > However, since this is the case, do we still need the
> > rcu_assign_pointer() conversion your patch does? All I can see it do is
> > slow down all RB-tree users, without any gain.
> 
> Don't we need the rcu_assign_pointer() on the read side primarily to
> make sure the pointer is still valid and assignments (writes) are not
> re-ordered? Are you suggesting that the pointer assignment paths be
> completely atomic?
> 
>From following reasons.
  - What we have to avoid is not to touch unkonwn memory via broken pointer.
    This is speculative look up and can miss vmas. So, even if tree is broken,
    there is no problem. Broken pointer which points to places other than rb-tree
    is problem.
  - rb-tree's rb_left and rb_right don't points to memory other than
    rb-tree. (or NULL)  And vmas are not freed/reused while rcu_read_lock().
    Then, we don't dive into unknown memory.
  - Then, we can skip rcu_assign_pointer().

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
