Received: from pocari-sweat.jprc.com (POCARI-SWEAT.JPRC.COM [207.86.147.217])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA03345
	for <linux-mm@kvack.org>; Wed, 3 Dec 1997 21:32:40 -0500
Subject: Re: 2.0.30: Lockups with huge proceses mallocing all VM
References: <Pine.LNX.3.91.971203225838.738B-100000@mirkwood.dummy.home>
From: Karl Kleinpaste <karl@jprc.com>
Date: 03 Dec 1997 21:26:19 -0500
In-Reply-To: Rik van Riel's message of "Wed, 3 Dec 1997 23:05:44 +0100 (MET)"
Message-ID: <vxkzpmhalo4.fsf@pocari-sweat.jprc.com>
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@fys.ruu.nl
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

[ I'm not on linux-mm, in fact I didn't know it existed until now. ]

Rik van Riel <H.H.vanRiel@fys.ruu.nl> writes:
> No, your system has just run out of memory... Maybe we should add
> some code to the kernel that puts out a KERN_ALERT message saying
> that free swap-space went below 10%

I do not think that would be helpful, and it misses the core issue.

> You mean that the program allocates memory without limit...
> It just allocates, allocates, allocates and NEVER FREE()s
> memory... This is just _wrong_ program design... 

The fact that the application is flawed is irrelevant.

On the one hand, it is certainly true that the program should behave
differently.  Of course, it really does want a hell of a lot of VM,
and that's OK: We expect that.  Ultimately, given the size of the
training data corpus in need of analysis -- I spidered the entirety of
Yahoo for this purpose -- we'll add yet more memory and more swap
space to accommodate it.  Or the author will do some serious rewriting
so as to maintain state outside VM.  But the problem at hand is not
that the application wants (too much) memory.  The problem is...

An application killed the system.

That must not happen.  Not ever.  For an ordinary application to be
able to destroy the machine as a whole by the simple act of demanding
excessive resources is entirely wrong.  If Linux is unable to protect
itself from the circumstance of resource overcommit, well, we should
all pack up and go home.

Please bear in mind that all this application does is to read a couple
hundred thousand files, build word vectors, and write a classification
database.  There is nothing remarkable about this sort of system
resource usage, other than its magnitude.

_If_ the situation were mere VM exhaustion (it's not; see below), then
a proper defense by the system would be either to deny further
malloc() attempts by returning NULLs in response to excessive
requests, or to kill the offending process entirely.  It is not
acceptable under any circumstance that the system attempt to satisfy
any request in a manner which induces the overall system's own death.

> hope this helps,

No, not really.  All that's been said is that Linux stands utterly
undefended against a really rather simplistic system resource abuse.

But I really don't think that's the case here.  Besides all the
preceding, I have toyed with some test programs which do nothing but
allocate page after page after page of memory, touching each page to
ensure that it has all been truly allocated...and I can't kill the
system that way.  Using such a program (see below), and siccing it on
my 700Mbytes' worth of VM, when the system approaches VM exhaustion,
the program fails, getting back a NULL from malloc().  Thus, Linux
defends itself at least partly, and what stands in question is where
this line of defense fails, where the bug in that defense lies.  The
problem is not nearly so simplistic as mere VM exhaustion.  It is
surely _tied closely to_ VM exhaustion, but there is something more
going on than just exhaustion.

--karl

PS- mem.c follows.  Run as, e.g.,
	mem 700000 512 512 1000
or
	mem 700000 16 64 1000
The latter will malloc() 1Kbyte at a time, making 700,000 attempts,
printing a `.' every 1000 malloc's, as an I'm-still-alive indicator.
But the system does not die in so doing -- rather, the program will
fail as desired, and stop.

#include <stdio.h>

main(int argc, char **argv)
{
    char *p, buf[1024];
    int count, i, j;
    int mstep, minterval, msize, modulus;

    if (argc != 5)
    {
        fprintf(stderr, "Usage: %s count step interval modulus\n", argv[0]);
	exit(1);
    }

    count = atoi(argv[1]);
    mstep = atoi(argv[2]);
    minterval = atoi(argv[3]);
    msize = mstep * minterval;
    modulus = atoi(argv[4]);

    for (i = 0; i < count; i++)
    {
	if ((p = (char *) malloc(msize)) == NULL)
	{
	    fprintf(stderr, "%s: malloc NULL, i=%d", argv[0], i);
	    goto done;
	}
	else
	{
	    for (j = 0; j < minterval; j++)
		*(p+(j*mstep)+10) = 'a';
	}
	if ((i % modulus) == 0)
	{
	    putchar('.');
	    fflush(stdout);
	}
    }
done:
    putchar('\n');
    gets(buf);
    exit(0);
}
