Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9D06B007B
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 12:04:15 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp03.au.ibm.com (8.14.3/8.13.1) with ESMTP id nAOH1QRj027678
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 04:01:26 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAOH0bhW1421448
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 04:00:39 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAOH46WU006750
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 04:04:07 +1100
Date: Tue, 24 Nov 2009 22:34:02 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH -mmotm] memcg: avoid oom-killing innocent task
	in case of use_hierarchy
Message-ID: <20091124170402.GB3365@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091124145759.194cfc9f.nishimura@mxp.nes.nec.co.jp> <661de9470911240531p5e587c42w96995fde37dbd401@mail.gmail.com> <20091124230029.7245e1b8.d-nishimura@mtf.biglobe.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20091124230029.7245e1b8.d-nishimura@mtf.biglobe.ne.jp>
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, stable <stable@kernel.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> [2009-11-24 23:00:29]:

> On Tue, 24 Nov 2009 19:01:54 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > On Tue, Nov 24, 2009 at 11:27 AM, Daisuke Nishimura
> > <nishimura@mxp.nes.nec.co.jp> wrote:
> > > task_in_mem_cgroup(), which is called by select_bad_process() to check whether
> > > a task can be a candidate for being oom-killed from memcg's limit, checks
> > > "curr->use_hierarchy"("curr" is the mem_cgroup the task belongs to).
> > >
> > > But this check return true(it's false positive) when:
> > >
> > >        <some path>/00          use_hierarchy == 0      <- hitting limit
> > >          <some path>/00/aa     use_hierarchy == 1      <- "curr"
> > >
> > > This leads to killing an innocent task in 00/aa. This patch is a fix for this
> > > bug. And this patch also fixes the arg for mem_cgroup_print_oom_info(). We
> > > should print information of mem_cgroup which the task being killed, not current,
> > > belongs to.
> > >
> > 
> > Quick Question: What happens if <some path>/00 has no tasks in it
> > after your patches?
> > 
> Nothing would happen because <some path>/00 never hit its limit.

Why not? I am talking of a scenario where <some path>/00 is set to a
limit (similar to your example) and hits its limit, but the groups
under it have no limits, but tasks. Shouldn't we be scanning
<some path>/00/aa as well?

> 
> The bug that this patch fixes is:
> 
> - create a dir <some path>/00 and set some limits.
> - create a sub dir <some path>/00/aa w/o any limits, and enable hierarchy.
> - run some programs in both in 00 and 00/aa. programs in 00 should be
>   big enough to cause oom by its limit.
> - when oom happens by 00's limit, tasks in 00/aa can also be killed.
>

To be honest, the last part is fair, specifically if 00/aa has a task
that is really the heaviest task as per the oom logic. no? Are you
suggesting that only tasks in <some path>/00 should be selected by the
oom logic? 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
