Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D5AD08D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 00:19:41 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 92E103EE0BD
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:19:38 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 796C745DE5D
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:19:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D8CD45DE4D
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:19:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C300E18004
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:19:38 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 10BCDE08003
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:19:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/6] mm: use mm_struct to resolve gate vma's in __get_user_pages
In-Reply-To: <1299631343-4499-2-git-send-email-wilsons@start.ca>
References: <1299631343-4499-1-git-send-email-wilsons@start.ca> <1299631343-4499-2-git-send-email-wilsons@start.ca>
Message-Id: <20110309141208.03F7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  9 Mar 2011 14:19:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Roland McGrath <roland@redhat.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

> We now check if a requested user page overlaps a gate vma using the supplied mm
> instead of the supplied task.  The given task is now used solely for accounting
> purposes and may be NULL.
> 
> Signed-off-by: Stephen Wilson <wilsons@start.ca>
> ---
>  mm/memory.c |   18 +++++++++++-------
>  1 files changed, 11 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 3863e86..36445e3 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1437,9 +1437,9 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		struct vm_area_struct *vma;
>  
>  		vma = find_extend_vma(mm, start);
> -		if (!vma && in_gate_area(tsk->mm, start)) {
> +		if (!vma && in_gate_area(mm, start)) {
>  			unsigned long pg = start & PAGE_MASK;
> -			struct vm_area_struct *gate_vma = get_gate_vma(tsk->mm);
> +			struct vm_area_struct *gate_vma = get_gate_vma(mm);
>  			pgd_t *pgd;
>  			pud_t *pud;
>  			pmd_t *pmd;

Hmm..
Is this works? In exec() case task has two mm, old and new-borned. tsk has
no enough information to detect gate area if 64bit process exec 32bit process
or oppsite case. On Linux, 32bit and 64bit processes have perfectly different
process vma layout.

Am I missing something?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
