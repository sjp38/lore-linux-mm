Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8096B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 01:29:06 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 200A83EE0C1
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 14:29:01 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0019745DEA3
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 14:29:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CC3FE45DE83
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 14:29:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BF0B01DB803F
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 14:29:00 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 88ACB1DB8038
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 14:29:00 +0900 (JST)
Date: Fri, 10 Jun 2011 14:22:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] [BUGFIX] update mm->owner even if no next owner.
Message-Id: <20110610142203.f2d6c922.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTi=_-md7tes5GPcYh5Bpd=g_FVaagw@mail.gmail.com>
References: <20110609212956.GA2319@redhat.com>
	<BANLkTikCfWhoLNK__ringzy7KjKY5ZEtNb3QTuX1jJ53wNNysA@mail.gmail.com>
	<BANLkTikF7=qfXAmrNzyMSmWm7Neh6yMAB8EbBp7oLcfQmrbDjA@mail.gmail.com>
	<20110610091355.2ce38798.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1106091812030.4904@sister.anvils>
	<20110610113311.409bb423.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610121949.622e4629.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610125551.385ea7ed.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610133021.2eaaf0da.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=_-md7tes5GPcYh5Bpd=g_FVaagw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiaotian Feng <xtfeng@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Fri, 10 Jun 2011 13:21:46 +0800
Xiaotian Feng <xtfeng@gmail.com> wrote:

> On Fri, Jun 10, 2011 at 12:30 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> >
> > I think this can be a fix.
> > maybe good to CC Oleg.
> 
> ==
> > From dff52fb35af0cf36486965d19ee79e04b59f1dc4 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Fri, 10 Jun 2011 13:15:14 +0900
> > Subject: [PATCH] [BUGFIX] update mm->owner even if no next owner.
> >
> > A panic is reported.
> >
> > > Call Trace:
> > >  [<ffffffff81139792>] mem_cgroup_from_task+0x15/0x17
> > >  [<ffffffff8113a75a>] __mem_cgroup_try_charge+0x148/0x4b4
> > >  [<ffffffff810493f3>] ? need_resched+0x23/0x2d
> > >  [<ffffffff814cbf43>] ? preempt_schedule+0x46/0x4f
> > >  [<ffffffff8113afe8>] mem_cgroup_charge_common+0x9a/0xce
> > >  [<ffffffff8113b6d1>] mem_cgroup_newpage_charge+0x5d/0x5f
> > >  [<ffffffff81134024>] khugepaged+0x5da/0xfaf
> > >  [<ffffffff81078ea0>] ? __init_waitqueue_head+0x4b/0x4b
> > >  [<ffffffff81133a4a>] ? add_mm_counter.constprop.5+0x13/0x13
> > >  [<ffffffff81078625>] kthread+0xa8/0xb0
> > >  [<ffffffff814d13e8>] ? sub_preempt_count+0xa1/0xb4
> > >  [<ffffffff814d5664>] kernel_thread_helper+0x4/0x10
> > >  [<ffffffff814ce858>] ? retint_restore_args+0x13/0x13
> > >  [<ffffffff8107857d>] ? __init_kthread_worker+0x5a/0x5a
> >
> > The code is.
> > >         return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
> > >                                 struct mem_cgroup, css);
> >
> >
> > What happens here is accssing a freed task struct "p" from mm->owner.
> > So, it's doubtful that mm->owner points to freed task struct.
> >
> >
> But from the bug itself, it looks more likely kernel is hitting a freed
> p->cgroups, right?
> If p is already freed, the kernel will fault on
> 781cc62d: 8b 82 fc 08 00 00       mov    0x8fc(%edx),%eax
> 
> Then you will not get a value of 6b6b6b87, right?


%edx here is a pointer for task struct.
Then, task->cgroup == 0x6b6b6b6b. It means "task" is freed.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
