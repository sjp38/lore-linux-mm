Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 758386B004D
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 11:01:42 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp08.au.ibm.com (8.14.3/8.13.1) with ESMTP id nABG1cda019313
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 03:01:38 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nABG1b1d1781838
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 03:01:38 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nABG1bXO018166
	for <linux-mm@kvack.org>; Thu, 12 Nov 2009 03:01:37 +1100
Date: Wed, 11 Nov 2009 21:31:34 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm 3/3] memcg: remove memcg_tasklist
Message-ID: <20091111160134.GM3314@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
 <20091111103533.c634ff8d.nishimura@mxp.nes.nec.co.jp>
 <20091111103906.5c3563bb.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091111103906.5c3563bb.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-11-11 10:39:06]:

> memcg_tasklist was introduced at commit 7f4d454d(memcg: avoid deadlock caused
> by race between oom and cpuset_attach) instead of cgroup_mutex to fix a deadlock
> problem.  The cgroup_mutex, which was removed by the commit, in
> mem_cgroup_out_of_memory() was originally introduced at commit c7ba5c9e
> (Memory controller: OOM handling).
> 
> IIUC, the intention of this cgroup_mutex was to prevent task move during
> select_bad_process() so that situations like below can be avoided.
> 
>   Assume cgroup "foo" has exceeded its limit and is about to trigger oom.
>   1. Process A, which has been in cgroup "baa" and uses large memory, is just
>      moved to cgroup "foo". Process A can be the candidates for being killed.
>   2. Process B, which has been in cgroup "foo" and uses large memory, is just
>      moved from cgroup "foo". Process B can be excluded from the candidates for
>      being killed.
> 
> But these race window exists anyway even if we hold a lock, because
> __mem_cgroup_try_charge() decides wether it should trigger oom or not outside
> of the lock. So the original cgroup_mutex in mem_cgroup_out_of_memory and thus
> current memcg_tasklist has no use. And IMHO, those races are not so critical
> for users.
> 
> This patch removes it and make codes simpler.
>

Could you please test for side-effects like concurrent OOM. An idea of
how the patchset was tested would be good to have, given the
implications of these changes.

Not-Yet-Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
