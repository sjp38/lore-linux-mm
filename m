Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id BB2626B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 07:37:40 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so17409809wic.1
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 04:37:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i10si3826226wix.56.2015.08.21.04.37.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Aug 2015 04:37:38 -0700 (PDT)
Subject: Re: difficult to pinpoint exhaustion of swap between 4.2.0-rc6 and
 4.2.0-rc7
References: <55D4A462.3070505@internode.on.net> <55D58CEB.9070701@suse.cz>
 <55D6ECBD.60303@internode.on.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55D70D80.5060009@suse.cz>
Date: Fri, 21 Aug 2015 13:37:36 +0200
MIME-Version: 1.0
In-Reply-To: <55D6ECBD.60303@internode.on.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arthur Marsh <arthur.marsh@internode.on.net>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On 08/21/2015 11:17 AM, Arthur Marsh wrote:
>
>
> Vlastimil Babka wrote on 20/08/15 17:46:
>> On 08/19/2015 05:44 PM, Arthur Marsh wrote:
>>> Hi, I've found that the Linus' git head kernel has had some unwelcome
>>> behaviour where chromium browser would exhaust all swap space in the
>>> course of a few hours. The behaviour appeared before the release of
>>> 4.2.0-rc7.
>>
>> Do you have any more details about the memory/swap usage? Is it really
>> that chromium process(es) itself eats more memory and starts swapping,
>> or that something else (a graphics driver?) eats kernel memory, and
>> chromium as one of the biggest processes is driven to swap by that? Can
>> you provide e.g. top output with good/bad kernels?
>>
>> Also what does /proc/meminfo and /proc/zoneinfo look like when it's
>> swapping?
>>
>> To see which processes use swap, you can try [1] :
>> for file in /proc/*/status ; do awk '/VmSwap|Name/{printf $2 " " $3}END{
>> print ""}' $file; done | sort -k 2 -n -r | less
>>
>> Thanks
>>
>> [1] http://www.cyberciti.biz/faq/linux-which-process-is-using-swap/
>>
>>> This does not happen with kernel 4.2.0-rc6.
>
> Sorry for the delay in replying. I had to give an extended run under
> kernel 4.2.0-rc6 to obtain comparative results. Both kernels' config
> files are attached.
>
> The applications running are the same both times, mainly iceweasel
> 38.1.0esr-3 and chromium 44.0.2403.107-1.
>
> With the rc7+ kernel but not the rc6 kernel, chromium eventually gets
> into a state of consuming lots of swap.
>
> I was able to capture the output requested when running a 4.2.0-rc7+
> kernel (Linus' git head as of around 05:00 UTC 19 August 2015) just
> before swap was exhausted, forcing me to do a control-alt-delete
> shutdown and waiting ages. The kernel config for the rc7+ is attached
>
> The comparison good kernel is from Debian:
> Linux am64 4.2.0-rc6-amd64 #1 SMP Debian 4.2~rc6-1~exp1 (2015-08-12)
> x86_64 GNU/Linux

Hm I didn't how similar are the configs, was the debian one used as a 
base for the self-compiled one? Just to rule out config differences... 
during the bisection you did use the same for compiling a "good" rc6 
kernel and "bad" rc7 kernel, right?

That, said, looking at the memory values:

rc6: Free+Buffers+A/I(Anon)+A/I(File)+Slab = 6769MB
rc7: ...                                   = 4714MB

That's 2GB unaccounted for. Which is bad, and yet not enough to explain 
a full 4GB swap. Another noticeable difference is rc7 using 1560MB ShMem 
vs 476MB. The rest must be due to more anonymous memory used by the 
processes. Iceweasel looks unchanged, so I'm guessing the chromiums... 
the top output probably doesn't give us the whole picture here. I'm 
still suspecting a graphics driver, which one do you use?

The shmem could be inspected by listing ipcs -m and ipcs -mp and grep 
grep SYSV /proc/*/maps and figuring out what processes are behind the 
pids. Doing that for rc6 and rc7 could tell us which processes use the 
extra 1GB of shmem in rc7.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
