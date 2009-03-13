Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 228866B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 03:17:30 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2D7HR3u008166
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 13 Mar 2009 16:17:27 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 841F945DD81
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:17:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C07745DD7F
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:17:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DE4FE08009
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:17:27 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B4336E08004
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:17:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention (v5)
In-Reply-To: <20090313070340.GI16897@balbir.in.ibm.com>
References: <20090313145032.AF4D.A69D9226@jp.fujitsu.com> <20090313070340.GI16897@balbir.in.ibm.com>
Message-Id: <20090313160632.683D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 13 Mar 2009 16:17:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > hm
> > I read past discussion. so, I think we discuss many aspect at once.
> > So, my current thinking is below, 
> > 
> > (1) if the group don't have any soft limit shrinking page, 
> >     mem_cgroup_soft_limit_reclaim() spent time unnecessary.
> >     -> right.
> 
> If the soft limit RB tree is empty, we don't spend any time at all.
> Are you referring to something else? Am I missing something? The tree
> will be empty if no group is over the soft limit.

maybe, I am missing anything.
May I ask your following paragraph meaning?


> I experimented a *lot* with zone reclaim and found it to be not so
> effective. Here is why
> 
> 1. We have no control over priority or how much to scan, that is
> controlled by balance_pgdat(). If we find that we are unable to scan
> anything, we continue scanning with the scan > 0 check, but we scan
> the same pages and the same number, because shrink_zone does scan >>
> priority.

I thought this sentense mean soft-limit-shrinking spent a lot of time.
if not, could you please tell me what makes so slower?

and, you wrote:

> 
> Yes, I sent that reason out as comments to Kame's patches. kswapd or
> balance_pgdat controls the zones, priority and in effect how many
> pages we scan while doing reclaim. I did lots of experiments and found
> that if soft limit reclaim occurred from kswapd, soft_limit_reclaim
> would almost always fail and shrink_zone() would succeed, since it
> looks at the whole zone and is always able to find some pages at all
> priority levels. It also does not allow for targetted reclaim based on
> how much we exceed the soft limit by. 

but, if "soft_limit_reclaim fail and shrink_zone() succeed" don't cause
any performance degression, I don't find why kswapd is wrong.

I guess you and kamezawa-san know it detail. but my understanding don't reach it.
Could you please tell me what so slowness.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
