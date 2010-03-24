Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 121656B01BD
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 03:05:57 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp04.au.ibm.com (8.14.3/8.13.1) with ESMTP id o2O724wd027490
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 18:02:04 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2O75oK81196246
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 18:05:50 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2O75nbG027000
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 18:05:50 +1100
Date: Wed, 24 Mar 2010 12:35:48 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH] fix race in file_mapped accounting in memcg
Message-ID: <20100324070547.GB3308@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100324154324.6d27336e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100324154324.6d27336e.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, arighi@develer.com
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-24 15:43:24]:

> A fix for race in file_mapped statistics. I noticed this race while discussing
> Andrea's dirty accounting patch series. 
> At the end of discusstion, I said "please don't touch file mapped". So, this bugfix
> should be posted as an independent patch.
> Tested on the latest mmotm.
> 
> Thanks,
> -Kame
> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, memcg's FILE_MAPPED accounting has following race with
> move_account (happens at rmdir()).
> 
>     increment page->mapcount (rmap.c)
>     mem_cgroup_update_file_mapped()           move_account()
> 					      lock_page_cgroup()
> 					      check page_mapped() if
> 					      page_mapped(page)>1 {
> 						FILE_MAPPED -1 from old memcg
> 						FILE_MAPPED +1 to old memcg
> 					      }
> 					      .....
> 					      overwrite pc->mem_cgroup
> 					      unlock_page_cgroup()
>     lock_page_cgroup()
>     FILE_MAPPED + 1 to pc->mem_cgroup
>     unlock_page_cgroup()
> 
> Then,
> 	old memcg (-1 file mapped)
> 	new memcg (+2 file mapped)
>

Good catch!


Reviewed-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 
 
-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
