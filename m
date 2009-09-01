Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 96FE86B004D
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 05:02:29 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8192SKv020653
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 1 Sep 2009 18:02:28 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D0EE445DE4C
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 18:02:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A080645DE4E
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 18:02:27 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CEC3E08004
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 18:02:27 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 277A81DB803A
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 18:02:27 +0900 (JST)
Date: Tue, 1 Sep 2009 18:00:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mmotm][BUG] free is bigger than presnet Re: mmotm 2009-08-27-16-51
 uploaded
Message-Id: <20090901180032.55f7b8ca.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <200908272355.n7RNtghC019990@imap1.linux-foundation.org>
References: <200908272355.n7RNtghC019990@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 27 Aug 2009 16:55:42 -0700
akpm@linux-foundation.org wrote:

> The mm-of-the-moment snapshot 2009-08-27-16-51 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/
> 
> and will soon be available at
> 
>    git://git.zen-sources.org/zen/mmotm.git
> 
> It contains the following patches against 2.6.31-rc7:
> 

I'm not digggin so much but /proc/meminfo corrupted.

[kamezawa@bluextal cgroup]$ cat /proc/meminfo
MemTotal:       24421124 kB
MemFree:        38314388 kB

Wow ;)
On x86-64 8cpu box + 24G memory.
(config is NUMA but the system itself is not NUMA.)

At boot time and for a while, It seems to be no trouble.

I used this.

== malloc.c

#include <stdio.h>

#define MSIZE (1024 * 1024 * 8)

int main(int argc, char *argv[])
{
        char **c;
        long size;
        int array_size, i;

        size = atoi(argv[1]);
        size *= 1024 * 1024;

        array_size =  size/MSIZE + 1;
        c= malloc(sizeof(void *) * array_size);

        for (i = 0; i < array_size; i++) {
                c[i] = malloc(MSIZE);
                memset(c[i], 0, MSIZE);
        }
        while (1) {
                for (i = 0; i < array_size; i++) {
                        memset(c[i], 0, MSIZE);
                        sleep(2);
                }
                sleep(10);
        }
        return;
}
==
# malloc 23000
# malloc 1000
and run hackbench 20.

OOM Kill message says free exceeds present ;(
==
Sep  1 18:01:17 localhost kernel: [ 3012.503440] active_anon:5461242 inactive_anon:473226 isolated_anon:384
Sep  1 18:01:17 localhost kernel: [ 3012.503440]  active_file:133 inactive_file:664 isolated_file:0
Sep  1 18:01:17 localhost kernel: [ 3012.503440]  unevictable:0 dirty:0 writeback:73 unstable:0 buffer:283
Sep  1 18:01:17 localhost kernel: [ 3012.503440]  free:9454041 slab_reclaimable:5144 slab_unreclaimable:10564
Sep  1 18:01:17 localhost kernel: [ 3012.503440]  mapped:7019 shmem:0 pagetables:22572 bounce:0
Sep  1 18:01:17 localhost kernel: [ 3012.503440] Node 0 DMA free:15788kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15016kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Sep  1 18:01:17 localhost kernel: [ 3012.503440] lowmem_reserve[]: 0 2951 23909 23909
Sep  1 18:01:17 localhost kernel: [ 3012.503440] Node 0 DMA32 free:11729908kB min:2440kB low:3048kB high:3660kB active_anon:1866292kB inactive_anon:466548kB active_file:140kB inactive_file:1588kB unevictable:0kB isolated(anon):256kB isolated(file):0kB present:3022624kB mlocked:0kB dirty:0kB writeback:292kB mapped:8kB shmem:0kB slab_reclaimable:2724kB slab_unreclaimable:10124kB kernel_stack:4504kB pagetables:21536kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:227 all_unreclaimable? no
Sep  1 18:01:17 localhost kernel: [ 3012.503440] lowmem_reserve[]: 0 0 20958 20958
Sep  1 18:01:17 localhost kernel: [ 3012.503440] Node 0 Normal free:26071392kB min:17340kB low:21672kB high:26008kB active_anon:19978676kB inactive_anon:1426356kB active_file:392kB inactive_file:1068kB unevictable:0kB isolated(anon):1280kB isolated(file):0kB present:21460992kB mlocked:0kB dirty:0kB writeback:0kB mapped:28068kB shmem:0kB slab_reclaimable:17852kB slab_unreclaimable:32132kB kernel_stack:3672kB pagetables:68752kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:3840 all_unreclaimable? no

==

I'll dig more but does anyone have hints ?


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
