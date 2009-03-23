Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DA3046B007E
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 22:38:03 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp08.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2N3YK8I001872
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 14:34:20 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2N3YZ22413974
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 14:34:38 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2N3YHYM017947
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 14:34:18 +1100
Date: Mon, 23 Mar 2009 09:04:04 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/5] Memory controller soft limit organize cgroups (v7)
Message-ID: <20090323033404.GG24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain> <20090319165735.27274.96091.sendpatchset@localhost.localdomain> <20090320124639.83d22726.kamezawa.hiroyu@jp.fujitsu.com> <20090322142105.GA24227@balbir.in.ibm.com> <20090323085314.7cce6c50.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090323085314.7cce6c50.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-23 08:53:14]:

> On Sun, 22 Mar 2009 19:51:05 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > >         if (mem_cgroup_soft_limit_check(mem, &soft_fail_res)) {
> > > 		mem_over_soft_limit =
> > > 			mem_cgroup_from_res_counter(soft_fail_res, res);
> > > 		mem_cgroup_update_tree(mem_over_soft_limit);
> > > 	}
> > > 
> > > Then, we really do softlimit check once in interval.
> > 
> > OK, so the trade-off is - every once per interval,
> > I need to walk up res_counters all over again, hold all locks and
> > check. Like I mentioned earlier, with the current approach I've
> > reduced the overhead significantly for non-users. Earlier I was seeing
> > a small loss in output with reaim, but since I changed
> > res_counter_uncharge to track soft limits, that difference is negligible
> > now.
> > 
> > The issue I see with this approach is that if soft-limits were
> > not enabled, even then we would need to walk up the hierarchy and do
> > tests, where as embedding it in res_counter_charge, one simple check
> > tells us we don't have more to do.
> > 
> Not at all.
> 
> just check softlimit is enabled or not in mem_cgroup_soft_limit_check() by some flag.
>

So far, we don't use flags, the default soft limit is LONGLONG_MAX, if
hierarchy is enabled, we need to check all the way up. The only way we
check over limit is via a comparison. Are you suggesting we cache the
value or save a special flag whenever the soft limit is set to
anything other than LONGLONG_MAX? It is an indication that we are
using soft limits, but we still need to see if we exceed it.

Why are we trying to over optimize this path? Like I mentioned
earlier, the degradation is down to the order of noise. Knuth,
re-learnt several times that "premature optimization is the root of
all evil". If we find an issue with performance, we can definitely go
down the road you are suggesting.
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
