Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA25172
	for <linux-mm@kvack.org>; Tue, 1 Dec 1998 10:51:26 -0500
Subject: Re: [PATCH] swapin readahead
References: <Pine.LNX.3.96.981127001214.445A-100000@mirkwood.dummy.home> <199812011513.PAA18172@dax.scot.redhat.com>
Reply-To: Zlatko.Calusic@CARNet.hr
Mime-Version: 1.0
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 01 Dec 1998 16:51:04 +0100
In-Reply-To: "Stephen C. Tweedie"'s message of "Tue, 1 Dec 1998 15:13:22 GMT"
Message-ID: <87lnkrn9nb.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi Rik,
> 
> In article <Pine.LNX.3.96.981127001214.445A-100000@mirkwood.dummy.home>,
> Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:
> 
> > here is a very first primitive version of as swapin
> > readahead patch. It seems to give much increased
> > throughput to swap and the desktop switch time has
> > decreased noticably.
> 
> > The checks are all needed. The first two checks are there
> > to avoid annoying messages from swap_state.c :)) 
> 
> There's a third check needed, I think, which probably accounts for the
> swap_duplicate errors people have been noting.  You need to skip pages
> which are marked as locked in the swap_lockmap, or the async page read
> may block (you might be trying to read in a page which is still being
> written to swap).  In this case, by the time you have slept, the swap
> entry is not necessarily still in use, so you may end up reading an
> unused swap entry.  That would certainly lead to swap_duplicate
> warnings, although I think they should be benign.
> 

That warnings are probably benign, but the patch in the whole has at
least one big engineering problem. Unfortunately, I'm trying to
understand other parts of the MM code, so currently I don't have the
time needed to play with the swapin readahead more.

But, what I observed is that memory gets lost in some strange way. It
is possible that lost pages are in the swap cache, and it looks like
nothing frees them at all.

Problem is becoming worse, as you push MM to its limit.

I don't understand how Rik doesn't notice this, but I'm able to
deadlock machine in a matter of minutes, by running simple memory
mallocing & reading program.

Needless to say, performance measurement are postponed until my
machine can stay alive after applying the patch. :)

To help further debugging, I'm appending source of a very simple
program that is one of the tests I like to run to see what happened to
MM recently. :)

Call it hogmem.c, compile it and then run it with two arguments. First
is how much memory to allocate (make it slightly bigger than size of
your physical memory in MB, to make system swapping), and second is
how many times to read the memory (some small number).

For example, I'm using it like hogmem 100 3 (with 64MB of RAM).

After it finishes (that won't happen if you apply swapin readahead
patch, you've been warned!), it will report memory reading speed in
MB/sec. That is, swapping speed, if your argv[1] was large enough to
make life painfull for your disk(s). :)

I'm looking forward for your comments on the subject.

Rik, hopefully this helps you to find a problem with logic in your
patch.

Also, looking at the patch source, it looks like the comment there is
completely misleading, as the for() loop is not doing anything, at
all. The patch can be shortened to do offset++, if() and only ONE
read_swap_cache_async, if I'm understanding it correctly. Sorry, I'm
not including it here, have some other things to do fast.

hogmem.c:

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <limits.h>
#include <signal.h>
#include <time.h>
#include <sys/times.h>

#define MB (1024 * 1024)

int nr, intsize, i, t;
clock_t st;
struct tms dummy;

void intr(int intnum)
{
    clock_t et = times(&dummy);

    printf("\nMemory speed: %.2f MB/sec\n", (2 * t * CLK_TCK * nr + (double) i * CLK_TCK * intsize / MB) / (et - st));
    exit(EXIT_SUCCESS);
}

int main(int argc, char **argv)
{
    int max, nr_times, *area, c;

    setbuf(stdout, 0);
    signal(SIGINT, intr);
    signal(SIGTERM, intr);
    intsize = sizeof(int);
    if (argc < 2 || argc > 3) {
	fprintf(stderr, "Usage: hogmem <MB> [times]\n");
	exit(EXIT_FAILURE);
    }
    nr = atoi(argv[1]);
    if (argc == 3)
	nr_times = atoi(argv[2]);
    else
	nr_times = INT_MAX;
    area = malloc(nr * MB);
    max = nr * MB / intsize;
    st = times(&dummy);
    for (c = 0; c < nr_times; c++)
    {
	for (i = 0; i < max; i++)
	    area[i]++;
	t++;
	putchar('.');
    }
    i = 0;
    intr(0);
    /* notreached */
    exit(EXIT_SUCCESS);
}

Regards,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	 Suicide is the most sincere form of self criticism.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
