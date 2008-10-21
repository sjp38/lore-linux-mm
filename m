Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m9L5UiTX000958
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 11:00:44 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9L5Ui661015828
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 11:00:44 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m9L5Uhl7032120
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 11:00:44 +0530
Message-ID: <48FD6901.6050301@linux.vnet.ibm.com>
Date: Tue, 21 Oct 2008 11:00:41 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH -mm 1/5] memcg: replace res_counter
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp> <20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp> <6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com> <20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Mon, 20 Oct 2008 12:53:58 -0700
> "Paul Menage" <menage@google.com> wrote:
> 
>> Can't we do this in a more generic way, rather than duplicating a lot
>> of functionality from res_counter?
>>
>> You're trying to track:
>>
>> - mem usage
>> - mem limit
>> - swap usage
>> - swap+mem usage
>> - swap+mem limit
>>
>> And ensuring that:
>>
>> - mem usage < mem limit
>> - swap+mem usage < swap+mem limit
>>
>> Could we somehow represent this as a pair of resource counters, one
>> for mem and one for swap+mem that are linked together?
>>
> 
> 1. It's harmful to increase size of *generic* res_counter. So, modifing
>    res_counter only for us is not a choice.
> 2. Operation should be done under a lock. We have to do 
>    -page + swap in atomic, at least.
> 3. We want to pack all member into a cache-line, multiple res_counter
>    is no good.
> 4. I hate res_counter ;)
> 

What do you hate about it? I'll review the patchset in detail (I am currently
unwell, but I'll definitely take a look later).

>> Maybe have an "aggregate" pointer in a res_counter that points to
>> another res_counter that sums some number of counters; both the mem
>> and the swap res_counter objects for a cgroup would point to the
>> mem+swap res_counter for their aggregate. Adjusting the usage of a
>> counter would also adjust its aggregate (or fail if adjusting the
>> aggregate failed).
>>
> It's complicated. 

It seems complicated and for hierarchies we'll do a simple charge up approach
(we've agreed upon the fact that hierarchies are expensive and deep hierarchies
most definitely are)

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
