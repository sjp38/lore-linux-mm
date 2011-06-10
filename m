Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id ECF836B004A
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 21:31:05 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p5A1V16X020145
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 18:31:03 -0700
Received: from pxi20 (pxi20.prod.google.com [10.243.27.20])
	by kpbe19.cbf.corp.google.com with ESMTP id p5A1UxcT024396
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 18:31:00 -0700
Received: by pxi20 with SMTP id 20so1611856pxi.27
        for <linux-mm@kvack.org>; Thu, 09 Jun 2011 18:30:59 -0700 (PDT)
Date: Thu, 9 Jun 2011 18:30:49 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: 3.0rc2 oops in mem_cgroup_from_task
In-Reply-To: <20110610091355.2ce38798.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1106091812030.4904@sister.anvils>
References: <20110609212956.GA2319@redhat.com> <BANLkTikCfWhoLNK__ringzy7KjKY5ZEtNb3QTuX1jJ53wNNysA@mail.gmail.com> <BANLkTikF7=qfXAmrNzyMSmWm7Neh6yMAB8EbBp7oLcfQmrbDjA@mail.gmail.com> <20110610091355.2ce38798.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 10 Jun 2011, KAMEZAWA Hiroyuki wrote:
> On Thu, 9 Jun 2011 16:42:09 -0700
> Ying Han <yinghan@google.com> wrote:
> 
> > ++cc Hugh who might have seen similar crashes on his machine.

Yes, I was testing my tmpfs changes, and saw it on i386 yesterday
morning.  Same trace as Dave's (including khugepaged, which may or
may not be relevant), aside from the i386/x86_64 differences.

BUG: unable to handle kernel paging request at 6b6b6b87

I needed to move forward with other work on that laptop, so just
jotted down the details to come back to later.  It came after one
hour of building swapping load in memcg, I've not tried again since.

> 
> Thank you for forwarding. Hmm. It seems the panic happens at khugepaged's 
> page collapse_huge_page().

Yes, the inlining in my kernel was different,
so collapse_huge_page() showed up in my backtrace.

> 
> ==
>         count_vm_event(THP_COLLAPSE_ALLOC);
>         if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
> ==
> It passes target mm to memcg and memcg gets a cgroup by
> ==
>  mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
> ==
> Panic here means....mm->owner's task_subsys_state contains bad pointer ?

781cc621 <mem_cgroup_from_task>:
781cc621:	55                   	push   %ebp
781cc622:	31 c0                	xor    %eax,%eax
781cc624:	89 e5                	mov    %esp,%ebp
781cc626:	8b 55 08             	mov    0x8(%ebp),%edx
781cc629:	85 d2                	test   %edx,%edx
781cc62b:	74 09                	je     781cc636 <mem_cgroup_from_task+0x15>
781cc62d:	8b 82 fc 08 00 00    	mov    0x8fc(%edx),%eax
781cc633:	8b 40 1c             	mov    0x1c(%eax),%eax   <==========
781cc636:	c9                   	leave  
781cc637:	c3                   	ret    

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
