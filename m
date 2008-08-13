Date: Wed, 13 Aug 2008 17:10:07 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: pthread_create() slow for many threads; also time to revisit
	64b context switch optimization?
Message-ID: <20080813151007.GA8780@elte.hu>
References: <af8810200808121736q76640cc1kb814385072fe9b29@mail.gmail.com> <af8810200808121745h596c175bk348d0aaeeb9bcb45@mail.gmail.com> <20080813104445.GA24632@elte.hu> <20080813063533.444c650d@infradead.org> <48A2EE07.3040003@redhat.com> <20080813142529.GB21129@elte.hu> <48A2F157.7000303@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48A2F157.7000303@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@redhat.com>
Cc: Arjan van de Ven <arjan@infradead.org>, akpm@linux-foundation.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, briangrant@google.com, cgd@google.com, mbligh@google.com, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

* Ulrich Drepper <drepper@redhat.com> wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Ingo Molnar wrote:
> > not sure exactly what numbers you mean, but there are lots of numbers in 
> > the first mail, attached below. For example:
> 
> I mean numbers indicating that it doesn't hurt performance on any of 
> today's machines.  If there are machines where it makes a difference 
> then we need the flag to indicate the _preference_ for a low stack, as 
> opposed to indicating a _requirement_.

there were a few numbers about that as well, and a test-app. The test 
app is below. The numbers were:

| I measured thread-to-thread context switches on two AMD processors and 
| five Intel procesors.  Tests used the same code with 32b or 64b stack 
| pointers; tests covered varying numbers of threads switched and 
| varying methods of allocating stacks.  Two systems gave 
| indistinguishable performance with 32b or 64b stacks, four gave 5%-10% 
| better performance using 64b stacks, and of the systems I tested, only 
| the P4 microarchitecture x86-64 system gave better performance for 32b 
| stacks, in that case vastly better.  Most systems had thread-to-thread 
| switch costs around 800-1200 cycles.  The P4 microarchitecture system 
| had 32b context switch costs around 3,000 cycles and 64b context 
| switches around 4,800 cycles.

i find it pretty unacceptable these days that we limit any aspect of 
pure 64-bit apps in any way to 4GB (or any other 32-bit-ish limit). 
[other than the small execution model which is 2GB obviously.]

	Ingo

--------------------->
// switch.cc -- measure thread-to-thread context switch times
// using either low-address stacks or high-address stacks

#include <sys/mman.h>
#include <sys/types.h>
#include <pthread.h>
#include <sched.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

const int kRequestedSwaps = 10000;
const int kNumThreads = 2;
const int kRequestedSwapsPerThread = kRequestedSwaps / kNumThreads;
const int kStackSize = 64 * 1024;
const int kTrials = 100;



typedef long long Tsc;
#define LARGEST_TSC	(static_cast<Tsc>(1ULL << (8 * sizeof(Tsc) - 2) - 1))

Tsc now() {
  unsigned int eax_lo, edx_hi;
  Tsc now;
  asm volatile("rdtsc" : "=a" (eax_lo), "=d" (edx_hi));
  now = ((Tsc)eax_lo) | ((Tsc)(edx_hi) << 32);
  return now;
}



// Use 0/1 for size to allow array subscripting.
const int pointer_sizes[] = { 32, 64 };
#define SZ_N  (sizeof(pointer_sizes) / sizeof(pointer_sizes[0]))
typedef int PointerSize;

PointerSize address_size(const void *vaddr) {
  intptr_t iaddr = reinterpret_cast<intptr_t>(vaddr);
  return ((iaddr >> 32) == 0) ? 0 : 1;
}



// One instance poitned to by every PerThread.
struct SharedArgs {
  // Read-only during a given test:
  cpu_set_t cpu;          // Only one bit set; all threads run on this CPU.

  // Read/write during a given test:
  pthread_barrier_t start_barrier;
  pthread_barrier_t stop_barrier;
};

// One per thread.
struct PerThread {
  // Thread args
  SharedArgs *shared_args;
  Tsc *stamps;

  // Per-thread storage.
  pthread_t thread;
  void *stack[SZ_N];                    // mmap()'d storage
  pthread_attr_t attr;
};



