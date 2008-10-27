Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9R3Esw9009208
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 27 Oct 2008 12:14:54 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 269F153C125
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 12:14:54 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id EF44F240049
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 12:14:53 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id D7CE31DB8041
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 12:14:53 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 82A8F1DB8038
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 12:14:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] lru_add_drain_all() don't use schedule_on_each_cpu()
In-Reply-To: <1225037872.32713.22.camel@twins>
References: <2f11576a0810260851h15cb7e1ahb454b70a2e99e1a8@mail.gmail.com> <1225037872.32713.22.camel@twins>
Message-Id: <20081027120405.1B45.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 27 Oct 2008 12:14:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Heiko Carstens <heiko.carstens@de.ibm.com>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Gautham Shenoy <ego@in.ibm.com>, Oleg Nesterov <oleg@tv-sign.ru>, Rusty Russell <rusty@rustcorp.com.au>, mpm <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

> Right, and would be about 4k+sizeof(task_struct), some people might be
> bothered, but most won't care.
> 
> > Perhaps, I misunderstand your intension. so can you point your
> > previous discussion url?
> 
> my google skillz fail me, but once in a while people complain that we
> have too many kernel threads.
> 
> Anyway, if we can re-use this per-cpu workqueue for more goals, I guess
> there is even less of an objection.

In general, you are right.
but this is special case. mmap_sem is really widely used various subsystem and drivers.
(because page fault via copy_user introduce to depend on mmap_sem)

Then, any work-queue reu-sing can cause similar dead-lock easily.


So I think we have two choices (nick explained it at this thread).

(1) own workqueue (the patch)
(2) avoid lru_add_drain_all completely


if you really strongly hate (1), we should target to (2) IMO.

Thought?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
