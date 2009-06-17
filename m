Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E99BF6B004F
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 05:23:38 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5H9DesG012817
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 05:13:40 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5H9OKVA252220
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 05:24:20 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5H9OK1Y022960
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 05:24:20 -0400
Date: Wed, 17 Jun 2009 14:54:14 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][BUGFIX] memcg: rmdir doesn't return
Message-ID: <20090617092414.GI7646@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090616140050.4172f988.kamezawa.hiroyu@jp.fujitsu.com> <20090616153810.fd710c5b.nishimura@mxp.nes.nec.co.jp> <20090616154820.c9065809.kamezawa.hiroyu@jp.fujitsu.com> <20090616174436.5a4b6577.kamezawa.hiroyu@jp.fujitsu.com> <20090617045643.GE7646@balbir.in.ibm.com> <20090617141109.8d9a47ea.kamezawa.hiroyu@jp.fujitsu.com> <20090617054955.GF7646@balbir.in.ibm.com> <20090617152748.6b6c643e.kamezawa.hiroyu@jp.fujitsu.com> <20090617073521.GG7646@balbir.in.ibm.com> <20090617180555.98f88d09.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090617180555.98f88d09.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-06-17 18:05:55]:

> On Wed, 17 Jun 2009 13:05:21 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-06-17 15:27:48]:
> 
> > > And even if release_agent() is called, it will do rmdir and see -EBUSY.
> > 
> > Because of hierarchy? But we need to cleanup hierarchy before rmdir()
> > no?
> > 
> 
> Assume following (I think my patch in git explains this.)
> 
> /cgroup/A/01
> 	 /02
> 	 /03
> 	 /04
> A and 01,02,03,04 is under hierarchy.
> 
> Now, 04 has no task and it can be removed by rmdir.
> Case 1) 01,02,03 hits memory limit heavily and hirerchical memory recalim
> walks. In this case, 04's css refcnt is got/put very often.
> Case 2) read statistics of cgroup/A very frequently, this means
> css_put/get is called very often agatinst 04.
> 
> Case 3)....
> 
> 04's refcnt is put/get when other group under hierarchy is busy and
> rmdir against 04 returns -EBUSY in some amount of possiblitly.
>

Yes, agreed! We did design hierarchy that way. Thanks for the detailed
explanation!
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
