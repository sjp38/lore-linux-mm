Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BB3506B0044
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 09:28:18 -0400 (EDT)
Received: by bwz24 with SMTP id 24so1001563bwz.10
        for <linux-mm@kvack.org>; Wed, 28 Oct 2009 06:28:16 -0700 (PDT)
Message-ID: <4AE846E8.1070303@gmail.com>
Date: Wed, 28 Oct 2009 14:28:08 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: Memory overcommit
References: <hav57c$rso$1@ger.gmane.org> <20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com> <hb2cfu$r08$2@ger.gmane.org> <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com> <4ADE3121.6090407@gmail.com> <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com> <4AE5CB4E.4090504@gmail.com> <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0910271843510.11372@sister.anvils> <alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com> <4AE78B8F.9050201@gmail.com> <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com> <4AE792B8.5020806@gmail.com> <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:

> On Wed, 28 Oct 2009, Vedran Furac wrote:
> 
>>> This is wrong; it doesn't "emulate oom" since oom_kill_process() always 
>>> kills a child of the selected process instead if they do not share the 
>>> same memory.  The chosen task in that case is untouched.
>> OK, I stand corrected then. Thanks! But, while testing this I lost X
>> once again and "test" survived for some time (check the timestamps):
>>
>> http://pastebin.com/d5c9d026e
>>
>> - It started by killing gkrellm(!!!)
>> - Then I lost X (kdeinit4 I guess)
>> - Then 103 seconds after the killing started, it killed "test" - the
>> real culprit.
>>
>> I mean... how?!
>>
> 
> Here are the five oom kills that occurred in your log, and notice that the 
> first four times it kills a child and not the actual task as I explained:

Yes, but four times wrong.

> Those are practically happening simultaneously with very little memory 
> being available between each oom kill.  Only later is "test" killed:
> 
> [97240.203228] Out of memory: kill process 5005 (test) score 256912 or a child
> [97240.206832] Killed process 5005 (test)
> 
> Notice how the badness score is less than 1/4th of the others.  So while 
> you may find it to be hogging a lot of memory, there were others that 
> consumed much more.
^^^^^^^^^^^^^^^^^^^^^

This is just wrong. I have 3.5GB of RAM, free says that 2GB are empty
(ignoring cache). Culprit then allocates all free memory (2GB). That
means it is using *more* than all other processes *together*. There
cannot be any other "that consumed much more".

> You can get a more detailed understanding of this by doing
> 
> 	echo 1 > /proc/sys/vm/oom_dump_tasks
> 
> before trying your testcase; it will show various information like the 
> total_vm

Looking at total_vm (VIRT in top/vsize in ps?) is completely wrong. If I
sum up those numbers for every process running I would get:

%ps -eo pid,vsize,command|awk '{ SUM += $2} END {print SUM/1024/1024}'
14.7935

14GB. And I only have 3GB. I usually use exmap to get realistic numbers:

http://www.berthels.co.uk/exmap/doc.html

> and oom_adj value for each task at the time of oom (and the 
> actual badness score is exported per-task via /proc/pid/oom_score in 
> real-time).  This will also include the rss and show what the end result 
> would be in using that value as part of the heuristic on this particular 
> workload compared to the current implementation.

Thanks, I'll try that... but I guess that using rss would yield better
results.


Regards,

Vedran

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
