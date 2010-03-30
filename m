Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 83D1F6B01FA
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 01:38:37 -0400 (EDT)
Date: Tue, 30 Mar 2010 14:30:38 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH(v2) -mmotm 2/2] memcg move charge of shmem at task
 migration
Message-Id: <20100330143038.422459da.nishimura@mxp.nes.nec.co.jp>
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
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Mar 2010 10:30:50 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-30 13:51:59]:
> 
> > On Tue, 30 Mar 2010 13:06:48 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > On Tue, 30 Mar 2010 12:11:19 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > On Tue, 30 Mar 2010 11:49:03 +0900
> > > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > 
> > > > > On Tue, 30 Mar 2010 11:23:01 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > > > SHARED mapped file cache is not moved by patch [1/2] ???
> > > > > > It sounds strange.
> > > > > > 
> > > > > hmm, I'm sorry I'm not so good at user applications, but is it usual to use
> > > > > VM_SHARED file caches(!tmpfs) ?
> > > > > And is it better for us to move them only when page_mapcount() == 1 ?
> > > > > 
> > > > 
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
Thank you for your information.

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
Right.

> > I think following is straightforward and simple.
> > 
> >  - If page is an anon or swap of anon, it's not moved if referer > 2. 
> 
> What is referer in this context? The cgroup refering to the page?
> 
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
I agree it would be more simple. I selected the current policy because
I was not sure whether we should move file caches(!tmpfs) with mapcount > 1,
and, IMHO, shared memory and file caches are different for users.
But it's O.K. for me to change current policy.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
