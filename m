Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EB4F06B005D
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 02:16:51 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n826Gtcc022726
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 2 Sep 2009 15:16:55 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E73BB45DE60
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 15:16:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C781745DE4D
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 15:16:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 97D93E18002
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 15:16:54 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 44CC71DB8040
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 15:16:54 +0900 (JST)
Date: Wed, 2 Sep 2009 15:15:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mmotm][PATCH] coalescing uncharge
Message-Id: <20090902151500.532ffc2f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090902134114.b6f1a04d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090902093438.eed47a57.kamezawa.hiroyu@jp.fujitsu.com>
	<20090902134114.b6f1a04d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Sep 2009 13:41:14 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

>  #ifdef CONFIG_SWAP
>  /*
>   * called after __delete_from_swap_cache() and drop "page" account.
> Index: mmotm-2.6.31-Aug27/include/linux/sched.h
> ===================================================================
> --- mmotm-2.6.31-Aug27.orig/include/linux/sched.h
> +++ mmotm-2.6.31-Aug27/include/linux/sched.h
> @@ -1540,6 +1540,13 @@ struct task_struct {
>  	unsigned long trace_recursion;
>  #endif /* CONFIG_TRACING */
>  	unsigned long stack_start;
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR /* memcg uses this to do batch job */
> +	struct memcg_batch_info {
> +		bool do_batch;
> +		struct mem_cgroup *memcg;
> +		long pages, memsw;
> +	} memcg_batch;
> +#endif
I wonder I should make this as a pointer
	struct memcg_batch_info *

and allocate this dynamically at attach. Hmm. maybe useful for other purpose
to track per-task memcg behavior.

Regards,
-Kmae

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
