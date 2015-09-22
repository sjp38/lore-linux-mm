Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id D45066B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 14:52:51 -0400 (EDT)
Received: by obbda8 with SMTP id da8so15461723obb.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:52:51 -0700 (PDT)
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com. [209.85.214.170])
        by mx.google.com with ESMTPS id 11si1811362obs.46.2015.09.22.11.52.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 11:52:51 -0700 (PDT)
Received: by obbbh8 with SMTP id bh8so15448115obb.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:52:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzBHDsB3icLkotCFdC57kNduredrUjd6+tt=q0OtuBS5Q@mail.gmail.com>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
 <1442903021-3893-6-git-send-email-mingo@kernel.org> <CA+55aFzyZ6UKb_Ujm3E3eFwW_KUf8Vw3sV6tFpmAAGnificVvQ@mail.gmail.com>
 <CALCETrUv3yV2LBt9b5B_PQdfNOgJtcQrqVatWUU7Aozi4BAfLQ@mail.gmail.com>
 <CA+55aFy2oQztH_8TXgyAn944SpvD5wb9k=Os3fSYTB8V1Gc45w@mail.gmail.com>
 <CALCETrUp2rmUSfKcTphEybfTQ8Kh58kRUekG80vx0TpZURo50g@mail.gmail.com> <CA+55aFzBHDsB3icLkotCFdC57kNduredrUjd6+tt=q0OtuBS5Q@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 22 Sep 2015 11:52:31 -0700
Message-ID: <CALCETrX9+dOE97r+A8v4eH7mhsPPA+hNXK7OF2ryMFhhHjT-jw@mail.gmail.com>
Subject: Re: [PATCH 05/11] mm: Introduce arch_pgd_init_late()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Sep 22, 2015 at 11:44 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Tue, Sep 22, 2015 at 11:37 AM, Andy Lutomirski <luto@amacapital.net> wrote:
>> kinds of mess.
>>
>> I don't think that anyone really wants to move #PF to IST, which means
>> that we simply cannot handle vmalloc faults that happen when switching
>> stacks after SYSCALL, no matter what fanciness we shove into the
>> page_fault asm.
>
> But that's fine. The kernel stack is special.  So yes, we want to make
> sure that the kernel stack is always mapped in the thread whose stack
> it is.
>
> But that's not a big and onerous guarantee to make. Not when the
> *real* problem is "random vmalloc allocations made by other processes
> that we are not in the least interested in, and we don't want to add
> synchronization for".
>

It's the kernel stack, the TSS (for sp0) and rsp_scratch at least.
But yes, that's not that onerous, and it's never lazily initialized
elsewhere.

How about this (long-term, not right now): Never free pgd entries.
For each pgd, track the number of populated kernel entries.  Also
track the global (init_mm) number of existing kernel entries.  At
context switch time, if new_pgd has fewer entries that the total, sync
it.

This hits *at most* 256 times per thread, and otherwise it's just a
single unlikely branch.  It guarantees that we only ever take a
vmalloc fault when accessing maps that didn't exist when we last
context switched, which gets us all of the important percpu stuff and
the kernel stack, even if we schedule onto a cpu that didn't exist
when the mm was created.

--Andy

>                          Linus



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
