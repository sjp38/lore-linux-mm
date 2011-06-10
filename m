Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1D5496B004A
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 22:40:13 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id AEE603EE0AE
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 11:40:08 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 92EB545DEA3
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 11:40:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7112445DE9F
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 11:40:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 64DA61DB803E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 11:40:08 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DB681DB803A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 11:40:08 +0900 (JST)
Date: Fri, 10 Jun 2011 11:33:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: 3.0rc2 oops in mem_cgroup_from_task
Message-Id: <20110610113311.409bb423.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1106091812030.4904@sister.anvils>
References: <20110609212956.GA2319@redhat.com>
	<BANLkTikCfWhoLNK__ringzy7KjKY5ZEtNb3QTuX1jJ53wNNysA@mail.gmail.com>
	<BANLkTikF7=qfXAmrNzyMSmWm7Neh6yMAB8EbBp7oLcfQmrbDjA@mail.gmail.com>
	<20110610091355.2ce38798.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1106091812030.4904@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Ying Han <yinghan@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 9 Jun 2011 18:30:49 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> On Fri, 10 Jun 2011, KAMEZAWA Hiroyuki wrote:
> > On Thu, 9 Jun 2011 16:42:09 -0700
> > Ying Han <yinghan@google.com> wrote:
> > 
> > > ++cc Hugh who might have seen similar crashes on his machine.
> 
> Yes, I was testing my tmpfs changes, and saw it on i386 yesterday
> morning.  Same trace as Dave's (including khugepaged, which may or
> may not be relevant), aside from the i386/x86_64 differences.
> 
> BUG: unable to handle kernel paging request at 6b6b6b87
> 
> I needed to move forward with other work on that laptop, so just
> jotted down the details to come back to later.  It came after one
> hour of building swapping load in memcg, I've not tried again since.
> 
> > 
> > Thank you for forwarding. Hmm. It seems the panic happens at khugepaged's 
> > page collapse_huge_page().
> 
> Yes, the inlining in my kernel was different,
> so collapse_huge_page() showed up in my backtrace.
> 
> > 
> > ==
> >         count_vm_event(THP_COLLAPSE_ALLOC);
> >         if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
> > ==
> > It passes target mm to memcg and memcg gets a cgroup by
> > ==
> >  mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
> > ==
> > Panic here means....mm->owner's task_subsys_state contains bad pointer ?
> 
> 781cc621 <mem_cgroup_from_task>:
> 781cc621:	55                   	push   %ebp
> 781cc622:	31 c0                	xor    %eax,%eax
> 781cc624:	89 e5                	mov    %esp,%ebp
> 781cc626:	8b 55 08             	mov    0x8(%ebp),%edx
> 781cc629:	85 d2                	test   %edx,%edx
> 781cc62b:	74 09                	je     781cc636 <mem_cgroup_from_task+0x15>
> 781cc62d:	8b 82 fc 08 00 00    	mov    0x8fc(%edx),%eax
> 781cc633:	8b 40 1c             	mov    0x1c(%eax),%eax   <==========
> 781cc636:	c9                   	leave  
> 781cc637:	c3                   	ret    
> 

then, access to task->cgroups->subsys[?] causes access to 6b6b6b87...

Then, task->cgroups or task->cgroups->subsys contains bad pointer.
Considering khugepaged, it grabs mm_struct and memcg make an access to
(mm->owner)->cgroups->subsys.

Then, from memcg's point of view, we need to doubt mm->owner is valid or not
for this kind of tasks.

Thank you for inputs.

-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
