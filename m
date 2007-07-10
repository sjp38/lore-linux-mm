Received: from krystal.dyndns.org ([76.65.100.197])
          by tomts43-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20070710082710.YEDG5730.tomts43-srv.bellnexxia.net@krystal.dyndns.org>
          for <linux-mm@kvack.org>; Tue, 10 Jul 2007 04:27:10 -0400
Date: Tue, 10 Jul 2007 04:27:09 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [patch 00/10] [RFC] SLUB patches for more functionality, performance and maintenance
Message-ID: <20070710082709.GC16148@Krystal>
References: <20070708034952.022985379@sgi.com> <p73y7hrywel.fsf@bingen.suse.de> <Pine.LNX.4.64.0707090845520.13792@schroedinger.engr.sgi.com> <46925B5D.8000507@google.com> <Pine.LNX.4.64.0707091055090.16207@schroedinger.engr.sgi.com> <4692A1D0.50308@mbligh.org> <20070709214426.GC1026@Krystal> <Pine.LNX.4.64.0707091451200.18780@schroedinger.engr.sgi.com> <20070709225817.GA5111@Krystal> <Pine.LNX.4.64.0707091715450.2062@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: 8BIT
In-Reply-To: <Pine.LNX.4.64.0707091715450.2062@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Martin Bligh <mbligh@mbligh.org>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

* Christoph Lameter (clameter@sgi.com) wrote:
> Ok here is a replacement patch for the cmpxchg patch. Problems
> 
> 1. cmpxchg_local is not available on all arches. If we wanted to do
>    this then it needs to be universally available.
> 

cmpxchg_local is not available on all archs, but local_cmpxchg is. It
expects a local_t type which is nothing else than a long. When the local
atomic operation is not more efficient or not implemented on a given
architecture, asm-generic/local.h falls back on atomic_long_t. If you
want, you could work on the local_t type, which you could cast from a
long to a pointer when you need so, since their size are, AFAIK, always
the same (and some VM code even assume this is always the case).

> 2. cmpxchg_local does generate the "lock" prefix. It should not do that.
>    Without fixes to cmpxchg_local we cannot expect maximum performance.
> 

Yup, see the patch I just posted for this.

> 3. The approach is x86 centric. It relies on a cmpxchg that does not
>    synchronize with memory used by other cpus and therefore is more
>    lightweight. As far as I know the IA64 cmpxchg cannot do that.
>    Neither several other processors. I am not sure how cmpxchgless
>    platforms would use that. We need a detailed comparison of
>    interrupt enable /disable vs. cmpxchg cycle counts for cachelines in
>    the cpu cache to evaluate the impact that such a change would have.
> 
>    The cmpxchg (or its emulation) does not need any barriers since the
>    accesses can only come from a single processor. 
> 

Yes, expected improvements goes as follow:
x86, x86_64 : must faster due to non-LOCKed cmpxchg
alpha: should be faster due to memory barrier removal
mips: memory barriers removed
powerpc 32/64: memory barriers removed

On other architectures, either there is no better implementation than
the standard atomic cmpxchg or it just has not been implemented.

I guess that a test series that would tell us how must improvement is
seen on the optimized architectures (local cmpxchg vs interrupt
enable/disable) and also what effect the standard cmpxchg has compared
to interrupt disable/enable on the architectures where we can't do
better than the standard cmpxchg will tell us if it is an interesting
way to go.  I would be happy to do these tests, but I don't have the
hardware handy. I provide a test module to get these characteristics
from various architectures in this email.

> Mathieu measured a significant performance benefit coming from not using
> interrupt enable / disable.
> 
> Some rough processor cycle counts (anyone have better numbers?)
> 
> 	STI	CLI	CMPXCHG
> IA32	36	26	1 (assume XCHG == CMPXCHG, sti/cli also need stack pushes/pulls)
> IA64	12	12	1 (but ar.ccv needs 11 cycles to set comparator,
> 			need register moves to preserve processors flags)
> 

The measurements I get (in cycles):

             enable interrupts (STI)   disable interrupts (CLI)   local CMPXCHG
IA32 (P4)    112                        82                         26
x86_64 AMD64 125                       102                         19

