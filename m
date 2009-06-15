Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 719306B004F
	for <linux-mm@kvack.org>; Sun, 14 Jun 2009 22:43:21 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id n5F2gZGM024364
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 12:42:35 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5F2ibld749660
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 12:44:38 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5F2iboG030711
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 12:44:37 +1000
Message-ID: <4A35B591.7040504@linux.vnet.ibm.com>
Date: Mon, 15 Jun 2009 08:14:33 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: Low overhead patches for the memory cgroup controller (v4)
References: <b7dd123f0a15fff62150bc560747d7f0.squirrel@webmail-b.css.fujitsu.com> <20090515181639.GH4451@balbir.in.ibm.com> <20090518191107.8a7cc990.kamezawa.hiroyu@jp.fujitsu.com> <20090531235121.GA6120@balbir.in.ibm.com> <20090602085744.2eebf211.kamezawa.hiroyu@jp.fujitsu.com> <20090605053107.GF11755@balbir.in.ibm.com> <20090614183740.GD23577@balbir.in.ibm.com> <20090615111817.84123ea1.nishimura@mxp.nes.nec.co.jp> <20090615112300.73ef1d8a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090615112300.73ef1d8a.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, KOSAKI Motohiro <m-kosaki@ceres.dti.ne.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Mon, 15 Jun 2009 11:18:17 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
>> On Mon, 15 Jun 2009 00:07:40 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>> Here is v4 of the patches, please review and comment
>>>
>>> Feature: Remove the overhead associated with the root cgroup
>>>
>>> From: Balbir Singh <balbir@linux.vnet.ibm.com>
>>>
>>> changelog v4 -> v3
>>> 1. Rebase to mmotm 9th june 2009
>>> 2. Remove PageCgroupRoot, we have account LRU flags to indicate that
>>>    we do only accounting and no reclaim.
>> hmm, I prefer the previous version of PCG_ACCT_LRU meaning. It can be
>> used to remove annoying list_empty(&pc->lru) and !pc->mem_cgroup checks.
>>
>>> 3. pcg_default_flags has been used again, since PCGF_ROOT is gone,
>>>    we set PCGF_ACCT_LRU only in mem_cgroup_add_lru_list
>> It might be safe, but I don't think it's a good idea to touch PCGF_ACCT_LRU
>> outside of zone->lru_lock.
>>
>> IMHO, the most complicated case is a SwapCache which has been read ahead by
>> a *different* cpu from the cpu doing do_swap_page(). Those SwapCache can be
>> on page_vec and be drained to LRU asymmetrically with do_swap_page().
>> Well, yes it would be safe just because PCGF_ACCT_LRU would not be set
>> if PCGF_USED has not been set, but I don't think it's a good idea to touch
>> PCGF_ACCT_LRU outside of zone->lru_lock anyway.
>>
>>
>> Doesn't a patch like below work for you ?
>> Lightly tested under global memory pressure(w/o memcg's memory pressure)
>> on a small machine(just a bit modified from then though).
>>

OK, so you like the older meaning and implementation, the code seems fine to me,
I like the removal of list_empty() checks that you and Kame have proposed.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
