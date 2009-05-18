Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8ECCD6B005D
	for <linux-mm@kvack.org>; Mon, 18 May 2009 06:12:32 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4IACf7C026950
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 18 May 2009 19:12:41 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FF7145DD74
	for <linux-mm@kvack.org>; Mon, 18 May 2009 19:12:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1294645DD7A
	for <linux-mm@kvack.org>; Mon, 18 May 2009 19:12:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 36F351DB8017
	for <linux-mm@kvack.org>; Mon, 18 May 2009 19:12:40 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C248E0800E
	for <linux-mm@kvack.org>; Mon, 18 May 2009 19:12:39 +0900 (JST)
Date: Mon, 18 May 2009 19:11:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Low overhead patches for the memory cgroup controller
 (v2)
Message-Id: <20090518191107.8a7cc990.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090515181639.GH4451@balbir.in.ibm.com>
References: <b7dd123f0a15fff62150bc560747d7f0.squirrel@webmail-b.css.fujitsu.com>
	<20090515181639.GH4451@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, KOSAKI Motohiro <m-kosaki@ceres.dti.ne.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 15 May 2009 23:46:39 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-05-16 02:45:03]:
> 
> > Balbir Singh wrote:
> > > Feature: Remove the overhead associated with the root cgroup
> > >
> > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > >
> > > This patch changes the memory cgroup and removes the overhead associated
> > > with LRU maintenance of all pages in the root cgroup. As a side-effect, we
> > > can
> > > no longer set a memory hard limit in the root cgroup.
> > >
> > > A new flag is used to track page_cgroup associated with the root cgroup
> > > pages. A new flag to track whether the page has been accounted or not
> > > has been added as well.
> > >
> > > Review comments higly appreciated
> > >
> > > Tests
> > >
> > > 1. Tested with allocate, touch and limit test case for a non-root cgroup
> > > 2. For the root cgroup tested performance impact with reaim
> > >
> > >
> > > 		+patch		mmtom-08-may-2009
> > > AIM9		1362.93		1338.17
> > > Dbase		17457.75	16021.58
> > > New Dbase	18070.18	16518.54
> > > Shared		9681.85		8882.11
> > > Compute		16197.79	15226.13
> > >
> > Hmm, at first impression, I can't convice the numbers...
> > Just avoiding list_add/del makes programs _10%_ faster ?
> > Could you show changes in cpu cache-miss late if you can ?
> > (And why Aim9 goes bad ?)
> 
> OK... I'll try but I am away on travel for 3 weeks :( you can try and run
> this as well
> 
tested aim7 with some config.

CPU: Xeon 3.1GHz/4Core x2 (8cpu)
Memory: 32G
HDD: Usual? Scsi disk (just 1 disk)
(try_to_free_pages() etc...will never be called.)

Multiuser config. #of tasks 1100 (near to peak on my host)

10runs.
rc6mm1 score(Jobs/min)
44009.1 44844.5 44691.1 43981.9 44992.6
44544.9 44179.1 44283.0 44442.9 45033.8  average=44500

+patch
44656.8 44270.8 44706.7 44106.1 44467.6
44585.3 44167.0 44756.7 44853.9 44249.4  average=44482

Dbase config. #of tasks 25
rc6mm1 score (jobs/min)
11022.7 11018.9 11037.9 11003.8 11087.5 
11145.2 11133.6 11068.3 11091.3 11106.6 average=11071

+patch
10888.0 10973.7 10913.9 11000.0 10984.9
10996.2 10969.9 10921.3 10921.3 11053.1 average=10962

Hmm, 1% improvement ?
(I think this is reasonable score of the effect of this patch)

Anyway, I'm afraid of difference between mine and your kernel config.
plz enjoy your travel for now :)

Thanks,
-Kame












--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
