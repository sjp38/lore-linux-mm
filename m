Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4A3416B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 06:50:54 -0500 (EST)
Message-ID: <494B8AD5.3090901@cn.fujitsu.com>
Date: Fri, 19 Dec 2008 19:51:49 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: Corruption with O_DIRECT and unaligned user buffers
References: <491DAF8E.4080506@quantum.com> <200811191526.00036.nickpiggin@yahoo.com.au> <20081119165819.GE19209@random.random> <20081218152952.GW24856@random.random>
In-Reply-To: <20081218152952.GW24856@random.random>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Tim LaBerge <tim.laberge@quantum.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Wang Chen <wangchen@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> diff -ur rhel-5.2/kernel/fork.c x/kernel/fork.c
> --- rhel-5.2/kernel/fork.c	2008-07-10 17:26:43.000000000 +0200
> +++ x/kernel/fork.c	2008-12-18 15:57:31.000000000 +0100
> @@ -368,7 +368,7 @@
>  		rb_parent = &tmp->vm_rb;
>  
>  		mm->map_count++;
> -		retval = copy_page_range(mm, oldmm, mpnt);
> +		retval = copy_page_range(mm, oldmm, tmp);
>  

Could you explain a bit why this change is needed?

Seems this is a revert of the following commit:

commit 0b0db14c536debd92328819fe6c51a49717e8440
Author: Hugh Dickins <hugh@veritas.com>
Date:   Mon Nov 21 21:32:20 2005 -0800

    [PATCH] unpaged: copy_page_range vma

    For copy_one_pte's print_bad_pte to show the task correctly (instead of
    "???"), dup_mmap must pass down parent vma rather than child vma.

    Signed-off-by: Hugh Dickins <hugh@veritas.com>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Linus Torvalds <torvalds@osdl.org>

diff --git a/kernel/fork.c b/kernel/fork.c
index e0d0b77..1c1cf8d 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -263,7 +263,7 @@ static inline int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
                rb_parent = &tmp->vm_rb;

                mm->map_count++;
-               retval = copy_page_range(mm, oldmm, tmp);
+               retval = copy_page_range(mm, oldmm, mpnt);

                if (tmp->vm_ops && tmp->vm_ops->open)
                        tmp->vm_ops->open(tmp);


>  		if (tmp->vm_ops && tmp->vm_ops->open)
>  			tmp->vm_ops->open(tmp);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
