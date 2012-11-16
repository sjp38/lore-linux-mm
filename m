Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id A30046B0062
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 21:50:56 -0500 (EST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <wangyun@linux.vnet.ibm.com>;
	Fri, 16 Nov 2012 12:46:47 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qAG2eM0j65863888
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 13:40:23 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qAG2okAi009490
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 13:50:46 +1100
Message-ID: <50A5AA03.2000707@linux.vnet.ibm.com>
Date: Fri, 16 Nov 2012 10:50:43 +0800
From: Michael Wang <wangyun@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [3.6.6] panic on reboot / khungtaskd blocked? (WARNING: at arch/x86/kernel/smp.c:123
 native_smp_send_reschedule)
References: <56378024.A3Kec8xZj0@pawels> <2413953.H7iie8v1th@pawels> <50A302C9.2060800@linux.vnet.ibm.com> <1984533.1jAeFKDqSR@localhost> <50A44854.6040905@linux.vnet.ibm.com> <20121115094046.GD1394@quack.suse.cz>
In-Reply-To: <20121115094046.GD1394@quack.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: =?UTF-8?B?UGF3ZcWCIFNpa29yYQ==?= <pawel.sikora@agmk.net>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, torvalds@linux-foundation.org, arekm@pld-linux.org, baggins@pld-linux.org, Alexander Viro <viro@zeniv.linux.org.uk>, Fengguang Wu <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On 11/15/2012 05:40 PM, Jan Kara wrote:
> On Thu 15-11-12 09:41:40, Michael Wang wrote:
>> On 11/15/2012 05:10 AM, PaweA? Sikora wrote:
>>> On Wednesday 14 of November 2012 10:32:41 Michael Wang wrote:
>>>> On 11/13/2012 05:40 PM, PaweA? Sikora wrote:
>>>>> On Monday 12 of November 2012 13:33:39 PaweA? Sikora wrote:
>>>>>> On Monday 12 of November 2012 11:22:47 PaweA? Sikora wrote:
>>>>>>> On Monday 12 of November 2012 15:40:31 Michael Wang wrote:
>>>>>>>> On 11/12/2012 03:16 PM, PaweA? Sikora wrote:
>>>>>>>>> On Monday 12 of November 2012 11:04:12 Michael Wang wrote:
>>>>>>>>>> On 11/09/2012 09:48 PM, PaweA? Sikora wrote:
>>>>>>>>>>> Hi,
>>>>>>>>>>>
>>>>>>>>>>> during playing with new ups i've caught an nice oops on reboot:
>>>>>>>>>>>
>>>>>>>>>>> http://imgbin.org/index.php?page=image&id=10253
>>>>>>>>>>>
>>>>>>>>>>> probably the upstream is also affected.
>>>>>>>>>>
>>>>>>>>>> Hi, PaweA?
>>>>>>>>>>
>>>>>>>>>> Are you using a clean 3.6.6 without any modify?
>>>>>>>>>
>>>>>>>>> yes, pure 3.6.6 form git tree with modular config.
>>>>>>>>>
>>>>>>>>>> Looks like some threads has set itself to be UNINTERRUPTIBLE with out
>>>>>>>>>> any design on switch itself back later(or the time is too long), are you
>>>>>>>>>> accidentally using some bad designed module?
>>>>>>>>>
>>>>>>>>> hmm, hard to say. mostly all modules are loaded automatically by kernel.
>>>>>>>>
>>>>>>>> Could you please provide the whole dmesg in text? your picture lost the
>>>>>>>> print info of the hung task.
>>>>>>>
>>>>>>> i've grabbed the console via rs232 but there's no more info (see attached txt).
>>>>>>
>>>>>> hmm, i have one observation.
>>>>>>
>>>>>> during rc.shutdown there're messages on console like this: Cannot stat file /proc/$pid/fd/1: Connection timed out
>>>>>> afaics this file descriptor points to vnc log file on a remote machine, e.g.:
>>>>>>
>>>>>> # ps aux|grep xfwm4
>>>>>> eda       1748  0.0  0.0 320220 11224 ?        S    13:08   0:00 xfwm4 
>>>>>>
>>>>>> # readlink -m /proc/1748/fd/1
>>>>>> /remote/dragon/ahome/eda/.vnc/odra:11.log
>>>>>>
>>>>>> # mount|grep ahome
>>>>>> dragon:/home/users/ on /remote/dragon/ahome type nfs (rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,soft,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.0.2.121,mountvers=3,mountport=45251,mountproto=udp,local_lock=none,addr=10.0.2.121)
>>>>>>
>>>>>>
>>>>>> so, probably during `killall5 -TERM/-KILL` on shutdown stage something sometimes go wrong
>>>>>> and these processes (xfce4/vncserver) survive the signal and hang on the nfs i/o.
>>>>>>
>>>>>
>>>>> ok, now i have full sysrq+w backtraces from shutdown process. i hope i'll help you.
>>>>
>>>> This can only tell us what's the task in UNINTERRUPTABLE state, but with
>>>> out time info, we can't find out which one is the hung task...
>>
>> So it's blocked on __lock_page() for too long?
>> Add more experts in mm aspect to cc.
>   It's really NFS related. E.g. in trace
> https://lkml.org/lkml/2012/11/14/657 we are waiting on PageWriteback bit
> in fact - i.e. we have submitted data to the NFS server and are waiting for
> its response that the data was written.

Do you mean, NFS lock some page, then wait on a respond which not come in?

Regards,
Michael Wang

> 
> 								Honza
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
