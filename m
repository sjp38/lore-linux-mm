Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C430290016F
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 05:53:15 -0400 (EDT)
Message-ID: <4E01BB86.5010708@5t9.de>
Date: Wed, 22 Jun 2011 11:53:10 +0200
From: Lutz Vieweg <lvml@5t9.de>
MIME-Version: 1.0
Subject: Re: "make -j" with memory.(memsw.)limit_in_bytes smaller than required
 -> livelock,  even for unlimited processes
References: <4E00AFE6.20302@5t9.de> <20110622091018.16c14c78.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110622091018.16c14c78.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On 06/22/2011 02:10 AM, KAMEZAWA Hiroyuki wrote:

> This is a famous fork-bomb problem.

Well, the classical fork-bomb would probably try to spawn an infinite
amount of processes, while the number of processes spawned by "make -j"
is limited to the amount of source files (200 in my reproduction Makefile=
)
and "make" will not restart any processes that got OOM-killed, so it
should terminate after a (not really long) while.

> Don't you use your test set under some cpu cgroup ?

I use the "cpu" controller, too, but haven't seen adverse
effects from doing that so far.
Even in the situation of the livelock I reported, processes
of other users that do not try I/O get their fair share
of CPU time.


> Then, you can stop oom-kill by echo 1>  .../memory.oom_control.
> All processes under memcg will be blocked. you can kill all process und=
er memcg
> by you hands.

Well, but automatic OOM-killing of the processes of the memory hog was ex=
actly
the desired behaviour I was looking for :-)


>>    echo 64M>/cgroup/test/memory.limit_in_bytes
>>    echo 64M>/cgroup/test/memory.memsw.limit_in_bytes
>
> 64M is crazy small limit for make -j , I use 300M for my test...

Just as well, in our real-world use case, the limits are set both
to 16G (which still isn't enough for a "make -j" on our huge source tree)=
,
I intentionally set a rather low limit for the test-Makefile because
I wanted to spare others from first having to write 16G of bogus
source-files to their local storage before the symptom can be reproduced.=



> and plesse see what hapeens when
>
>   echo 1>  /memory.oom_control

When I do this before the "make -j", the make childs are stopped,
processes of other users proceed normally.

But of course this will let the user who did the "make -j" assume
the machine is just busy with the compilation, instead of telling
him "you used too much memory".
And further processes started by the same users will mysteriously
stop, too...


> Then, waiting for some page bit...I/O of libc mapped pages ?
>
> Hmm. it seems buggy behavior. Okay, I'll dig this.

Thanks a lot for investigating!

Regards,

Lutz Vieweg


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
