Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8B24E8D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 03:30:44 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F36B83EE0C1
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:30:39 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D914545DE4E
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:30:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BAC6345DE4D
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:30:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A9C141DB803A
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:30:39 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7112E1DB8038
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:30:39 +0900 (JST)
Date: Fri, 28 Jan 2011 17:24:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH 1/4] memcg: fix limit estimation at reclaim for
 hugepage
Message-Id: <20110128172438.6c49d4ea.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTikCjKCtjhRH-ZVsEQN-Luz==8g8e60uxhCTeD2w@mail.gmail.com>
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128122449.e4bb0e5f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128134019.27abcfe2.nishimura@mxp.nes.nec.co.jp>
	<20110128135839.d53422e8.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikCjKCtjhRH-ZVsEQN-Luz==8g8e60uxhCTeD2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 28 Jan 2011 17:04:16 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

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
> 

You're right. But
 - This patch oder doesn't affect bi-sect of the bug. because 
   2 bugs seems to be the same.
 - This patch implements a leaf function for the real fix.

Then, I think patch order is not problem here.

Thank you for pointing out.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
