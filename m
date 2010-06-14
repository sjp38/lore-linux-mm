Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D34306B01B2
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 03:36:53 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5E7OArD020849
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 03:24:10 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5E7anEK1663088
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 03:36:49 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5E7an1G019237
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 03:36:49 -0400
Date: Mon, 14 Jun 2010 13:06:46 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 1/2] Linux/Guest unmapped page cache control
Message-ID: <20100614073646.GS5191@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>
 <20100608155146.3749.67837.sendpatchset@L34Z31A.ibm.com>
 <20100613183145.GM5191@balbir.in.ibm.com>
 <20100614092819.cb7515a5.kamezawa.hiroyu@jp.fujitsu.com>
 <20100614064955.GR5191@balbir.in.ibm.com>
 <20100614160021.7febbdb2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100614160021.7febbdb2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kvm <kvm@vger.kernel.org>, Avi Kivity <avi@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-06-14 16:00:21]:

> On Mon, 14 Jun 2010 12:19:55 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > - Why don't you believe LRU ? And if LRU doesn't work well, should it be
> > >   fixed by a knob rather than generic approach ?
> > > - No side effects ?
> > 
> > I believe in LRU, just that the problem I am trying to solve is of
> > using double the memory for caching the same data (consider kvm
> > running in cache=writethrough or writeback mode, both the hypervisor
> > and the guest OS maintain a page cache of the same data). As the VM's
> > grow the overhead is substantial. In my runs I found upto 60%
> > duplication in some cases.
> > 
> > 
> > - Linux vm guys tend to say, "free memory is bad memory". ok, for what
> >   free memory created by your patch is used ? IOW, I can't see the benefit.
> >   If free memory that your patch created will be used for another page-cache,
> >   it will be dropped soon by your patch itself.
> > 
> > Free memory is good for cases when you want to do more in the same
> > system. I agree that in a bare metail environment that might be
> > partially true. I don't have a problem with frequently used data being
> > cached, but I am targetting a consolidated environment at the moment.
> > Moreover, the administrator has control via a boot option, so it is
> > non-instrusive in many ways.
> 
> It sounds that what you want is to improve performance etc. but to make it
> easy sizing the system and to help admins. Right ?
>

Right, to allow freeing up of using double the memory to cache data.
 
> From performance perspective, I don't see any advantage to drop caches
> which can be dropped easily. I just use cpus for the purpose it may no
> be necessary.
> 

It is not that easy, in a virtualized environment, you do directly
reclaim, but use a mechanism like ballooning and that too requires a
smart software to decide where to balloon from. This patch (optionally
if enabled) optimizes that by

1. Reducing double caching
2. Not requiring newer smarts or a management software to monitor and
balloon
3. Allows better estimation of free memory by avoiding double caching
4. Allows immediate use of free memory for other applications or
startup of newer guest instances.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
