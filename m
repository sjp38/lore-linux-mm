Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 949F46B0044
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 18:52:34 -0400 (EDT)
Date: Sat, 28 Apr 2012 00:51:46 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] mm: Warn once when a page is freed with PG_mlocked
Message-ID: <20120427225146.GM2536@cmpxchg.org>
References: <1335548546-25040-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1335548546-25040-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>

On Fri, Apr 27, 2012 at 10:42:26AM -0700, Ying Han wrote:
> I am resending this patch orginally from Mel, and the reason we spotted this
> is due to the next patch where I am adding the mlock stat into per-memcg
> meminfo. We found out that it is impossible to update the counter if the page
> is in the freeing patch w/ mlocked bit set.
> 
> Then we started wondering if it is possible at all. It shouldn't happen that
> freeing a mlocked page without going through munlock_vma_pages_all(). Looks
> like it did happen few years ago, and here is the patch introduced it
> 
> commit 985737cf2ea096ea946aed82c7484d40defc71a8
> Author: Lee Schermerhorn <lee.schermerhorn@hp.com>
> Date:   Sat Oct 18 20:26:53 2008 -0700
> 
>     mlock: count attempts to free mlocked page

I was going to ask what changed that it can't happen anymore, but then
remembered how I was able to up this counter in the past: truncating a
private file mapping with mlocked COWed anon pages.  Because this path
unmaps vmas coming from the inode, it takes mapping->i_mmap_mutex, and
you can't nest page lock inside it to do the munlock (because of rmap).

> There are two ways to persue and I would like to ask people's opinion:
> 
> 1. revert the patch totally and the page will get into bad_page(). Then we
> get the report as well.
> 
> 2. fix up the page like the patch does but put on warn_once() to report the
> problem.
> 
> People might feel more confident by doing step by step which adding the
> warn_on() first and then revert it later. So I resend the patch from Mel and
> here is the patch:
> 
> When a page is freed with the PG_mlocked set, it is considered an unexpected
> but recoverable situation. A counter records how often this event happens
> but it is easy to miss that this event has occured at all. This patch warns
> once when PG_mlocked is set to prompt debuggers to check the counter to
> see how often it is happening.

Here is a program that will trigger your warning.

dexter:~$ grep mlockfreed /proc/vmstat 
unevictable_pgs_mlockfreed 3
dexter:~$ ./mlockfree 
dexter:~$ grep mlockfreed /proc/vmstat 
unevictable_pgs_mlockfreed 4

---

#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>

int main(void)
{
	char *map;
	int fd;

	fd = open("chigurh", O_CREAT|O_EXCL|O_RDWR);
	unlink("chigurh");
	ftruncate(fd, 4096);
	map = mmap(NULL, 4096, PROT_WRITE, MAP_PRIVATE, fd, 0);
	map[0] = 11;
	mlock(map, sizeof(fd));
	ftruncate(fd, 0);
	close(fd);
	munlock(map, sizeof(fd));
	munmap(map, 4096);
	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
