Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 31D918D003B
	for <linux-mm@kvack.org>; Tue, 17 May 2011 20:53:38 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 94A6B3EE0C2
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:53:35 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D3D22AEB45
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:53:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C0FC45DE54
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:53:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0EA5DEF8006
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:53:35 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C9014E08003
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:53:34 +0900 (JST)
Message-ID: <4DD3187C.3050408@jp.fujitsu.com>
Date: Wed, 18 May 2011 09:53:16 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] comm: Introduce comm_lock spinlock to protect task->comm
 access
References: <1305665263-20933-1-git-send-email-john.stultz@linaro.org>	 <1305665263-20933-2-git-send-email-john.stultz@linaro.org>	 <20110517212734.GB28054@elte.hu> <1305669256.2466.6286.camel@twins>
In-Reply-To: <1305669256.2466.6286.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: a.p.zijlstra@chello.nl
Cc: mingo@elte.hu, john.stultz@linaro.org, linux-kernel@vger.kernel.org, joe@perches.com, mina86@mina86.com, apw@canonical.com, jirislaby@gmail.com, rientjes@google.com, dave@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org

(2011/05/18 6:54), Peter Zijlstra wrote:
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
>>
>> Why does this matter so much? A NULL string is not a big deal.
>>
>> Note, since task->comm is 16 bytes there's the CMPXCHG16B instruction on x86
>> which could be used to update it atomically, should atomicity really be
>> desired.
>
> The changelog also fails to mention _WHY_ this is no longer true. Nor
> does it treat why making it true again isn't an option.
>
> Who is changing another task's comm? That's just silly.

I'm not sure it's silly or not. But the fact is, comm override was introduced
following patch. Personally I'd like to mark it to "depend on EXPERT". but John
seems to dislike the idea.



commit 4614a696bd1c3a9af3a08f0e5874830a85b889d4
Author: john stultz <johnstul@us.ibm.com>
Date:   Mon Dec 14 18:00:05 2009 -0800

     procfs: allow threads to rename siblings via /proc/pid/tasks/tid/comm


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
