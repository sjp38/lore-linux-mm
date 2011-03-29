Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 136448D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:45:51 -0400 (EDT)
Date: Tue, 29 Mar 2011 15:45:47 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [trivial PATCH] Remove pointless next_mz nullification in
 mem_cgroup_soft_limit_reclaim
Message-ID: <20110329134547.GC3361@tiehlicka.suse.cz>
References: <20110329132800.GA3361@tiehlicka.suse.cz>
 <AANLkTikYepYY01P+MELCpT+nFiPor3+-Oo=kyr2FE03C@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTikYepYY01P+MELCpT+nFiPor3+-Oo=kyr2FE03C@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue 29-03-11 21:40:13, Zhu Yanhai wrote:
> Michal,
> IIUC it's to prevent the infinite loop, as in the end of the do-while
> there's
> if (!nr_reclaimed &&
>     (next_mz == NULL ||
>     loop > MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS))
> 		break;

> so the loop will break earlier if all groups are iterated once and no
> pages are freed.

The code (in mmotm 2011-03-10-16-42) reads:
			do {
				[skipped comments]
                                next_mz =
                                __mem_cgroup_largest_soft_limit_node(mctz);
                                if (next_mz == mz) {
                                        css_put(&next_mz->mem->css);
					next_mz = NULL;
                                } else /* next_mz == NULL or other memcg */
                                        break;
                        } while (1);

So we do not break out of the loop and start a new iteration if next_mz == mz
and assign next_mz again.
Am I missing something?
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
