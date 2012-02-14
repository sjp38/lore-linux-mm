Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id AFC3C6B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 06:10:13 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D17583EE0BB
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 20:10:11 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B835445DE53
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 20:10:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9792145DE4E
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 20:10:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8854C1DB803F
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 20:10:11 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 308E41DB802C
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 20:10:11 +0900 (JST)
Date: Tue, 14 Feb 2012 20:08:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/6 v4] memcg: fix performance of
 mem_cgroup_begin_update_page_stat()
Message-Id: <20120214200842.df132ab1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAHH2K0baOnU6BE5c16cR0KiMvM3Hz+ngcBCs5e4+xJ_dcoeOww@mail.gmail.com>
References: <20120214120414.025625c2.kamezawa.hiroyu@jp.fujitsu.com>
	<20120214121631.782352f2.kamezawa.hiroyu@jp.fujitsu.com>
	<CAHH2K0baOnU6BE5c16cR0KiMvM3Hz+ngcBCs5e4+xJ_dcoeOww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>

On Mon, 13 Feb 2012 23:22:50 -0800
Greg Thelen <gthelen@google.com> wrote:

> On Mon, Feb 13, 2012 at 7:16 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > From 3377fd7b6e23a5d2a368c078eae27e2b49c4f4aa Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Mon, 6 Feb 2012 12:14:47 +0900
> > Subject: [PATCH 6/6] memcg: fix performance of mem_cgroup_begin_update_page_stat()
> >
> > mem_cgroup_begin_update_page_stat() should be very fast because
> > it's called very frequently. Now, it needs to look up page_cgroup
> > and its memcg....this is slow.
> >
> > This patch adds a global variable to check "a memcg is moving or not".
> 
> s/a memcg/any memcg/
> 
yes.

> > By this, the caller doesn't need to visit page_cgroup and memcg.
> 
> s/By/With/
> 
ok.

> > Here is a test result. A test program makes page faults onto a file,
> > MAP_SHARED and makes each page's page_mapcount(page) > 1, and free
> > the range by madvise() and page fault again. A This program causes
> > 26214400 times of page fault onto a file(size was 1G.) and shows
> > shows the cost of mem_cgroup_begin_update_page_stat().
> 
> Out of curiosity, what is the performance of the mmap program before
> this series?
> 

Score of 3 runs underlinux-next.
==
[root@bluextal test]# time ./mmap 1G

real    0m21.041s
user    0m6.146s
sys     0m14.625s
[root@bluextal test]# time ./mmap 1G

real    0m21.063s
user    0m6.019s
sys     0m14.776s
[root@bluextal test]# time ./mmap 1G

real    0m21.178s
user    0m6.000s
sys     0m14.849s
==

My program is attached. This program is for checking cost of updating FILE_MAPPED.
I guess sys_time scores's error rate will be 0.2-0.3 sec.

Thanks,
-Kame
==
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>

void reader(int fd, int size)
{
	int i, off, x;
	char *addr;

	addr = mmap(NULL, size, PROT_READ, MAP_SHARED, fd, 0);
	for (i = 0; i < 100; i++) {
		for(off = 0; off < size; off += 4096) {
			x += *(addr + off);
		}
		madvise(addr, size, MADV_DONTNEED);
	}
}

int main(int argc, char *argv[])
{
	int fd;
	char *addr, *c;
	unsigned long size;
	struct stat statbuf;

	fd = open(argv[1], O_RDONLY);
	if (fd < 0) {
		perror("cannot open file");
		return 1;
	}

	if (fstat(fd, &statbuf)) {
		perror("fstat failed");
		return 1;
	}
	size = statbuf.st_size;
	/* mmap in 2 place. */
	addr = mmap(NULL, size, PROT_READ, MAP_SHARED, fd, 0);
	mlock(addr, size);
	reader(fd, size);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
