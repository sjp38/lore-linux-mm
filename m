Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 56D796B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 02:25:35 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A20C13EE0C0
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 16:25:33 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BBAC45DE50
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 16:25:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 73BCC45DE4F
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 16:25:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 625CFE18002
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 16:25:33 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CBD21DB802F
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 16:25:33 +0900 (JST)
Date: Mon, 30 Jan 2012 16:24:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: how to make memory.memsw.failcnt is nonzero
Message-Id: <20120130162413.2c82893e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4F2604C5.7050900@cn.fujitsu.com>
References: <4EFADFF8.5020703@cn.fujitsu.com>
	<20120103160411.GD3891@tiehlicka.suse.cz>
	<4F06C31E.4010904@cn.fujitsu.com>
	<20120106101219.GB10292@tiehlicka.suse.cz>
	<4F2604C5.7050900@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peng Haitao <penght@cn.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 30 Jan 2012 10:47:33 +0800
Peng Haitao <penght@cn.fujitsu.com> wrote:

> 
> Michal Hocko said the following on 2012-1-6 18:12:
> >> If there is something wrong, I think the bug will be in mem_cgroup_do_charge()
> >> of mm/memcontrol.c
> >>
> >> 2210         ret = res_counter_charge(&memcg->res, csize, &fail_res);
> >> 2211 
> >> 2212         if (likely(!ret)) {
> ...
> >> 2221                 flags |= MEM_CGROUP_RECLAIM_NOSWAP;
> >> 2222         } else
> >> 2223                 mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
> >>
> >> When hit memory.limit_in_bytes, res_counter_charge() will return -ENOMEM,
> >> this will execute line 2222: } else.
> >> But I think when hit memory.limit_in_bytes, the function should determine further
> >> to memory.memsw.limit_in_bytes.
> >> This think is OK?
> > 
> > I don't think so. We have an invariant (hard limit is "stronger" than
> > memsw limit) memory.limit_in_bytes <= memory.memsw.limit_in_bytes so
> > when we hit the hard limit we do not have to consider memsw because
> > resource counter:
> >  a) we already have to do reclaim for hard limit
> >  b) we check whether we might swap out later on in
> >  mem_cgroup_hierarchical_reclaim (root_memcg->memsw_is_minimum) so we
> >  will not end up swapping just to make hard limit ok and go over memsw
> >  limit.
> > 
> > Please also note that we will retry charging after reclaim if there is a
> > chance to meet the limit.
> > Makes sense?
> 
> Yeah.
> 
> But I want to test memory.memsw.failcnt is nonzero, how steps?
> Thanks.
> 

Here is a quick hacked test program. see below.

A rough test.

[root@bluextal memcg_test]# cgcreate -g memory:X
[root@bluextal memcg_test]# cgset -r memory.limit_in_bytes=200M X
[root@bluextal memcg_test]# cgset -r memory.memsw.limit_in_bytes=300M X
[root@bluextal memcg_test]# cgexec -g memory:X ./check 200 300
[root@bluextal memcg_test]# echo 0 > /cgroup/memory/X/memory.memsw.failcnt
[root@bluextal memcg_test]# cat /cgroup/memory/X/memory.memsw.failcnt
0
[root@bluextal memcg_test]# cgexec -g memory:X ./check 200 300
Killed <-----------------------------------------------------------------------OOM Killed.
[root@bluextal memcg_test]# cat /cgroup/memory/X/memory.memsw.failcnt
17     <-----------------------------------------------------------------------memsw failcnt up.


Easy way is
1. allocate memory in Anon.
2. kick out anon memory to swap as much as possible by file I/O.-------(*1)
3. delete file cache by some way (I used unlink() here.) --------------(*2)
4. allocate anon memory.

The important points are (*1) and (*2). see a program below.

You can prevent OOM (freeze-at-oom) by
[root@bluextal memcg_test]# cgset -r memory.oom_control=1 X

Here is the memory.stat at OOM.

[root@bluextal test]# cat /cgroup/memory/X/memory.stat
cache 0
rss 209666048
mapped_file 0
pgpgin 30567
pgpgout 72381
swap 104906752
<snip>
hierarchical_memory_limit 209715200
hierarchical_memsw_limit 314572800

rss+cache < memory.limit
rss+swap == memsw.limit.





==
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <string.h>

int main(int argc, char *argv[])
{
        char filename[] = "./tmpfile-for-test";
        unsigned long mem_size = atoi(argv[1]);
        unsigned long memsw_size = atoi(argv[2]);
        unsigned long file_size;
        int fd, len;
        char *addr, *buf;

        if (memsw_size < 100)
                return 0;
        mem_size *= 1024 * 1024;
        memsw_size *= 1024 * 1024;

        memsw_size = memsw_size - 10 * 1024 * 1024; /* 10M Bytes of margin */
        addr = mmap(NULL, memsw_size, PROT_READ|PROT_WRITE,
                        MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);

        /* allocate pages and cause swap out */
        memset(addr, 0, memsw_size);

        /* create file, this will make more swaps. */
        file_size = mem_size * 80 / 100;

        fd = open(filename, O_RDWR| O_TRUNC, 0644);

        buf = malloc(1024 *1024);

        for (len = 0; len < file_size; len += 1024*1024) {
                write(fd, buf, 1024*1024);
        }
        /* read the file again */
        lseek(fd, SEEK_SET, 0);
        for (len = 0; len < file_size; len += 1024 * 1024)
                read(fd, buf, 1024 * 1024);
        lseek(fd, SEEK_SET, 0);
        for (len = 0; len < file_size; len += 1024 * 1024)
                read(fd, buf, 1024 * 1024);
        unlink(filename);

        addr = malloc(9 * 1024 * 1024);
        memset(addr, 0, 9 * 1024 * 1024);
        printf("done\n");
        sleep(100);
}













--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