> Looks like STI/CLI is pretty expensive and it seems that we may be able to
> optimize the alloc / free hotpath quite a bit if we could drop the 
> interrupt enable / disable. But we need some measurements.
> 
> 
> Draft of a new patch:
> 
> SLUB: Single atomic instruction alloc/free using cmpxchg_local
> 
> A cmpxchg allows us to avoid disabling and enabling interrupts. The cmpxchg
> is optimal to allow operations on per cpu freelist. We can stay on one
> processor by disabling preemption() and allowing concurrent interrupts
> thus avoiding the overhead of disabling and enabling interrupts.
> 
> Pro:
> 	- No need to disable interrupts.
> 	- Preempt disable /enable vanishes on non preempt kernels
> Con:
>         - Slightly complexer handling.
> 	- Updates to atomic instructions needed
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 

Test local cmpxchg vs int disable/enable. Please run on a 2.6.22 kernel
(or recent 2.6.21-rcX-mmX) (with my cmpxchg local fix patch for x86_64).
Make sure the TSC reads (get_cycles()) are reliable on your platform.

Mathieu

/* test-cmpxchg-nolock.c
 *
 * Compare local cmpxchg with irq disable / enable.
 */

#include <linux/jiffies.h>
#include <linux/compiler.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/calc64.h>
#include <asm/timex.h>
#include <asm/system.h>

#define NR_LOOPS 20000

int test_val = 0;

static void do_test_cmpxchg(void)
{
	int ret;
	long flags;
	unsigned int i;
	cycles_t time1, time2, time;
	long rem;

	local_irq_save(flags);
	preempt_disable();
	time1 = get_cycles();
	for (i = 0; i < NR_LOOPS; i++) {
		ret = cmpxchg_local(&test_val, 0, 0);
	}
	time2 = get_cycles();
	local_irq_restore(flags);
	preempt_enable();
	time = time2 - time1;

	printk(KERN_ALERT "test results: time for non locked cmpxchg\n");
	printk(KERN_ALERT "number of loops: %d\n", NR_LOOPS);
	printk(KERN_ALERT "total time: %llu\n", time);
	time = div_long_long_rem(time, NR_LOOPS, &rem);
	printk(KERN_ALERT "-> non locked cmpxchg takes %llu cycles\n", time);
	printk(KERN_ALERT "test end\n");
}

/*
 * This test will have a higher standard deviation due to incoming interrupts.
 */
static void do_test_enable_int(void)
{
	long flags;
	unsigned int i;
	cycles_t time1, time2, time;
	long rem;

	local_irq_save(flags);
	preempt_disable();
	time1 = get_cycles();
	for (i = 0; i < NR_LOOPS; i++) {
		local_irq_restore(flags);
	}
	time2 = get_cycles();
	local_irq_restore(flags);
	preempt_enable();
	time = time2 - time1;

	printk(KERN_ALERT "test results: time for enabling interrupts (STI)\n");
	printk(KERN_ALERT "number of loops: %d\n", NR_LOOPS);
	printk(KERN_ALERT "total time: %llu\n", time);
	time = div_long_long_rem(time, NR_LOOPS, &rem);
	printk(KERN_ALERT "-> enabling interrupts (STI) takes %llu cycles\n",
					time);
	printk(KERN_ALERT "test end\n");
}

static void do_test_disable_int(void)
{
	unsigned long flags, flags2;
	unsigned int i;
	cycles_t time1, time2, time;
	long rem;

	local_irq_save(flags);
	preempt_disable();
	time1 = get_cycles();
	for ( i = 0; i < NR_LOOPS; i++) {
		local_irq_save(flags2);
	}
	time2 = get_cycles();
	local_irq_restore(flags);
	preempt_enable();
	time = time2 - time1;

	printk(KERN_ALERT "test results: time for disabling interrupts (CLI)\n");
	printk(KERN_ALERT "number of loops: %d\n", NR_LOOPS);
	printk(KERN_ALERT "total time: %llu\n", time);
	time = div_long_long_rem(time, NR_LOOPS, &rem);
	printk(KERN_ALERT "-> disabling interrupts (CLI) takes %llu cycles\n",
				time);
	printk(KERN_ALERT "test end\n");
}



static int ltt_test_init(void)
{
	printk(KERN_ALERT "test init\n");
	
	do_test_cmpxchg();
	do_test_enable_int();
	do_test_disable_int();
	return -EAGAIN; /* Fail will directly unload the module */
}

static void ltt_test_exit(void)
{
	printk(KERN_ALERT "test exit\n");
}

module_init(ltt_test_init)
module_exit(ltt_test_exit)

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Mathieu Desnoyers");
MODULE_DESCRIPTION("Cmpxchg local test");

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
