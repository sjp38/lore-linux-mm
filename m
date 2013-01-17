Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 54FF46B0006
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 17:46:05 -0500 (EST)
Message-ID: <1358462763.23211.57.camel@gandalf.local.home>
Subject: Re: [RFC][PATCH] slub: Check for page NULL before doing the
 node_match check
From: Steven Rostedt <rostedt@goodmis.org>
Date: Thu, 17 Jan 2013 17:46:03 -0500
In-Reply-To: <0000013c4a7e7fbf-c51fd42a-2455-4fec-bb37-915035956f05-000000@email.amazonses.com>
References: <1358446258.23211.32.camel@gandalf.local.home>
	  <1358447864.23211.34.camel@gandalf.local.home>
	  <0000013c4a69a2cf-1a19a6f6-e6a3-4f06-99a4-10fdd4b9aca2-000000@email.amazonses.com>
	 <1358458996.23211.46.camel@gandalf.local.home>
	 <0000013c4a7e7fbf-c51fd42a-2455-4fec-bb37-915035956f05-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio R.
 Goncalves" <lgoncalv@redhat.com>

On Thu, 2013-01-17 at 21:51 +0000, Christoph Lameter wrote:

> This is dealing with the same cpu being interrupted. Some of these
> segments are in interrupt disable sections so they are not affected.

Except that we are not always on the same CPU. Now I'm looking at
mainline (non modified by -rt):

>From slab_alloc_node():

	/*
	 * Must read kmem_cache cpu data via this cpu ptr. Preemption is
	 * enabled. We may switch back and forth between cpus while
	 * reading from one cpu area. That does not matter as long
	 * as we end up on the original cpu again when doing the cmpxchg.
	 */
	c = __this_cpu_ptr(s->cpu_slab);

	/*
	 * The transaction ids are globally unique per cpu and per operation on
	 * a per cpu queue. Thus they can be guarantee that the cmpxchg_double
	 * occurs on the right processor and that there was no operation on the
	 * linked list in between.
	 */
	tid = c->tid;
	barrier();

	object = c->freelist;
	page = c->page;
	if (unlikely(!object || !node_match(page, node)))
		object = __slab_alloc(s, gfpflags, node, addr, c);

Where we hit the bug on -rt, and can most certainly do it on mainline.

This code does not disable preemption (the comment even states that). So
if we switch CPUs after reading __this_cpu_ptr(), we are still accessing
the 'c' pointer of the CPU we left. Hence, there's nothing protecting
c->page being NULL when c->freelist is not NULL.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
