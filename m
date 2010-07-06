Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 05B856B025C
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 12:25:25 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v4 00/12] KVM: Add host swap event notifications for PV guest
Date: Tue,  6 Jul 2010 19:24:48 +0300
Message-Id: <1278433500-29884-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

KVM virtualizes guest memory by means of shadow pages or HW assistance
like NPT/EPT. Not all memory used by a guest is mapped into the guest
address space or even present in a host memory at any given time.
When vcpu tries to access memory page that is not mapped into the guest
address space KVM is notified about it. KVM maps the page into the guest
address space and resumes vcpu execution. If the page is swapped out
from host memory vcpu execution is suspended till the page is not swapped
into the memory again. This is inefficient since vcpu can do other work
(run other task or serve interrupts) while page gets swapped in.

To overcome this inefficiency this patch series implements "asynchronous
page fault" for paravirtualized KVM guests. If a page that vcpu is
trying to access is swapped out KVM sends an async PF to the vcpu
and continues vcpu execution. Requested page is swapped in by another
thread in parallel.  When vcpu gets async PF it puts faulted task to
sleep until "wake up" interrupt is delivered. When the page is brought
to the host memory KVM sends "wake up" interrupt and the guest's task
resumes execution.

To measure performance benefits I use a simple benchmark program (below)
that starts number of threads. Some of them do work (increment counter),
others access huge array in random location trying to generate host page
faults. The size of the array is smaller then guest memory bug bigger
then host memory so we are guarantied that host will swap out part of
the array.

Running the benchmark inside guest with 4 cpus 2G memory running in 512M
container in the host using the command line "./bm -f 4 -w 4 -t 60" (run 4
faulting threads and 4 working threads for a minute) I get this result:

With async pf:
start
worker 0: 63972141051
worker 1: 65149033299
worker 2: 66301967246
worker 3: 63423000989
total: 258846142585


Without async pf:
start
worker 0: 30619912622
worker 1: 33951339266
worker 2: 31577780093
worker 3: 33603607972
total: 129752639953

The gain is 50% as expected.

Perf data look like this:
With async pf:
    97.93%       bm  bm                    [.] work_thread
     1.74%       bm  [kernel.kallsyms]     [k] retint_careful
     0.10%       bm  [kernel.kallsyms]     [k] _raw_spin_unlock_irq
     0.08%       bm  bm                    [.] fault_thread
     0.05%       bm  [kernel.kallsyms]     [k] _raw_spin_unlock_irqrestore
     0.02%       bm  [kernel.kallsyms]     [k] __do_softirq
     0.02%       bm  [kernel.kallsyms]     [k] rcu_process_gp_end

Without async pf:
    63.42%       bm  bm                    [.] work_thread
    13.64%       bm  [kernel.kallsyms]     [k] __do_softirq
     8.95%       bm  bm                    [.] fault_thread
     5.27%       bm  [kernel.kallsyms]     [k] _raw_spin_unlock_irq
     2.79%       bm  [kernel.kallsyms]     [k] hrtimer_run_pending
     2.35%       bm  [kernel.kallsyms]     [k] run_timer_softirq
     1.28%       bm  [kernel.kallsyms]     [k] _raw_spin_lock_irq
     1.16%       bm  [kernel.kallsyms]     [k] debug_smp_processor_id
     0.23%       bm  libc-2.10.2.so        [.] random_r
     0.18%       bm  [kernel.kallsyms]     [k] rcu_bh_qs
     0.18%       bm  [kernel.kallsyms]     [k] find_busiest_group
     0.14%       bm  [kernel.kallsyms]     [k] retint_careful
     0.14%       bm  libc-2.10.2.so        [.] random

Changes:
 v1->v2
   Use MSR instead of hypercall.
   Move most of the code into arch independent place.
   halt inside a guest instead of doing "wait for page" hypercall if
    preemption is disabled.
 v2->v3
   Use MSR from range 0x4b564dxx.
   Add slot version tracking.
   Support migration by restarting all guest processes after migration.
   Drop patch that tract preemptability for non-preemptable kernels
    due to performance concerns. Send async PF to non-preemptable
    guests only when vcpu is executing userspace code.
 v3->v4
  Provide alternative page fault handler in PV guest instead of adding hook to
   standard page fault handler and patch it out on non-PV guests.
  Allow only limited number of outstanding async page fault per vcpu.
  Unify  gfn_to_pfn and gfn_to_pfn_async code.
  Cancel outstanding slow work on reset.
 
