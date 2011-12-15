Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 386416B004F
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 17:20:16 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CE4313EE0B5
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 07:20:14 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B898645DF01
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 07:20:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A217745DE66
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 07:20:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 90D291DB804E
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 07:20:14 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C4D11DB804A
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 07:20:14 +0900 (JST)
Date: Fri, 16 Dec 2011 07:18:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch v3] oom, memcg: fix exclusion of memcg threads after
 they have detached their mm
Message-Id: <20111216071855.25abd0ad.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1112151335370.17878@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1112131659100.32369@chino.kir.corp.google.com>
	<20111214102942.GA11786@tiehlicka.suse.cz>
	<alpine.DEB.2.00.1112141838470.27595@chino.kir.corp.google.com>
	<20111215155926.GA22819@tiehlicka.suse.cz>
	<alpine.DEB.2.00.1112151335370.17878@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu, 15 Dec 2011 13:36:11 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> The oom killer relies on logic that identifies threads that have already
> been oom killed when scanning the tasklist and, if found, deferring until
> such threads have exited.  This is done by checking for any candidate
> threads that have the TIF_MEMDIE bit set.
> 
> For memcg ooms, candidate threads are first found by calling
> task_in_mem_cgroup() since the oom killer should not defer if there's an
> oom killed thread in another memcg.
> 
> Unfortunately, task_in_mem_cgroup() excludes threads if they have
> detached their mm in the process of exiting so TIF_MEMDIE is never
> detected for such conditions.  This is different for global, mempolicy,
> and cpuset oom conditions where a detached mm is only excluded after
> checking for TIF_MEMDIE and deferring, if necessary, in
> select_bad_process().
> 
> The fix is to return true if a task has a detached mm but is still in the
> memcg or its hierarchy that is currently oom.  This will allow the oom
> killer to appropriately defer rather than kill unnecessarily or, in the
> worst case, panic the machine if nothing else is available to kill.
> 
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

Thank you.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
