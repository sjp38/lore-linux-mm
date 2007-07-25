Message-ID: <46A7031D.5080300@gmail.com>
Date: Wed, 25 Jul 2007 10:00:29 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>  <200707102015.44004.kernel@kolivas.org>  <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>  <46A57068.3070701@yahoo.com.au>  <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>  <46A58B49.3050508@yahoo.com.au> <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com> <Pine.LNX.4.64.0707242130470.2229@asgard.lang.hm>
In-Reply-To: <Pine.LNX.4.64.0707242130470.2229@asgard.lang.hm>
Content-Type: multipart/mixed;
 boundary="------------010607010003030501040802"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: david@lang.hm
Cc: Ray Lee <ray-lk@madrabbit.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------010607010003030501040802
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

On 07/25/2007 06:46 AM, david@lang.hm wrote:

> you could make a synthetic test by writing a memory hog that allocates 
> 3/4 of your ram then pauses waiting for input and then randomly accesses 
> the memory for a while (say randomly accessing 2x # of pages allocated) 
> and then pausing again before repeating

Something like this?

> run two of these, alternating which one is running at any one time. time 
> how long it takes to do the random accesses.
> 
> the difference in this time should be a fair example of how much it 
> would impact the user.

Notenotenote, not sure what you're going to show with it (times are simply 
as horrendous as I'd expect) but thought I'd try to inject something other 
than steaming cups of 4-letter beverages.

Rene.

--------------010607010003030501040802
Content-Type: text/plain;
 name="hog.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hog.c"

/* gcc -W -Wall -o hog hog.c */

#include <stdlib.h>
#include <stdio.h>

#include <sys/time.h>
#include <unistd.h>

int main(void)
{
	int pages, pagesize, i;
	unsigned char *mem;
	struct timeval tv;
	
	pages = sysconf(_SC_PHYS_PAGES);
	if (pages < 0) {
		perror("_SC_PHYS_PAGES");
		return EXIT_FAILURE;
	}
	pages = (3 * pages) / 4;

	pagesize = sysconf(_SC_PAGESIZE);
	if (pagesize < 0) {
		perror("_SC_PAGESIZE");
		return EXIT_FAILURE;
	}

	mem = malloc(pages * pagesize);
	if (!mem) {
		fprintf(stderr, "out of memory\n");
		return EXIT_FAILURE;
	}
	for (i = 0; i < pages; i++)
		mem[i * pagesize] = 0;

	gettimeofday(&tv, NULL);
	srand((unsigned int)tv.tv_sec);

	while (1) {
		struct timeval start;

		getchar();

		gettimeofday(&start, NULL);
		for (i = 0; i < 2 * pages; i++)
			mem[(rand() / (RAND_MAX / pages + 1)) * pagesize] = 0;
		gettimeofday(&tv, NULL);

		timersub(&tv, &start, &tv);
		printf("%lu.%lu\n", tv.tv_sec, tv.tv_usec);
	}

	return EXIT_SUCCESS;
}

--------------010607010003030501040802--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
