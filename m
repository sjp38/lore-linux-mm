Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 862AD6B004F
	for <linux-mm@kvack.org>; Tue, 23 Dec 2008 17:22:34 -0500 (EST)
Received: by ewy3 with SMTP id 3so2909963ewy.14
        for <linux-mm@kvack.org>; Tue, 23 Dec 2008 14:22:32 -0800 (PST)
Message-ID: <961aa3350812231422u39adc12dna71060186f9026e0@mail.gmail.com>
Date: Wed, 24 Dec 2008 07:22:31 +0900
From: "Akinobu Mita" <akinobu.mita@gmail.com>
Subject: Re: [PATCH] fix unmap_vmas() with NULL vma
In-Reply-To: <20081223150618.GB3215@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081223103820.GB7217@localhost.localdomain>
	 <20081223150618.GB3215@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> Why bail out this late?  We can save the other stuff in exit_mmap() as
> well if we have no mmaps.
>
> Granted, the path is dead cold so the extra call overhead doesn't
> matter but I think the check is logically better placed in
> exit_mmap().

Looks good, this patch should go in.

>        Hannes
>
> ---
> Subject: mm: check for no mmaps in exit_mmap()
>
> When dup_mmap() ooms we can end up with mm->mmap == NULL.  The error
> path does mmput() and unmap_vmas() gets a NULL vma which it
> dereferences.
>
> In exit_mmap() there is nothing to do at all for this case, we can
> cancel the callpath right there.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>
> diff --git a/mm/mmap.c b/mm/mmap.c
> index d4855a6..b9d1636 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2091,6 +2091,9 @@ void exit_mmap(struct mm_struct *mm)
>        arch_exit_mmap(mm);
>        mmu_notifier_release(mm);
>
> +       if (!mm->mmap)
> +               return;
> +
>        if (mm->locked_vm) {
>                vma = mm->mmap;
>                while (vma) {
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
