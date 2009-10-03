Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D704A60021D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 20:58:58 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n930xUBk023568
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 3 Oct 2009 09:59:30 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A27A45DE70
	for <linux-mm@kvack.org>; Sat,  3 Oct 2009 09:59:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F151845DE6E
	for <linux-mm@kvack.org>; Sat,  3 Oct 2009 09:59:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DCC791DB8041
	for <linux-mm@kvack.org>; Sat,  3 Oct 2009 09:59:29 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8691C1DB803A
	for <linux-mm@kvack.org>; Sat,  3 Oct 2009 09:59:29 +0900 (JST)
Message-ID: <e515e3c588c8f44626fa7f87d680fae5.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <alpine.DEB.1.00.0910021511030.18180@chino.kir.corp.google.com>
References: <20091001165721.32248.14861.sendpatchset@localhost.localdomain>
    <20091001165832.32248.32725.sendpatchset@localhost.localdomain>
    <alpine.DEB.1.00.0910021511030.18180@chino.kir.corp.google.com>
Date: Sat, 3 Oct 2009 09:59:28 +0900 (JST)
Subject: Re: [patch] nodemask: make NODEMASK_ALLOC more general
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com, Lee Schermerhorn <lee.schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> NODEMASK_ALLOC(x, m) assumes x is a type of struct, which is unnecessary.
> It's perfectly reasonable to use this macro to allocate a nodemask_t,
> which is anonymous, either dynamically or on the stack depending on
> NODES_SHIFT.
>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
Seems reasonable (my macro was not good)
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

BTW...CPUMASK_ALLOC gone away ?
by  #ifdef CONFIG_CPUMASK_OFFSTACK
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=4b805b17382c11a8b1c9bb8053ce9d1dcde0701a

Hm, comment should be updated, at least.

Thanks,
-Kame

> ---
>  include/linux/nodemask.h |   15 ++++++++-------
>  1 files changed, 8 insertions(+), 7 deletions(-)
>
> diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
> --- a/include/linux/nodemask.h
> +++ b/include/linux/nodemask.h
> @@ -486,14 +486,14 @@ static inline int num_node_state(enum node_states
> state)
>
>  /*
>   * For nodemask scrach area.(See CPUMASK_ALLOC() in cpumask.h)
> + * NODEMASK_ALLOC(x, m) allocates an object of type 'x' with the name
> 'm'.
>   */
> -
>  #if NODES_SHIFT > 8 /* nodemask_t > 64 bytes */
> -#define NODEMASK_ALLOC(x, m) struct x *m = kmalloc(sizeof(*m),
> GFP_KERNEL)
> -#define NODEMASK_FREE(m) kfree(m)
> +#define NODEMASK_ALLOC(x, m)		x *m = kmalloc(sizeof(*m), GFP_KERNEL)
> +#define NODEMASK_FREE(m)		kfree(m)
>  #else
> -#define NODEMASK_ALLOC(x, m) struct x _m, *m = &_m
> -#define NODEMASK_FREE(m)
> +#define NODEMASK_ALLOC(x, m)		x _m, *m = &_m
> +#define NODEMASK_FREE(m)		do {} while (0)
>  #endif
>
>  /* A example struture for using NODEMASK_ALLOC, used in mempolicy. */
> @@ -502,8 +502,9 @@ struct nodemask_scratch {
>  	nodemask_t	mask2;
>  };
>
> -#define NODEMASK_SCRATCH(x) NODEMASK_ALLOC(nodemask_scratch, x)
> -#define NODEMASK_SCRATCH_FREE(x)  NODEMASK_FREE(x)
> +#define NODEMASK_SCRATCH(x)	\
> +		NODEMASK_ALLOC(struct nodemask_scratch, x)
> +#define NODEMASK_SCRATCH_FREE(x)	NODEMASK_FREE(x)
>
>
>  #endif /* __LINUX_NODEMASK_H */
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
