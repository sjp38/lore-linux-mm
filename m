Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E6A876B025E
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 03:32:03 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u144so22798552wmu.1
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 00:32:03 -0800 (PST)
Received: from mx1.molgen.mpg.de (mx1.molgen.mpg.de. [141.14.17.9])
        by mx.google.com with ESMTPS id dh9si18742512wjc.125.2016.12.06.00.32.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 00:32:02 -0800 (PST)
Subject: Re: INFO: rcu_sched detected stalls on CPUs/tasks with `kswapd` and
 `mem_cgroup_shrink_node`
References: <20161121134130.GB18112@dhcp22.suse.cz>
 <20161121140122.GU3612@linux.vnet.ibm.com>
 <20161121141818.GD18112@dhcp22.suse.cz>
 <20161121142901.GV3612@linux.vnet.ibm.com>
 <68025f6c-6801-ab46-b0fc-a9407353d8ce@molgen.mpg.de>
 <20161124101525.GB20668@dhcp22.suse.cz> <583AA50A.9010608@molgen.mpg.de>
 <20161128110449.GK14788@dhcp22.suse.cz>
 <109d5128-f3a4-4b6e-db17-7a1fcb953500@molgen.mpg.de>
 <29196f89-c35e-f79d-8e4d-2bf73fe930df@molgen.mpg.de>
 <20161130110944.GD18432@dhcp22.suse.cz>
 <099c4569-a010-5414-0934-6af3734d8460@molgen.mpg.de>
 <6c8599e5-7f4c-c60b-8954-08168af6343b@molgen.mpg.de>
From: Donald Buczek <buczek@molgen.mpg.de>
Message-ID: <4f7a37cc-2315-8163-71a1-cf947ee2a457@molgen.mpg.de>
Date: Tue, 6 Dec 2016 09:32:01 +0100
MIME-Version: 1.0
In-Reply-To: <6c8599e5-7f4c-c60b-8954-08168af6343b@molgen.mpg.de>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Paul Menzel <pmenzel@molgen.mpg.de>, dvteam@molgen.mpg.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>

On 12/02/16 10:14, Donald Buczek wrote:
> On 11/30/16 12:43, Donald Buczek wrote:
>> On 11/30/16 12:09, Michal Hocko wrote:
>>> [CCing Paul]
>>>
>>> On Wed 30-11-16 11:28:34, Donald Buczek wrote:
>>> [...]
>>>> shrink_active_list gets and releases the spinlock and calls 
>>>> cond_resched().
>>>> This should give other tasks a chance to run. Just as an 
>>>> experiment, I'm
>>>> trying
>>>>
>>>> --- a/mm/vmscan.c
>>>> +++ b/mm/vmscan.c
>>>> @@ -1921,7 +1921,7 @@ static void shrink_active_list(unsigned long
>>>> nr_to_scan,
>>>>          spin_unlock_irq(&pgdat->lru_lock);
>>>>
>>>>          while (!list_empty(&l_hold)) {
>>>> -               cond_resched();
>>>> +               cond_resched_rcu_qs();
>>>>                  page = lru_to_page(&l_hold);
>>>>                  list_del(&page->lru);
>>>>
>>>> and didn't hit a rcu_sched warning for >21 hours uptime now. We'll 
>>>> see.
>>> This is really interesting! Is it possible that the RCU stall detector
>>> is somehow confused?
>>
>> Wait... 21 hours is not yet a test result.
>
> For the records: We didn't have any stall warnings after 2 days and 20 
> hours now and so I'm quite confident, that my above patch fixed the 
> problem for v4.8.0. On previous boots the rcu warnings started after 
> 37,0.2,1,2,0.8 hours uptime.
>
> Now I've applied this patch to stable latest (v4.8.11) on another 
> backup machine which suffered even more rcu stalls.
>
> Donald
>
>> [...]

For the records: After 3 days and 21 hours we've got a rcu stall warning 
again [1]. So my patch didn't fix it.

Trying "[PATCH] mm, vmscan: add cond_resched into shrink_node_memcg" 
from Michal Hocko [2] on top of v4.8.12 on both servers now.

[1] https://owww.molgen.mpg.de/~buczek/321322/2016-12-06.dmesg.txt
[2] https://marc.info/?i=20161202095841.16648-1-mhocko%40kernel.org

-- 
Donald Buczek
buczek@molgen.mpg.de
Tel: +49 30 8413 1433

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
