Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C073A6B005A
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 06:51:17 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp08.au.ibm.com (8.14.3/8.13.1) with ESMTP id n8TB6EjI019602
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 21:06:14 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8TBBimK1446042
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 21:11:44 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n8TBDvWU011827
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 21:13:57 +1000
Date: Tue, 29 Sep 2009 16:43:55 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] memcg: some modification to softlimit under
 hierarchical memory reclaim.
Message-ID: <20090929111354.GC498@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090929150141.0e672290.kamezawa.hiroyu@jp.fujitsu.com>
 <20090929061132.GA498@balbir.in.ibm.com>
 <20090929183321.3d4fbc1d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090929183321.3d4fbc1d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-09-29 18:33:21]:

> On Tue, 29 Sep 2009 11:41:32 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-09-29 15:01:41]:
> > 
> > > No major changes in this patch for 3 weeks.
> > > While testing, I found a few css->refcnt bug in softlimit.(and posted patches)
> > > But it seems no more (easy) ones.
> > >
> > 
> > Kamezawa-San, this worries me, could you please confirm if you are
> > able to see this behaviour without your patches applied as well? I am
> > doing some more stress tests on my side.
> >  
> I found an easy way to reprocue. And yes, it can happen without this series.
> 
> ==
> #!/bin/bash -x
> 
> mount -tcgroup none /cgroups -omemory
> mkdir /cgroups/A
> 
> while true;do
>         mkdir /cgroups/A/01
>         echo 3M > /cgroups/A/01/memory.soft_limit_in_bytes
>         echo $$ > /cgroups/A/01/tasks
>         dd if=/dev/zero of=./tmpfile bs=4096 count=1024
>         rm ./tmpfile
>         sync
>         sleep 1
>         echo $$ > /cgroups/A/tasks
>         rmdir /cgroups/A/01
> done
> ==
> Run this scipt under memory pressure.
> Then folloiwng happens. refcnt goes bad. (WARN_ON is my css_refcnt patch's one)
>

Excellent script, i was able to reproduce the problem with the WARN_ON
patch applied. I am going to try the fix now.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
