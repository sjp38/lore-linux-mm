Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 079E86B0062
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 02:31:03 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBH7V0NR014056
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 17 Dec 2009 16:31:01 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A63E445DE51
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 16:31:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7610145DE55
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 16:31:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E1AB1DB8041
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 16:31:00 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F24421DB8038
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 16:30:59 +0900 (JST)
Date: Thu, 17 Dec 2009 16:27:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 0/8] memcg: move charge at task migration
 (14/Dec)
Message-Id: <20091217162744.e09a271a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091217160009.57eb946f.nishimura@mxp.nes.nec.co.jp>
References: <20091214151748.bf9c4978.nishimura@mxp.nes.nec.co.jp>
	<20091215033000.GD6036@balbir.in.ibm.com>
	<20091215131421.00b87ad1.nishimura@mxp.nes.nec.co.jp>
	<20091217160009.57eb946f.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: balbir@linux.vnet.ibm.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Dec 2009 16:00:09 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Tue, 15 Dec 2009 13:14:21 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > On Tue, 15 Dec 2009 09:00:00 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-12-14 15:17:48]:
> > > 
> > > > Hi.
> > > > 
> > > > These are current patches of my move-charge-at-task-migration feature.
> > > > 
> > > > * They have not been mature enough to be merged into linus tree yet. *
> > > > 
> > > > Actually, there is a NULL pointer dereference BUG, which I found in my stress
> > > > test after about 40 hours running and I'm digging now.
> > > > I post these patches just to share my current status.
> > > >
> > > Could this be because of the css_get() and css_put() changes from the
> > > previous release?
> > > 
> > I suspect so. Perhaps, [5/8] or [8/8] might be the guilt.
> > 
> > I'm now running test without [8/8]. It has survived for 24h so far, but
> > I must run for more time to verify it's all right or not.
> > I'm also looking closely into my patches again.
> > 
> I think I get the cause of this bug.
> 
> In [8/8], I postponed calling mem_cgroup_get() till the end of task migration
> (i.e. I called __mem_cgroup_get() in mem_cgroup_clear_mc()).
> But if a process which has been moved to a new group does swap-in, it calls
> mem_cgroup_put() against the new mem_cgroup. This means the mem_cgroup->refcnt
> of the new group might be decreased to 0, so that the mem_cgroup can be freed
> (__mem_cgroup_free() is called) unexpectedly.
> 
> I'll fix this by not postponing mem_cgroup_get(postponing mem_cgroup_put() would be
> all right), and test it during this weekend.
> 
> 
Great!. Thank you for your efforts. 

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
