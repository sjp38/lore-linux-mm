Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id F0BF06B0002
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 21:24:59 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4E79F3EE0C0
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 10:24:58 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3579E45DE50
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 10:24:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D9C645DE4D
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 10:24:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BE37E08003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 10:24:58 +0900 (JST)
Received: from G01JPEXCHYT16.g01.fujitsu.local (G01JPEXCHYT16.g01.fujitsu.local [10.128.194.55])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id ACD8A1DB802F
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 10:24:57 +0900 (JST)
Message-ID: <5175E2D4.5030004@jp.fujitsu.com>
Date: Tue, 23 Apr 2013 10:24:36 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Bug fix PATCH v2] numa, cpu hotplug: Change links of CPU and
 node when changing node number by onlining CPU
References: <5170D4CB.20900@jp.fujitsu.com> <20130422153541.04ba682f13910cfede0d2ff7@linux-foundation.org> <5175D01E.5000302@jp.fujitsu.com> <20130422173459.487fa3e6.akpm@linux-foundation.org>
In-Reply-To: <20130422173459.487fa3e6.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@gmail.com, mingo@kernel.org, hpa@zytor.com, srivatsa.bhat@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

2013/04/23 9:34, Andrew Morton wrote:
> On Tue, 23 Apr 2013 09:04:46 +0900 Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> wrote:
>
>> 2013/04/23 7:35, Andrew Morton wrote:
>>> On Fri, 19 Apr 2013 14:23:23 +0900 Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> wrote:
>>>
>>>> When booting x86 system contains memoryless node, node numbers of CPUs
>>>> on memoryless node were changed to nearest online node number by
>>>> init_cpu_to_node() because the node is not online.
>>>>
>>>> ...
>>>>
>>>> If we hot add memory to memoryless node and offine/online all CPUs on
>>>> the node, node numbers of these CPUs are changed to correct node numbers
>>>> by srat_detect_node() because the node become online.
>>>
>>> OK, here's a dumb question.
>>>
>>> At boot time the CPUs are assigned to the "nearest online node" rather
>>> than to their real memoryless node.  The patch arranges for those CPUs
>>> to still be assigned to the "nearest online node" _after_ some memory
>>> is hot-added to their real node.  Correct?
>>
>> Yes. For changing node number of CPUs safely, we should offline CPUs.
>>
>>>
>>> Would it not be better to fix this by assigning those CPUs to their real,
>>> memoryless node right at the initial boot?  Or is there something in
>>> the kernel which makes cpus-on-a-memoryless-node not work correctly?
>>>
>>
>> I think assigning CPUs to real node is better. But current Linux's node
>> strongly depend on memory. Thus if we just create cpus-on-a-memoryless-node,
>> the kernel cannot work correctly.
>
> hm, why.  I'd have thought that if we tell the kernel something like
> "this node has one zone, the size of which is zero bytes" then a
> surprising amount of the existing code will Just Work.
>
> What goes wrong?

Sorry I forgot detailed issue.
When I saw following issue, I tried to fix it and found that current
Linux's node strongly depend on memory.
https://lkml.org/lkml/2012/9/12/20

I'll try to fix it again.

Thanks,
Yasuaki Ishimatsu

> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
