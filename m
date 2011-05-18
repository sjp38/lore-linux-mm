Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF7A8D003B
	for <linux-mm@kvack.org>; Tue, 17 May 2011 21:03:04 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 85B643EE0BC
	for <linux-mm@kvack.org>; Wed, 18 May 2011 10:03:01 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D95745DE6A
	for <linux-mm@kvack.org>; Wed, 18 May 2011 10:03:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F4B145DE4D
	for <linux-mm@kvack.org>; Wed, 18 May 2011 10:03:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FBF01DB803F
	for <linux-mm@kvack.org>; Wed, 18 May 2011 10:03:01 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E2BEE1DB8038
	for <linux-mm@kvack.org>; Wed, 18 May 2011 10:03:00 +0900 (JST)
Message-ID: <4DD31AB4.4050007@jp.fujitsu.com>
Date: Wed, 18 May 2011 10:02:44 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] comm: Introduce comm_lock spinlock to protect task->comm
 access
References: <1305665263-20933-1-git-send-email-john.stultz@linaro.org>	 <1305665263-20933-2-git-send-email-john.stultz@linaro.org>	 <20110517212734.GB28054@elte.hu> <1305671225.2915.133.camel@work-vm>
In-Reply-To: <1305671225.2915.133.camel@work-vm>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.stultz@linaro.org
Cc: mingo@elte.hu, linux-kernel@vger.kernel.org, joe@perches.com, mina86@mina86.com, apw@canonical.com, jirislaby@gmail.com, rientjes@google.com, dave@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, a.p.zijlstra@chello.nl

(2011/05/18 7:27), John Stultz wrote:
> On Tue, 2011-05-17 at 23:27 +0200, Ingo Molnar wrote:
>> * John Stultz<john.stultz@linaro.org>  wrote:
>>
>>> The implicit rules for current->comm access being safe without locking are no
>>> longer true. Accessing current->comm without holding the task lock may result
>>> in null or incomplete strings (however, access won't run off the end of the
>>> string).
>>
>> This is rather unfortunate - task->comm is used in a number of performance
>> critical codepaths such as tracing.

Right.


>> Why does this matter so much? A NULL string is not a big deal.
>
> I'll defer to KOSAKI Motohiro and David on this bit. :)

Heh, I did ask you current locking rule of task->comm after you introduced
writable /proc/<pid>/comm.


>> Note, since task->comm is 16 bytes there's the CMPXCHG16B instruction on x86
>> which could be used to update it atomically, should atomicity really be
>> desired.
>
> Could we use this where cmpxchg16b is available and fall back to locking
> if not? Or does that put too much of a penalty on arches that don't have
> cmpxchg16b support?
>
> Alternatively, we can have locked accessors that are safe in the
> majority of slow-path warning printks, and provide unlocked accessors
> for cases where the performance is critical and the code can properly
> handle possibly incomplete comms.

Probably, this is safer choice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
