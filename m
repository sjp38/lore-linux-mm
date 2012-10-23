Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 3AE186B0062
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 05:02:05 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so1949008dad.14
        for <linux-mm@kvack.org>; Tue, 23 Oct 2012 02:02:04 -0700 (PDT)
Message-ID: <50865D06.5090605@gmail.com>
Date: Tue, 23 Oct 2012 17:01:58 +0800
From: Sha Zhengju <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: process hangs on do_exit when oom happens
References: <op.wmbi5kbrn27o5l@gaoqiang-d1.corp.qihoo.net>	<20121019160425.GA10175@dhcp22.suse.cz> <CAKWKT+ZRMHzgCLJ1quGnw-_T1b9OboYKnQdRc2_Z=rdU_PFVtw@mail.gmail.com>
In-Reply-To: <CAKWKT+ZRMHzgCLJ1quGnw-_T1b9OboYKnQdRc2_Z=rdU_PFVtw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiang Gao <gaoqiangscut@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, linux-mm@kvack.org, bsingharora@gmail.com

On 10/23/2012 11:35 AM, Qiang Gao wrote:
> information about the system is in the attach file "information.txt"
>
> I can not reproduce it in the upstream 3.6.0 kernel..
>
> On Sat, Oct 20, 2012 at 12:04 AM, Michal Hocko<mhocko@suse.cz>  wrote:
>> On Wed 17-10-12 18:23:34, gaoqiang wrote:
>>> I looked up nothing useful with google,so I'm here for help..
>>>
>>> when this happens:  I use memcg to limit the memory use of a
>>> process,and when the memcg cgroup was out of memory,
>>> the process was oom-killed   however,it cannot really complete the
>>> exiting. here is the some information
>> How many tasks are in the group and what kind of memory do they use?
>> Is it possible that you were hit by the same issue as described in
>> 79dfdacc memcg: make oom_lock 0 and 1 based rather than counter.
>>
>>> OS version:  centos6.2    2.6.32.220.7.1
>> Your kernel is quite old and you should be probably asking your
>> distribution to help you out. There were many fixes since 2.6.32.
>> Are you able to reproduce the same issue with the current vanila kernel?
>>
>>> /proc/pid/stack
>>> ---------------------------------------------------------------
>>>
>>> [<ffffffff810597ca>] __cond_resched+0x2a/0x40
>>> [<ffffffff81121569>] unmap_vmas+0xb49/0xb70
>>> [<ffffffff8112822e>] exit_mmap+0x7e/0x140
>>> [<ffffffff8105b078>] mmput+0x58/0x110
>>> [<ffffffff81061aad>] exit_mm+0x11d/0x160
>>> [<ffffffff81061c9d>] do_exit+0x1ad/0x860
>>> [<ffffffff81062391>] do_group_exit+0x41/0xb0
>>> [<ffffffff81077cd8>] get_signal_to_deliver+0x1e8/0x430
>>> [<ffffffff8100a4c4>] do_notify_resume+0xf4/0x8b0
>>> [<ffffffff8100b281>] int_signal+0x12/0x17
>>> [<ffffffffffffffff>] 0xffffffffffffffff
>> This looks strange because this is just an exit part which shouldn't
>> deadlock or anything. Is this stack stable? Have you tried to take check
>> it more times?
>>

Does the machine only have about 700M memory? I also find something
in the log file:

Node 0 DMA free:2772kB min:72kB low:88kB high:108kB present:15312kB..
lowmem_reserve[]: 0 674 674 674
Node 0 DMA32 free:*3172kB* min:3284kB low:4104kB high:4924kB present:690712kB ..
lowmem_reserve[]: 0 0 0 0
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
179184 pages RAM  ==>  179184 * 4 / 1024 = *700M*
6773 pages reserved


Note that the free memory of DMA32(3172KB) is lower than min watermark,
which means the global is under pressure now. What's more the swap is off,
so the global oom is normal behavior.


Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
