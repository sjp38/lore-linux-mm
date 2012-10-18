Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 4F5136B0044
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 11:33:00 -0400 (EDT)
Date: Thu, 18 Oct 2012 17:32:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom, memcg: handle sysctl oom_kill_allocating_task while
 memcg oom happening
Message-ID: <20121018153256.GC24295@dhcp22.suse.cz>
References: <1350382328-28977-1-git-send-email-handai.szj@taobao.com>
 <20121016133439.GI13991@dhcp22.suse.cz>
 <CAFj3OHVW-betpEnauzk-vQEfw_7bJxFneQb2oWpAZzOpZuMDiQ@mail.gmail.com>
 <20121018115640.GB24295@dhcp22.suse.cz>
 <5080097D.5020501@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5080097D.5020501@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Sha Zhengju <handai.szj@taobao.com>, David Rientjes <rientjes@google.com>

On Thu 18-10-12 21:51:57, Sha Zhengju wrote:
> On 10/18/2012 07:56 PM, Michal Hocko wrote:
> >On Wed 17-10-12 01:14:48, Sha Zhengju wrote:
> >>On Tuesday, October 16, 2012, Michal Hocko<mhocko@suse.cz>  wrote:
> >[...]
> >>>Could you be more specific about the motivation for this patch? Is it
> >>>"let's be consistent with the global oom" or you have a real use case
> >>>for this knob.
> >>>
> >>In our environment(rhel6), we encounter a memcg oom 'deadlock'
> >>problem.  Simply speaking, suppose process A is selected to be killed
> >>by memcg oom killer, but A is uninterruptible sleeping on a page
> >>lock. What's worse, the exact page lock is holding by another memcg
> >>process B which is trapped in mem_croup_oom_lock(proves to be a
> >>livelock).
> >Hmm, this is strange. How can you get down that road with the page lock
> >held? Is it possible this is related to the issue fixed by: 1d65f86d
> >(mm: preallocate page before lock_page() at filemap COW)?
> 
> No, it has nothing with the cow page. By checking stack of the process A
> selected to be killed(uninterruptible sleeping), it was stuck at:
> __do_fault->filemap_fault->__lock_page_or_retry->wait_on_page_bit--(D
> state).
> The person B holding the exactly page lock is on the following path:
> __do_fault->filemap_fault->__do_page_cache_readahead->..->mpage_readpages
> ->add_to_page_cache_locked ---- >(in memcg oom and cannot exit)

Hmm filemap_fault locks the page after the read ahead is triggered
already so it doesn't call mpage_readpages with any page locked - the
add_to_page_cache_lru is called without any page locked.
This is at least the current code. It might be different in rhel6 but
calling memcg charging with a page lock is definitely a bug.

> In mpage_readpages, B tends to read a dozen of pages in: for each of
> page will do
> locking, charging, and then send out a big bio. And A is waiting for
> one of the pages
> and stuck.
> 
> As I said, 37b23e05 has made pagefault killable by changing
> uninterruptible sleeping to killable sleeping. So A can be woke up to
> exit successfully and free the memory which can in turn help B pass
> memcg charging period.
> 
> (By the way, it seems commit 37b23e05 and 7d9fdac need to be

79dfdaccd1d5 you mean, right? That one just helps when there are too
many tasks trashing oom killer so it is not related to what you are
trying to achieve. Besides that make sure you take 23751be0 if you
take it.

> backported to --stable tree to deliver RHEL users. ;-) )

I am not sure the first one qualifies the stable tree inclusion as it is
a feature.

> >>Then A can not exit successfully to free the memory and both of them
> >>can not moving on.
> >>Indeed, we should dig into these locks to find the solution and
> >>in fact the 37b23e05 (x86, mm: make pagefault killable) and
> >>7d9fdac(Memcg: make oom_lock 0 and 1 based other than counter) have
> >>already solved the problem, but if oom_killing_allocating_task is
> >>memcg aware, enabling this suicide oom behavior will be a simpler
> >>workaround. What's more, enabling the sysctl can avoid other potential
> >>oom problems to some extent.
> >As I said, I am not against this but I really want to see a valid use
> >case first. So far I haven't seen any because what you mention above is
> >a clear bug which should be fixed. I can imagine the huge number of
> >tasks in the group could be a problem as well but I would like to see
> >what are those problems first.
> >
> 
> In view of consistent with global oom and performance benefit, I suggest
> we may as well open it in memcg oom as there's no obvious harm.

I am not sure about "no obvious harm" part. The policy could be
different in different groups e.g. and the global knob could be really
misleading. But the question is. Is it worth having this per group? To
be honest, I do not like the global knob either and I am not entirely
keen on spreading it out into memcg unless there is a real use case for
it.

> As refer to the bug I mentioned, obviously the key solution is the above two
> patchset, but considing other *potential* memcg oom bugs, the sysctl may
> be a role of temporary workaround to some extent... but it's just a
> workaround.

We shouldn't add something like that just to workaround obvious bugs.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
