Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DB4116B0207
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 00:56:07 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2U4u4L8011746
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 30 Mar 2010 13:56:04 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A74CC45DE55
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 13:56:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8351B45DE4E
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 13:56:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5866BE38002
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 13:56:03 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EDE851DB804C
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 13:56:02 +0900 (JST)
Date: Tue, 30 Mar 2010 13:51:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH(v2) -mmotm 2/2] memcg move charge of shmem at task
 migration
Message-Id: <20100330135159.025b9366.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100330130648.ad559645.nishimura@mxp.nes.nec.co.jp>
References: <20100329120243.af6bfeac.nishimura@mxp.nes.nec.co.jp>
	<20100329120359.1c6a277d.nishimura@mxp.nes.nec.co.jp>
	<20100329133645.e3bde19f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330103301.b0d20f7e.nishimura@mxp.nes.nec.co.jp>
	<20100330112301.f5bb49d7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330114903.476af77e.nishimura@mxp.nes.nec.co.jp>
	<20100330121119.fcc7d45b.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330130648.ad559645.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Mar 2010 13:06:48 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Tue, 30 Mar 2010 12:11:19 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 30 Mar 2010 11:49:03 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > On Tue, 30 Mar 2010 11:23:01 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > SHARED mapped file cache is not moved by patch [1/2] ???
> > > > It sounds strange.
> > > > 
> > > hmm, I'm sorry I'm not so good at user applications, but is it usual to use
> > > VM_SHARED file caches(!tmpfs) ?
> > > And is it better for us to move them only when page_mapcount() == 1 ?
> > > 
> > 
> > Considering shared library which has only one user, moving MAP_SHARED makes sense.
> > Unfortunately, there are people who creates their own shared library just for
> > their private dlopen() etc. (shared library for private use...)
> > 
> > So, I think moving MAP_SHARED files makes sense.
> > 
> Thank you for your explanations.
> I'll update my patches to allow to move MAP_SHARED(but page_mapcount() == 1)
> file caches, and resend.
> 

Hmm, considering again...current summary is following...right ?

 - If page is an anon, it's not moved if page_mapcount() > 2.
 - If page is a page cache, it's not moved if page_mapcount() > 2.
 - If page is a shmem, it's not moved regardless of mapcount.
 - If pte is swap, it's not moved refcnt > 2.

I think following is straightforward and simple.

 - If page is an anon or swap of anon, it's not moved if referer > 2. 
   (i.e. inherited from it's parent)
 - If page is file,shmem or swap of shmem, it's moved regardless of referer.
   But pages only under "from" memcg can be moved.

I doubt adding too much speciality to shmem is not good.


How do you think ?

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
