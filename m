Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id ECD026B01F8
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 03:12:08 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2V7C5nB027506
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 31 Mar 2010 16:12:06 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B0CDA45DE55
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 16:12:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D9AB45DE4F
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 16:12:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7171FE38004
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 16:12:05 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 28CAA8F8006
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 16:12:02 +0900 (JST)
Date: Wed, 31 Mar 2010 16:08:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable
 task can be found
Message-Id: <20100331160816.8582a9a0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1003310007450.9287@chino.kir.corp.google.com>
References: <20100328145528.GA14622@desktop>
	<20100328162821.GA16765@redhat.com>
	<alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com>
	<20100329140633.GA26464@desktop>
	<alpine.DEB.2.00.1003291259400.14859@chino.kir.corp.google.com>
	<20100330142923.GA10099@desktop>
	<alpine.DEB.2.00.1003301326490.5234@chino.kir.corp.google.com>
	<20100331095714.9137caab.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1003302302420.22316@chino.kir.corp.google.com>
	<20100331151356.673c16c0.kamezawa.hiroyu@jp.fujitsu.com>
	<20100331063007.GN3308@balbir.in.ibm.com>
	<alpine.DEB.2.00.1003302331001.839@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1003310007450.9287@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Mar 2010 00:08:38 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> It's pointless to try to kill current if select_bad_process() did not
> find an eligible task to kill in mem_cgroup_out_of_memory() since it's
> guaranteed that current is a member of the memcg that is oom and it is,
> by definition, unkillable.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Ah, okay. If current is killable, current should be found by select_bad_process.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>  mm/oom_kill.c |    5 +----
>  1 files changed, 1 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -500,12 +500,9 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
>  	read_lock(&tasklist_lock);
>  retry:
>  	p = select_bad_process(&points, limit, mem, CONSTRAINT_NONE, NULL);
> -	if (PTR_ERR(p) == -1UL)
> +	if (!p || PTR_ERR(p) == -1UL)
>  		goto out;
>  
> -	if (!p)
> -		p = current;
> -
>  	if (oom_kill_process(p, gfp_mask, 0, points, limit, mem,
>  				"Memory cgroup out of memory"))
>  		goto retry;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
