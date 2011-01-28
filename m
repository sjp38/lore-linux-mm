Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8D7F98D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 03:43:00 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5578E3EE0C0
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:42:58 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CB5145DE5C
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:42:58 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B43F45DE59
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:42:58 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E6211DB804B
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:42:58 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BA6221DB8047
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:42:57 +0900 (JST)
Date: Fri, 28 Jan 2011 17:36:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH 1/4] memcg: fix limit estimation at reclaim for
 hugepage
Message-Id: <20110128173655.7c1d9ebd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTinikUM09bXbLZ5zU1gdgfdPZSQmbycbbeSyGk59@mail.gmail.com>
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128122449.e4bb0e5f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128134019.27abcfe2.nishimura@mxp.nes.nec.co.jp>
	<20110128135839.d53422e8.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikCjKCtjhRH-ZVsEQN-Luz==8g8e60uxhCTeD2w@mail.gmail.com>
	<20110128081723.GD2213@cmpxchg.org>
	<AANLkTinikUM09bXbLZ5zU1gdgfdPZSQmbycbbeSyGk59@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 28 Jan 2011 17:25:58 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Hi Hannes,
> 
> On Fri, Jan 28, 2011 at 5:17 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Fri, Jan 28, 2011 at 05:04:16PM +0900, Minchan Kim wrote:
> >> Hi Kame,
> >>
> >> On Fri, Jan 28, 2011 at 1:58 PM, KAMEZAWA Hiroyuki
> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> > How about this ?
> >> > ==
> >> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> >
> >> > Current memory cgroup's code tends to assume page_size == PAGE_SIZE
> >> > and arrangement for THP is not enough yet.
> >> >
> >> > This is one of fixes for supporing THP. This adds
> >> > mem_cgroup_check_margin() and checks whether there are required amount of
> >> > free resource after memory reclaim. By this, THP page allocation
> >> > can know whether it really succeeded or not and avoid infinite-loop
> >> > and hangup.
> >> >
> >> > Total fixes for do_charge()/reclaim memory will follow this patch.
> >>
> >> If this patch is only related to THP, I think patch order isn't good.
> >> Before applying [2/4], huge page allocation will retry without
> >> reclaiming and loop forever by below part.
> >>
> >> @@ -1854,9 +1858,6 @@ static int __mem_cgroup_do_charge(struct
> >> A  A  A  } else
> >> A  A  A  A  A  A  A  mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
> >>
> >> - A  A  if (csize > PAGE_SIZE) /* change csize and retry */
> >> - A  A  A  A  A  A  return CHARGE_RETRY;
> >> -
> >> A  A  A  if (!(gfp_mask & __GFP_WAIT))
> >> A  A  A  A  A  A  A  return CHARGE_WOULDBLOCK;
> >>
> >> Am I missing something?
> >
> > No, you are correct. A But I am not sure the order really matters in
> > theory: you have two endless loops that need independent fixing.
> 
> That's why I ask a question.
> Two endless loop?
> 
> One is what I mentioned. The other is what?
> Maybe this patch solve the other.
> But I can't guess it by only this description. Stupid..
> 
> Please open my eyes.
> 

One is.

  if (csize > PAGE_SIZE)
	return CHARGE_RETRY;

By this, reclaim will never be called.


Another is a check after memory reclaim.
==
       ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
                                        gfp_mask, flags);
        /*
         * try_to_free_mem_cgroup_pages() might not give us a full
         * picture of reclaim. Some pages are reclaimed and might be
         * moved to swap cache or just unmapped from the cgroup.
         * Check the limit again to see if the reclaim reduced the
         * current usage of the cgroup before giving up
         */
        if (ret || mem_cgroup_check_under_limit(mem_over_limit))
                return CHARGE_RETRY;
==

ret != 0 if one page is reclaimed. Then, khupaged will retry charge and 
cannot get enough room, reclaim, one page -> again. SO, in busy memcg,
HPAGE_SIZE allocation never fails.

Even if khupaged luckly allocates HPAGE_SIZE, because khugepaged walks vmas
one by one and try to collapse each pmd, under mmap_sem(), this seems a hang by
khugepaged, infinite loop.


Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
