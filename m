Subject: Re: [RFC][PATCH] lru_add_drain_all() don't use
	schedule_on_each_cpu()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <2f11576a0810290017g310e4469gd27aa857866849bd@mail.gmail.com>
References: <2f11576a0810210851g6e0d86benef5d801871886dd7@mail.gmail.com>
	 <2f11576a0810211018g5166c1byc182f1194cfdd45d@mail.gmail.com>
	 <20081023235425.9C40.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20081027145509.ebffcf0e.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0810280914010.15939@quilx.com>
	 <20081028134536.9a7a5351.akpm@linux-foundation.org>
	 <1225229366.6343.74.camel@lts-notebook>
	 <2f11576a0810290017g310e4469gd27aa857866849bd@mail.gmail.com>
Content-Type: multipart/mixed; boundary="=-1BA4qEJtvsphARYKZVsK"
Date: Wed, 29 Oct 2008 08:40:14 -0400
Message-Id: <1225284014.8257.36.camel@lts-notebook>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, npiggin@suse.de, linux-kernel@vger.kernel.org, hugh@veritas.com, torvalds@linux-foundation.org, riel@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-1BA4qEJtvsphARYKZVsK
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2008-10-29 at 16:17 +0900, KOSAKI Motohiro wrote:
> > I believe that we still  have the lru_drain_all() called from the fault
> > path [with mmap_sem held] in clear_page_mlock().  We call
> > clear_page_mlock() on COW of an mlocked page in a VM_LOCKED vma to
> > ensure that we don't end up with an mlocked page in some other task's
> > non-VM_LOCKED vma where we'd then fail to munlock it later.  During
> > development testing, Rik encountered scenarios where a page would
> > encounter a COW fault while it was still making its way to the LRU via
> > the pagevecs.  So, he added the 'drain_all() and that seemed to avoid
> > this scenario.
> 
> Agreed.
> 
> 
> > Now, in the current upstream version of the unevictable mlocked pages
> > patches, we just count any mlocked pages [vmstat] that make their way to
> > free*page() instead of BUGging out, as we were doing earlier during
> > development.  So, maybe we can drop the lru_drain_add()s in the
> > unevictable mlocked pages work and live with the occasional freed
> > mlocked page, or mlocked page on the active/inactive lists to be dealt
> > with by vmscan.
> 
> hm, okey.
> maybe, I was wrong.
> 
> I'll make "dropping lru_add_drain_all()" patch soon.
> I expect I need few days.
>   make the patch:                  1 day
>   confirm by stress workload:  2-3 days
> 
> because rik's original problem only happend on heavy wokload, I think.

Indeed.  It was an ad hoc test program [2 versions attached] written
specifically to beat on COW of shared pages mlocked by parent then COWed
by parent or child and unmapped explicitly or via exit.  We were trying
to find all the ways the we could end up freeing mlocked pages--and
there were several.  Most of these turned out to be genuine
coding/design defects [as difficult as that may be to believe :-)], so
tracking them down was worthwhile.  And, I think that, in general,
clearing a page's mlocked state and rescuing from the unevictable lru
list on COW--to prevent the mlocked page from ending up mapped into some
task's non-VM_LOCKED vma--is a good thing to strive for.  

Now, looking at the current code [28-rc1] in [__]clear_page_mlock():
We've already cleared the PG_mlocked flag, we've decremented the mlocked
pages stats, and we're just trying to rescue the page from the
unevictable list to the in/active list.  If we fail to isolate the page,
then either some other task has it isolated and will return it to an
appropriate lru or it resides in a pagevec heading for an in/active lru
list.  We don't use pagevec for unevictable list.  Any other cases?  If
not, then we can probably dispense with the "try harder" logic--the
lru_add_drain()--in __clear_page_mlock().

Do you agree?  Or have I missed something?

Lee   

--=-1BA4qEJtvsphARYKZVsK
Content-Disposition: attachment; filename=rvr-mlock-oops.c
Content-Type: text/x-csrc; name=rvr-mlock-oops.c; charset=UTF-8
Content-Transfer-Encoding: 7bit

/*
 * In the split VM code in 2.6.25-rc3-mm1 and later, we see PG_mlock
 * pages freed from the exit/exit_mmap path.  This test case creates
 * a process, forks it, mlocks, touches some memory and exits, to
 * try and trigger the bug - Rik van Riel, Mar 2008
 */
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#define NUMFORKS 1000
#define MEMSIZE 1024*1024

void child(void)
{
	char * mem;
	int err;
	int i;

	err = mlockall(MCL_CURRENT|MCL_FUTURE);
	if (err < 0) {
		printf("child mlock failed\n");
		exit(1);
	}

	mem = malloc(MEMSIZE);
	if (!mem) {
		printf("child could not allocate memory\n");
		exit(2);
	}

	/* Touch the memory so the kernel allocates actual pages. */
	for (i = 0; i < MEMSIZE; i++)
		mem[i] = i;

	/* Avoids the oops?  Nope ... :( */
	munlockall();

	/* This is where we can trigger the oops. */
	exit(0);
}

int main(int argc, char *argv)
{
	int i;
	int status;

	for (i = 0; i < NUMFORKS ; i++) {
		pid_t pid = fork();

		if (!pid)	
			child(); /* does not return */
		else if (pid > 0)
			wait(&status);
		else {
			printf("fork failed\n");
			exit(1);
		}
	}
}

--=-1BA4qEJtvsphARYKZVsK
Content-Disposition: attachment; filename=rvr-mlock-oops2.c
Content-Type: text/x-csrc; name=rvr-mlock-oops2.c; charset=UTF-8
Content-Transfer-Encoding: 7bit

/*
 * In the split VM code in 2.6.25-rc3-mm1 and later, we see PG_mlock
 * pages freed from the exit/exit_mmap path.  This test case creates
 * a process, forks it, mlocks, touches some memory and exits, to
 * try and trigger the bug - Rik van Riel, Mar 2008
 */
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#define NUMFORKS 1
#define MEMSIZE 1024*1024

void child(void)
{
	char * mem;
	int i;

	mem = malloc(MEMSIZE);
	if (!mem) {
		printf("child could not allocate memory\n");
		exit(2);
	}

	/* Touch the memory so the kernel allocates actual pages. */
	for (i = 0; i < MEMSIZE; i++)
		mem[i] = i;

	/* This is where we can trigger the oops. */
	exit(0);
}

int main(int argc, char *argv)
{
	int i;
	int status;
	pid_t pid;
	int err;

	err = mlockall(MCL_CURRENT|MCL_FUTURE);
	if (err < 0) {
		printf("parent mlock failed\n");
		exit(1);
	}

	pid = getpid();

	printf("parent pid = %d\n", pid);

	for (i = 0; i < NUMFORKS ; i++) {
		pid = fork();

		if (!pid)	
			child(); /* does not return */
		else if (pid > 0)
			wait(&status);
		else {
			printf("fork failed\n");
			exit(1);
		}
	}
}

--=-1BA4qEJtvsphARYKZVsK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
