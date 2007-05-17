Date: Wed, 16 May 2007 17:24:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] scalable rw_mutex
Message-Id: <20070516172435.bd3270bd.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0705161639010.12688@schroedinger.engr.sgi.com>
References: <20070511131541.992688403@chello.nl>
	<20070511132321.895740140@chello.nl>
	<20070511093108.495feb70.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705111006470.32716@schroedinger.engr.sgi.com>
	<20070511110522.ed459635.akpm@linux-foundation.org>
	<p73odkpeusf.fsf@bingen.suse.de>
	<20070512110624.9ac3aa44.akpm@linux-foundation.org>
	<20070516162829.23f9b1c4.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705161639010.12688@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@tv-sign.ru>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 16 May 2007 16:40:59 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 16 May 2007, Andrew Morton wrote:
> 
> > (I hope.  Might have race windows in which the percpu_counter_sum() count is
> > inaccurate?)
> 
> The question is how do these race windows affect the locking scheme?

The race to which I refer here is if another CPU is running
percpu_counter_sum() in the window between the clearing of the bit in
cpu_online_map and the CPU_DEAD callout.  Maybe that's too small to care
about in the short-term, dunno.

Officially we should fix that by taking lock_cpu_hotplug() in
percpu_counter_sum(), but I hate that thing.

I was thinking of putting a cpumask into the counter.  If we do that then
there's no race at all: everything happens under fbc->lock.  This would be
a preferable fix, if we need to fix it.

But I'd prefer that freezer-based cpu-hotplug comes along and saves us
again.



umm, actually, we can fix the race by using CPU_DOWN_PREPARE instead of
CPU_DEAD.  Because it's OK if percpu_counter_sum() looks at a gone-away
CPU's slot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
