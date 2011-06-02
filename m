Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A12586B004A
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 21:54:08 -0400 (EDT)
Date: Wed, 1 Jun 2011 18:53:27 -0700
From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [BUG 3.0.0-rc1] ksm: NULL pointer dereference in ksm_do_scan()
Message-ID: <20110602015327.GC16009@sequoia.sous-sol.org>
References: <20110601222032.GA2858@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110601222032.GA2858@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Mel Gorman <mel@csn.ul.ie>, Izik Eidus <ieidus@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

* Andrea Righi (andrea@betterlinux.com) wrote:
> The bug can be easily reproduced using the following testcase:

Thanks for the testcase.

> ========================
> #include <stdio.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <sys/mman.h>
> 
> #define BUFSIZE getpagesize()
> 
> int main(int argc, char **argv)
> {
> 	void *ptr;
> 
> 	if (posix_memalign(&ptr, getpagesize(), BUFSIZE) < 0) {
> 		perror("posix_memalign");
> 		exit(1);
> 	}
> 	if (madvise(ptr, BUFSIZE, MADV_MERGEABLE) < 0) {
> 		perror("madvise");
> 		exit(1);
> 	}
> 	*(char *)NULL = 0;
> 
> 	return 0;
> }
> ========================
> 
> It seems that when a task segfaults mm_slot->mm becomes NULL, but it's
> still wrongly considered by the ksm scan. Is there a race with
> __ksm_exit()?

Hmm, wonder if khugepaged has the same issue too.  We should be holding
a reference to ->mm, but we seem to have inconsistent serialization w/
mmap_sem.  Hugh mentioned some of these concerns when introducing
ksm_exit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
