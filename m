Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A36068D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 03:17:30 -0500 (EST)
Date: Fri, 28 Jan 2011 09:17:23 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [BUGFIX][PATCH 1/4] memcg: fix limit estimation at reclaim for
 hugepage
Message-ID: <20110128081723.GD2213@cmpxchg.org>
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
 <20110128122449.e4bb0e5f.kamezawa.hiroyu@jp.fujitsu.com>
 <20110128134019.27abcfe2.nishimura@mxp.nes.nec.co.jp>
 <20110128135839.d53422e8.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTikCjKCtjhRH-ZVsEQN-Luz==8g8e60uxhCTeD2w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTikCjKCtjhRH-ZVsEQN-Luz==8g8e60uxhCTeD2w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 28, 2011 at 05:04:16PM +0900, Minchan Kim wrote:
> Hi Kame,
> 
> On Fri, Jan 28, 2011 at 1:58 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > How about this ?
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > Current memory cgroup's code tends to assume page_size == PAGE_SIZE
> > and arrangement for THP is not enough yet.
> >
> > This is one of fixes for supporing THP. This adds
> > mem_cgroup_check_margin() and checks whether there are required amount of
> > free resource after memory reclaim. By this, THP page allocation
> > can know whether it really succeeded or not and avoid infinite-loop
> > and hangup.
> >
> > Total fixes for do_charge()/reclaim memory will follow this patch.
> 
> If this patch is only related to THP, I think patch order isn't good.
> Before applying [2/4], huge page allocation will retry without
> reclaiming and loop forever by below part.
> 
> @@ -1854,9 +1858,6 @@ static int __mem_cgroup_do_charge(struct
>  	} else
>  		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
> 
> -	if (csize > PAGE_SIZE) /* change csize and retry */
> -		return CHARGE_RETRY;
> -
>  	if (!(gfp_mask & __GFP_WAIT))
>  		return CHARGE_WOULDBLOCK;
> 
> Am I missing something?

No, you are correct.  But I am not sure the order really matters in
theory: you have two endless loops that need independent fixing.

This order, however, is probably more practical during bisection.
When you fix the hidden problem before you uncover this code by fixing
the other problem, at least during bisection you will only hit one of
the two bugs :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
