Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6541C6B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 21:40:10 -0500 (EST)
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id n092e7fE010872
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 18:40:08 -0800
Received: from wf-out-1314.google.com (wfc28.prod.google.com [10.142.3.28])
	by spaceape8.eur.corp.google.com with ESMTP id n092dU2x002484
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 18:40:04 -0800
Received: by wf-out-1314.google.com with SMTP id 28so10647611wfc.29
        for <linux-mm@kvack.org>; Thu, 08 Jan 2009 18:40:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <604427e00901051539x52ab85bcua94cd8036e5b619a@mail.gmail.com>
References: <604427e00901051539x52ab85bcua94cd8036e5b619a@mail.gmail.com>
Date: Thu, 8 Jan 2009 18:40:04 -0800
Message-ID: <604427e00901081840pa6dcc41u9a7a5c69302c7b60@mail.gmail.com>
Subject: Re: [PATCH]Fix: 32bit binary has 64bit address of stack vma
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 5, 2009 at 3:39 PM, Ying Han <yinghan@google.com> wrote:
> From: Ying Han <yinghan@google.com>
>
> Fix 32bit binary get 64bit stack vma offset.
>
> 32bit binary running on 64bit system, the /proc/pid/maps shows for the
> vma represents stack get a 64bit adress:
> ff96c000-ff981000 rwxp 7ffffffea000 00:00 0 [stack]
>
> Signed-off-by:  Ying Han <yinghan@google.com>
>
> fs/exec.c                     |    5 +-
>
> diff --git a/fs/exec.c b/fs/exec.c
> index 4e834f1..8c3eff4 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -517,6 +517,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, uns
>        unsigned long length = old_end - old_start;
>        unsigned long new_start = old_start - shift;
>        unsigned long new_end = old_end - shift;
> +       unsigned long new_pgoff = new_start >> PAGE_SHIFT;
>        struct mmu_gather *tlb;
>
>        BUG_ON(new_start > new_end);
> @@ -531,7 +532,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, uns
>        /*
>         * cover the whole range: [new_start, old_end)
>         */
> -       vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL);
> +       vma_adjust(vma, new_start, old_end, new_pgoff, NULL);
>
>        /*
>         * move the page tables downwards, on failure we rely on
> @@ -564,7 +565,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, uns
>        /*
>         * shrink the vma to just the new range.
>         */
> -       vma_adjust(vma, new_start, new_end, vma->vm_pgoff, NULL);
> +       vma_adjust(vma, new_start, new_end, new_pgoff, NULL);
>
>        return 0;
>  }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
