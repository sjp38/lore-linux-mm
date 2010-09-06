Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 35A296B0047
	for <linux-mm@kvack.org>; Sun,  5 Sep 2010 20:41:33 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o860fUT5022303
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 6 Sep 2010 09:41:30 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3EA7D45DE50
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 09:41:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CD7045DE4F
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 09:41:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F03201DB8015
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 09:41:29 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A52A91DB8013
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 09:41:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 13/14] mm: mempolicy: Check return code of check_range
In-Reply-To: <1283711588-7628-1-git-send-email-segooon@gmail.com>
References: <1283711588-7628-1-git-send-email-segooon@gmail.com>
Message-Id: <20100906093610.C8B5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  6 Sep 2010 09:41:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Kulikov Vasiliy <segooon@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, kernel-janitors@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> From: Vasiliy Kulikov <segooon@gmail.com>
> 
> Function check_range may return ERR_PTR(...). Check for it.

When happen this issue?

afaik, check_range return error when following condition.
 1) mm->mmap->vm_start argument is incorrect
 2) don't have neigher MPOL_MF_STATS, MPOL_MF_MOVE and MPOL_MF_MOVE_ALL

I think both case is not happen in real. Am I overlooking anything?


> 
> Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>
> ---
>  Compile tested.
> 
>  mm/mempolicy.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index f969da5..b73f02c 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -924,12 +924,15 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
>  	nodemask_t nmask;
>  	LIST_HEAD(pagelist);
>  	int err = 0;
> +	struct vm_area_struct *vma;
>  
>  	nodes_clear(nmask);
>  	node_set(source, nmask);
>  
> -	check_range(mm, mm->mmap->vm_start, mm->task_size, &nmask,
> +	vma = check_range(mm, mm->mmap->vm_start, mm->task_size, &nmask,
>  			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
> +	if (IS_ERR(vma))
> +		return PTR_ERR(vma);
>  
>  	if (!list_empty(&pagelist))
>  		err = migrate_pages(&pagelist, new_node_page, dest, 0);
> -- 
> 1.7.0.4
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
