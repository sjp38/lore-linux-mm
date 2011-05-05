Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1B72290010B
	for <linux-mm@kvack.org>; Thu,  5 May 2011 13:17:42 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p45HHchW001541
	for <linux-mm@kvack.org>; Thu, 5 May 2011 10:17:40 -0700
Received: from qwi2 (qwi2.prod.google.com [10.241.195.2])
	by kpbe16.cbf.corp.google.com with ESMTP id p45HFus3028779
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 5 May 2011 10:17:36 -0700
Received: by qwi2 with SMTP id 2so2323281qwi.22
        for <linux-mm@kvack.org>; Thu, 05 May 2011 10:17:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110505092140.GC14830@balbir.in.ibm.com>
References: <1304529244-31051-1-git-send-email-yinghan@google.com>
	<20110505092140.GC14830@balbir.in.ibm.com>
Date: Thu, 5 May 2011 10:17:36 -0700
Message-ID: <BANLkTi=2h-D8n-0u7iEmt=GSxFK5upBW6Q@mail.gmail.com>
Subject: Re: [PATCH V2] Eliminate task stack trace duplication.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org

On Thu, May 5, 2011 at 2:21 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wr=
ote:
> * Ying Han <yinghan@google.com> [2011-05-04 10:14:04]:
>
>> The problem with small dmesg ring buffer like 512k is that only limited =
number
>> of task traces will be logged. Sometimes we lose important information o=
nly
>> because of too many duplicated stack traces.
>>
>> This patch tries to reduce the duplication of task stack trace in the du=
mp
>> message by hashing the task stack. The hashtable is a 32k pre-allocated =
buffer
>> during bootup. Then we hash the task stack with stack_depth 32 for each =
stack
>> entry. Each time if we find the identical task trace in the task stack, =
we dump
>> only the pid of the task which has the task trace dumped. So it is easy =
to back
>> track to the full stack with the pid.
>>
>> [ =A0 58.469730] kworker/0:0 =A0 =A0 S 0000000000000000 =A0 =A0 0 =A0 =
=A0 4 =A0 =A0 =A02 0x00000000
>> [ =A0 58.469735] =A0ffff88082fcfde80 0000000000000046 ffff88082e9d8000 f=
fff88082fcfc010
>> [ =A0 58.469739] =A0ffff88082fce9860 0000000000011440 ffff88082fcfdfd8 f=
fff88082fcfdfd8
>> [ =A0 58.469743] =A00000000000011440 0000000000000000 ffff88082fcee180 f=
fff88082fce9860
>> [ =A0 58.469747] Call Trace:
>> [ =A0 58.469751] =A0[<ffffffff8108525a>] worker_thread+0x24b/0x250
>> [ =A0 58.469754] =A0[<ffffffff8108500f>] ? manage_workers+0x192/0x192
>> [ =A0 58.469757] =A0[<ffffffff810885bd>] kthread+0x82/0x8a
>> [ =A0 58.469760] =A0[<ffffffff8141aed4>] kernel_thread_helper+0x4/0x10
>> [ =A0 58.469763] =A0[<ffffffff8108853b>] ? kthread_worker_fn+0x112/0x112
>> [ =A0 58.469765] =A0[<ffffffff8141aed0>] ? gs_change+0xb/0xb
>> [ =A0 58.469768] kworker/u:0 =A0 =A0 S 0000000000000004 =A0 =A0 0 =A0 =
=A0 5 =A0 =A0 =A02 0x00000000
>> [ =A0 58.469773] =A0ffff88082fcffe80 0000000000000046 ffff880800000000 f=
fff88082fcfe010
>> [ =A0 58.469777] =A0ffff88082fcea080 0000000000011440 ffff88082fcfffd8 f=
fff88082fcfffd8
>> [ =A0 58.469781] =A00000000000011440 0000000000000000 ffff88082fd4e9a0 f=
fff88082fcea080
>> [ =A0 58.469785] Call Trace:
>> [ =A0 58.469786] <Same stack as pid 4>
>> [ =A0 58.470235] kworker/0:1 =A0 =A0 S 0000000000000000 =A0 =A0 0 =A0 =
=A013 =A0 =A0 =A02 0x00000000
>> [ =A0 58.470255] =A0ffff88082fd3fe80 0000000000000046 ffff880800000000 f=
fff88082fd3e010
>> [ =A0 58.470279] =A0ffff88082fcee180 0000000000011440 ffff88082fd3ffd8 f=
fff88082fd3ffd8
>> [ =A0 58.470301] =A00000000000011440 0000000000000000 ffffffff8180b020 f=
fff88082fcee180
>> [ =A0 58.470325] Call Trace:
>> [ =A0 58.470332] <Same stack as pid 4>
>
> Given that pid's can be reused, I wonder if in a large time window the
> output can be confusing? The dmesg ring buffer can be scaled with a
> config option .. (CONFIG_LOG_BUF_LEN??)

yes, we can always configure it to a larger value. however, it depends
how much duplications you might have and the buffer can be easily
filled up. this patch is useful which we can keep the same ring buffer
size but get more information out of by only doing
dedup of task stacks.

--Ying

>
> --
> =A0 =A0 =A0 =A0Three Cheers,
> =A0 =A0 =A0 =A0Balbir
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
