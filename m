Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AC3366B01F1
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 22:07:11 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7I275MU005963
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 18 Aug 2010 11:07:05 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0920545DE53
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:07:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 864A645DE4D
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:07:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 183DC1DB8044
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:07:03 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 720BFE18005
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:07:02 +0900 (JST)
Date: Wed, 18 Aug 2010 11:02:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: code improvement of check_stack_guard_page
Message-Id: <20100818110200.ff5b5615.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTinfgXOzbqgrRY4oCGXFtKtEyJO_rvQeeEEeEZz7@mail.gmail.com>
References: <AANLkTinfgXOzbqgrRY4oCGXFtKtEyJO_rvQeeEEeEZz7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: jovi zhang <bookjovi@gmail.com>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, hughd@google.com, riel@redhat.com, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 15 Aug 2010 13:07:56 +0800
jovi zhang <bookjovi@gmail.com> wrote:

> little code improvement of check_stack_guard_page function.
> this commit is on top of commit "mm: keep a guard page below a grow-down
> stack segment" of linus.
> 

Hmm. difference in binary code finally ?

-Kame

> diff --git a/mm/memory.c b/mm/memory.c
> index 9b3b73f..643b112 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2768,13 +2768,15 @@ out_release:
>   */
>  static inline int check_stack_guard_page(struct vm_area_struct *vma,
> unsigned long address)
>  {
> -       address &= PAGE_MASK;
> -       if ((vma->vm_flags & VM_GROWSDOWN) && address == vma->vm_start) {
> -               address -= PAGE_SIZE;
> -               if (find_vma(vma->vm_mm, address) != vma)
> -                       return -ENOMEM;
> -
> -               expand_stack(vma, address);
> +       if (vma->vm_flags & VM_GROWSDOWN) {
> +               address &= PAGE_MASK;
> +               if(address == vma->vm_start) {
> +                       address -= PAGE_SIZE;
> +                       if (unlikely(find_vma(vma->vm_mm, address) != vma))
> +                               return -ENOMEM;
> +
> +                       expand_stack(vma, address);
> +               }
>         }
>         return 0;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
