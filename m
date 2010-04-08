Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 612346B0210
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 14:06:09 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o38I63TC030009
	for <linux-mm@kvack.org>; Thu, 8 Apr 2010 20:06:03 +0200
Received: from pzk26 (pzk26.prod.google.com [10.243.19.154])
	by wpaz17.hot.corp.google.com with ESMTP id o38I61n0010653
	for <linux-mm@kvack.org>; Thu, 8 Apr 2010 11:06:02 -0700
Received: by pzk26 with SMTP id 26so2103906pzk.6
        for <linux-mm@kvack.org>; Thu, 08 Apr 2010 11:06:01 -0700 (PDT)
Date: Thu, 8 Apr 2010 11:05:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable task
 can be found
In-Reply-To: <20100407205418.FB90.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1004081036520.25592@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com> <20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com> <20100407205418.FB90.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Apr 2010, KOSAKI Motohiro wrote:

> > > > oom-badness-heuristic-rewrite.patch
> > > 
> > > Do you have any specific feedback that you could offer on why you decided 
> > > to nack this?
> > > 
> > 
> > I like this patch. But I think no one can't Ack this because there is no
> > "correct" answer. At least, this show good behavior on my environment.
> 
> see diffstat. that's perfectly crap, obviously need to make separate patches
> individual one. Who can review it?
> 
>  Documentation/filesystems/proc.txt |   95 ++++----
>  Documentation/sysctl/vm.txt        |   21 +
>  fs/proc/base.c                     |   98 ++++++++
>  include/linux/memcontrol.h         |    8
>  include/linux/oom.h                |   17 +
>  include/linux/sched.h              |    3
>  kernel/fork.c                      |    1
>  kernel/sysctl.c                    |    9
>  mm/memcontrol.c                    |   18 +
>  mm/oom_kill.c                      |  319 ++++++++++++++-------------
>  10 files changed, 404 insertions(+), 185 deletions(-)
> 
> additional commets is in below.
> 

This specific change cannot be broken down into individual patches as much 
as I'd like to.  It's a complete rewrite of the badness() function and 
requires two new tunables to be introduced, determination of the amount of 
memory available to current, formals being changed around, and 
documentation.

A review tip: the change itself is in the rewrite of the function now 
called oom_badness(), so I recommend applying downloading mmotm and 
reading it there as well as the documentation change.  The remainder of 
the patch fixes up the various callers of that function and isn't 
interesting.

> If you suggest to revert pagefault_oom itself, it is considerable. but
> even though I don't think so.
> 
> quote nick's mail
> 
> 	The thing I should explain is that user interfaces are most important
> 	for their intended semantics. We don't generally call bugs or oversights
> 	part of the interface, and they are to be fixed unless some program
> 	relies on them.
> 

I disagree, I believe the long-standing semantics of user interfaces such 
as panic_on_oom are more important than what the name implies or what it 
was intended for when it was introduced.

> 	Nowhere in the vm documentation does it say anything about "pagefault
> 	ooms", and even in the kernel code, even to mm developers (who mostly
> 	don't care about oom killer) probably wouldn't immediately think of
> 	pagefault versus any other type of oom.
> 
> 	Given that, do you think it is reasonable, when panic_on_oom is set,
> 	to allow a process to be killed due to oom condition? Or do you think
> 	that was an oversight of the implementation?
> 

Users have a well-defined and long-standing method of protecting their 
applications from oom kill and that is OOM_DISABLE.  With my patch, if 
current is unkillable because it is OOM_DISABLE, then we fallback to a 
tasklist scan iff panic_on_oom is unset.

> 	Regardless of what architectures currently do. Yes there is a
> 	consistency issue, and it should have been fixed earlier, but the
> 	consistency issue goes both ways now. Some (the most widely tested
> 	and used, if that matters) architectures, do it the right way.
> 
> So, this patch is purely backstep. it break panic_on_oom.
> If anyone post "pagefault_out_of_memory() aware pagefault for ppc" or 
> something else architecture, I'm glad and ack it.
> 

It's not a backstep, it's making all architectures consistent as it sits 
right now in mmotm.  If someone would like to change all VM_FAULT_OOM 
handlers to do a tasklist scan and not default to killing current, that is 
an extension of this patchset.  Likewise, if we want to ensure 
panic_on_oom is respected even for pagefault ooms, then we need to do that 
on all architectures so that we don't have multiple definitions depending 
on machine type.  The semantics of a sysctl shouldn't depend on the 
architecture and right now it does, so this patch fixes that.  In other 
words: if you want to extend the definition of panic_on_oom, then do so 
completely for all architectures first and then add it to the 
documentation.

