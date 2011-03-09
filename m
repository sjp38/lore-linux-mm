Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 13F2B8D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 00:22:08 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CE4D83EE0BC
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:22:04 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B166445DE6B
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:22:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 977BD45DE55
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:22:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7960E1DB8041
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:22:04 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D5121DB803E
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:22:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/6] proc: disable mem_write after exec
In-Reply-To: <1299631343-4499-5-git-send-email-wilsons@start.ca>
References: <1299631343-4499-1-git-send-email-wilsons@start.ca> <1299631343-4499-5-git-send-email-wilsons@start.ca>
Message-Id: <20110309142107.03FA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  9 Mar 2011 14:22:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Roland McGrath <roland@redhat.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

> This change makes mem_write() observe the same constraints as mem_read().  This
> is particularly important for mem_write as an accidental leak of the fd across
> an exec could result in arbitrary modification of the target process' memory.
> IOW, /proc/pid/mem is implicitly close-on-exec.
> 
> Signed-off-by: Stephen Wilson <wilsons@start.ca>
> ---
>  fs/proc/base.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index 9d096e8..e52702d 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -848,6 +848,10 @@ static ssize_t mem_write(struct file * file, const char __user *buf,
>  	if (check_mem_permission(task))
>  		goto out;
>  
> +	copied = -EIO;
> +	if (file->private_data != (void *)((long)current->self_exec_id))
> +		goto out;
> +

I agree.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
