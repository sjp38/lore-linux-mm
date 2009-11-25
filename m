Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 86E256B0044
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 19:03:55 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAP03lBg000516
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 25 Nov 2009 09:03:47 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 254A345DE51
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 09:03:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 06B7A45DE4F
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 09:03:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DA68C1DB8038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 09:03:46 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 90E6D1DB803A
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 09:03:43 +0900 (JST)
Date: Wed, 25 Nov 2009 09:00:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH -stable] memcg: avoid oom-killing innocent task
 in case of use_hierarchy
Message-Id: <20091125090050.e366dca5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091124162854.fb31e81e.nishimura@mxp.nes.nec.co.jp>
References: <20091124145759.194cfc9f.nishimura@mxp.nes.nec.co.jp>
	<20091124162854.fb31e81e.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: stable <stable@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Nov 2009 16:28:54 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> task_in_mem_cgroup(), which is called by select_bad_process() to check whether
> a task can be a candidate for being oom-killed from memcg's limit, checks
> "curr->use_hierarchy"("curr" is the mem_cgroup the task belongs to).
> 
> But this check return true(it's false positive) when:
> 
> 	<some path>/00		use_hierarchy == 0	<- hitting limit
> 	  <some path>/00/aa	use_hierarchy == 1	<- "curr"
> 
> This leads to killing an innocent task in 00/aa. This patch is a fix for this
> bug. And this patch also fixes the arg for mem_cgroup_print_oom_info(). We
> should print information of mem_cgroup which the task being killed, not current,
> belongs to.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/memcontrol.c |    2 +-
>  mm/oom_kill.c   |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index fd4529d..3acc226 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -496,7 +496,7 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
>  	task_unlock(task);
>  	if (!curr)
>  		return 0;
> -	if (curr->use_hierarchy)
> +	if (mem->use_hierarchy)
>  		ret = css_is_ancestor(&curr->css, &mem->css);
>  	else
>  		ret = (curr == mem);

Hmm. Maybe not-expected behavior...could you add comment ?

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
(*) I'm sorry I can't work enough in these days.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