// Distinguish betwen start/stop timestamp for each iteration
typedef enum { START, STOP } StartStop;

// Record each timestamp in isolation for minimum runtime cache footprint;
// after a run, copy each timestamp to one of these so can sort and also track
// start/stop, etc.
struct Event {
  Tsc time;
  StartStop start_stop;
  int thread_num;
  int iter;
};

// Sort events in increasing time order.
int event_pred(const void *ve0, const void *ve1) {
  const Event *e0 = static_cast<const Event *>(ve0);
  const Event *e1 = static_cast<const Event *>(ve1);
  return e0->time - e1->time;
}

// Data to aggregate across runs.  Print only after runs are all over, in order
// to minimize possible overlap of I/O and benchmark.
struct Result {
  int pointer_size;
  int swaps;
  Tsc fastest;
};



// Each thread runs this worker.
void *worker(void *v_per_thread) {
  const PerThread *per_thread = static_cast<const PerThread *>(v_per_thread);
  SharedArgs *shared_args = per_thread->shared_args;

  // Run all threads on the same CPU.
  const cpu_set_t *cpu = &shared_args->cpu;
  int cc = sched_setaffinity(0/*self*/, sizeof(*cpu), cpu);
  if (cc != 0) {
    perror("sched_setaffinity");
    exit(1);
  }

  // Wait for all workers to be ready before running the inner loop.
  cc = pthread_barrier_wait(&shared_args->start_barrier);
  if ((cc != 0) && (cc != PTHREAD_BARRIER_SERIAL_THREAD)) {
    perror("pthread_barrier_wait");
    exit(1);
  }

  // Inner loop: track time before and after a swap.  In principle we
  // can use just one timestamp per iteration, but that gives more
  // variance between timestamps from overheads such as cache misses
  // not related to the context switch.
  Tsc *stamp = per_thread->stamps;
  for (int i = 0; i < kRequestedSwapsPerThread; ++i) {
    // Run timed critical section in as much isolation as possible.
    // Notably, read stamps but avoid saving them to memory and taking
    // cache misses until after both %tsc reads.
    asm volatile ("nop" ::: "memory");
    Tsc start = now();
    sched_yield();
    Tsc stop = now();
    asm volatile ("nop" ::: "memory");
    *stamp++ = start;
    *stamp++ = stop;
  }

  // Release the manager to clean up.
  cc = pthread_barrier_wait(&shared_args->stop_barrier);
  if ((cc != 0) && (cc != PTHREAD_BARRIER_SERIAL_THREAD)) {
    perror("pthread_barrier_wait");
    exit(1);
  }

  return NULL;
}


// Manager code that creates and starts worker threads, waits, then cleans up.
void run_test(PerThread *per_thread, PointerSize ps) {
  // Create worker threads.
  for (int th = 0; th < kNumThreads; ++th) {
    int cc = pthread_attr_setstack(&per_thread[th].attr,
                                   per_thread[th].stack[ps], kStackSize);
    if (cc != 0) {
      perror("pthread_attr_setstack");
      exit(1);
    }

    cc = pthread_create(&per_thread[th].thread, &per_thread[th].attr,
                        worker, &per_thread[th]);
    if (cc != 0) {
      perror("pthread_create");
      exit(1);
    }
  }

  // Release all worker threads to run their inner loop,
  // then wait for all to finish before joining any.
  SharedArgs *shared_args = per_thread->shared_args;
  int cc = pthread_barrier_wait(&shared_args->start_barrier);
  if ((cc != 0) && (cc != PTHREAD_BARRIER_SERIAL_THREAD)) {
    perror("pthread_barrier_wait");
    exit(1);
  }
  cc = pthread_barrier_wait(&shared_args->stop_barrier);
  if ((cc != 0) && (cc != PTHREAD_BARRIER_SERIAL_THREAD)) {
    perror("pthread_barrier_wait");
    exit(1);
  }

  // Clean up worker threads.
  for (int th = 0; th < kNumThreads; ++th) {
    int cc = pthread_join(per_thread[th].thread, NULL);
    if (cc != 0) {
      perror("pthread_join");
      exit(1);
    }
  }
}


