Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2506B0169
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 05:00:31 -0400 (EDT)
Message-ID: <4E560F2A.1030801@profihost.ag>
Date: Thu, 25 Aug 2011 11:00:26 +0200
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
MIME-Version: 1.0
Subject: Re: slow performance on disk/network i/o full speed after drop_caches
References: <4E5494D4.1050605@profihost.ag> <CAOJsxLEFYW0eDbXQ0Uixf-FjsxHZ_1nmnovNx1CWj=m-c-_vJw@mail.gmail.com> <4E54BDCF.9020504@profihost.ag> <20110824093336.GB5214@localhost>
In-Reply-To: <20110824093336.GB5214@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jens Axboe <jaxboe@fusionio.com>, Linux Netdev List <netdev@vger.kernel.org>

Am 24.08.2011 11:33, schrieb Wu Fengguang:
> On Wed, Aug 24, 2011 at 05:01:03PM +0800, Stefan Priebe - Profihost AG wrote:
>>
>>>> sync&&   echo 3>/proc/sys/vm/drop_caches&&   sleep 2&&   echo 0
>>>>> /proc/sys/vm/drop_caches
>>
>> Another way to get it working again is to stop some processes. Could be
>> mysql or apache or php fcgi doesn't matter. Just free some memory.
>> Although there are already 5GB free.
>
> Is it a NUMA machine and _every_ node has enough free pages?
>
>          grep . /sys/devices/system/node/node*/vmstat
>
> Thanks,
> Fengguang
Hi Fengguang,

thanks for your fast reply.

Here is the data you requested:

root@server1015-han:~# grep . /sys/devices/system/node/node*/vmstat
/sys/devices/system/node/node0/vmstat:nr_written 5546561
/sys/devices/system/node/node0/vmstat:nr_dirtied 5572497
/sys/devices/system/node/node1/vmstat:nr_written 3936
/sys/devices/system/node/node1/vmstat:nr_dirtied 4190

modified it a little bit:
~# while [ true ]; do ps -eo 
user,pid,tid,class,rtprio,ni,pri,psr,pcpu,vsz,rss,pmem,stat,wchan:28,cmd 
| grep scp | grep -v grep; sleep 1; done

root     12409 12409 TS       -   0  19   0 59.8  42136  1724  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/
root     12409 12409 TS       -   0  19   0 64.0  42136  1724  0.0 Rs 
-                            scp -t /tmp/
root     12409 12409 TS       -   0  19   0 67.7  42136  1724  0.0 Rs 
-                            scp -t /tmp/
root     12409 12409 TS       -   0  19   8 70.6  42136  1724  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/
root     12409 12409 TS       -   0  19   8 73.5  42136  1724  0.0 Rs 
-                            scp -t /tmp/
root     12409 12409 TS       -   0  19   8 76.0  42136  1724  0.0 Rs 
-                            scp -t /tmp/
root     12409 12409 TS       -   0  19   8 78.2  42136  1724  0.0 Rs 
-                            scp -t /tmp/
root     12409 12409 TS       -   0  19   8 80.0  42136  1724  0.0 Rs 
-                            scp -t /tmp/
root     12409 12409 TS       -   0  19   8 80.9  42136  1724  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/
root     12409 12409 TS       -   0  19   2 76.7  42136  1724  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/
root     12409 12409 TS       -   0  19   1 75.6  42136  1724  0.0 Ds 
pipe_read                    scp -t /tmp/
root     12409 12409 TS       -   0  19   0 76.0  42136  1724  0.0 Rs 
-                            scp -t /tmp/
root     12409 12409 TS       -   0  19   1 75.2  42136  1724  0.0 Rs 
-                            scp -t /tmp/
root     12409 12409 TS       -   0  19   1 76.6  42136  1724  0.0 Rs 
-                            scp -t /tmp/
root     12409 12409 TS       -   0  19   1 77.9  42136  1724  0.0 Rs 
-                            scp -t /tmp/
root     12409 12409 TS       -   0  19   1 79.0  42136  1724  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/
root     12409 12409 TS       -   0  19   1 72.8  42136  1724  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/
root     12409 12409 TS       -   0  19   0 73.0  42136  1724  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/
root     12409 12409 TS       -   0  19   0 73.8  42136  1724  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/
root     12409 12409 TS       -   0  19   1 74.3  42136  1724  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/
root     12409 12409 TS       -   0  19   1 73.4  42136  1724  0.0 Ss 
-                            scp -t /tmp/
root     12409 12409 TS       -   0  19   1 71.3  42136  1724  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/
root     12409 12409 TS       -   0  19   1 71.9  42136  1724  0.0 Rs 
-                            scp -t /tmp/
root     12409 12409 TS       -   0  19   0 72.7  42136  1724  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/
root     12409 12409 TS       -   0  19   3 73.5  42136  1724  0.0 Rs 
-                            scp -t /tmp/
root     12409 12409 TS       -   0  19   3 74.4  42136  1724  0.0 Rs 
-                            scp -t /tmp/
root     12409 12409 TS       -   0  19   3 75.2  42136  1724  0.0 Rs 
-                            scp -t /tmp/
root     12409 12409 TS       -   0  19   0 76.0  42136  1724  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/
root     12409 12409 TS       -   0  19   8 76.6  42136  1724  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/
root     12409 12409 TS       -   0  19   1 74.8  42136  1724  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/
root     12409 12409 TS       -   0  19   1 73.2  42136  1724  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/
root     12409 12409 TS       -   0  19   1 73.9  42136  1724  0.0 Rs 
poll_schedule_timeout        scp -t /tmp/
root     12409 12409 TS       -   0  19   0 72.4  42136  1724  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/
root     12409 12409 TS       -   0  19   8 72.0  42136  1724  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/
root     12409 12409 TS       -   0  19   8 72.5  42136  1724  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/
root     12409 12409 TS       -   0  19   8 72.9  42136  1724  0.0 Rs 
-                            scp -t /tmp/
root     12409 12409 TS       -   0  19   8 73.5  42136  1724  0.0 Rs 
-                            scp -t /tmp/
root     12566 12566 TS       -   0  19   1  0.0  42136  1728  0.0 Rs 
-                            scp -t /tmp/
root     12566 12566 TS       -   0  19   1 23.0  42136  1728  0.0 Rs 
-                            scp -t /tmp/
root     12566 12566 TS       -   0  19   1 49.5  42136  1728  0.0 Rs 
-                            scp -t /tmp/
root     12566 12566 TS       -   0  19   2 63.3  42136  1728  0.0 Rs 
-                            scp -t /tmp/
root     12566 12566 TS       -   0  19   1 71.5  42136  1728  0.0 Rs 
-                            scp -t /tmp/
root     12566 12566 TS       -   0  19   1 77.4  42136  1728  0.0 Rs 
-                            scp -t /tmp/
root     12566 12566 TS       -   0  19   1 70.3  42136  1728  0.0 Rs 
-                            scp -t /tmp/
root     12566 12566 TS       -   0  19   1 73.1  42136  1728  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/
root     12566 12566 TS       -   0  19   0 65.7  42136  1728  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/
root     12566 12566 TS       -   0  19   1 61.2  42136  1728  0.0 Ss 
-                            scp -t /tmp/
root     12566 12566 TS       -   0  19   1 63.7  42136  1728  0.0 Rs 
-                            scp -t /tmp/
root     12636 12636 TS       -   0  19   8  0.0  42136  1728  0.0 Ss 
poll_schedule_timeout        scp -t /tmp/


Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
