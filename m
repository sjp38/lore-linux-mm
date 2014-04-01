Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id C9F956B0035
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 02:29:28 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id z10so9107734pdj.32
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 23:29:28 -0700 (PDT)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id a3si10532704pay.471.2014.03.31.23.29.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 31 Mar 2014 23:29:27 -0700 (PDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 286BF3EE0C5
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 15:29:26 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1579645DEC4
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 15:29:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.nic.fujitsu.com [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E675845DEC1
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 15:29:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C8D881DB803E
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 15:29:25 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 60C33E08004
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 15:29:25 +0900 (JST)
Message-ID: <533A5CB1.1@jp.fujitsu.com>
Date: Tue, 01 Apr 2014 15:29:05 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>	<20140331143217.c6ff958e1fd9944d78507418@linux-foundation.org>	<1396306773.18499.22.camel@buesod1.americas.hpqcorp.net>	<20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org>	<1396308332.18499.25.camel@buesod1.americas.hpqcorp.net> <20140331170546.3b3e72f0.akpm@linux-foundation.org>
In-Reply-To: <20140331170546.3b3e72f0.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <davidlohr@hp.com>
Cc: Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Gotou, Yasunori" <y-goto@jp.fujitsu.com>, chenhanxiao <chenhanxiao@cn.fujitsu.com>, Gao feng <gaofeng@cn.fujitsu.com>

(2014/04/01 9:05), Andrew Morton wrote:
> On Mon, 31 Mar 2014 16:25:32 -0700 Davidlohr Bueso <davidlohr@hp.com> wrote:
>
>> On Mon, 2014-03-31 at 16:13 -0700, Andrew Morton wrote:
>>> On Mon, 31 Mar 2014 15:59:33 -0700 Davidlohr Bueso <davidlohr@hp.com> wrote:
>>>
>>>>>
>>>>> - Shouldn't there be a way to alter this namespace's shm_ctlmax?
>>>>
>>>> Unfortunately this would also add the complexity I previously mentioned.
>>>
>>> But if the current namespace's shm_ctlmax is too small, you're screwed.
>>> Have to shut down the namespace all the way back to init_ns and start
>>> again.
>>>
>>>>> - What happens if we just nuke the limit altogether and fall back to
>>>>>    the next check, which presumably is the rlimit bounds?
>>>>
>>>> afaik we only have rlimit for msgqueues. But in any case, while I like
>>>> that simplicity, it's too late. Too many workloads (specially DBs) rely
>>>> heavily on shmmax. Removing it and relying on something else would thus
>>>> cause a lot of things to break.
>>>
>>> It would permit larger shm segments - how could that break things?  It
>>> would make most or all of these issues go away?
>>>
>>
>> So sysadmins wouldn't be very happy, per man shmget(2):
>>
>> EINVAL A new segment was to be created and size < SHMMIN or size >
>> SHMMAX, or no new segment was to be created, a segment with given key
>> existed, but size is greater than the size of that segment.
>
> So their system will act as if they had set SHMMAX=enormous.  What
> problems could that cause?
>
>
> Look.  The 32M thing is causing problems.  Arbitrarily increasing the
> arbitrary 32M to an arbitrary 128M won't fix anything - we still have
> the problem.  Think bigger, please: how can we make this problem go
> away for ever?
>

Our middleware engineers has been complaining about this sysctl limit.
System administrator need to calculate required sysctl value by making sum
of all planned middlewares, and middleware provider needs to write "please
calculate systcl param by....." in their installation manuals.

Now, I think containers will be the base application platform. In the container,
the memory is limited by "memory cgroup" and the admin of container should be able
to overwrite the limit in the container to the value arbitrarily.

Because of these, I vote for

  1. remove the limit
     (but removing this may cause applications corrupted...)
  or

  2. A container admin should set the value considering memcg's limit.

  BTW, if /proc/sys is bind-mounted as read-only by lxc runtime,
  it seems difficult for admin to modify it. I have no idea whether it's lack
  of kernel feature or it's userland's problem.

Thanks,
-Kame






  





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
