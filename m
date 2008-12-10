Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id mBA7pBpq031167
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 18:51:11 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mBA7kkGN4182124
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 18:46:46 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mBA7kDYk020862
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 18:46:14 +1100
Date: Wed, 10 Dec 2008 13:16:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][RFT] memcg fix cgroup_mutex deadlock when cpuset
	reclaims memory
Message-ID: <20081210074611.GA25467@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20081210051947.GH7593@balbir.in.ibm.com> <20081210151948.9a83f70a.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20081210151948.9a83f70a.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: menage@google.com, KAMEZAWA Hiroyuki <kamezawa.hiroyuki@jp.fujitsu.com>, Daisuke Miyakawa <dmiyakawa@google.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> [2008-12-10 15:19:48]:

> On Wed, 10 Dec 2008 10:49:47 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > Hi,
> > 
> > Here is a proposed fix for the memory controller cgroup_mutex deadlock
> > reported. It is lightly tested and reviewed. I need help with review
> > and test. Is the reported deadlock reproducible after this patch? A
> > careful review of the cpuset impact will also be highly appreciated.
> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > cpuset_migrate_mm() holds cgroup_mutex throughout the duration of
> > do_migrate_pages(). The issue with that is that
> > 
> > 1. It can lead to deadlock with memcg, as do_migrate_pages()
> >    enters reclaim
> > 2. It can lead to long latencies, preventing users from creating/
> >    destroying other cgroups anywhere else
> > 
> > The patch holds callback_mutex through the duration of cpuset_migrate_mm() and
> > gives up cgroup_mutex while doing so.
> > 
> I agree changing cpuset_migrate_mm not to hold cgroup_mutex to fix the dead lock
> is one choice, and it looks good to me at the first impression.
> 
> But I'm not sure it's good to change cpuset(other subsystem) code because of memcg.
> 
> Anyway, I'll test this patch and report the result tomorrow.
> (Sorry, I don't have enough time today.)

Thanks for helping Daisuke-San!

I'll look forward to your test result. I'll continue to pound my
system meanwhile

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
