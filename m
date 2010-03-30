Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7335F6B01FA
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 01:13:29 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2U5DQ3M003528
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 30 Mar 2010 14:13:26 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E751845DE5A
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 14:13:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B7E9445DE52
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 14:13:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8EAA3E08002
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 14:13:25 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 32CBA1DB8038
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 14:13:25 +0900 (JST)
Date: Tue, 30 Mar 2010 14:09:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH(v2) -mmotm 2/2] memcg move charge of shmem at task
 migration
Message-Id: <20100330140942.cfbf2f6c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100330050050.GA3308@balbir.in.ibm.com>
References: <20100329120243.af6bfeac.nishimura@mxp.nes.nec.co.jp>
	<20100329120359.1c6a277d.nishimura@mxp.nes.nec.co.jp>
	<20100329133645.e3bde19f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330103301.b0d20f7e.nishimura@mxp.nes.nec.co.jp>
	<20100330112301.f5bb49d7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330114903.476af77e.nishimura@mxp.nes.nec.co.jp>
	<20100330121119.fcc7d45b.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330130648.ad559645.nishimura@mxp.nes.nec.co.jp>
	<20100330135159.025b9366.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330050050.GA3308@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Mar 2010 10:30:50 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-30 13:51:59]:
> > > > Considering shared library which has only one user, moving MAP_SHARED makes sense.
> > > > Unfortunately, there are people who creates their own shared library just for
> > > > their private dlopen() etc. (shared library for private use...)
> > > > 
> > > > So, I think moving MAP_SHARED files makes sense.
> > > > 
> 
> IIRC, the libraries are loaded with MAP_PRIVATE and MAP_SHARED is not
> set.
> 
Ah, yes. I was wrong.
But changing handling of MAP_SHARED/MAP_PRIVATE is not good.
It will give much confusion to users.


> > > Thank you for your explanations.
> > > I'll update my patches to allow to move MAP_SHARED(but page_mapcount() == 1)
> > > file caches, and resend.
> > > 
> > 
> > Hmm, considering again...current summary is following...right ?
> > 
> >  - If page is an anon, it's not moved if page_mapcount() > 2.
> >  - If page is a page cache, it's not moved if page_mapcount() > 2.
> >  - If page is a shmem, it's not moved regardless of mapcount.
> >  - If pte is swap, it's not moved refcnt > 2.
> > 
> > I think following is straightforward and simple.
> > 
> >  - If page is an anon or swap of anon, it's not moved if referer > 2. 
> 
> What is referer in this context? The cgroup refering to the page?
> 
page_mapcount(page) + refcnt_to_swap_entry(ent.val)

Bye.
-Kame
> >    (i.e. inherited from it's parent)
> >  - If page is file,shmem or swap of shmem, it's moved regardless of referer.
> >    But pages only under "from" memcg can be moved.
> > 
> > I doubt adding too much speciality to shmem is not good.
> >
> 
> Yep, I tend to agree, but I need to take a closer look again at the
> patches. 
> 
> -- 
> 	Three Cheers,
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
