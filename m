Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 480296B01D8
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:41:56 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58BfrN9007944
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:41:53 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 409E145DE4E
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:53 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E1ED45DD71
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:53 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F35C61DB8019
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:52 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AAEA1DB8013
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 01/18] oom: filter tasks not sharing the same cpuset
In-Reply-To: <alpine.DEB.2.00.1006010013080.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010013080.29202@chino.kir.corp.google.com>
Message-Id: <20100607084024.873B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:41:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Tasks that do not share the same set of allowed nodes with the task that
> triggered the oom should not be considered as candidates for oom kill.
> 
> Tasks in other cpusets with a disjoint set of mems would be unfairly
> penalized otherwise because of oom conditions elsewhere; an extreme
> example could unfairly kill all other applications on the system if a
> single task in a user's cpuset sets itself to OOM_DISABLE and then uses
> more memory than allowed.
> 
> Killing tasks outside of current's cpuset rarely would free memory for
> current anyway.  To use a sane heuristic, we must ensure that killing a
> task would likely free memory for current and avoid needlessly killing
> others at all costs just because their potential memory freeing is
> unknown.  It is better to kill current than another task needlessly.

I've put following historically remark in the description of the patch.


    We applied the exactly same patch in 2005:

        : commit ef08e3b4981aebf2ba9bd7025ef7210e8eec07ce
        : Author: Paul Jackson <pj@sgi.com>
        : Date:   Tue Sep 6 15:18:13 2005 -0700
        :
        : [PATCH] cpusets: confine oom_killer to mem_exclusive cpuset
        :
        : Now the real motivation for this cpuset mem_exclusive patch series seems
        : trivial.
        :
        : This patch keeps a task in or under one mem_exclusive cpuset from provoking an
        : oom kill of a task under a non-overlapping mem_exclusive cpuset.  Since only
        : interrupt and GFP_ATOMIC allocations are allowed to escape mem_exclusive
        : containment, there is little to gain from oom killing a task under a
        : non-overlapping mem_exclusive cpuset, as almost all kernel and user memory
        : allocation must come from disjoint memory nodes.
        :
        : This patch enables configuring a system so that a runaway job under one
        : mem_exclusive cpuset cannot cause the killing of a job in another such cpuset
        : that might be using very high compute and memory resources for a prolonged
        : time.

    And we changed it to current logic in 2006

        : commit 7887a3da753e1ba8244556cc9a2b38c815bfe256
        : Author: Nick Piggin <npiggin@suse.de>
        : Date:   Mon Sep 25 23:31:29 2006 -0700
        :
        : [PATCH] oom: cpuset hint
        :
        : cpuset_excl_nodes_overlap does not always indicate that killing a task will
        : not free any memory we for us.  For example, we may be asking for an
        : allocation from _anywhere_ in the machine, or the task in question may be
        : pinning memory that is outside its cpuset.  Fix this by just causing
        : cpuset_excl_nodes_overlap to reduce the badness rather than disallow it.

    And we haven't get the explanation why this patch doesn't reintroduced
    an old issue. 

I don't refuse a patch if it have multiple ack. But if you have any
material or number, please show us soon.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
