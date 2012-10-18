Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id A295C6B005A
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 09:51:53 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so4092633dad.14
        for <linux-mm@kvack.org>; Thu, 18 Oct 2012 06:51:52 -0700 (PDT)
Message-ID: <5080097D.5020501@gmail.com>
Date: Thu, 18 Oct 2012 21:51:57 +0800
From: Sha Zhengju <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] oom, memcg: handle sysctl oom_kill_allocating_task while
 memcg oom happening
References: <1350382328-28977-1-git-send-email-handai.szj@taobao.com> <20121016133439.GI13991@dhcp22.suse.cz> <CAFj3OHVW-betpEnauzk-vQEfw_7bJxFneQb2oWpAZzOpZuMDiQ@mail.gmail.com> <20121018115640.GB24295@dhcp22.suse.cz>
In-Reply-To: <20121018115640.GB24295@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Sha Zhengju <handai.szj@taobao.com>, David Rientjes <rientjes@google.com>

On 10/18/2012 07:56 PM, Michal Hocko wrote:
> On Wed 17-10-12 01:14:48, Sha Zhengju wrote:
>> On Tuesday, October 16, 2012, Michal Hocko<mhocko@suse.cz>  wrote:
> [...]
>>> Could you be more specific about the motivation for this patch? Is it
>>> "let's be consistent with the global oom" or you have a real use case
>>> for this knob.
>>>
>> In our environment(rhel6), we encounter a memcg oom 'deadlock'
>> problem.  Simply speaking, suppose process A is selected to be killed
>> by memcg oom killer, but A is uninterruptible sleeping on a page
>> lock. What's worse, the exact page lock is holding by another memcg
>> process B which is trapped in mem_croup_oom_lock(proves to be a
>> livelock).
> Hmm, this is strange. How can you get down that road with the page lock
> held? Is it possible this is related to the issue fixed by: 1d65f86d
> (mm: preallocate page before lock_page() at filemap COW)?

No, it has nothing with the cow page. By checking stack of the process A
selected to be killed(uninterruptible sleeping), it was stuck at:
__do_fault->filemap_fault->__lock_page_or_retry->wait_on_page_bit--(D 
state).
The person B holding the exactly page lock is on the following path:
__do_fault->filemap_fault->__do_page_cache_readahead->..->mpage_readpages
->add_to_page_cache_locked ---- >(in memcg oom and cannot exit)
In mpage_readpages, B tends to read a dozen of pages in: for each of 
page will do
locking, charging, and then send out a big bio. And A is waiting for one 
of the pages
and stuck.

As I said, 37b23e05 has made pagefault killable by changing 
uninterruptible sleeping
to killable sleeping. So A can be woke up to exit successfully and free 
the memory which
can in turn help B pass memcg charging period.

(By the way, it seems commit 37b23e05 and 7d9fdac need to be backported 
to --stable tree
to deliver RHEL users. ;-) )

>> Then A can not exit successfully to free the memory and both of them
>> can not moving on.
>> Indeed, we should dig into these locks to find the solution and
>> in fact the 37b23e05 (x86, mm: make pagefault killable) and
>> 7d9fdac(Memcg: make oom_lock 0 and 1 based other than counter) have
>> already solved the problem, but if oom_killing_allocating_task is
>> memcg aware, enabling this suicide oom behavior will be a simpler
>> workaround. What's more, enabling the sysctl can avoid other potential
>> oom problems to some extent.
> As I said, I am not against this but I really want to see a valid use
> case first. So far I haven't seen any because what you mention above is
> a clear bug which should be fixed. I can imagine the huge number of
> tasks in the group could be a problem as well but I would like to see
> what are those problems first.
>

In view of consistent with global oom and performance benefit, I suggest
we may as well open it in memcg oom as there's no obvious harm.
As refer to the bug I mentioned, obviously the key solution is the above two
patchset, but considing other *potential* memcg oom bugs, the sysctl may
be a role of temporary workaround to some extent... but it's just a 
workaround.


Thanks,
Sha

>>> The primary motivation for oom_kill_allocating_tas AFAIU was to reduce
>>> search over huge tasklists and reduce task_lock holding times. I am not
>>> sure whether the original concern is still valid since 6b0c81b (mm,
>>> oom: reduce dependency on tasklist_lock) as the tasklist_lock usage has
>>> been reduced conciderably in favor of RCU read locks is taken but maybe
>>> even that can be too disruptive?
>>> David?
>>
>> On the other hand, from the semantic meaning of oom_kill_allocating_task,
>> it implies to allow suicide-like oom, which has no obvious relationship
>> with performance problems(such as huge task lists or task_lock holding
>> time).
> I guess that suicide-like oom in fact means "kill the poor soul that
> happened to charge the last". I do not see any use case for this from
> top of my head (appart from the performance benefits of course).
>
>> So make the sysctl be consistent with global oom will be better or set
>> an individual option for memcg oom just as panic_on_oom does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