> > > > oom-deprecate-oom_adj-tunable.patch
> > > 
> > > Alan had a concern about removing /proc/pid/oom_adj, or redefining it with 
> > > different semantics as I originally did, and then I updated the patchset 
> > > to deprecate the old tunable as Andrew suggested.
> > > 
> > > My somewhat arbitrary time of removal was approximately 18 months from 
> > > the date of deprecation which would give us 5-6 major kernel releases in 
> > > between.  If you think that's too early of a deadline, then I'd happily 
> > > extend it by 6 months or a year.
> > > 
> > > Keeping /proc/pid/oom_adj around indefinitely isn't very helpful if 
> > > there's a finer grained alternative available already unless you want 
> > > /proc/pid/oom_adj to actually mean something in which case you'll never be 
> > > able to seperate oom badness scores from bitshifts.  I believe everyone 
> > > agrees that a more understood and finer grained tunable is necessary as 
> > > compared to the current implementation that has very limited functionality 
> > > other than polarizing tasks.
> 
> The problem is, oom_adj is one of most widely used knob. it is not only used
> admin, but also be used applications. in addition, oom_score_adj is bad interface
> and no good to replace oom_adj. kamezawa-san, as following your mentioned.
> 

oom_adj is retained but deprecated, so I'm not sure what you're suggesting 
here.  Do you think we should instead keep oom_adj forever in parallel 
with oom_score_adj?  It's quite clear that a more powerful, finer-grained 
solution is necessary than what oom_adj provides.  I believe the 
deprecation for 5-6 major kernel releases is enough, but we can certainly 
talk about extending that by a year if you'd like.

Can you elaborate on why you believe oom_score_adj is a bad interface or 
have had problems with it in your personal use?

> agreed. oom_score_adj is completely crap. should gone.
> but also following pseudo scaling adjustment is crap too. it don't consider
> both page sharing and mlock pages. iow, it never works correctly.
> 
> 
> +       points = (get_mm_rss(mm) + get_mm_counter(mm, MM_SWAPENTS)) * 1000 /
> +                       totalpages;
> 

That baseline actually does work much better than total_vm as we've 
discussed multiple times on LKML leading up to the development of this 
series, but if you'd like to propose additional considerations into the 
heuristic, than please do so.

> > > > oom-replace-sysctls-with-quick-mode.patch
> > > > 
> > > > IIRC, alan and nick and I NAKed such patch. everybody explained the reason.
> > > 
> > > Which patch of the four you listed are you referring to here?
> > > 
> > replacing used sysctl is bad idea, in general.
> > 
> > I have no _strong_ opinion. I welcome the patch series. But aboves are my concern.
> > Thank you for your work.
> 
> I really hate "that is _inteltional_ regression" crap. now almost developers
> ignore a bug report and don't join problem investigate works. I and very few
> people does that. (ok, I agree you are in such few developers, thanks)
> 
> Why can't we discard it simplely? please don't make crap.
> 

Perhaps you don't understand.  The users of oom_kill_allocating_task are 
those systems that have extremely large tasklists and so iterating through 
it comes at a substantial cost.  It was originally requested by SGI 
because they preferred an alternative to the tasklist scan used for 
cpuset-constrained ooms and were satisfied with simply killing something 
quickly instead of iterating the tasklist.

This patchset, however, enables oom_dump_tasks by default because it 
provides useful information to the user to understand the memory use of 
their applications so they can hopefully determine why the oom occurred.  
This requires a tasklist scan itself, so those same users of 
oom_kill_allocating_task are no longer protected from that cost by simply 
setting this sysctl.  They must also disable oom_dump_tasks or we're at 
the same efficiency that we were before oom_kill_allocating_task was 
introduced.

Since they must modify their startup scripts, and since the users of both 
of these sysctls are the same and nobody would use one without the other, 
it should be possible to consolidate them into a single sysctl.  If 
additional changes are made to the oom killer in the future, it would then 
be possible to test for this single sysctl, oom_kill_quick, instead 
without introducing additional sysctls and polluting procfs.

Thus, it's completely unnecessary to keep oom_kill_allocating_task and we 
can redefine it for those systems.  What alternatives do you have in mind 
or what part of this logic do you not agree with?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
