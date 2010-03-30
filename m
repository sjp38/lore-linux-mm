Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DA4A16B0207
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 01:01:04 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id o2U4Ei6e014599
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 09:44:44 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2U50r1L2494476
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 10:30:53 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2U50r2K030521
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 16:00:53 +1100
Date: Tue, 30 Mar 2010 10:30:50 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH(v2) -mmotm 2/2] memcg move charge of shmem at task
 migration
Message-ID: <20100330050050.GA3308@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100329120243.af6bfeac.nishimura@mxp.nes.nec.co.jp>
 <20100329120359.1c6a277d.nishimura@mxp.nes.nec.co.jp>
 <20100329133645.e3bde19f.kamezawa.hiroyu@jp.fujitsu.com>
 <20100330103301.b0d20f7e.nishimura@mxp.nes.nec.co.jp>
 <20100330112301.f5bb49d7.kamezawa.hiroyu@jp.fujitsu.com>
 <20100330114903.476af77e.nishimura@mxp.nes.nec.co.jp>
 <20100330121119.fcc7d45b.kamezawa.hiroyu@jp.fujitsu.com>
 <20100330130648.ad559645.nishimura@mxp.nes.nec.co.jp>
 <20100330135159.025b9366.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100330135159.025b9366.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-30 13:51:59]:

> On Tue, 30 Mar 2010 13:06:48 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Tue, 30 Mar 2010 12:11:19 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Tue, 30 Mar 2010 11:49:03 +0900
> > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > 
> > > > On Tue, 30 Mar 2010 11:23:01 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > > SHARED mapped file cache is not moved by patch [1/2] ???
> > > > > It sounds strange.
> > > > > 
> > > > hmm, I'm sorry I'm not so good at user applications, but is it usual to use
> > > > VM_SHARED file caches(!tmpfs) ?
> > > > And is it better for us to move them only when page_mapcount() == 1 ?
> > > > 
> > > 
> > > Considering shared library which has only one user, moving MAP_SHARED makes sense.
> > > Unfortunately, there are people who creates their own shared library just for
> > > their private dlopen() etc. (shared library for private use...)
> > > 
> > > So, I think moving MAP_SHARED files makes sense.
> > > 

IIRC, the libraries are loaded with MAP_PRIVATE and MAP_SHARED is not
set.

> > Thank you for your explanations.
> > I'll update my patches to allow to move MAP_SHARED(but page_mapcount() == 1)
> > file caches, and resend.
> > 
> 
> Hmm, considering again...current summary is following...right ?
> 
>  - If page is an anon, it's not moved if page_mapcount() > 2.
>  - If page is a page cache, it's not moved if page_mapcount() > 2.
>  - If page is a shmem, it's not moved regardless of mapcount.
>  - If pte is swap, it's not moved refcnt > 2.
> 
> I think following is straightforward and simple.
> 
>  - If page is an anon or swap of anon, it's not moved if referer > 2. 

What is referer in this context? The cgroup refering to the page?

>    (i.e. inherited from it's parent)
>  - If page is file,shmem or swap of shmem, it's moved regardless of referer.
>    But pages only under "from" memcg can be moved.
> 
> I doubt adding too much speciality to shmem is not good.
>

Yep, I tend to agree, but I need to take a closer look again at the
patches. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
