Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F2E9D6B0078
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 21:38:34 -0400 (EDT)
Date: Thu, 9 Jun 2011 10:30:23 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [BUGFIX][PATCH v3] memcg: fix behavior of per cpu charge cache
 draining.
Message-Id: <20110609103023.4c4deaf2.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110609093045.1f969d30.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110609093045.1f969d30.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Thu, 9 Jun 2011 09:30:45 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> From 0ebd8a90a91d50c512e7c63e5529a22e44e84c42 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Wed, 8 Jun 2011 13:51:11 +0900
> Subject: [PATCH] Fix behavior of per-cpu charge cache draining in memcg.
> 
> For performance, memory cgroup caches some "charge" from res_counter
> into per cpu cache. This works well but because it's cache,
> it needs to be flushed in some cases. Typical cases are
> 	1. when someone hit limit.
> 	2. when rmdir() is called and need to charges to be 0.
> 
> But "1" has problem.
> 
> Recently, with large SMP machines, we many kworker runs because
> of flushing memcg's cache. Bad things in implementation are
> 
> a) it's called before calling try_to_free_mem_cgroup_pages()
>    so, it's called immidiately when a task hit limit.
>    (I though it was better to avoid to run into memory reclaim.
>     But it was wrong decision.)
> 
> b) Even if a cpu contains a cache for memcg not related to
>    a memcg which hits limit, drain code is called.
> 
> This patch fixes a) and b) by
> 
> A) delay calling of flushing until one run of try_to_free...
>    Then, the number of calling is decreased.
> B) check percpu cache contains a useful data or not.
> plus
> C) check asynchronous percpu draining doesn't run.
> 
> BTW, why this patch relpaces atomic_t counter with mutex is
> to guarantee a memcg which is pointed by stock->cacne is
> not destroyed while we check css_id.
> 
> Reported-by: Ying Han <yinghan@google.com>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
