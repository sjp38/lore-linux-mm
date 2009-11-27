Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0397C6B004D
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 00:02:39 -0500 (EST)
Date: Fri, 27 Nov 2009 13:58:10 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 4/5] memcg: avoid oom during recharge at task
 move
Message-Id: <20091127135810.ef5fee0b.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091124114358.80e0cafe.nishimura@mxp.nes.nec.co.jp>
References: <20091119132734.1757fc42.nishimura@mxp.nes.nec.co.jp>
	<20091119133030.8ef46be0.nishimura@mxp.nes.nec.co.jp>
	<20091123051041.GQ31961@balbir.in.ibm.com>
	<20091124114358.80e0cafe.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Fri__27_Nov_2009_13_58_10_+0900_.bKjjwvbiFiJoLvu"
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

--Multipart=_Fri__27_Nov_2009_13_58_10_+0900_.bKjjwvbiFiJoLvu
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

> > Sorry, if I missed it, but I did not see any time overhead of moving a
> > task after these changes. Could you please help me understand the cost
> > of moving say a task with 1G anonymous memory to another group and
> > the cost of moving a task with 512MB anonymous and 512 page cache
> > mapped, etc. It would be nice to understand the overall cost.
> > 
> O.K.
> I'll test programs with big anonymous pages and measure the time and report.
> 
I measured the elapsed time of "echo <pid> > <some path>/tasks" on KVM guest
with 4CPU/4GB(Xeon/3GHz).

- used the attached simple program.
- made 2 directories(00, 01) under root, and enabled recharge_at_immigrate in both.
- measured the elapsed time by "time -p" for moving between:

  (1) root -> 00
  (2) 00 -> 01

  we don't need to call res_counter_uncharge against root, so (1) would be smaller
  than (2).

  (3) 00(setting mem.limit to half size of total) -> 01

  To compare the overhead of anon and swap.

Results:

       |  252M  |  512M  |   1G
  -----+--------+--------+--------
   (1) |  0.21  |  0.41  |  0.821
  -----+--------+--------+--------
   (2) |  0.43  |  0.85  |  1.71
  -----+--------+--------+--------
   (3) |  0.40  |  0.81  |  1.62
  -----+--------+--------+--------


hmm, it would be better to add some comments to memory.txt like:

  Note: It may take several seconds if you move charges in giga bytes order.


Regards,
Daisuke Nishimura.


--Multipart=_Fri__27_Nov_2009_13_58_10_+0900_.bKjjwvbiFiJoLvu
Content-Type: text/x-csrc;
 name="bigmem.c"
Content-Disposition: attachment;
 filename="bigmem.c"
Content-Transfer-Encoding: 7bit

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

void
usage(void)
{
	fprintf(stderr, "bigmem <anon size(MB)>\n");
}

int
main(int argc, char *argv[])
{
	void *buf;
	size_t size;
	pid_t pid;

	if (argc != 2) {
		usage();
		return 1;
	}

	pid = getpid();
	fprintf(stdout, "pid is %d\n", pid);

	size = atol(argv[1]) * 1024 * 1024;
	buf = mmap(NULL, size, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
	if (buf == MAP_FAILED) {
		perror(NULL);
		return errno;
	}

	memset(buf, 0, size);
	fprintf(stdout, "allocated %ld bytes anonymous memory\n");

	pause();
}


--Multipart=_Fri__27_Nov_2009_13_58_10_+0900_.bKjjwvbiFiJoLvu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
