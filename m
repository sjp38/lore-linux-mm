Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 58C406B0044
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 19:10:47 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAP0AiKA022607
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 25 Nov 2009 09:10:44 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 285A045DE60
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 09:10:44 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F240A45DE4D
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 09:10:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CCF0E1DB803E
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 09:10:43 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 74B451DB8037
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 09:10:43 +0900 (JST)
Date: Wed, 25 Nov 2009 09:07:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH -mmotm] memcg: avoid oom-killing innocent task
 in case of use_hierarchy
Message-Id: <20091125090756.690d7a68.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091124170402.GB3365@balbir.in.ibm.com>
References: <20091124145759.194cfc9f.nishimura@mxp.nes.nec.co.jp>
	<661de9470911240531p5e587c42w96995fde37dbd401@mail.gmail.com>
	<20091124230029.7245e1b8.d-nishimura@mtf.biglobe.ne.jp>
	<20091124170402.GB3365@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: nishimura@mxp.nes.nec.co.jp, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, stable <stable@kernel.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Nov 2009 22:34:02 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> [2009-11-24 23:00:29]:
> 
> > On Tue, 24 Nov 2009 19:01:54 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > On Tue, Nov 24, 2009 at 11:27 AM, Daisuke Nishimura
> > > <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > task_in_mem_cgroup(), which is called by select_bad_process() to check whether
> > > > a task can be a candidate for being oom-killed from memcg's limit, checks
> > > > "curr->use_hierarchy"("curr" is the mem_cgroup the task belongs to).
> > > >
> > > > But this check return true(it's false positive) when:
> > > >
> > > > A  A  A  A <some path>/00 A  A  A  A  A use_hierarchy == 0 A  A  A <- hitting limit
> > > > A  A  A  A  A <some path>/00/aa A  A  use_hierarchy == 1 A  A  A <- "curr"
> > > >
> > > > This leads to killing an innocent task in 00/aa. This patch is a fix for this
> > > > bug. And this patch also fixes the arg for mem_cgroup_print_oom_info(). We
> > > > should print information of mem_cgroup which the task being killed, not current,
> > > > belongs to.
> > > >
> > > 
> > > Quick Question: What happens if <some path>/00 has no tasks in it
> > > after your patches?
> > > 
> > Nothing would happen because <some path>/00 never hit its limit.
> 
> Why not? I am talking of a scenario where <some path>/00 is set to a
> limit (similar to your example) and hits its limit, but the groups
> under it have no limits, but tasks. Shouldn't we be scanning
> <some path>/00/aa as well?
> 
No.  <some path>/00 == use_hierarchy=0 means _all_ children's accounting
information is never added up to <some path>/00.

If there is no task in <some path>/00, it means <some path>/00 contains only
file cache and not-migrated rss. To hit limit, the admin has to make 
memory.(memsw).limit_in_bytes smaller. But in this case, oom is not called.
-ENOMEM is returned to users. IIUC.




> > 
> > The bug that this patch fixes is:
> > 
> > - create a dir <some path>/00 and set some limits.
> > - create a sub dir <some path>/00/aa w/o any limits, and enable hierarchy.
> > - run some programs in both in 00 and 00/aa. programs in 00 should be
> >   big enough to cause oom by its limit.
> > - when oom happens by 00's limit, tasks in 00/aa can also be killed.
> >
> 
> To be honest, the last part is fair, specifically if 00/aa has a task
> that is really the heaviest task as per the oom logic. no? Are you
> suggesting that only tasks in <some path>/00 should be selected by the
> oom logic? 
> 
<some path>/00 and <some path>/00/aa has completely different accounting set.
There are no hierarchy relationship. The directory tree shows "virtual"
hierarchy but in reality, their relationship is horizontal rather than hierarchycal.

So, killing tasks only in <some path>/00 is better.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
