Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0D1CE8D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 20:30:25 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5B3863EE0C1
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 10:30:20 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BAE145DE67
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 10:30:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E15B45DE4D
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 10:30:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C9A0E38002
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 10:30:20 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CAEA21DB803C
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 10:30:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] procfs: fix /proc/<pid>/maps heap check
In-Reply-To: <alpine.DEB.1.10.1103021449000.27610@esdhcp041196.research.nokia.com>
References: <1298996813-8625-1-git-send-email-aaro.koskinen@nokia.com> <alpine.DEB.1.10.1103021449000.27610@esdhcp041196.research.nokia.com>
Message-Id: <20110303102631.B939.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Mar 2011 10:30:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaro Koskinen <aaro.koskinen@nokia.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, stable@kernel.org

> Hi,
> 
> On Tue, 1 Mar 2011, Aaro Koskinen wrote:
> > The current check looks wrong and prints "[heap]" only if the mapping
> > matches exactly the heap. However, the heap may be merged with some
> > other mappings, and there may be also be multiple mappings.
> >
> > Signed-off-by: Aaro Koskinen <aaro.koskinen@nokia.com>
> > Cc: stable@kernel.org
> 
> Below is a test program and an example output showing the problem,
> and the correct output with the patch:
> 
> Without the patch:
> 
>  	# ./a.out &
>  	# cat /proc/$!/maps | head -4
>  	00008000-00009000 r-xp 00000000 01:00 9224       /a.out
>  	00010000-00011000 rw-p 00000000 01:00 9224       /a.out
>  	00011000-00012000 rw-p 00000000 00:00 0
>  	00012000-00013000 rw-p 00000000 00:00 0
> 
> With the patch:
> 
>  	# ./a.out &
>  	# cat /proc/$!/maps | head -4
>  	00008000-00009000 r-xp 00000000 01:00 9228       /a.out
>  	00010000-00011000 rw-p 00000000 01:00 9228       /a.out
>  	00011000-00012000 rw-p 00000000 00:00 0          [heap]
>  	00012000-00013000 rw-p 00000000 00:00 0          [heap]
> 
> The test program:
> 
> #include <stdio.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <sys/mman.h>
> 
> int main (void)
> {
>  	if (sbrk(4096) == (void *)-1) {
>  		perror("first sbrk(): ");
>  		return EXIT_FAILURE;
>  	}
> 
>  	if (mlockall(MCL_FUTURE)) {
>  		perror("mlockall(): ");
>  		return EXIT_FAILURE;
>  	}
> 
>  	if (sbrk(4096) == (void *)-1) {
>  		perror("second sbrk(): ");
>  		return EXIT_FAILURE;
>  	}

Your description said, 
	the heap may be merged with some other mappings,
                        ^^^^^^
but your example is splitting case. not merge. In other words, your
patch care splitting case but break merge case.

Ok, we have no obvious correct behavior. This is debatable. So,
Why do you think vma splitting case is important than merge?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
