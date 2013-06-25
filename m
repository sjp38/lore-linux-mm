Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id E1DFC6B0032
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 21:39:53 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 02FE63EE0BD
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 10:39:52 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E484F45DE5D
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 10:39:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C640D45DE5A
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 10:39:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BAB111DB8047
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 10:39:51 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 632A4E18002
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 10:39:51 +0900 (JST)
Message-ID: <51C8F4B9.9060604@jp.fujitsu.com>
Date: Tue, 25 Jun 2013 10:39:05 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, memcg: add oom killer delay
References: <20130603193147.GC23659@dhcp22.suse.cz> <alpine.DEB.2.02.1306031411380.22083@chino.kir.corp.google.com> <20130604095514.GC31242@dhcp22.suse.cz> <alpine.DEB.2.02.1306042329320.20610@chino.kir.corp.google.com> <20130605093937.GK15997@dhcp22.suse.cz> <alpine.DEB.2.02.1306051657001.29626@chino.kir.corp.google.com> <20130610142321.GE5138@dhcp22.suse.cz> <alpine.DEB.2.02.1306111321360.32688@chino.kir.corp.google.com> <20130612202348.GA17282@dhcp22.suse.cz> <alpine.DEB.2.02.1306121408490.24902@chino.kir.corp.google.com> <20130613151602.GG23070@dhcp22.suse.cz> <alpine.DEB.2.02.1306131508300.8686@chino.kir.corp.google.com> <51BA6A2A.3060107@jp.fujitsu.com> <alpine.DEB.2.02.1306140254590.8780@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1306140254590.8780@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

(2013/06/14 19:12), David Rientjes wrote:
> On Fri, 14 Jun 2013, Kamezawa Hiroyuki wrote:
>
>> Reading your discussion, I think I understand your requirements.
>> The problem is that I can't think you took into all options into
>> accounts and found the best way is this new oom_delay. IOW, I can't
>> convice oom-delay is the best way to handle your issue.
>>
>
> Ok, let's talk about it.
>

I'm sorry that my RTT is long in these days.

>> Your requeirement is
>>   - Allowing userland oom-handler within local memcg.
>>
>
> Another requirement:
>
>   - Allow userland oom handler for global oom conditions.
>
> Hopefully that's hooked into memcg because the functionality is already
> there, we can simply duplicate all of the oom functionality that we'll be
> adding for the root memcg.
>

At mm-summit, it was discussed ant people seems to think user-land-oom-handler
is impossible. Hm, and in-kernel scripting was discussed, as far as I remember.



>> Considering straightforward, the answer should be
>>   - Allowing oom-handler daemon out of memcg's control by its limit.
>>     (For example, a flag/capability for a task can archive this.)
>>     Or attaching some *fixed* resource to the task rather than cgroup.
>>
>>     Allow to set task->secret_saving=20M.
>>
>
> Exactly!
>
> First of all, thanks very much for taking an interest in our usecase and
> discussing it with us.
>
> I didn't propose what I referred to earlier in the thread as "memcg
> reserves" because I thought it was going to be a more difficult battle.
> The fact that you brought it up first actually makes me think it's less
> insane :)
>
> We do indeed want memcg reserves and I have patches to add it if you'd
> like to see that first.  It ensures that this userspace oom handler can
> actually do some work in determining which process to kill.  The reserve
> is a fraction of true memory reserves (the space below the per-zone min
> watermarks) which is dependent on min_free_kbytes.  This does indeed
> become more difficult with true and complete kmem charging.  That "work"
> could be opening the tasks file (which allocates the pidlist within the
> kernel), checking /proc/pid/status for rss, checking for how long a
> process has been running, checking for tid, sending a signal to drop
> caches, etc.
>


Considering only memcg, bypassing all charge-limit-check will work.
But as you say, that will not work against global-oom.
Then, in-kernel scripting was discussed.


> We'd also like to do this for global oom conditions, which makes it even
> more interesting.  I was thinking of using a fraction of memory reserves
> as the oom killer currently does (that memory below the min watermark) for
> these purposes.
>
> Memory charging is simply bypassed for these oom handlers (we only grant
> access to those waiting on the memory.oom_control eventfd) up to
> memory.limit_in_bytes + (min_free_kbytes / 4), for example.  I don't think
> this is entirely insane because these oom handlers should lead to future
> memory freeing, just like TIF_MEMDIE processes.
>

I think that kinds of bypassing is acceptable.


>> Going back to your patch, what's confusing is your approach.
>> Why the problem caused by the amount of memory should be solved by
>> some dealy, i.e. the amount of time ?
>>
>> This exchanging sounds confusing to me.
>>
>
> Even with all of the above (which is not actually that invasive of a
> patch), I still think we need memory.oom_delay_millisecs.  I probably made
> a mistake in describing what that is addressing if it seems like it's
> trying to address any of the above.
>
> If a userspace oom handler fails to respond even with access to those
> "memcg reserves",

How this happens ?

>  the kernel needs to kill within that memcg.  Do we do
> that above a set time period (this patch) or when the reserves are
> completely exhausted?  That's debatable, but if we are to allow it for
> global oom conditions as well then my opinion was to make it as safe as
> possible; today, we can't disable the global oom killer from userspace and
> I don't think we should ever allow it to be disabled.  I think we should
> allow userspace a reasonable amount of time to respond and then kill if it
> is exceeded.
>
> For the global oom case, we want to have a priority-based memcg selection.
> Select the lowest priority top-level memcg and kill within it.  If it has
> an oom notifier, send it a signal to kill something.  If it fails to
> react, kill something after memory.oom_delay_millisecs has elapsed.  If
> there isn't a userspace oom notifier, kill something within that lowest
> priority memcg.
>

Someone may be against that kind of control and say "Hey, I have better idea".
That was another reason that oom-scirpiting was discussed. No one can implement
general-purpose-victim-selection-logic.

> The bottomline with my approach is that I don't believe there is ever a
> reason for an oom memcg to remain oom indefinitely.  That's why I hate
> memory.oom_control == 1 and I think for the global notification it would
> be deemed a nonstarter since you couldn't even login to the machine.
>
>> I'm not against what you finally want to do, but I don't like the fix.
>>
>
> I'm thrilled to hear that, and I hope we can work to make userspace oom
> handling more effective.
>
> What do you think about that above?

IMHO, it will be difficult but allowing to write script/filter for oom-killing
will be worth to try. like..

==
for_each_process :
   if comm == mem_manage_daemon :
      continue
   if user == root              :
      continue
   score = default_calc_score()
   if score > high_score :
      selected = current
==

BTW, if you love the logic in the userland oom daemon, why you can't implement
it in the kernel ? Does that do some pretty things other than sending SIGKILL ?

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
