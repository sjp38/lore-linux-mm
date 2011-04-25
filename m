Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 574328D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 03:47:31 -0400 (EDT)
Received: by yib18 with SMTP id 18so761921yib.14
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 00:47:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110425114429.266A.A69D9226@jp.fujitsu.com>
References: <20110424202158.45578f31@neptune.home> <20110424235928.71af51e0@neptune.home>
 <20110425114429.266A.A69D9226@jp.fujitsu.com>
From: Mike Frysinger <vapier.adi@gmail.com>
Date: Mon, 25 Apr 2011 03:47:09 -0400
Message-ID: <BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Bruno_Pr=C3=A9mont?= <bonbons@linux-vserver.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Sun, Apr 24, 2011 at 22:42, KOSAKI Motohiro wrote:
>> On Sun, 24 April 2011 Bruno Pr=C3=A9mont wrote:
>> > On an older system I've been running Gentoo's revdep-rebuild to check
>> > for system linking/*.la consistency and after doing most of the work t=
he
>> > system starved more or less, just complaining about stuck tasks now an=
d
>> > then.
>> > Memory usage graph as seen from userspace showed sudden quick increase=
 of
>> > memory usage though only a very few MB were swapped out (c.f. attached=
 RRD
>> > graph).
>>
>> Seems I've hit it once again (though detected before system was fully
>> stalled by trying to reclaim memory without success).
>>
>> This time it was during simple compiling...
>> Gathered info below:
>>
>> /proc/meminfo:
>> MemTotal: =C2=A0 =C2=A0 =C2=A0 =C2=A0 480660 kB
>> MemFree: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 64948 kB
>> Buffers: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 10304 kB
>> Cached: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 6924 kB
>> SwapCached: =C2=A0 =C2=A0 =C2=A0 =C2=A0 4220 kB
>> Active: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A011100 kB
>> Inactive: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A015732 kB
>> Active(anon): =C2=A0 =C2=A0 =C2=A0 4732 kB
>> Inactive(anon): =C2=A0 =C2=A0 4876 kB
>> Active(file): =C2=A0 =C2=A0 =C2=A0 6368 kB
>> Inactive(file): =C2=A0 =C2=A010856 kB
>> Unevictable: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A032 kB
>> Mlocked: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A032 kB
>> SwapTotal: =C2=A0 =C2=A0 =C2=A0 =C2=A0524284 kB
>> SwapFree: =C2=A0 =C2=A0 =C2=A0 =C2=A0 456432 kB
>> Dirty: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A080 kB
>> Writeback: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 kB
>> AnonPages: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A06268 kB
>> Mapped: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2604 kB
>> Shmem: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 4 kB
>> Slab: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 250632 kB
>> SReclaimable: =C2=A0 =C2=A0 =C2=A051144 kB
>> SUnreclaim: =C2=A0 =C2=A0 =C2=A0 199488 kB =C2=A0 <--- look big as well.=
..
>> KernelStack: =C2=A0 =C2=A0 =C2=A0131032 kB =C2=A0 <--- what???
>
> KernelStack is used 8K bytes per thread. then, your system should have
> 16000 threads. but your ps only showed about 80 processes.
> Hmm... stack leak?

i might have a similar report for 2.6.39-rc4 (seems to be working fine
in 2.6.38.4), but for embedded Blackfin systems running gdbserver
processes over and over (so lots of short lived forks)

i wonder if you have a lot of zombies or otherwise unclaimed resources
?  does `ps aux` show anything unusual ?
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