Gleb Natapov (12):
  Move kvm_smp_prepare_boot_cpu() from kvmclock.c to kvm.c.
  Add PV MSR to enable asynchronous page faults delivery.
  Add async PF initialization to PV guest.
  Provide special async page fault handler when async PF capability is
    detected
  Export __get_user_pages_fast.
  Add get_user_pages() variant that fails if major fault is required.
  Maintain memslot version number
  Inject asynchronous page fault into a guest if page is swapped out.
  Retry fault before vmentry
  Handle async PF in non preemptable context
  Let host know whether the guest can handle async PF in non-userspace
    context.
  Send async PF when guest is not in userspace too.

 arch/x86/include/asm/kvm_host.h |   27 ++++-
 arch/x86/include/asm/kvm_para.h |   14 ++
 arch/x86/include/asm/traps.h    |    1 +
 arch/x86/kernel/entry_32.S      |   10 ++
 arch/x86/kernel/entry_64.S      |    3 +
 arch/x86/kernel/kvm.c           |  261 ++++++++++++++++++++++++++++++++++++++
 arch/x86/kernel/kvmclock.c      |   13 +--
 arch/x86/kernel/smpboot.c       |    3 +
 arch/x86/kvm/Kconfig            |    2 +
 arch/x86/kvm/mmu.c              |   62 +++++++++-
 arch/x86/kvm/paging_tmpl.h      |   50 +++++++-
 arch/x86/kvm/x86.c              |  122 +++++++++++++++++-
 arch/x86/mm/gup.c               |    2 +
 fs/ncpfs/mmap.c                 |    2 +
 include/linux/kvm.h             |    1 +
 include/linux/kvm_host.h        |   32 +++++
 include/linux/kvm_para.h        |    2 +
 include/linux/mm.h              |    5 +
 include/trace/events/kvm.h      |   60 +++++++++
 mm/filemap.c                    |    3 +
 mm/memory.c                     |   31 ++++-
 mm/shmem.c                      |    8 +-
 virt/kvm/Kconfig                |    3 +
 virt/kvm/kvm_main.c             |  266 ++++++++++++++++++++++++++++++++++++++-
 24 files changed, 949 insertions(+), 34 deletions(-)

=== benchmark.c ===

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>

#define FAULTING_THREADS 1
#define WORKING_THREADS 1
#define TIMEOUT 5
#define MEMORY 1024*1024*1024

pthread_barrier_t barrier;
volatile int stop;
size_t pages;

void *fault_thread(void* p)
{
	char *mem = p;

	pthread_barrier_wait(&barrier);

	while (!stop)
		mem[(random() % pages) << 12] = 10;

	pthread_barrier_wait(&barrier);

	return NULL;
}

void *work_thread(void* p)
{
	unsigned long *i = p;

	pthread_barrier_wait(&barrier);

	while (!stop)
		(*i)++;

	pthread_barrier_wait(&barrier);

	return NULL;
}

int main(int argc, char **argv)
{
	int ft = FAULTING_THREADS, wt = WORKING_THREADS;
	unsigned int timeout = TIMEOUT;
	size_t mem = MEMORY;
	void *buf;
	int i, opt, verbose = 0;
	pthread_t t;
	pthread_attr_t pattr;
	unsigned long *res, sum = 0;

	while((opt = getopt(argc, argv, "f:w:m:t:v")) != -1) {
		switch (opt) {
		case 'f':
			ft = atoi(optarg);
			break;
		case 'w':
			wt = atoi(optarg);
			break;
		case 'm':
			mem = atoi(optarg);
			break;
		case 't':
			timeout = atoi(optarg);
			break;
		case 'v':
			verbose++;
			break;
		default:
			fprintf(stderr, "Usage %s [-f num] [-w num] [-m byte] [-t secs]\n", argv[0]);
			exit(1);
		}
	}

	if (verbose)
		printf("fault=%d work=%d mem=%lu timeout=%d\n", ft, wt, mem, timeout);

	pages = mem >> 12;
	posix_memalign(&buf, 4096, pages << 12);
	res = malloc(sizeof (unsigned long) * wt);
	memset(res, 0, sizeof (unsigned long) * wt);

	pthread_attr_init(&pattr);
	pthread_barrier_init(&barrier, NULL, ft + wt + 1);

	for (i = 0; i < ft; i++) {
		pthread_create(&t, &pattr, fault_thread, buf);
		pthread_detach(t);
	}

	for (i = 0; i < wt; i++) {
		pthread_create(&t, &pattr, work_thread, &res[i]);
		pthread_detach(t);
	}

	/* prefault memory */
	memset(buf, 0, pages << 12);
	printf("start\n");

	pthread_barrier_wait(&barrier);

	pthread_barrier_destroy(&barrier);
	pthread_barrier_init(&barrier, NULL, ft + wt + 1);

	sleep(timeout);
	stop = 1;

	pthread_barrier_wait(&barrier);

	for (i = 0; i < wt; i++) {
		sum += res[i];
		printf("worker %d: %lu\n", i, res[i]);
	}
	printf("total: %lu\n", sum);

	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
