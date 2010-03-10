Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 572246B00B4
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 22:56:38 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp09.au.ibm.com (8.14.3/8.13.1) with ESMTP id o2A3uQq4027766
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 14:56:26 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2A3oebh1560596
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 14:50:40 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2A3uPjb016483
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 14:56:26 +1100
Date: Wed, 10 Mar 2010 09:26:24 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH mmotm 2.5/4] memcg: disable irq at page cgroup lock (Re:
 [PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
 infrastructure)
Message-ID: <20100310035624.GP3073@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100308105641.e2e714f4.kamezawa.hiroyu@jp.fujitsu.com>
 <20100308111724.3e48aee3.nishimura@mxp.nes.nec.co.jp>
 <20100308113711.d7a249da.kamezawa.hiroyu@jp.fujitsu.com>
 <20100308170711.4d8b02f0.nishimura@mxp.nes.nec.co.jp>
 <20100308173100.b5997fd4.kamezawa.hiroyu@jp.fujitsu.com>
 <20100309001252.GB13490@linux>
 <20100309091914.4b5f6661.kamezawa.hiroyu@jp.fujitsu.com>
 <20100309102928.9f36d2bb.nishimura@mxp.nes.nec.co.jp>
 <20100309045058.GX3073@balbir.in.ibm.com>
 <20100310104309.c5f9c9a9.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100310104309.c5f9c9a9.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, Andrea Righi <arighi@develer.com>, linux-kernel@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, Vivek Goyal <vgoyal@redhat.com>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2010-03-10 10:43:09]:

> > Please please measure the performance overhead of this change.
> > 
> 
> here.
> 
> > > > > > > I made a patch below and measured the time(average of 10 times) of kernel build
> > > > > > > on tmpfs(make -j8 on 8 CPU machine with 2.6.33 defconfig).
> > > > > > > 
> > > > > > > <before>
> > > > > > > - root cgroup: 190.47 sec
> > > > > > > - child cgroup: 192.81 sec
> > > > > > > 
> > > > > > > <after>
> > > > > > > - root cgroup: 191.06 sec
> > > > > > > - child cgroup: 193.06 sec
> > > > > > > 
> 
> <after2(local_irq_save/restore)>
> - root cgroup: 191.42 sec
> - child cgroup: 193.55 sec
> 
> hmm, I think it's in error range, but I can see a tendency by testing several times
> that it's getting slower as I add additional codes. Using local_irq_disable()/enable()
> except in mem_cgroup_update_file_mapped(it can be the only candidate to be called
> with irq disabled in future) might be the choice.
>

Error range would depend on things like standard deviation and
repetition. It might be good to keep update_file_mapped and see the
impact. My concern is with large systems, the difference might be
larger.
 
-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
