Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1BC776B003D
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 01:29:13 -0500 (EST)
Date: Thu, 3 Dec 2009 15:00:33 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 4/5] memcg: avoid oom during recharge at task
 move
Message-Id: <20091203150033.18dd293f.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091203142243.5222d7bb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091119132734.1757fc42.nishimura@mxp.nes.nec.co.jp>
	<20091119133030.8ef46be0.nishimura@mxp.nes.nec.co.jp>
	<20091123051041.GQ31961@balbir.in.ibm.com>
	<20091124114358.80e0cafe.nishimura@mxp.nes.nec.co.jp>
	<20091127135810.ef5fee0b.nishimura@mxp.nes.nec.co.jp>
	<20091203135805.23a8b0f7.nishimura@mxp.nes.nec.co.jp>
	<20091203142243.5222d7bb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Dec 2009 14:22:43 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 3 Dec 2009 13:58:05 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > I'm now trying to decrease these overhead as much as possible, and the current
> > status is bellow.
> > 
> thanks.
> 
> > (support for moving swap charge has not been pushed yet in my tree, so I tested
> > only (1) and (2) cases.)
> > 
> >        |  252M  |  512M  |   1G
> >   -----+--------+--------+--------
> >    (1) |  0.20  |  0.40  |  0.81
> >   -----+--------+--------+--------
> >    (2) |  0.20  |  0.40  |  0.81
> > 
> What is the unit of each numbers ? seconds ? And migration of a process with 1G bytes
> requires 0.8sec ? But, hmm, speed up twice! sounds nice.
> 
Ah, these numbers mean "seconds".
I agree they are big yet...

> 
> > What I've done are are:
> > - Instead of calling res_counter_uncharge() against the old cgroup in __mem_cgroup_move_account()
> >   evrytime, call res_counter_uncharge(PAGE_SIZE * moved) at the end of task migration once.
> sounds reasonable.
> 
> > - Instead of calling try_charge repeatedly, call res_counter_charge(PAGE_SIZE * necessary)
> >   in can_attach() if possible.
> sounds reasonable, too.
> 
> > - Not only res_counter_charge/uncharge, consolidate css_get()/put() too.
> > 
> please do. But, hmm, I'd like to remove css_put/get per pages ;) But I put it aside now.
> 
I do agree with you, but removing them would be a big change..
This change reduced about 0.2sec in 1GB case, so it's a workaround for now.


Thanks,
Daisuke Nishimura.

> > 
> > BTW, KAMEZAWA-san, are you planning to add mm_counter for swap yet ?
> yes. please see my newest patch ;) extreme one.http://marc.info/?l=linux-mm&m=125980393923228&w=2
> 
> > To tell the truth, instead of making use of mm_counter, I want to parse the page table
> > in can_attach as I did before, because:
> > - parsing the page table in can_attach seems not to add so big overheads(see below).
> ok.
> 
> > - if we add support for file-cache and shmem in future, I think we need to parse the page table
> >   anyway, because there is no independent mm_counter for shmem. I want to treat them
> >   independently because users don't consider shmem as file-cahce, IMHO.
> > 
> ok. about scanning page tables. 
> Moving 1G means moving 262144, scanning 128 page tables. Maybe not very big cost.
> 
> I still doubt moving "shared" pages "silently" is useful but it's another topic, here.
> 
> > (parsing the page table in can_attach)
> >        |  252M  |  512M  |   1G
> >   -----+--------+--------+--------
> >    (1) |  0.21  |  0.41  |  0.83
> >   -----+--------+--------+--------
> >    (2) |  0.21  |  0.41  |  0.83
> > 
> > Hopefully, I want to post a new version in this week.
> > 
> 
> Thank you for your efforts.
> 
> Thanks,
> -Kame
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
