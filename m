Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6F75B6B011F
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 01:24:26 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2C6OO32004717
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Mar 2010 15:24:24 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C769045DE62
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 15:24:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 98C1545DE51
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 15:24:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7440BE78003
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 15:24:23 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AC61E38005
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 15:24:23 +0900 (JST)
Date: Fri, 12 Mar 2010 15:20:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 05/10 -mm v3] oom: badness heuristic rewrite
Message-Id: <20100312152048.e7dc8135.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1003100239150.30013@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003100236510.30013@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1003100239150.30013@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Mar 2010 02:41:32 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

>  	if (sysctl_panic_on_oom == 2)
>  		panic("out of memory(memcg). panic_on_oom is selected.\n");
> +
> +	limit = mem_cgroup_get_limit(mem) >> PAGE_SHIFT;

A small concern here.

+u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
+{
+       return res_counter_read_u64(&memcg->memsw, RES_LIMIT);
+}

Because memory cgroup has 2 limit controls as "memory" and "memory+swap",
a user may set only "memory" limitation. (Especially on swapless system.)
Then, memcg->memsw limit can be infinite in some situation.

So, how about this ? (just an idea after breif thinking..)

u64 mem_cgroup_get_memsw_limit(struct mem_cgroup *memcg)
{
	u64 memlimit, memswlimit;

	memlimit = res_counter_read_u64(&memcg->res, RES_LIMIT);
	memswlimit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
	if (memlimit + total_swap_pages > memswlimit)
		return memswlimit;
	return memlimit + total_swap_pages;
}

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
