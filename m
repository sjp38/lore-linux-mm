Date: Wed, 4 Apr 2007 16:00:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: preemption and rwsems (was: Re: missing madvise functionality)
Message-Id: <20070404160006.8d81a533.akpm@linux-foundation.org>
In-Reply-To: <20070403202937.GE355@devserv.devel.redhat.com>
References: <46128051.9000609@redhat.com>
	<p73648dz5oa.fsf@bingen.suse.de>
	<46128CC2.9090809@redhat.com>
	<20070403172841.GB23689@one.firstfloor.org>
	<20070403125903.3e8577f4.akpm@linux-foundation.org>
	<4612B645.7030902@redhat.com>
	<20070403202937.GE355@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jakub Jelinek <jakub@redhat.com>
Cc: Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Apr 2007 16:29:37 -0400
Jakub Jelinek <jakub@redhat.com> wrote:

> #include <pthread.h>
> #include <stdlib.h>
> #include <sys/mman.h>
> #include <unistd.h>
> 
> void *
> tf (void *arg)
> {
>   (void) arg;
>   size_t ps = sysconf (_SC_PAGE_SIZE);
>   void *p = mmap (NULL, 128 * ps, PROT_READ | PROT_WRITE,
>                   MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
>   if (p == MAP_FAILED)
>     exit (1);
>   int i;
>   for (i = 0; i < 100000; i++)
>     {
>       /* Pretend to use the buffer.  */
>       char *q, *r = (char *) p + 128 * ps;
>       size_t s;
>       for (q = (char *) p; q < r; q += ps)
>         *q = 1;
>       for (s = 0, q = (char *) p; q < r; q += ps)
>         s += *q;
>       /* Free it.  Replace this mmap with
>          madvise (p, 128 * ps, MADV_THROWAWAY) when implemented.  */
>       if (mmap (p, 128 * ps, PROT_NONE,
>                 MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED, -1, 0) != p)
>         exit (2);
>       /* And immediately malloc again.  This would then be deleted.  */
>       if (mprotect (p, 128 * ps, PROT_READ | PROT_WRITE))
>         exit (3);
>     }
>   return NULL;
> }
> 
> int
> main (void)
> {
>   pthread_t th[32];
>   int i;
>   for (i = 0; i < 32; i++)
>     if (pthread_create (&th[i], NULL, tf, NULL))
>       exit (4);
>   for (i = 0; i < 32; i++)
>     pthread_join (th[i], NULL);
>   return 0;
> }

This little test app is fun.

I run it all on a single CPU under `taskset -c 0' on the 8-way and it still
causes 160,000 context switches per second and takes 9.5 seconds (after
s/100000/1000).

The kernel has

# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
# CONFIG_PREEMPT_BKL is not set

and when I switch that to

CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
# CONFIG_PREEMPT_BKL is not set

the context switch rate falls to zilch and total runtime falls to 6.4
seconds.

Presumably the same problem will occur with CONFIG_PREEMPT_VOLUNTARY on
uniprocessor kernels.

<thinks>

What we effectively have is 32 threads on a single CPU all doing

	for (ever) {
		down_write()
		up_write()
		down_read()
		up_read();
	}

and rwsems are "fair".  So

  thread A                                     thread B

  down_write();

  cond_resched()
  ->schedule()

                                               down_read() -> blocks

  up_write()

  down_read()

  up_read()

  down_write() -> there's a reader: block

                                               down_read() -> succeeds

                                               up_read()

                                               down_write() -> there's another down_writer: block

  down_write() -> succeeds

  up_write()

  down_read() -> there's a down_writer: block

                                               down_write() succeeds

                                               up_write()

                                               down_read() -> succeeds

                                               up_read()

                                               down_write() -> there's a down_reader: block

  down_read() succeeds


ad nauseum.


If that cond_resched() was not there, none of this would ever happen - each
thread merrily chugs away doing its ups and downs until it expires its
timeslice.  Interesting, in a sad sort of way.



Setting CONFIG_PREEMPT_NONE doesn't appear to make any difference to
context switch rate or runtime when all eight CPUs are used, so this
phenomenon is unlikely to be involved in the mysql problem.

I wonder why a similar thing doesn't happen when more than one CPU is used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
