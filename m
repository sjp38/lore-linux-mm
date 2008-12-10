Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id mBA8BMfE012981
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 13:41:22 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mBA8BOl0663784
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 13:41:24 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id mBA8BL4H023839
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 19:11:22 +1100
Date: Wed, 10 Dec 2008 13:41:14 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][RFT] memcg fix cgroup_mutex deadlock when cpuset
	reclaims memory
Message-ID: <20081210081114.GB25467@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20081210051947.GH7593@balbir.in.ibm.com> <20081210151948.9a83f70a.nishimura@mxp.nes.nec.co.jp> <20081210164126.8b3be761.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20081210164126.8b3be761.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: menage@google.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Miyakawa <dmiyakawa@google.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> [2008-12-10 16:41:26]:

> On Wed, 10 Dec 2008 15:19:48 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > On Wed, 10 Dec 2008 10:49:47 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > Hi,
> > > 
> > > Here is a proposed fix for the memory controller cgroup_mutex deadlock
> > > reported. It is lightly tested and reviewed. I need help with review
> > > and test. Is the reported deadlock reproducible after this patch? A
> > > careful review of the cpuset impact will also be highly appreciated.
> > > 
> > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > 
> > > cpuset_migrate_mm() holds cgroup_mutex throughout the duration of
> > > do_migrate_pages(). The issue with that is that
> > > 
> > > 1. It can lead to deadlock with memcg, as do_migrate_pages()
> > >    enters reclaim
> > > 2. It can lead to long latencies, preventing users from creating/
> > >    destroying other cgroups anywhere else
> > > 
> > > The patch holds callback_mutex through the duration of cpuset_migrate_mm() and
> > > gives up cgroup_mutex while doing so.
> > > 
> > I agree changing cpuset_migrate_mm not to hold cgroup_mutex to fix the dead lock
> > is one choice, and it looks good to me at the first impression.
> > 
> > But I'm not sure it's good to change cpuset(other subsystem) code because of memcg.
> > 
> > Anyway, I'll test this patch and report the result tomorrow.
> > (Sorry, I don't have enough time today.)
> > 
> Unfortunately, this patch doesn't seem enough.
> 
> This patch can fix dead lock caused by "circular lock of cgroup_mutex",
> but cannot that of caused by "race between page reclaim and cpuset_attach(mpol_rebind_mm)".
> 
> (The dead lock I fixed in memcg-avoid-dead-lock-caused-by-race-between-oom-and-cpuset_attach.patch
> was caused by "race between memcg's oom and mpol_rebind_mm, and was independent of hierarchy.)
> 

Yes, I agree, my point was to fix the deadlock caused in the hierarchy
due to cpuset_migrate_mm(). If I understand correctly

1. This patch introduces no new bug, but the old bug remains. The
deadlock is fixed
2. We need this patch + your fix to completely solve the problem?

Could you also share how to reproduce the issue, I'll test on my end
as well.

Thanks for your help!

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
