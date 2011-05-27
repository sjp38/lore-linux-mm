Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 22D506B0011
	for <linux-mm@kvack.org>; Fri, 27 May 2011 00:34:36 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p4R4YXrJ007514
	for <linux-mm@kvack.org>; Thu, 26 May 2011 21:34:33 -0700
Received: from qyl38 (qyl38.prod.google.com [10.241.83.230])
	by kpbe17.cbf.corp.google.com with ESMTP id p4R4XgPO002426
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 May 2011 21:34:32 -0700
Received: by qyl38 with SMTP id 38so914435qyl.15
        for <linux-mm@kvack.org>; Thu, 26 May 2011 21:34:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110527120539.91778598.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikcdOGkJWxS0Sey8C1ereVk8ucvQQ@mail.gmail.com>
	<20110527114837.8fae7f00.kamezawa.hiroyu@jp.fujitsu.com>
	<20110527120539.91778598.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 26 May 2011 21:34:31 -0700
Message-ID: <BANLkTiniJjpoo+cnO2xtSm9VqzA--z9F7Q@mail.gmail.com>
Subject: Re: [RFC][PATCH v3 0/10] memcg async reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Thu, May 26, 2011 at 8:05 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 27 May 2011 11:48:37 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> On Thu, 26 May 2011 18:49:26 -0700
>> Ying Han <yinghan@google.com> wrote:
>
>> > Hmm.. I noticed a very strange behavior on a simple test w/ the patch =
set.
>> >
>> > Test:
>> > I created a 4g memcg and start doing cat. Then the memcg being OOM
>> > killed as soon as it reaches its hard_limit. We shouldn't hit OOM even
>> > w/o async-reclaim.
>> >
>> > Again, I will read through the patch. But like to post the test result=
 first.
>> >
>> > $ echo $$ >/dev/cgroup/memory/A/tasks
>> > $ cat /dev/cgroup/memory/A/memory.limit_in_bytes
>> > 4294967296
>> >
>> > $ time cat /export/hdc3/dd_A/tf0 > /dev/zero
>> > Killed
>> >
>> > real =A0 =A0 =A0 =A00m53.565s
>> > user =A0 =A0 =A0 =A00m0.061s
>> > sys 0m4.814s
>> >
>>
>> Hmm, what I see is
>> =3D=3D
>> root@bluextal kamezawa]# ls -l test/1G
>> -rw-rw-r--. 1 kamezawa kamezawa 1053261824 May 13 13:58 test/1G
>> [root@bluextal kamezawa]# mkdir /cgroup/memory/A
>> [root@bluextal kamezawa]# echo 0 > /cgroup/memory/A/tasks
>> [root@bluextal kamezawa]# echo 300M > /cgroup/memory/A/memory.limit_in_b=
ytes
>> [root@bluextal kamezawa]# echo 1 > /cgroup/memory/A/memory.async_control
>> [root@bluextal kamezawa]# cat test/1G > /dev/null
>> [root@bluextal kamezawa]# cat /cgroup/memory/A/memory.reclaim_stat
>> recent_scan_success_ratio 83
>> limit_scan_pages 82
>> limit_freed_pages 49
>> limit_elapsed_ns 242507
>> soft_scan_pages 0
>> soft_freed_pages 0
>> soft_elapsed_ns 0
>> margin_scan_pages 218630
>> margin_freed_pages 181598
>> margin_elapsed_ns 117466604
>> [root@bluextal kamezawa]#
>> =3D=3D
>>
>> I'll turn off swapaccount and try again.
>>
>
> A bug found....I added memory.async_control file to memsw.....file set by=
 mistake.
> Then, async_control cannot be enabled when swapaccount=3D0. I'll fix that=
.

Yes, i have that changed in my previous testing
>
> So, how do you enabled async_control ?

$ echo 1 >/dev/cgroup/memory/D/memory.async_control

?

--Ying
>
> Thanks,
> -Kame
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
