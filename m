Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 066D66B0092
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 05:06:01 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 925B63EE0BC
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 19:06:00 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 770DE45DEAD
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 19:06:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 51EB245DEA6
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 19:06:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0362C1DB803C
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 19:06:00 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3590E1DB8041
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 19:05:59 +0900 (JST)
Date: Fri, 17 Feb 2012 19:04:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/6] page cgroup diet v5
Message-Id: <20120217190433.7598a56e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120217182426.86aebfde.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120217182426.86aebfde.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Fri__17_Feb_2012_19_04_33_+0900_MKUFGOJfuClWukl+"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>

This is a multi-part message in MIME format.

--Multipart=_Fri__17_Feb_2012_19_04_33_+0900_MKUFGOJfuClWukl+
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Fri, 17 Feb 2012 18:24:26 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 
> This patch set is for removing 2 flags PCG_FILE_MAPPED and PCG_MOVE_LOCK on
> page_cgroup->flags. After this, page_cgroup has only 3bits of flags.
> And, this set introduces a new method to update page status accounting per memcg.
> With it, we don't have to add new flags onto page_cgroup if 'struct page' has
> information. This will be good for avoiding a new flag for page_cgroup.
> 
> Fixed pointed out parts.
>  - added more comments
>  - fixed texts
>  - removed redundant arguments.
> 
> Passed some tests on 3.3.0-rc3-next-20120216.
> 

Here is a micro benchmark test before/after this series.
mmap 1G bytes twice and repeat fault->drop repeatedly. (test program is attached)

== Before == 3 runs after 1st run
[root@bluextal test]# time ./mmap 1G

real    0m21.053s
user    0m6.046s
sys     0m14.743s
[root@bluextal test]# time ./mmap 1G

real    0m21.302s
user    0m6.027s
sys     0m14.979s
[root@bluextal test]# time ./mmap 1G

real    0m21.061s
user    0m6.020s
sys     0m14.722s

== After == 3 runs after 1st run
[root@bluextal test]# time ./mmap 1G

real    0m20.969s
user    0m5.960s
sys     0m14.777s
[root@bluextal test]# time ./mmap 1G

real    0m20.968s
user    0m6.069s
sys     0m14.650s
[root@bluextal test]# time ./mmap 1G

real    0m21.164s
user    0m6.152s
sys     0m14.707s


I think there is no regression.


Thanks,
-Kame




--Multipart=_Fri__17_Feb_2012_19_04_33_+0900_MKUFGOJfuClWukl+
Content-Type: text/x-csrc;
 name="mmap.c"
Content-Disposition: attachment;
 filename="mmap.c"
Content-Transfer-Encoding: 7bit

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

--Multipart=_Fri__17_Feb_2012_19_04_33_+0900_MKUFGOJfuClWukl+--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
