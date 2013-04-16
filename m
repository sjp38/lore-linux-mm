Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id EABCA6B0027
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 13:57:12 -0400 (EDT)
Message-ID: <516D90F6.3020603@linux.intel.com>
Date: Tue, 16 Apr 2013 10:57:10 -0700
From: Darren Hart <dvhart@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] futex: bugfix for futex-key conflict when futex use hugepage
References: <OF000BBE68.EBB4E92E-ON48257B4F.0010C2E7-48257B4F.0013FB89@zte.com.cn>
In-Reply-To: <OF000BBE68.EBB4E92E-ON48257B4F.0010C2E7-48257B4F.0013FB89@zte.com.cn>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhang.yi20@zte.com.cn
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>

On 04/15/2013 08:37 PM, zhang.yi20@zte.com.cn wrote:
> Hello,
>

Hi Zhang,

I've rewrapped your plain text here for legibility, please adjust your
mail client accordingly.

> The futex-keys of processes share futex determined by page-offset,
> mapping-host, and mapping-index of the user space address.  User appications
> using hugepage for futex may lead to futex-key conflict.  Assume there are two
> or more futexes in diffrent normal pages of the hugepage, and each futex has
> the same offset in its normal page, causing all the futexes have the same
> futex-key.  In that case, futex may not work well.
>
> This patch adds the normal page index in the compound page into the offset of
> futex-key.

It also modifies the mm prep_compound*page() routines to set the page
compound index. You didn't modify the structure itself, I'm curious why
this information wasn't set before? Something for the MM folks I guess..

>
> Steps to reproduce the bug:
> 1. The 1st thread map a file of hugetlbfs, and use the return address as the
>    1st mutex's address, and use the return address with PAGE_SIZE added as the
>    2nd mutex's address;
> 2. The 1st thread initialize the two mutexes with pshared attribute, and lock
>    the two mutexes.
> 3. The 1st thread create the 2nd thread, and the 2nd thread block on the 1st
>    mutex.
> 4. The 1st thread create the 3rd thread, and the 3rd thread block on the 2nd
>    mutex.
> 5. The 1st thread unlock the 2nd mutex, the 3rd thread can not take the 2nd
>    mutex, and may block forever.


Again, a functional testcase in futextest would be a good idea. This
helps validate the patch and also can be used to identify regressions in
the future.


> Signed-off-by: Zhang Yi <zhang.yi20@zte.com.cn>
> Tested-by: Ma Chenggong <ma.chenggong@zte.com.cn>
> Reviewed-by: Liu Dong <liu.dong3@zte.com.cn>
> Reviewed-by: Cui Yunfeng <cui.yunfeng@zte.com.cn>
> Reviewed-by: Lu Zhongjun <lu.zhongjun@zte.com.cn>
> Reviewed-by: Jiang Biao <jiang.biao2@zte.com.cn>
>
> diff -uprN orig/linux-3.9-rc7/include/linux/mm.h
> new/linux-3.9-rc7/include/linux/mm.h
> --- orig/linux-3.9-rc7/include/linux/mm.h       2013-04-15
> 00:45:16.000000000 +0000
> +++ new/linux-3.9-rc7/include/linux/mm.h        2013-04-16
> 11:21:59.573458000 +0000
> @@ -502,6 +502,20 @@ static inline void set_compound_order(st
>         page[1].lru.prev = (void *)order;
>  }
>
> +static inline void set_page_compound_index(struct page *page, int index)
> +{
> +       if (PageHead(page))
> +               return;
> +       page->index = index;
> +}

I presume the spaces instead of tabs is a result of your mailer mangling
whitespace?

> +
> +static inline int get_page_compound_index(struct page *page)
> +{
> +       if (PageHead(page))
> +               return 0;
> +       return page->index;
> +}
> +
>  #ifdef CONFIG_MMU
>  /*
>   * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
> diff -uprN orig/linux-3.9-rc7/kernel/futex.c
> new/linux-3.9-rc7/kernel/futex.c
> --- orig/linux-3.9-rc7/kernel/futex.c   2013-04-15 00:45:16.000000000
> +0000
> +++ new/linux-3.9-rc7/kernel/futex.c    2013-04-16 11:13:30.069887000
> +0000
> @@ -239,7 +239,7 @@ get_futex_key(u32 __user *uaddr, int fsh
>         unsigned long address = (unsigned long)uaddr;
>         struct mm_struct *mm = current->mm;
>         struct page *page, *page_head;
> -       int err, ro = 0;
> +       int err, ro = 0, comp_idx = 0;
>
>         /*
>          * The futex address must be "naturally" aligned.
> @@ -299,6 +299,7 @@ again:
>                          * freed from under us.
>                          */
>                         if (page != page_head) {
> +                               comp_idx = get_page_compound_index(page);
>                                 get_page(page_head);
>                                 put_page(page);
>                         }
> @@ -311,6 +312,7 @@ again:
>  #else
>         page_head = compound_head(page);
>         if (page != page_head) {
> +               comp_idx = get_page_compound_index(page);
>                 get_page(page_head);
>                 put_page(page);
>         }
> @@ -363,7 +365,8 @@ again:
>                 key->private.mm = mm;
>                 key->private.address = address;
>         } else {
> -               key->both.offset |= FUT_OFF_INODE; /* inode-based key */
> +               key->both.offset |= (comp_idx << PAGE_SHIFT)
> +                                   | FUT_OFF_INODE; /* inode-based key */

Comments at the end of lines are bad form already, when moving to
multi-line, please move the comment just above the statements.

What is the max value of comp_idx? Are we at risk of truncating it?
Looks like not really from my initial look.

This also needs a comment in futex.h describing the usage of the offset
field in union futex_key as well as above get_futex_key describing the
key for shared mappings.


Thanks,

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Technical Lead - Linux Kernel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
