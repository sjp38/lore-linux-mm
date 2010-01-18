Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D75736B006A
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 22:10:37 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0I3AYed030179
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 18 Jan 2010 12:10:34 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 91B0045DE54
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 12:10:34 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 57C5D45DE4E
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 12:10:34 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 35B651DB805D
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 12:10:34 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C75441DB8038
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 12:10:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm-2010-01-15-15-34] Fix wrong offset for vma merge in mbind
In-Reply-To: <1263658528.2162.6.camel@barrios-desktop>
References: <1263658528.2162.6.camel@barrios-desktop>
Message-Id: <20100118120957.AE42.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Mon, 18 Jan 2010 12:10:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> mm-fix-mbind-vma-merge-problem.patch added vma_merge in mbind
> to merge mergeable vmas.
> But it passed wrong offset of vm_file.
> 
> This patch fixes it.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>

Nice catch!
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


> ---
>  mm/mempolicy.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 9751f3f..7e529d0 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -570,6 +570,7 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
>  	struct vm_area_struct *prev;
>  	struct vm_area_struct *vma;
>  	int err = 0;
> +	pgoff_t pgoff;
>  	unsigned long vmstart;
>  	unsigned long vmend;
>  
> @@ -582,9 +583,9 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
>  		vmstart = max(start, vma->vm_start);
>  		vmend   = min(end, vma->vm_end);
>  
> +		pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
>  		prev = vma_merge(mm, prev, vmstart, vmend, vma->vm_flags,
> -				  vma->anon_vma, vma->vm_file, vma->vm_pgoff,
> -				  new_pol);
> +				  vma->anon_vma, vma->vm_file, pgoff, new_pol);
>  		if (prev) {
>  			vma = prev;
>  			next = vma->vm_next;
> -- 
> 1.6.3.3
> 
> 
> 
> -- 
> Kind regards,
> Minchan Kim
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
