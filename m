Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 9C6E46B02CF
	for <linux-mm@kvack.org>; Fri,  3 May 2013 05:59:27 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jc3so637418bkc.14
        for <linux-mm@kvack.org>; Fri, 03 May 2013 02:59:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130503091149.GA17496@dhcp22.suse.cz>
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
	<1356456367-14660-1-git-send-email-handai.szj@taobao.com>
	<20130102104421.GC22160@dhcp22.suse.cz>
	<20130503091149.GA17496@dhcp22.suse.cz>
Date: Fri, 3 May 2013 17:59:24 +0800
Message-ID: <CAFj3OHU1DMVKuzaHGbnBnRGzzvzUC6+t-k2zb3v=BnZP0CiEcg@mail.gmail.com>
Subject: Re: [PATCH V3 4/8] memcg: add per cgroup dirty pages accounting
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Glauber Costa <glommer@parallels.com>, Dave Chinner <dchinner@redhat.com>, Sha Zhengju <handai.szj@taobao.com>

On Fri, May 3, 2013 at 5:11 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Wed 02-01-13 11:44:21, Michal Hocko wrote:
>> On Wed 26-12-12 01:26:07, Sha Zhengju wrote:
>> > From: Sha Zhengju <handai.szj@taobao.com>
>> >
>> > This patch adds memcg routines to count dirty pages, which allows memory controller
>> > to maintain an accurate view of the amount of its dirty memory and can provide some
>> > info for users while cgroup's direct reclaim is working.
>>
>> I guess you meant targeted resp. (hard/soft) limit reclaim here,
>> right? It is true that this is direct reclaim but it is not clear to me
>> why the usefulnes should be limitted to the reclaim for users. I would
>> understand this if the users was in fact in-kernel users.
>>
>> [...]
>> > To prevent AB/BA deadlock mentioned by Greg Thelen in previous version
>> > (https://lkml.org/lkml/2012/7/30/227), we adjust the lock order:
>> > ->private_lock --> mapping->tree_lock --> memcg->move_lock.
>> > So we need to make mapping->tree_lock ahead of TestSetPageDirty in __set_page_dirty()
>> > and __set_page_dirty_nobuffers(). But in order to avoiding useless spinlock contention,
>> > a prepare PageDirty() checking is added.
>>
>> But there is another AA deadlock here I believe.
>> page_remove_rmap
>>   mem_cgroup_begin_update_page_stat           <<< 1
>>   set_page_dirty
>>     __set_page_dirty_buffers
>>       __set_page_dirty
>>         mem_cgroup_begin_update_page_stat     <<< 2
>>         move_lock_mem_cgroup
>>           spin_lock_irqsave(&memcg->move_lock, *flags);
>
> JFYI since abf09bed (s390/mm: implement software dirty bits) this is no
> longer possible. I haven't checked wheter there are other cases like
> this one and it should be better if mem_cgroup_begin_update_page_stat
> was recursive safe if that can be done without too many hacks.
> I will have a look at this (hopefully) sometimes next week.
>

Hi Michal,


I'm sorry for not being able to return to this problem immediately after LSF/MM.
That is good news. IIRC, it's the only place we have encountered
recursive problem in accounting memcg dirty pages. But I'll try to
revive my previous work of simplifying
mem_cgroup_begin_update_page_stat() lock.
I'll back to it in next few days.


--
Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
