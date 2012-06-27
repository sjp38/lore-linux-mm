Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id DF8B76B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 08:04:28 -0400 (EDT)
Message-ID: <1340798663.10063.36.camel@twins>
Subject: Re: needed lru_add_drain_all() change
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 27 Jun 2012 14:04:23 +0200
In-Reply-To: <20120626143703.396d6d66.akpm@linux-foundation.org>
References: <20120626143703.396d6d66.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

On Tue, 2012-06-26 at 14:37 -0700, Andrew Morton wrote:
> lru_add_drain_all() uses schedule_on_each_cpu().  But
> schedule_on_each_cpu() hangs if a realtime thread is spinning, pinned
> to a CPU.  There's no intention to change the scheduler behaviour, so
> I
> think we should remove schedule_on_each_cpu() from the kernel.
>=20

Anything that uses a per-cpu workqueue and waits on work from another
cpu is vulnerable too. This would include things like padata, crypto and
possibly others.

ksoftirqd is vulnerable too, if it were preempted while handling a
softirq, all of softirq handling will be out the window for that cpu.

infiniband/hw/ehca would likely malfunction as well, since it has
per-cpu threads.


FIFO is dangerous, don't do stupid things :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