// After a run, find out which sched_yield() calls actually did a yield,
// then find out the fastest sched_yield() that occured during the run.
Result process_data(Event *event, const PerThread per_thread[],
                    int requested_swaps_per_thread, PointerSize pointer_size) {
  // Copy timestamps in to a struct to associate timestamps with thread number.
  int event_num = 0;
  for (int th = 0; th < kNumThreads; ++th) {
    const Tsc *stamps = per_thread[th].stamps;
    int stamp_num = 0;
    StartStop start_stop = START;
    // 2* because there's a start stamp and stop stamp for each swap
    for (int iter = 0; iter < (2 * requested_swaps_per_thread); ++iter) {
      event[event_num].time = stamps[stamp_num++];
      event[event_num].start_stop = start_stop;
      start_stop = (start_stop == START) ? STOP : START;
      event[event_num].thread_num = th;
      event[event_num].iter = iter;
      ++event_num;
    }
  }
  int num_events = event_num;

  // Sort data in timestamp order.
  qsort(event, num_events, sizeof(event[0]), event_pred);

  // A context switch occurred ff two adjacent stamps are for
  // different threads.  A requested context switch very likely
  // occured if a context switch was between a START stamp in the
  // first thread and a STOP stamp in the second.  Note that some
  // non-requested context switches also get logged.  As example, a
  // preemptive cswap could have occured, and the following
  // sched_yield() may have done a yield-to-self.
  Tsc fastest = LARGEST_TSC;
  int swaps = 0;
  for (int e = 0; e < (num_events - 1); ++e) {
    if ((event[e].thread_num != event[e+1].thread_num) &&
        (event[e].start_stop == START) && (event[e+1].start_stop == STOP)) {
      ++swaps;
      Tsc t = event[e+1].time - event[e].time;
      if (t < fastest)
        fastest = t;
    }
  }

  Result result;
  result.pointer_size = pointer_size;
  result.swaps = swaps;
  result.fastest = fastest;
  return result;
}


// Dump results for one run.  Also aggregate "best of best" and "worst of best".
void dump_one_run(Tsc best[SZ_N], Tsc worst[SZ_N], int trial_num,
                  const Result *result) {
  Tsc t = result->fastest;
  PointerSize ps = result->pointer_size;
  int cc = printf("run: %d pointer-size: %d requested-swaps: %d got-swaps: %d fastest: %lld\n",
                  trial_num, pointer_sizes[ps],
                  kRequestedSwaps, result->swaps, result->fastest);
  if (cc < 0) {
    perror("printf");
    exit(1);
  }
  if (t < best[ps])
    best[ps] = t;
  if (t > worst[ps])
    worst[ps] = t;
}

void *mmap_stack(PointerSize pointer_size) {
  int location_flag;
  switch(pointer_sizes[pointer_size]) {
    case 32: location_flag = MAP_32BIT; break;
    case 64: location_flag = 0x0; break;
    default:
      fprintf(stderr, "Implementation error: unhandled stack placement\n");
      exit(1);
  }

  void *stack = mmap(0, kStackSize, PROT_READ|PROT_WRITE,
                     MAP_PRIVATE|MAP_ANONYMOUS|location_flag, 0, 0);
  if (stack == MAP_FAILED) {
    perror("mmap");
    exit(1);
  }

  // Check we got the stack location we requested
  PointerSize got = address_size(stack);
  if (got != pointer_size) {
    // Note: MSWindohs and Linux are asymmetrical about %p: one prints
    // with a leading 0x, the other does not.  Assume here it does not matter.
    fprintf(stderr, "Did not get requested pointer size\n");
    exit(1);
  }

  return stack;
}

void munmap_stack(void *stack) {
  int cc = munmap(stack, kStackSize);
  if (cc != 0) {
    perror("munmap");
    exit(1);
  }
}

