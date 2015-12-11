Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 24EAD6B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 15:55:52 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id su19so47508505igc.0
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 12:55:52 -0800 (PST)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id j18si1945795ioe.201.2015.12.11.12.55.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 12:55:51 -0800 (PST)
Received: by mail-ig0-x22d.google.com with SMTP id g19so48076811igv.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 12:55:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151211204939.GA2604@uranus>
References: <20151211204939.GA2604@uranus>
Date: Fri, 11 Dec 2015 12:55:51 -0800
Message-ID: <CA+55aFzbBQp-QzWj2k7twuZ7+ESFpzoRPGZVKWkDv04zHCZ3Sg@mail.gmail.com>
Subject: Re: [RFC] mm: Account anon mappings as RLIMIT_DATA
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Vegard Nossum <vegard.nossum@oracle.com>, Willy Tarreau <w@1wt.eu>, Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Fri, Dec 11, 2015 at 12:49 PM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
>
> This should give a way to control the amount of anonymous
> memory allocated.

This looks good to me, assuming it gets testing. I think we could add
the hugetlb stuff later, I think it's a separate improvement.

Small nit:

> @@ -1214,6 +1214,8 @@ void vm_stat_account(struct mm_struct *m
>  {
>         const unsigned long stack_flags
>                 = VM_STACK_FLAGS & (VM_GROWSUP|VM_GROWSDOWN);
> +       const unsigned long not_anon_acc
> +               = VM_GROWSUP | VM_GROWSDOWN | VM_SHARED | VM_MAYSHARE;
>
>         mm->total_vm += pages;
>
> @@ -1223,6 +1225,9 @@ void vm_stat_account(struct mm_struct *m
>                         mm->exec_vm += pages;
>         } else if (flags & stack_flags)
>                 mm->stack_vm += pages;
> +
> +       if (!file && (flags & not_anon_acc) == 0)
> +               mm->anon_vm += pages;
>  }
>  #endif /* CONFIG_PROC_FS */
>
> @@ -1534,6 +1539,13 @@ static inline int accountable_mapping(st
>         return (vm_flags & (VM_NORESERVE | VM_SHARED | VM_WRITE)) == VM_WRITE;
>  }
>
> +static inline int anon_accountable_mapping(struct file *file, vm_flags_t vm_flags)
> +{
> +       return !file &&
> +               (vm_flags & (VM_GROWSDOWN | VM_GROWSUP |
> +                            VM_SHARED | VM_MAYSHARE)) == 0;
> +}

You're duplicating that "is it an anon accountable mapping" logic. I
think you should move the inline helper function up, and use it in
vm_stat_account().

Other than that, I think the patch certainly looks clean and obvious
enough. But I didn't actually try to *run* it, maybe it ends up not
working due to something I don't see.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
