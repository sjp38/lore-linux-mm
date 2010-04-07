Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 802286B01E3
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 09:29:32 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o37DTT2o026618
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 7 Apr 2010 22:29:29 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D02245DE51
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:29:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B23545DE4E
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:29:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 00960E38001
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:29:29 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 939141DB8038
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:29:25 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable task can be found
In-Reply-To: <20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com>
References: <alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com> <20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20100407205418.FB90.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  7 Apr 2010 22:29:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, 6 Apr 2010 14:47:58 -0700 (PDT)
> David Rientjes <rientjes@google.com> wrote:
> 
> > On Tue, 6 Apr 2010, KOSAKI Motohiro wrote:
> > 
> > > Many people reviewed these patches, but following four patches got no ack.
> > > 
> > > oom-badness-heuristic-rewrite.patch
> > 
> > Do you have any specific feedback that you could offer on why you decided 
> > to nack this?
> > 
> 
> I like this patch. But I think no one can't Ack this because there is no
> "correct" answer. At least, this show good behavior on my environment.

see diffstat. that's perfectly crap, obviously need to make separate patches
individual one. Who can review it?

 Documentation/filesystems/proc.txt |   95 ++++----
 Documentation/sysctl/vm.txt        |   21 +
 fs/proc/base.c                     |   98 ++++++++
 include/linux/memcontrol.h         |    8
 include/linux/oom.h                |   17 +
 include/linux/sched.h              |    3
 kernel/fork.c                      |    1
 kernel/sysctl.c                    |    9
 mm/memcontrol.c                    |   18 +
 mm/oom_kill.c                      |  319 ++++++++++++++-------------
 10 files changed, 404 insertions(+), 185 deletions(-)

additional commets is in below.


> > > oom-default-to-killing-current-for-pagefault-ooms.patch
> > 
> > Same, what is the specific concern that you have with this patch?
> 
> I'm not sure about this. Personally, I feel pagefault-out-of-memory only
> happens drivers are corrupted. So, I have no much concern on this.

If you suggest to revert pagefault_oom itself, it is considerable. but
even though I don't think so.

quote nick's mail

	The thing I should explain is that user interfaces are most important
	for their intended semantics. We don't generally call bugs or oversights
	part of the interface, and they are to be fixed unless some program
	relies on them.

	Nowhere in the vm documentation does it say anything about "pagefault
	ooms", and even in the kernel code, even to mm developers (who mostly
	don't care about oom killer) probably wouldn't immediately think of
	pagefault versus any other type of oom.

	Given that, do you think it is reasonable, when panic_on_oom is set,
	to allow a process to be killed due to oom condition? Or do you think
	that was an oversight of the implementation?

	Regardless of what architectures currently do. Yes there is a
	consistency issue, and it should have been fixed earlier, but the
	consistency issue goes both ways now. Some (the most widely tested
	and used, if that matters) architectures, do it the right way.

So, this patch is purely backstep. it break panic_on_oom.
If anyone post "pagefault_out_of_memory() aware pagefault for ppc" or 
something else architecture, I'm glad and ack it.


> > If you don't believe we should kill current first, could you please submit 
> > patches for all other architectures like powerpc that already do this as 
> > their only course of action for VM_FAULT_OOM and then make pagefault oom 
> > killing consistent amongst architectures?
>
> > 
> > > oom-deprecate-oom_adj-tunable.patch
> > 
> > Alan had a concern about removing /proc/pid/oom_adj, or redefining it with 
> > different semantics as I originally did, and then I updated the patchset 
> > to deprecate the old tunable as Andrew suggested.
> > 
> > My somewhat arbitrary time of removal was approximately 18 months from 
> > the date of deprecation which would give us 5-6 major kernel releases in 
> > between.  If you think that's too early of a deadline, then I'd happily 
> > extend it by 6 months or a year.
> > 
> > Keeping /proc/pid/oom_adj around indefinitely isn't very helpful if 
> > there's a finer grained alternative available already unless you want 
> > /proc/pid/oom_adj to actually mean something in which case you'll never be 
> > able to seperate oom badness scores from bitshifts.  I believe everyone 
> > agrees that a more understood and finer grained tunable is necessary as 
> > compared to the current implementation that has very limited functionality 
> > other than polarizing tasks.

The problem is, oom_adj is one of most widely used knob. it is not only used
admin, but also be used applications. in addition, oom_score_adj is bad interface
and no good to replace oom_adj. kamezawa-san, as following your mentioned.

> If oom-badness-heuristic-rewrite.patch will go ahead, this should go.
> But my concern is administorator has to check all oom_score_adj and
> tune it again if he adds more memory to the system.
> 
> Now, not-small amount of people use Virtual Machine or Contaienr. So, this
> oom_score_adj's sensivity to the size of memory can put admins to hell.
> 
>  Assume a host A and B. A has 4G memory, B has 8G memory.
>  Here, an applicaton which consumes 2G memory.
>  Then, this application's oom_score will be 500 on A, 250 on B.
>  To make oom_score 0 by oom_score_adj, admin should set -500 on A, -250 on B.
> 
> I think this kind of interface is _bad_. If admin is great and all machines
> in the system has the same configuration, this oom_score_adj will work powerfully.
> I admit it.
> But usually, admin are not great and the system includes irregular hosts.
> I hope you add one more magic knob to give admins to show importance of application
> independent from system configuration, which can work cooperatively with oom_score_adj.

agreed. oom_score_adj is completely crap. should gone.
but also following pseudo scaling adjustment is crap too. it don't consider
both page sharing and mlock pages. iow, it never works correctly.


+       points = (get_mm_rss(mm) + get_mm_counter(mm, MM_SWAPENTS)) * 1000 /
+                       totalpages;


> 
> > > oom-replace-sysctls-with-quick-mode.patch
> > > 
> > > IIRC, alan and nick and I NAKed such patch. everybody explained the reason.
> > 
> > Which patch of the four you listed are you referring to here?
> > 
> replacing used sysctl is bad idea, in general.
> 
> I have no _strong_ opinion. I welcome the patch series. But aboves are my concern.
> Thank you for your work.

I really hate "that is _inteltional_ regression" crap. now almost developers
ignore a bug report and don't join problem investigate works. I and very few
people does that. (ok, I agree you are in such few developers, thanks)

Why can't we discard it simplely? please don't make crap.


now, sadly, I can imagine why some active developers have prefered to
override ugly code immeditely rather than a code review and dialogue.
I'm feel down that I have to do it.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
