Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5DF3F6B004A
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 22:12:46 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9M2Cine021688
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 22 Oct 2010 11:12:44 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F18B745DE7A
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 11:12:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CB0C145DE4D
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 11:12:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B4BDCEF8002
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 11:12:43 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CB9F1DB803B
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 11:12:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] fix error reporting in move_pages syscall
In-Reply-To: <20101019101505.GG10207@redhat.com>
References: <20101019101505.GG10207@redhat.com>
Message-Id: <20101022110754.53B5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 22 Oct 2010 11:12:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> vma returned by find_vma does not necessary include given address. If
> this happens code tries to follow page outside of any vma and returns
> ENOENT instead of EFAULT.
> 
> Signed-off-by: Gleb Natapov <gleb@redhat.com>
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 38e7cad..b91a253 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -841,7 +841,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
>  
>  		err = -EFAULT;
>  		vma = find_vma(mm, pp->addr);
> -		if (!vma || !vma_migratable(vma))
> +		if (!vma || pp->addr < vma->vm_start || !vma_migratable(vma))
>  			goto set_status;
>  
>  		page = follow_page(vma, pp->addr, FOLL_GET);
> @@ -1005,7 +1005,7 @@ static void do_pages_stat_array(struct mm_struct *mm, unsigned long nr_pages,
>  		int err = -EFAULT;
>  
>  		vma = find_vma(mm, addr);
> -		if (!vma)
> +		if (!vma || addr < vma->vm_start)
>  			goto set_status;
>  
>  		page = follow_page(vma, addr, 0);
> --
> 			Gleb.

Looks good to me.
	Revewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
