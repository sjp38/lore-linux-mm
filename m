Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6D2516B0035
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 23:07:52 -0400 (EDT)
Received: by mail-ob0-f181.google.com with SMTP id gq1so4995606obb.26
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 20:07:52 -0700 (PDT)
Received: from mail-ob0-x229.google.com (mail-ob0-x229.google.com [2607:f8b0:4003:c01::229])
        by mx.google.com with ESMTPS id w1si30346605oey.176.2014.04.21.20.07.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Apr 2014 20:07:51 -0700 (PDT)
Received: by mail-ob0-f169.google.com with SMTP id uz6so2688191obc.14
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 20:07:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1397960791-16320-2-git-send-email-davidlohr@hp.com>
References: <1397960791-16320-1-git-send-email-davidlohr@hp.com>
	<1397960791-16320-2-git-send-email-davidlohr@hp.com>
Date: Tue, 22 Apr 2014 11:07:51 +0800
Message-ID: <CAMk6uBmoqERYT=ZKMtUM29Q-FPd5tMR9J+i8eUikJhph6rJFEA@mail.gmail.com>
Subject: Re: [PATCH 1/6] blackfin/ptrace: call find_vma with the mmap_sem held
From: Steven Miao <realmz6@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, zeus@gnu.org, aswin@hp.com, linux-mm@kvack.org, "open list:CAN NETWORK DRIVERS <linux-can@vger.kernel.org>, open list:NETWORKING DRIVERS <netdev@vger.kernel.org>, open list" <linux-kernel@vger.kernel.org>, bfin <adi-buildroot-devel@lists.sourceforge.net>

Hi Davidlohr,

On Sun, Apr 20, 2014 at 10:26 AM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> Performing vma lookups without taking the mm->mmap_sem is asking
> for trouble. While doing the search, the vma in question can be
> modified or even removed before returning to the caller. Take the
> lock (shared) in order to avoid races while iterating through the
> vmacache and/or rbtree.
Yes, mm->mmap_sem should lock here. Applied, thanks.
>
> This patch is completely *untested*.
>
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> Cc: Steven Miao <realmz6@gmail.com>
> Cc: adi-buildroot-devel@lists.sourceforge.net
> ---
>  arch/blackfin/kernel/ptrace.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/arch/blackfin/kernel/ptrace.c b/arch/blackfin/kernel/ptrace.c
> index e1f88e0..8b8fe67 100644
> --- a/arch/blackfin/kernel/ptrace.c
> +++ b/arch/blackfin/kernel/ptrace.c
> @@ -117,6 +117,7 @@ put_reg(struct task_struct *task, unsigned long regno, unsigned long data)
>  int
>  is_user_addr_valid(struct task_struct *child, unsigned long start, unsigned long len)
>  {
> +       bool valid;
>         struct vm_area_struct *vma;
>         struct sram_list_struct *sraml;
>
> @@ -124,9 +125,12 @@ is_user_addr_valid(struct task_struct *child, unsigned long start, unsigned long
>         if (start + len < start)
>                 return -EIO;
>
> +       down_read(&child->mm->mmap_sem);
>         vma = find_vma(child->mm, start);
> -       if (vma && start >= vma->vm_start && start + len <= vma->vm_end)
> -                       return 0;
> +       valid = vma && start >= vma->vm_start && start + len <= vma->vm_end;
> +       up_read(&child->mm->mmap_sem);
> +       if (valid)
> +               return 0;
>
>         for (sraml = child->mm->context.sram_list; sraml; sraml = sraml->next)
>                 if (start >= (unsigned long)sraml->addr
> --
> 1.8.1.4
>
-steven

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
