Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DC9CC6B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 22:16:52 -0400 (EDT)
Date: Fri, 26 Aug 2011 10:16:48 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: slow performance on disk/network i/o full speed after
 drop_caches
Message-ID: <20110826021648.GA19529@localhost>
References: <4E5494D4.1050605@profihost.ag>
 <CAOJsxLEFYW0eDbXQ0Uixf-FjsxHZ_1nmnovNx1CWj=m-c-_vJw@mail.gmail.com>
 <4E54BDCF.9020504@profihost.ag>
 <20110824093336.GB5214@localhost>
 <4E560F2A.1030801@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E560F2A.1030801@profihost.ag>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jens Axboe <jaxboe@fusionio.com>, Linux Netdev List <netdev@vger.kernel.org>

Hi Stefan,

> Here is the data you requested:
> 
> root@server1015-han:~# grep . /sys/devices/system/node/node*/vmstat
> /sys/devices/system/node/node0/vmstat:nr_written 5546561
> /sys/devices/system/node/node0/vmstat:nr_dirtied 5572497
> /sys/devices/system/node/node1/vmstat:nr_written 3936
> /sys/devices/system/node/node1/vmstat:nr_dirtied 4190

Ah you are running an older kernel that didn't show all the vmstat
numbers. But still it's revealing that node 0 is used heavily and node
1 is almost idle. So I won't be surprised to see most free pages lie
in node 1.

> modified it a little bit:
> ~# while [ true ]; do ps -eo 
> user,pid,tid,class,rtprio,ni,pri,psr,pcpu,vsz,rss,pmem,stat,wchan:28,cmd 
> | grep scp | grep -v grep; sleep 1; done
> 
> root     12409 12409 TS       -   0  19   0 59.8  42136  1724  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/

It's mostly doing poll() waits. There must be some dependency on
something other to make progress. Would you post the full ps output
for all tasks, and even better, run

        echo t > /proc/sysrq-trigger

To dump the kernel stacks?

Thanks,
Fengguang


> root     12409 12409 TS       -   0  19   0 64.0  42136  1724  0.0 Rs 
> -                            scp -t /tmp/
> root     12409 12409 TS       -   0  19   0 67.7  42136  1724  0.0 Rs 
> -                            scp -t /tmp/
> root     12409 12409 TS       -   0  19   8 70.6  42136  1724  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/
> root     12409 12409 TS       -   0  19   8 73.5  42136  1724  0.0 Rs 
> -                            scp -t /tmp/
> root     12409 12409 TS       -   0  19   8 76.0  42136  1724  0.0 Rs 
> -                            scp -t /tmp/
> root     12409 12409 TS       -   0  19   8 78.2  42136  1724  0.0 Rs 
> -                            scp -t /tmp/
> root     12409 12409 TS       -   0  19   8 80.0  42136  1724  0.0 Rs 
> -                            scp -t /tmp/
> root     12409 12409 TS       -   0  19   8 80.9  42136  1724  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/
> root     12409 12409 TS       -   0  19   2 76.7  42136  1724  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/
> root     12409 12409 TS       -   0  19   1 75.6  42136  1724  0.0 Ds 
> pipe_read                    scp -t /tmp/
> root     12409 12409 TS       -   0  19   0 76.0  42136  1724  0.0 Rs 
> -                            scp -t /tmp/
> root     12409 12409 TS       -   0  19   1 75.2  42136  1724  0.0 Rs 
> -                            scp -t /tmp/
> root     12409 12409 TS       -   0  19   1 76.6  42136  1724  0.0 Rs 
> -                            scp -t /tmp/
> root     12409 12409 TS       -   0  19   1 77.9  42136  1724  0.0 Rs 
> -                            scp -t /tmp/
> root     12409 12409 TS       -   0  19   1 79.0  42136  1724  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/
> root     12409 12409 TS       -   0  19   1 72.8  42136  1724  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/
> root     12409 12409 TS       -   0  19   0 73.0  42136  1724  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/
> root     12409 12409 TS       -   0  19   0 73.8  42136  1724  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/
> root     12409 12409 TS       -   0  19   1 74.3  42136  1724  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/
> root     12409 12409 TS       -   0  19   1 73.4  42136  1724  0.0 Ss 
> -                            scp -t /tmp/
> root     12409 12409 TS       -   0  19   1 71.3  42136  1724  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/
> root     12409 12409 TS       -   0  19   1 71.9  42136  1724  0.0 Rs 
> -                            scp -t /tmp/
> root     12409 12409 TS       -   0  19   0 72.7  42136  1724  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/
> root     12409 12409 TS       -   0  19   3 73.5  42136  1724  0.0 Rs 
> -                            scp -t /tmp/
> root     12409 12409 TS       -   0  19   3 74.4  42136  1724  0.0 Rs 
> -                            scp -t /tmp/
> root     12409 12409 TS       -   0  19   3 75.2  42136  1724  0.0 Rs 
> -                            scp -t /tmp/
> root     12409 12409 TS       -   0  19   0 76.0  42136  1724  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/
> root     12409 12409 TS       -   0  19   8 76.6  42136  1724  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/
> root     12409 12409 TS       -   0  19   1 74.8  42136  1724  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/
> root     12409 12409 TS       -   0  19   1 73.2  42136  1724  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/
> root     12409 12409 TS       -   0  19   1 73.9  42136  1724  0.0 Rs 
> poll_schedule_timeout        scp -t /tmp/
> root     12409 12409 TS       -   0  19   0 72.4  42136  1724  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/
> root     12409 12409 TS       -   0  19   8 72.0  42136  1724  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/
> root     12409 12409 TS       -   0  19   8 72.5  42136  1724  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/
> root     12409 12409 TS       -   0  19   8 72.9  42136  1724  0.0 Rs 
> -                            scp -t /tmp/
> root     12409 12409 TS       -   0  19   8 73.5  42136  1724  0.0 Rs 
> -                            scp -t /tmp/
> root     12566 12566 TS       -   0  19   1  0.0  42136  1728  0.0 Rs 
> -                            scp -t /tmp/
> root     12566 12566 TS       -   0  19   1 23.0  42136  1728  0.0 Rs 
> -                            scp -t /tmp/
> root     12566 12566 TS       -   0  19   1 49.5  42136  1728  0.0 Rs 
> -                            scp -t /tmp/
> root     12566 12566 TS       -   0  19   2 63.3  42136  1728  0.0 Rs 
> -                            scp -t /tmp/
> root     12566 12566 TS       -   0  19   1 71.5  42136  1728  0.0 Rs 
> -                            scp -t /tmp/
> root     12566 12566 TS       -   0  19   1 77.4  42136  1728  0.0 Rs 
> -                            scp -t /tmp/
> root     12566 12566 TS       -   0  19   1 70.3  42136  1728  0.0 Rs 
> -                            scp -t /tmp/
> root     12566 12566 TS       -   0  19   1 73.1  42136  1728  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/
> root     12566 12566 TS       -   0  19   0 65.7  42136  1728  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/
> root     12566 12566 TS       -   0  19   1 61.2  42136  1728  0.0 Ss 
> -                            scp -t /tmp/
> root     12566 12566 TS       -   0  19   1 63.7  42136  1728  0.0 Rs 
> -                            scp -t /tmp/
> root     12636 12636 TS       -   0  19   8  0.0  42136  1728  0.0 Ss 
> poll_schedule_timeout        scp -t /tmp/
> 
> 
> Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
