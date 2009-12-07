Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 244DB60021B
	for <linux-mm@kvack.org>; Mon,  7 Dec 2009 01:36:18 -0500 (EST)
Date: Mon, 7 Dec 2009 15:34:48 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 0/7] memcg: move charge at task migration
 (04/Dec)
Message-Id: <20091207153448.55e11607.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091204160042.3e5fd83d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091204144609.b61cc8c4.nishimura@mxp.nes.nec.co.jp>
	<20091204155317.2d570a55.kamezawa.hiroyu@jp.fujitsu.com>
	<20091204160042.3e5fd83d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Mon__7_Dec_2009_15_34_48_+0900_CQe7v98SmurGYq7F"
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

--Multipart=_Mon__7_Dec_2009_15_34_48_+0900_CQe7v98SmurGYq7F
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Fri, 4 Dec 2009 16:00:42 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 4 Dec 2009 15:53:17 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Fri, 4 Dec 2009 14:46:09 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > > In this version:
> > >        |  252M  |  512M  |   1G
> > >   -----+--------+--------+--------
> > >    (1) |  0.15  |  0.30  |  0.60
> > >   -----+--------+--------+--------
> > >    (2) |  0.15  |  0.30  |  0.60
> > >   -----+--------+--------+--------
> > >    (3) |  0.22  |  0.44  |  0.89
> > > 
> > Nice !
> > 
> 
> Ah. could you clarify...
> 
>  1. How is fork()/exit() affected by this move ?
I measured using unixbench(./Run -c 1 spawn execl). I used the attached script to do
task migration infinitly(./switch3.sh /cgroup/memory/01 /cgroup/memory/02 [pid of bash]).
The script is executed on a different cpu from the unixbench's by taskset.

(1) no task migration(run on /01)

Execl Throughput                                192.7 lps   (29.9 s, 2 samples)
Process Creation                                475.5 lps   (30.0 s, 2 samples)

Execl Throughput                                191.2 lps   (29.9 s, 2 samples)
Process Creation                                463.4 lps   (30.0 s, 2 samples)

Execl Throughput                                191.0 lps   (29.9 s, 2 samples)
Process Creation                                474.9 lps   (30.0 s, 2 samples)


(2) under task migration between /01 and /02 w/o setting move_charge_at_immigrate

Execl Throughput                                150.2 lps   (29.8 s, 2 samples)
Process Creation                                344.1 lps   (30.0 s, 2 samples)

Execl Throughput                                146.9 lps   (29.8 s, 2 samples)
Process Creation                                337.7 lps   (30.0 s, 2 samples)

Execl Throughput                                150.5 lps   (29.8 s, 2 samples)
Process Creation                                345.3 lps   (30.0 s, 2 samples)


(3) under task migration between /01 and /02 w/ setting move_charge_at_immigrate

Execl Throughput                                142.9 lps   (29.9 s, 2 samples)
Process Creation                                323.1 lps   (30.0 s, 2 samples)

Execl Throughput                                146.6 lps   (29.8 s, 2 samples)
Process Creation                                332.0 lps   (30.0 s, 2 samples)

Execl Throughput                                150.9 lps   (29.8 s, 2 samples)
Process Creation                                344.2 lps   (30.0 s, 2 samples)


(those values seem terrible :(  I run them on KVM guest...)
(2) seems a bit better than (3), but the impact of task migration itself is
far bigger.


>  2. How long cpuset's migration-at-task-move requires ?
>     I guess much longer than this.
I measured in the same environment using fakenuma. It took 1.17sec for 256M,
2.33sec for 512M, and 4.69sec for 1G.


>  3. If need to reclaim memory for moving tasks, can this be longer ?
I think so.

>     If so, we may need some trick to release cgroup_mutex in task moving.
> 
hmm, I see your concern but I think it isn't so easy.. IMHO, we need changes
in cgroup layer and should take care not to cause dead lock.


Regards,
Daisuke Nishimura.

--Multipart=_Mon__7_Dec_2009_15_34_48_+0900_CQe7v98SmurGYq7F
Content-Type: text/x-sh;
 name="switch3.sh"
Content-Disposition: attachment;
 filename="switch3.sh"
Content-Transfer-Encoding: 7bit

#!/bin/bash

SRC=$1
DST=$2
EXCLUDE_LIST="$3"

move_task()
{
	local ret

	for pid in $1
	do
		echo "${EXCLUDE_LIST}" | grep -w -q $pid
		if [ $? -eq 0 ]; then
			continue
		fi
		echo -n "$pid "
		/bin/echo $pid >$2/tasks 2>/dev/null
	done
	echo ""
}

stopflag=0

interrupt()
{
	stopflag=1
}

trap interrupt INT

while [ $stopflag -ne 1 ]
do
	echo "----- `date` -----"
	move_task "`cat ${SRC}/tasks`" ${DST}
	TMP=${SRC}
	SRC=${DST}
	DST=${TMP}
done





--Multipart=_Mon__7_Dec_2009_15_34_48_+0900_CQe7v98SmurGYq7F--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
