Message-ID: <3905EB26.8DBFD111@mandrakesoft.com>
Date: Tue, 25 Apr 2000 14:59:50 -0400
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
References: <Pine.LNX.4.21.0004251757360.9768-100000@alpha.random> <Pine.LNX.4.21.0004251418520.10408-100000@duckman.conectiva> <20000425113616.A7176@stormix.com>
Content-Type: multipart/mixed;
 boundary="------------29A5383F0B1F58900684AA9C"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Simon Kirby <sim@stormix.com>
Cc: riel@nl.linux.org, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Ben LaHaise <bcrl@redhat.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------29A5383F0B1F58900684AA9C
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Simon Kirby wrote:
> Hrmm.. I guess the ideal solution would be that swappable pages would age
> just like cache pages and everything else?  Then, if a particular
> program's page hasn't been accessed for 60 seconds and there is nothing
> older in the page cahce, it would swap out...

Again a policy decision...  I think such a feature should be present and
enabled by default, but there are some people who would prefer that
their configuration not do this, or would prefer that the timeout for
old pages be far longer than 60 seconds.

The main reason is there is a noticeable performance increase when you
have so much more physical memory available for page and buffer cache. 
I manually force this behavior now with the attached 'fillmem' program,
usually before a big compile on an otherwise quiet machine.

	Jeff





-- 
Jeff Garzik              | Nothing cures insomnia like the
Building 1024            | realization that it's time to get up.
MandrakeSoft, Inc.       |        -- random fortune
--------------29A5383F0B1F58900684AA9C
Content-Type: text/plain; charset=us-ascii;
 name="fillmem.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fillmem.c"

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

#define MEGS 140
#define MEG (1024 * 1024)

int main (int argc, char *argv[])
{
	void **data;
	int i, r;
	size_t megs = MEGS;

	if ((argc >= 2) && (atoi(argv[1]) > 0))
		megs = atoi(argv[1]);

	data = malloc (megs * sizeof (void*));
	if (!data) abort();

	memset (data, 0, megs * sizeof (void*));

	srand(time(NULL));

	for (i = 0; i < megs; i++) {
		data[i] = malloc(MEG);
		memset (data[i], i, MEG);
		printf("malloc/memset %03d/%03lu\n", i+1, megs);
	}
	for (i = megs - 1; i >= 0; i--) {
		r = rand() % 200;
		memset (data[i], r, MEG);
		printf("memset #2 %03d/%03lu = %d\n", i+1, megs, r);
	}
	printf("done\n");
	return 0;
}

--------------29A5383F0B1F58900684AA9C--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
