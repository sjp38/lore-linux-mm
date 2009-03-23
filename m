Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EFD1B6B0083
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 22:43:40 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N3e8im008745
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 23 Mar 2009 12:40:09 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BF75A45DD7D
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 12:40:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C08E45DD7E
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 12:40:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 47F1EE08008
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 12:40:08 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 00180E08003
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 12:40:08 +0900 (JST)
Date: Mon, 23 Mar 2009 12:38:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/5] Memory controller soft limit organize cgroups (v7)
Message-Id: <20090323123841.caa91874.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090323033404.GG24227@balbir.in.ibm.com>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
	<20090319165735.27274.96091.sendpatchset@localhost.localdomain>
	<20090320124639.83d22726.kamezawa.hiroyu@jp.fujitsu.com>
	<20090322142105.GA24227@balbir.in.ibm.com>
	<20090323085314.7cce6c50.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323033404.GG24227@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Mar 2009 09:04:04 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-23 08:53:14]:
> 
> > On Sun, 22 Mar 2009 19:51:05 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > >         if (mem_cgroup_soft_limit_check(mem, &soft_fail_res)) {
> > > > 		mem_over_soft_limit =
> > > > 			mem_cgroup_from_res_counter(soft_fail_res, res);
> > > > 		mem_cgroup_update_tree(mem_over_soft_limit);
> > > > 	}
> > > > 
> > > > Then, we really do softlimit check once in interval.
> > > 
> > > OK, so the trade-off is - every once per interval,
> > > I need to walk up res_counters all over again, hold all locks and
> > > check. Like I mentioned earlier, with the current approach I've
> > > reduced the overhead significantly for non-users. Earlier I was seeing
> > > a small loss in output with reaim, but since I changed
> > > res_counter_uncharge to track soft limits, that difference is negligible
> > > now.
> > > 
> > > The issue I see with this approach is that if soft-limits were
> > > not enabled, even then we would need to walk up the hierarchy and do
> > > tests, where as embedding it in res_counter_charge, one simple check
> > > tells us we don't have more to do.
> > > 
> > Not at all.
> > 
> > just check softlimit is enabled or not in mem_cgroup_soft_limit_check() by some flag.
> >
> 
> So far, we don't use flags, the default soft limit is LONGLONG_MAX, if
> hierarchy is enabled, we need to check all the way up. The only way we
> check over limit is via a comparison. Are you suggesting we cache the
> value or save a special flag whenever the soft limit is set to
> anything other than LONGLONG_MAX? It is an indication that we are
> using soft limits, but we still need to see if we exceed it.
> 

Hmm ok, then, what we have to do here is
"children's softlimit should not be greater than parent's".
or
"if no softlimit, make last_tree_update to be enough big (jiffies + 1year)"
This will reduce the check.

> Why are we trying to over optimize this path? Like I mentioned
> earlier, the degradation is down to the order of noise. Knuth,
> re-learnt several times that "premature optimization is the root of
> all evil". If we find an issue with performance, we can definitely go
> down the road you are suggesting.
>  

I just don't like "check always even if unnecessary"

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
