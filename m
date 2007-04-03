Date: Tue, 3 Apr 2007 16:29:37 -0400
From: Jakub Jelinek <jakub@redhat.com>
Subject: Re: missing madvise functionality
Message-ID: <20070403202937.GE355@devserv.devel.redhat.com>
Reply-To: Jakub Jelinek <jakub@redhat.com>
References: <46128051.9000609@redhat.com> <p73648dz5oa.fsf@bingen.suse.de> <46128CC2.9090809@redhat.com> <20070403172841.GB23689@one.firstfloor.org> <20070403125903.3e8577f4.akpm@linux-foundation.org> <4612B645.7030902@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4612B645.7030902@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 03, 2007 at 01:17:09PM -0700, Ulrich Drepper wrote:
> Andrew Morton wrote:
> > Ulrich, could you suggest a little test app which would demonstrate this
> > behaviour?
> 
> It's not really reliably possible to demonstrate this with a small
> program using malloc.  You'd need something like this mysql test case
> which Rik said is not hard to run by yourself.
> 
> If somebody adds a kernel interface I can easily produce a glibc patch
> so that the test can be run in the new environment.
> 
> But it's of course easy enough to simulate the specific problem in a
> micro benchmark.  If you want that let me know.

I think something like following testcase which simulates what free
and malloc do when trimming/growing a non-main arena.

My guess is that all the page zeroing is pretty expensive as well and
takes significant time, but I haven't profiled it.

#include <pthread.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <unistd.h>

void *
tf (void *arg)
{
  (void) arg;
  size_t ps = sysconf (_SC_PAGE_SIZE);
  void *p = mmap (NULL, 128 * ps, PROT_READ | PROT_WRITE,
                  MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  if (p == MAP_FAILED)
    exit (1);
  int i;
  for (i = 0; i < 100000; i++)
    {
      /* Pretend to use the buffer.  */
      char *q, *r = (char *) p + 128 * ps;
      size_t s;
      for (q = (char *) p; q < r; q += ps)
        *q = 1;
      for (s = 0, q = (char *) p; q < r; q += ps)
        s += *q;
      /* Free it.  Replace this mmap with
         madvise (p, 128 * ps, MADV_THROWAWAY) when implemented.  */
      if (mmap (p, 128 * ps, PROT_NONE,
                MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED, -1, 0) != p)
        exit (2);
      /* And immediately malloc again.  This would then be deleted.  */
      if (mprotect (p, 128 * ps, PROT_READ | PROT_WRITE))
        exit (3);
    }
  return NULL;
}

int
main (void)
{
  pthread_t th[32];
  int i;
  for (i = 0; i < 32; i++)
    if (pthread_create (&th[i], NULL, tf, NULL))
      exit (4);
  for (i = 0; i < 32; i++)
    pthread_join (th[i], NULL);
  return 0;
}

	Jakub

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
