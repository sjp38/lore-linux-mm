Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A3C5E900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 15:35:05 -0400 (EDT)
Date: Mon, 18 Apr 2011 12:34:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mempolicy: reduce references to the current
Message-Id: <20110418123433.7b72b103.akpm@linux-foundation.org>
In-Reply-To: <1302847688-8076-1-git-send-email-namhyung@gmail.com>
References: <BANLkTinDFrbUNPnUmed2aBTu1_QHFQie-w@mail.gmail.com>
	<1302847688-8076-1-git-send-email-namhyung@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>

On Fri, 15 Apr 2011 15:08:08 +0900
Namhyung Kim <namhyung@gmail.com> wrote:

> Remove duplicated reference to the 'current' task using a local
> variable. Since refering the current can be a burden, it'd better
> cache the reference, IMHO. At least this saves some bytes on x86_64.
> 
>   $ size mempolicy-{old,new}.o
>      text    data    bss     dec     hex filename
>     25203    2448   9176   36827    8fdb mempolicy-old.o
>     25136    2448   9184   36768    8fa0 mempolicy-new.o
> 
> Signed-off-by: Namhyung Kim <namhyung@gmail.com>
> ---
>  mm/mempolicy.c |   58 +++++++++++++++++++++++++++++--------------------------
>  1 files changed, 31 insertions(+), 27 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 959a8b8c7350..5a30065590aa 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -304,6 +304,7 @@ static void mpol_rebind_nodemask(struct mempolicy *pol, const nodemask_t *nodes,
>  				 enum mpol_rebind_step step)
>  {
>  	nodemask_t tmp;
> +	struct task_struct *tsk = current;
>  
>  	if (pol->flags & MPOL_F_STATIC_NODES)
>  		nodes_and(tmp, pol->w.user_nodemask, *nodes);
> @@ -335,12 +336,12 @@ static void mpol_rebind_nodemask(struct mempolicy *pol, const nodemask_t *nodes,
>  	else
>  		BUG();
>  
> -	if (!node_isset(current->il_next, tmp)) {
> -		current->il_next = next_node(current->il_next, tmp);
> -		if (current->il_next >= MAX_NUMNODES)
> -			current->il_next = first_node(tmp);
> -		if (current->il_next >= MAX_NUMNODES)
> -			current->il_next = numa_node_id();
> +	if (!node_isset(tsk->il_next, tmp)) {
> +		tsk->il_next = next_node(tsk->il_next, tmp);
> +		if (tsk->il_next >= MAX_NUMNODES)
> +			tsk->il_next = first_node(tmp);
> +		if (tsk->il_next >= MAX_NUMNODES)
> +			tsk->il_next = numa_node_id();
>  	}
>  }

Odd.  The new(ish) percpu_read_stable() stuff produces very efficient
code for `current' and usually means that caching `current' in a local
is unneeded, often an overall loss.

So... what is going wrong in mempolicy.c?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
