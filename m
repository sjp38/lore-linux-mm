Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1637B6B00A0
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 23:36:41 -0400 (EDT)
Date: Mon, 12 Oct 2009 20:35:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [resend][PATCH v2] mlock() doesn't wait to finish
 lru_add_drain_all()
Message-Id: <20091012203555.405bd9e7.akpm@linux-foundation.org>
In-Reply-To: <20091013110409.C758.A69D9226@jp.fujitsu.com>
References: <20091013090347.C752.A69D9226@jp.fujitsu.com>
	<20091012185139.75c13648.akpm@linux-foundation.org>
	<20091013110409.C758.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Galbraith <efault@gmx.de>, Oleg Nesterov <onestero@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Oct 2009 12:18:17 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> The problem is in __lru_cache_add().
> 
> ============================================================
> void __lru_cache_add(struct page *page, enum lru_list lru)
> {
>         struct pagevec *pvec = &get_cpu_var(lru_add_pvecs)[lru];
> 
>         page_cache_get(page);
>         if (!pagevec_add(pvec, page))
>                 ____pagevec_lru_add(pvec, lru);
>         put_cpu_var(lru_add_pvecs);
> }
> ============================================================
> 
> current typical scenario is
> 1. preempt disable
> 2. assign lru_add_pvec
> 3. page_cache_get()
> 4. pvec->pages[pvec->nr++] = page;
> 5. preempt enable
> 
> but the preempt disabling assume drain_cpu_pagevecs() run on process context.
> we need to convert it with irq_disabling.

Nope, preempt_disable()/enable() can be performed in hard IRQ context. 
I see nothing in __lru_cache_add() which would cause problems when run
from hard IRQ.

Apart from latency, of course.  Doing a full smp_call_function() in
lru_add_drain_all() might get expensive if it's ever called with any
great frequency.

A smart implementation might take a peek at other cpu's queues and omit
the cross-CPU call if the queue is empty, for example..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
