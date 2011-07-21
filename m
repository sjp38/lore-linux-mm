Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id ADB336B004A
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 06:32:40 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D1A203EE0BC
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 19:32:37 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BB40745DEB4
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 19:32:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A37F645DE7E
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 19:32:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DAFB1DB8038
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 19:32:37 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 552571DB803C
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 19:32:37 +0900 (JST)
Date: Thu, 21 Jul 2011 19:25:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] memcg: unify sync and async per-cpu charge cache
 draining
Message-Id: <20110721192525.56721c52.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <16dca2225fc14783a16d00c43f6680b67418da65.1311241300.git.mhocko@suse.cz>
References: <cover.1311241300.git.mhocko@suse.cz>
	<16dca2225fc14783a16d00c43f6680b67418da65.1311241300.git.mhocko@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Thu, 21 Jul 2011 09:50:00 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> Currently we have two ways how to drain per-CPU caches for charges.
> drain_all_stock_sync will synchronously drain all caches while
> drain_all_stock_async will asynchronously drain only those that refer to
> a given memory cgroup or its subtree in hierarchy.
> Targeted async draining has been introduced by 26fe6168 (memcg: fix
> percpu cached charge draining frequency) to reduce the cpu workers
> number.
> 
> sync draining is currently triggered only from mem_cgroup_force_empty
> which is triggered only by userspace (mem_cgroup_force_empty_write) or
> when a cgroup is removed (mem_cgroup_pre_destroy). Although these are
> not usually frequent operations it still makes some sense to do targeted
> draining as well, especially if the box has many CPUs.
> 
> This patch unifies both methods to use the single code (drain_all_stock)
> which relies on the original async implementation and just adds
> flush_work to wait on all caches that are still under work for the sync
> mode.
> We are using FLUSHING_CACHED_CHARGE bit check to prevent from waiting on
> a work that we haven't triggered.
> Please note that both sync and async functions are currently protected
> by percpu_charge_mutex so we cannot race with other drainers.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

hmm..maybe good.
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
