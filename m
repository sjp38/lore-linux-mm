Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id F28556B004F
	for <linux-mm@kvack.org>; Sun, 31 May 2009 19:57:48 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5101HLh022838
	for <linux-mm@kvack.org>; Sun, 31 May 2009 20:01:17 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4VNwfKW172454
	for <linux-mm@kvack.org>; Sun, 31 May 2009 19:58:41 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4VNweEm020850
	for <linux-mm@kvack.org>; Sun, 31 May 2009 19:58:41 -0400
Date: Mon, 1 Jun 2009 07:51:21 +0800
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] Low overhead patches for the memory cgroup controller
	(v2)
Message-ID: <20090531235121.GA6120@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <b7dd123f0a15fff62150bc560747d7f0.squirrel@webmail-b.css.fujitsu.com> <20090515181639.GH4451@balbir.in.ibm.com> <20090518191107.8a7cc990.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090518191107.8a7cc990.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, KOSAKI Motohiro <m-kosaki@ceres.dti.ne.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-05-18 19:11:07]:

> On Fri, 15 May 2009 23:46:39 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-05-16 02:45:03]:
> > 
> > > Balbir Singh wrote:
> > > > Feature: Remove the overhead associated with the root cgroup
> > > >
> > > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > >
> > > > This patch changes the memory cgroup and removes the overhead associated
> > > > with LRU maintenance of all pages in the root cgroup. As a side-effect, we
> > > > can
> > > > no longer set a memory hard limit in the root cgroup.
> > > >
> > > > A new flag is used to track page_cgroup associated with the root cgroup
> > > > pages. A new flag to track whether the page has been accounted or not
> > > > has been added as well.
> > > >
> > > > Review comments higly appreciated
> > > >
> > > > Tests
> > > >
> > > > 1. Tested with allocate, touch and limit test case for a non-root cgroup
> > > > 2. For the root cgroup tested performance impact with reaim
> > > >
> > > >
> > > > 		+patch		mmtom-08-may-2009
> > > > AIM9		1362.93		1338.17
> > > > Dbase		17457.75	16021.58
> > > > New Dbase	18070.18	16518.54
> > > > Shared		9681.85		8882.11
> > > > Compute		16197.79	15226.13
> > > >
> > > Hmm, at first impression, I can't convice the numbers...
> > > Just avoiding list_add/del makes programs _10%_ faster ?
> > > Could you show changes in cpu cache-miss late if you can ?
> > > (And why Aim9 goes bad ?)
> > 
> > OK... I'll try but I am away on travel for 3 weeks :( you can try and run
> > this as well
> > 
> tested aim7 with some config.
> 
> CPU: Xeon 3.1GHz/4Core x2 (8cpu)
> Memory: 32G
> HDD: Usual? Scsi disk (just 1 disk)
> (try_to_free_pages() etc...will never be called.)
> 
> Multiuser config. #of tasks 1100 (near to peak on my host)
> 
> 10runs.
> rc6mm1 score(Jobs/min)
> 44009.1 44844.5 44691.1 43981.9 44992.6
> 44544.9 44179.1 44283.0 44442.9 45033.8  average=44500
> 
> +patch
> 44656.8 44270.8 44706.7 44106.1 44467.6
> 44585.3 44167.0 44756.7 44853.9 44249.4  average=44482
> 
> Dbase config. #of tasks 25
> rc6mm1 score (jobs/min)
> 11022.7 11018.9 11037.9 11003.8 11087.5 
> 11145.2 11133.6 11068.3 11091.3 11106.6 average=11071
> 
> +patch
> 10888.0 10973.7 10913.9 11000.0 10984.9
> 10996.2 10969.9 10921.3 10921.3 11053.1 average=10962
> 
> Hmm, 1% improvement ?
> (I think this is reasonable score of the effect of this patch)
> 
> Anyway, I'm afraid of difference between mine and your kernel config.
> plz enjoy your travel for now :)
>


Hi, Andrew,

Could you please pick up these patches for testing. Kamezawa-San, I am
assuming that you are OK with these patches going to -mm for testing?

Would you like me to resend the patches?

Balbir 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
