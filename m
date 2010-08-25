Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B59AC6B01F1
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 21:43:47 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7P1lcFX001181
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 25 Aug 2010 10:47:39 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B3F7645DE70
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 10:47:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7094945DE4D
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 10:47:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 43400E38002
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 10:47:38 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EA5EC1DB8037
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 10:47:37 +0900 (JST)
Date: Wed, 25 Aug 2010 10:42:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] cgroup: ID notification call back
Message-Id: <20100825104240.7dbaba6a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTikuJ9x1u+GC_ox448Fp9wdJ2_GJyu6kNwjOJ9Y=@mail.gmail.com>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820185816.1dbcd53a.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=imK6Px+JrdVupg2V3jtN9pgmEdWv=+aB1XKLY@mail.gmail.com>
	<20100825092010.cfe91b1a.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikD3CFRPo7WvWwCnLQ+jzEs6rUk1sivYM3aRbGJ@mail.gmail.com>
	<20100825093747.24085b28.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=KW_gxbmB14j5opSKL+-JFDFKO1YP6a7yvT8U5@mail.gmail.com>
	<20100825100310.ba3fd27e.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikuJ9x1u+GC_ox448Fp9wdJ2_GJyu6kNwjOJ9Y=@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Aug 2010 18:35:00 -0700
Paul Menage <menage@google.com> wrote:

> On Tue, Aug 24, 2010 at 6:03 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > Hmm. How this pseudo code looks like ? This passes "new id" via
> > cgroup->subsys[array] at creation. (Using union will be better, maybe).
> >
> 
> That's rather ugly. I was thinking of something more like this. (Not
> even compiled yet, and the only subsystem updated is cpuset).
> 

Hmm, but placing css and subsystem's its own structure in different cache line
can increase cacheline/TLB miss, I think.

I wonder I should stop this patch series and do small thing.
I prefer to call alloc_css_id() by ->create() call by subsys's its own decistion
is much better and cleaner. (as my original design)

mem_cgroup_create()
{

	cgroup_attach_css_id(ss, cgrp, &mem->css);
}

And then, there will be no difficulty.

Do we have to call alloc_css_id() in kernel/cgroup.c ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