int main(int argc, char **argv) {
  SharedArgs shared_args;

  // Find the highest-numbered CPU, all threads run on that thread only.
  {
    cpu_set_t set;
    int sz = sched_getaffinity(0, sizeof(set), &set);
    // Documentation says sched_getaffinity() returns the size used by
    // the kernel, but by experiment it returns zero on some 2.6.18
    // systems, but with a sensible mask nonetheless.
    if (sz < 0) {
      perror ("sched_getaffinity");
      exit(1);
    }
    // Find an available processor/core.  If possible grab something other
    // than CPU 0 to minimize interference from interrupts preferentially
    // delivered to core 0.
    int proc;
    for (proc=CPU_SETSIZE-1; proc>=0; --proc)
      if (CPU_ISSET(proc, &set))
        break;
    if (proc >= CPU_SETSIZE) {
      fprintf (stderr, "No virtual processors!?\n");
      exit(1);
    }
    CPU_ZERO(&shared_args.cpu);
    CPU_SET(proc, &shared_args.cpu);
  }

  // Reusable per-thread setup
  PerThread per_thread[kNumThreads];
  for (int th = 0; th < kNumThreads; ++th) {
    per_thread[th].stamps = new Tsc[2 * kRequestedSwaps];
    per_thread[th].shared_args = &shared_args;
    for (int ps = 0; ps < SZ_N; ++ps)
      per_thread[th].stack[ps] = mmap_stack(static_cast<PointerSize>(ps));
    int cc = pthread_attr_init(&per_thread[th].attr);
    if (cc != 0) {
      perror("pthread_attr_init");
      exit(1);
    }
  }

  // Storage for post-processing timestamps from one trial run.
  // 2 stamps per iteration.  'new' the storage since long runs
  // otherwise overflow the stack.
  Event *event = new Event[kNumThreads * (2 * kRequestedSwaps)];

  // Post-processed data for all trial runs.  Written during the "run
  // tests" phase and read during the "dump data" phase.
  int kNumRuns = kTrials * SZ_N;
  Result result[kNumRuns];
  int result_num = 0;

  // Pthread barriers are cyclic, so can reuse them. +1 for the manager thread
  pthread_barrier_init(&shared_args.start_barrier, NULL, kNumThreads + 1);
  pthread_barrier_init(&shared_args.stop_barrier, NULL, kNumThreads + 1);

  // Warming runs
  {
    run_test(per_thread, static_cast<PointerSize>(0/*32b*/));
    run_test(per_thread, static_cast<PointerSize>(1/*64b*/));
  }

  // Run tests
  for (int trial = 0; trial < kTrials; ++trial) {
    int requested_swaps_per_thread = kRequestedSwaps / kNumThreads;
    for (int ps = 0; ps < SZ_N; ++ps) {
      PointerSize pointer_size = static_cast<PointerSize>(ps);
      run_test(per_thread, pointer_size);

      // Process data and save to RAM.  Do not do explicit I/O here on the
      // basis background activity may interfere with context switches.
      result[result_num++] = process_data(event,
                                          per_thread,
                                          requested_swaps_per_thread,
                                          pointer_size);
    }
  }

  // Cleanup
  pthread_barrier_destroy(&shared_args.start_barrier);
  pthread_barrier_destroy(&shared_args.stop_barrier);

  for (int th = 0; th < kNumThreads; ++th) {
    delete[] per_thread[th].stamps;
    for (int ps = 0; ps < SZ_N; ++ps)
      munmap_stack(per_thread[th].stack[ps]);
    int cc = pthread_attr_destroy(&per_thread[th].attr);
    if (cc != 0) {
      perror("pthread_attr_destory");
      exit(1);
    }
  }
  delete[] event;

  // Dump data from RAM to stdout.
  Tsc best[SZ_N] = { LARGEST_TSC, LARGEST_TSC };
  Tsc worst[SZ_N] = { 0, 0 };
  for (int r = 0; r < result_num; ++r)
    dump_one_run(best, worst, r, &result[r]);
  for (int sz = 0; sz < SZ_N; ++sz) {
    int cc = printf("best-of-best[%d]: %lld\nworst-of-best[%d]: %lld\n",
                    pointer_sizes[sz], best[sz], pointer_sizes[sz], worst[sz]);
    if (cc < 0) {
      perror("printf");
      exit(1);
    }
  }
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
