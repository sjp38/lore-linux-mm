Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B07BD8D0040
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 07:58:38 -0500 (EST)
Date: Wed, 2 Mar 2011 14:55:13 +0200 (EET)
From: Aaro Koskinen <aaro.koskinen@nokia.com>
Subject: Re: [PATCH] procfs: fix /proc/<pid>/maps heap check
In-Reply-To: <1298996813-8625-1-git-send-email-aaro.koskinen@nokia.com>
Message-ID: <alpine.DEB.1.10.1103021449000.27610@esdhcp041196.research.nokia.com>
References: <1298996813-8625-1-git-send-email-aaro.koskinen@nokia.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, stable@kernel.org, Aaro Koskinen <aaro.koskinen@nokia.com>

Hi,

On Tue, 1 Mar 2011, Aaro Koskinen wrote:
> The current check looks wrong and prints "[heap]" only if the mapping
> matches exactly the heap. However, the heap may be merged with some
> other mappings, and there may be also be multiple mappings.
>
> Signed-off-by: Aaro Koskinen <aaro.koskinen@nokia.com>
> Cc: stable@kernel.org

Below is a test program and an example output showing the problem,
and the correct output with the patch:

Without the patch:

 	# ./a.out &
 	# cat /proc/$!/maps | head -4
 	00008000-00009000 r-xp 00000000 01:00 9224       /a.out
 	00010000-00011000 rw-p 00000000 01:00 9224       /a.out
 	00011000-00012000 rw-p 00000000 00:00 0
 	00012000-00013000 rw-p 00000000 00:00 0

With the patch:

 	# ./a.out &
 	# cat /proc/$!/maps | head -4
 	00008000-00009000 r-xp 00000000 01:00 9228       /a.out
 	00010000-00011000 rw-p 00000000 01:00 9228       /a.out
 	00011000-00012000 rw-p 00000000 00:00 0          [heap]
 	00012000-00013000 rw-p 00000000 00:00 0          [heap]

The test program:

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>

int main (void)
{
 	if (sbrk(4096) == (void *)-1) {
 		perror("first sbrk(): ");
 		return EXIT_FAILURE;
 	}

 	if (mlockall(MCL_FUTURE)) {
 		perror("mlockall(): ");
 		return EXIT_FAILURE;
 	}

 	if (sbrk(4096) == (void *)-1) {
 		perror("second sbrk(): ");
 		return EXIT_FAILURE;
 	}

 	while (1)
 		sleep(1);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
