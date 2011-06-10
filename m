Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C8BC26B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 00:02:51 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9BFDA3EE0C0
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 13:02:46 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8677645DE9D
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 13:02:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EE7545DE9B
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 13:02:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 636BA1DB8038
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 13:02:46 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DC761DB802C
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 13:02:46 +0900 (JST)
Date: Fri, 10 Jun 2011 12:55:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: 3.0rc2 oops in mem_cgroup_from_task
Message-Id: <20110610125551.385ea7ed.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110610121949.622e4629.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110609212956.GA2319@redhat.com>
	<BANLkTikCfWhoLNK__ringzy7KjKY5ZEtNb3QTuX1jJ53wNNysA@mail.gmail.com>
	<BANLkTikF7=qfXAmrNzyMSmWm7Neh6yMAB8EbBp7oLcfQmrbDjA@mail.gmail.com>
	<20110610091355.2ce38798.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1106091812030.4904@sister.anvils>
	<20110610113311.409bb423.kamezawa.hiroyu@jp.fujitsu.com>
	<20110610121949.622e4629.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 10 Jun 2011 12:19:49 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri, 10 Jun 2011 11:33:11 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Thu, 9 Jun 2011 18:30:49 -0700 (PDT)
> > Hugh Dickins <hughd@google.com> wrote:
>  
> > > 781cc621 <mem_cgroup_from_task>:
> > > 781cc621:	55                   	push   %ebp
> > > 781cc622:	31 c0                	xor    %eax,%eax
> > > 781cc624:	89 e5                	mov    %esp,%ebp
> > > 781cc626:	8b 55 08             	mov    0x8(%ebp),%edx
> > > 781cc629:	85 d2                	test   %edx,%edx
> > > 781cc62b:	74 09                	je     781cc636 <mem_cgroup_from_task+0x15>
> > > 781cc62d:	8b 82 fc 08 00 00    	mov    0x8fc(%edx),%eax
> > > 781cc633:	8b 40 1c             	mov    0x1c(%eax),%eax   <==========
> > > 781cc636:	c9                   	leave  
> > > 781cc637:	c3                   	ret    
> > > 
> > 
> > then, access to task->cgroups->subsys[?] causes access to 6b6b6b87...
> > 
> > Then, task->cgroups or task->cgroups->subsys contains bad pointer.
> > Considering khugepaged, it grabs mm_struct and memcg make an access to
> > (mm->owner)->cgroups->subsys.
> > 
> > Then, from memcg's point of view, we need to doubt mm->owner is valid or not
> > for this kind of tasks.
> > 
> 
> Dave's log shows 6b6b6b6b6b..., too.
> 
> I guess it as "POISON_FREE" of slab object. Then, task->cgroups may used after free.
> 
Ah, sorry.

0x1c(%eax) == 6b6b6b87 means %eax was 0x6b6b6b6b.
The %eax was the contents of [task->cgroups]....hmm, then, task itself is freed
pointer (and poisoned). So, it seems a problem of accessing mm->owner..

Thanks,
-Kame












--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
