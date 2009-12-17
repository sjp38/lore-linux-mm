Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CCA3E6B0062
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 02:03:40 -0500 (EST)
Date: Thu, 17 Dec 2009 16:00:09 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 0/8] memcg: move charge at task migration
 (14/Dec)
Message-Id: <20091217160009.57eb946f.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091215131421.00b87ad1.nishimura@mxp.nes.nec.co.jp>
References: <20091214151748.bf9c4978.nishimura@mxp.nes.nec.co.jp>
	<20091215033000.GD6036@balbir.in.ibm.com>
	<20091215131421.00b87ad1.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Dec 2009 13:14:21 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> On Tue, 15 Dec 2009 09:00:00 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-12-14 15:17:48]:
> > 
> > > Hi.
> > > 
> > > These are current patches of my move-charge-at-task-migration feature.
> > > 
> > > * They have not been mature enough to be merged into linus tree yet. *
> > > 
> > > Actually, there is a NULL pointer dereference BUG, which I found in my stress
> > > test after about 40 hours running and I'm digging now.
> > > I post these patches just to share my current status.
> > >
> > Could this be because of the css_get() and css_put() changes from the
> > previous release?
> > 
> I suspect so. Perhaps, [5/8] or [8/8] might be the guilt.
> 
> I'm now running test without [8/8]. It has survived for 24h so far, but
> I must run for more time to verify it's all right or not.
> I'm also looking closely into my patches again.
> 
I think I get the cause of this bug.

In [8/8], I postponed calling mem_cgroup_get() till the end of task migration
(i.e. I called __mem_cgroup_get() in mem_cgroup_clear_mc()).
But if a process which has been moved to a new group does swap-in, it calls
mem_cgroup_put() against the new mem_cgroup. This means the mem_cgroup->refcnt
of the new group might be decreased to 0, so that the mem_cgroup can be freed
(__mem_cgroup_free() is called) unexpectedly.

I'll fix this by not postponing mem_cgroup_get(postponing mem_cgroup_put() would be
all right), and test it during this weekend.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
