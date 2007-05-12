Date: Sat, 12 May 2007 11:06:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] scalable rw_mutex
Message-Id: <20070512110624.9ac3aa44.akpm@linux-foundation.org>
In-Reply-To: <p73odkpeusf.fsf@bingen.suse.de>
References: <20070511131541.992688403@chello.nl>
	<20070511132321.895740140@chello.nl>
	<20070511093108.495feb70.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705111006470.32716@schroedinger.engr.sgi.com>
	<20070511110522.ed459635.akpm@linux-foundation.org>
	<p73odkpeusf.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Lameter <clameter@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@tv-sign.ru>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 12 May 2007 20:55:28 +0200 Andi Kleen <andi@firstfloor.org> wrote:

> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > On Fri, 11 May 2007 10:07:17 -0700 (PDT)
> > Christoph Lameter <clameter@sgi.com> wrote:
> > 
> > > On Fri, 11 May 2007, Andrew Morton wrote:
> > > 
> > > > yipes.  percpu_counter_sum() is expensive.
> > > 
> > > Capable of triggering NMI watchdog on 4096+ processors?
> > 
> > Well.  That would be a millisecond per cpu which sounds improbable.  And
> > we'd need to be calling it under local_irq_save() which we presently don't.
> > And nobody has reported any problems against the existing callsites.
> > 
> > But it's no speed demon, that's for sure.
> 
> There is one possible optimization for this I did some time ago. You don't really
> need to sum all over the possible map, but only all CPUs that were ever 
> online. But this only helps on systems where the possible map is bigger
> than online map in the common case. But that shouldn't be the case anymore on x86
> -- it just used to be. If it's true on some other architectures it might
> be still worth it.
> 

hm, yeah.

We could put a cpumask in percpu_counter, initialise it to
cpu_possible_map.  Then, those callsites which have hotplug notifiers can
call into new percpu_counter functions which clear and set bits in that
cpumask and which drain percpu_counter.counts[cpu] into
percpu_counter.count.

And percpu_counter_sum() gets taught to do for_each_cpu_mask(fbc->cpumask).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
