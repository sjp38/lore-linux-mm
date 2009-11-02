Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9994F6B0089
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 14:58:55 -0500 (EST)
Received: by bwz7 with SMTP id 7so7291167bwz.6
        for <linux-mm@kvack.org>; Mon, 02 Nov 2009 11:58:54 -0800 (PST)
Message-ID: <4AEF39FA.9070707@gmail.com>
Date: Mon, 02 Nov 2009 20:58:50 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: Memory overcommit
References: <hav57c$rso$1@ger.gmane.org> <4AE5CB4E.4090504@gmail.com> <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0910271843510.11372@sister.anvils> <alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com> <4AE78B8F.9050201@gmail.com> <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com> <4AE792B8.5020806@gmail.com> <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com> <20091028135519.805c4789.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910272205200.7507@chino.kir.corp.google.com> <20091028150536.674abe68.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910272311001.15462@chino.kir.corp.google.com> <20091028152015.3d383cd6.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910290136000.11476@chino.kir.corp.google.com> <4AE97861.1070902@gmail.com> <alpine.DEB.2.00.0910291248480.2276@chino.kir.corp.google.com> <4AEAF145.3010801@gmail.com> <alpine.DEB.2.00.0910301218410.31986@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.0910301218410.31986@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:

> On Fri, 30 Oct 2009, Vedran Furac wrote:
> 
>>> The problem you identified in http://pastebin.com/f3f9674a0, however, is a 
>>> forkbomb issue where the badness score should never have been so high for 
>>> kdeinit4 compared to "test".  That's directly proportional to adding the 
>>> scores of all disjoint child total_vm values into the badness score for 
>>> the parent and then killing the children instead.
>> Could you explain me why ntpd invoked oom killer? Its parent is init. Or
>> syslog-ng?
>>
> 
> Because it attempted an order-0 GFP_USER allocation and direct reclaim 
> could not free any pages.
> 
> The task that invoked the oom killer is simply the unlucky task that tried 
> an allocation that couldn't be satisified through direct reclaim.  It's 
> usually unrelated to the task chosen for kill unless 
> /proc/sys/vm/oom_kill_allocating_task is enabled (which SGI requested to 
> avoid excessively long tasklist scans).

Oh, well, I didn't know that. Maybe rephrasing of that part of the
output would help eliminating future misinterpretation.

>> OK then, if you have a solution, I would be glad to test your patch. I
>> won't care much if you don't change total_vm as a baseline. Just make
>> random killing history.
> 
> The only randomness is in selecting a task that has a different mm from 
> the parent in the order of its child list.  Yes, that can be addressed by 
> doing a smarter iteration through the children before killing one of them.
> 
> Keep in mind that a heuristic as simple as this:
> 
>  - kill the task that was started most recently by the same uid, or
> 
>  - kill the task that was started most recently on the system if a root
>    task calls the oom killer,
> 
> would have yielded perfect results for your testcase but isn't necessarily 
> something that we'd ever want to see.

Of course, I want algorithm that works well in all possible situations.

Regards,

Vedran

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
