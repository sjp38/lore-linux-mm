Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CA6AA6B003D
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 00:08:43 -0500 (EST)
Date: Thu, 3 Dec 2009 13:58:05 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 4/5] memcg: avoid oom during recharge at task
 move
Message-Id: <20091203135805.23a8b0f7.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091127135810.ef5fee0b.nishimura@mxp.nes.nec.co.jp>
References: <20091119132734.1757fc42.nishimura@mxp.nes.nec.co.jp>
	<20091119133030.8ef46be0.nishimura@mxp.nes.nec.co.jp>
	<20091123051041.GQ31961@balbir.in.ibm.com>
	<20091124114358.80e0cafe.nishimura@mxp.nes.nec.co.jp>
	<20091127135810.ef5fee0b.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Nov 2009 13:58:10 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > Sorry, if I missed it, but I did not see any time overhead of moving a
> > > task after these changes. Could you please help me understand the cost
> > > of moving say a task with 1G anonymous memory to another group and
> > > the cost of moving a task with 512MB anonymous and 512 page cache
> > > mapped, etc. It would be nice to understand the overall cost.
> > > 
> > O.K.
> > I'll test programs with big anonymous pages and measure the time and report.
> > 
> I measured the elapsed time of "echo <pid> > <some path>/tasks" on KVM guest
> with 4CPU/4GB(Xeon/3GHz).
> 
> - used the attached simple program.
> - made 2 directories(00, 01) under root, and enabled recharge_at_immigrate in both.
> - measured the elapsed time by "time -p" for moving between:
> 
>   (1) root -> 00
>   (2) 00 -> 01
> 
>   we don't need to call res_counter_uncharge against root, so (1) would be smaller
>   than (2).
> 
>   (3) 00(setting mem.limit to half size of total) -> 01
> 
>   To compare the overhead of anon and swap.
> 
> Results:
> 
>        |  252M  |  512M  |   1G
>   -----+--------+--------+--------
>    (1) |  0.21  |  0.41  |  0.821
>   -----+--------+--------+--------
>    (2) |  0.43  |  0.85  |  1.71
>   -----+--------+--------+--------
>    (3) |  0.40  |  0.81  |  1.62
>   -----+--------+--------+--------
> 
I'm now trying to decrease these overhead as much as possible, and the current
status is bellow.

(support for moving swap charge has not been pushed yet in my tree, so I tested
only (1) and (2) cases.)

       |  252M  |  512M  |   1G
  -----+--------+--------+--------
   (1) |  0.20  |  0.40  |  0.81
  -----+--------+--------+--------
   (2) |  0.20  |  0.40  |  0.81

What I've done are are:
- Instead of calling res_counter_uncharge() against the old cgroup in __mem_cgroup_move_account()
  evrytime, call res_counter_uncharge(PAGE_SIZE * moved) at the end of task migration once.
- Instead of calling try_charge repeatedly, call res_counter_charge(PAGE_SIZE * necessary)
  in can_attach() if possible.
- Not only res_counter_charge/uncharge, consolidate css_get()/put() too.


BTW, KAMEZAWA-san, are you planning to add mm_counter for swap yet ?
To tell the truth, instead of making use of mm_counter, I want to parse the page table
in can_attach as I did before, because:
- parsing the page table in can_attach seems not to add so big overheads(see below).
- if we add support for file-cache and shmem in future, I think we need to parse the page table
  anyway, because there is no independent mm_counter for shmem. I want to treat them
  independently because users don't consider shmem as file-cahce, IMHO.

(parsing the page table in can_attach)
       |  252M  |  512M  |   1G
  -----+--------+--------+--------
   (1) |  0.21  |  0.41  |  0.83
  -----+--------+--------+--------
   (2) |  0.21  |  0.41  |  0.83

Hopefully, I want to post a new version in this week.


Regards,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
