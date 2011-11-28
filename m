Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id F14E16B0099
	for <linux-mm@kvack.org>; Sun, 27 Nov 2011 23:33:19 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 581293EE0C0
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 13:33:16 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F8CA45DE5B
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 13:33:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A63E45DE58
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 13:33:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 176C41DB803E
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 13:33:16 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D707F1DB8037
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 13:33:15 +0900 (JST)
Date: Mon, 28 Nov 2011 13:32:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v6 10/10] Disable task moving when using kernel memory
 accounting
Message-Id: <20111128133203.2d52ee28.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1322242696-27682-11-git-send-email-glommer@parallels.com>
References: <1322242696-27682-1-git-send-email-glommer@parallels.com>
	<1322242696-27682-11-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, paul@paulmenage.org, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org

On Fri, 25 Nov 2011 15:38:16 -0200
Glauber Costa <glommer@parallels.com> wrote:

> Since this code is still experimental, we are leaving the exact
> details of how to move tasks between cgroups when kernel memory
> accounting is used as future work.
> 
> For now, we simply disallow movement if there are any pending
> accounted memory.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   23 ++++++++++++++++++++++-
>  1 files changed, 22 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2df5d3c..ab7e57b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5451,10 +5451,19 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
>  {
>  	int ret = 0;
>  	struct mem_cgroup *mem = mem_cgroup_from_cont(cgroup);
> +	struct mem_cgroup *from = mem_cgroup_from_task(p);
> +
> +#if defined(CONFIG_CGROUP_MEM_RES_CTLR_KMEM) && defined(CONFIG_INET)
> +	if (from != mem && !mem_cgroup_is_root(from) &&
> +	    res_counter_read_u64(&from->tcp_mem.tcp_memory_allocated, RES_USAGE)) {
> +		printk(KERN_WARNING "Can't move tasks between cgroups: "
> +			"Kernel memory held. task: %s\n", p->comm);
> +		return 1;
> +	}
> +#endif

Hmm, the kernel memory is not guaranteed as being held by the 'task' ?

How about
"Now, moving task between cgroup is disallowed while the source cgroup 
 containes kmem reference." ?

Hmm.. we need to fix this task-move/rmdir issue before production use.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
