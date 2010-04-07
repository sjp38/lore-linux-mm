Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0BC866B01E3
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 20:24:44 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o370OgOT010917
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 7 Apr 2010 09:24:42 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EE4245DE52
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 09:24:42 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id F3F3A45DE51
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 09:24:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D123B1DB8012
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 09:24:41 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F0C91DB8014
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 09:24:41 +0900 (JST)
Date: Wed, 7 Apr 2010 09:20:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable
 task can be found
Message-Id: <20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com>
References: <20100405154923.23228529.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1004051552400.27040@chino.kir.corp.google.com>
	<20100406201645.7E69.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Apr 2010 14:47:58 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 6 Apr 2010, KOSAKI Motohiro wrote:
> 
> > Many people reviewed these patches, but following four patches got no ack.
> > 
> > oom-badness-heuristic-rewrite.patch
> 
> Do you have any specific feedback that you could offer on why you decided 
> to nack this?
> 

I like this patch. But I think no one can't Ack this because there is no
"correct" answer. At least, this show good behavior on my environment.


> > oom-default-to-killing-current-for-pagefault-ooms.patch
> 
> Same, what is the specific concern that you have with this patch?
> 

I'm not sure about this. Personally, I feel pagefault-out-of-memory only
happens drivers are corrupted. So, I have no much concern on this.


> If you don't believe we should kill current first, could you please submit 
> patches for all other architectures like powerpc that already do this as 
> their only course of action for VM_FAULT_OOM and then make pagefault oom 
> killing consistent amongst architectures?
> 
> > oom-deprecate-oom_adj-tunable.patch
> 
> Alan had a concern about removing /proc/pid/oom_adj, or redefining it with 
> different semantics as I originally did, and then I updated the patchset 
> to deprecate the old tunable as Andrew suggested.
> 
> My somewhat arbitrary time of removal was approximately 18 months from 
> the date of deprecation which would give us 5-6 major kernel releases in 
> between.  If you think that's too early of a deadline, then I'd happily 
> extend it by 6 months or a year.
> 
> Keeping /proc/pid/oom_adj around indefinitely isn't very helpful if 
> there's a finer grained alternative available already unless you want 
> /proc/pid/oom_adj to actually mean something in which case you'll never be 
> able to seperate oom badness scores from bitshifts.  I believe everyone 
> agrees that a more understood and finer grained tunable is necessary as 
> compared to the current implementation that has very limited functionality 
> other than polarizing tasks.
> 

If oom-badness-heuristic-rewrite.patch will go ahead, this should go.
But my concern is administorator has to check all oom_score_adj and
tune it again if he adds more memory to the system.

Now, not-small amount of people use Virtual Machine or Contaienr. So, this
oom_score_adj's sensivity to the size of memory can put admins to hell.

 Assume a host A and B. A has 4G memory, B has 8G memory.
 Here, an applicaton which consumes 2G memory.
 Then, this application's oom_score will be 500 on A, 250 on B.
 To make oom_score 0 by oom_score_adj, admin should set -500 on A, -250 on B.

I think this kind of interface is _bad_. If admin is great and all machines
in the system has the same configuration, this oom_score_adj will work powerfully.
I admit it.
But usually, admin are not great and the system includes irregular hosts.
I hope you add one more magic knob to give admins to show importance of application
independent from system configuration, which can work cooperatively with oom_score_adj.


> > oom-replace-sysctls-with-quick-mode.patch
> > 
> > IIRC, alan and nick and I NAKed such patch. everybody explained the reason.
> 
> Which patch of the four you listed are you referring to here?
> 
replacing used sysctl is bad idea, in general.

I have no _strong_ opinion. I welcome the patch series. But aboves are my concern.
Thank you for your work.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
