Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id B3B066B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 14:44:48 -0400 (EDT)
Received: by iofh134 with SMTP id h134so23586642iof.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:44:48 -0700 (PDT)
Received: from mail-io0-x22d.google.com (mail-io0-x22d.google.com. [2607:f8b0:4001:c06::22d])
        by mx.google.com with ESMTPS id l86si3758900ioi.106.2015.09.22.11.44.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 11:44:48 -0700 (PDT)
Received: by iofb144 with SMTP id b144so23644731iof.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:44:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrUp2rmUSfKcTphEybfTQ8Kh58kRUekG80vx0TpZURo50g@mail.gmail.com>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
	<1442903021-3893-6-git-send-email-mingo@kernel.org>
	<CA+55aFzyZ6UKb_Ujm3E3eFwW_KUf8Vw3sV6tFpmAAGnificVvQ@mail.gmail.com>
	<CALCETrUv3yV2LBt9b5B_PQdfNOgJtcQrqVatWUU7Aozi4BAfLQ@mail.gmail.com>
	<CA+55aFy2oQztH_8TXgyAn944SpvD5wb9k=Os3fSYTB8V1Gc45w@mail.gmail.com>
	<CALCETrUp2rmUSfKcTphEybfTQ8Kh58kRUekG80vx0TpZURo50g@mail.gmail.com>
Date: Tue, 22 Sep 2015 11:44:47 -0700
Message-ID: <CA+55aFzBHDsB3icLkotCFdC57kNduredrUjd6+tt=q0OtuBS5Q@mail.gmail.com>
Subject: Re: [PATCH 05/11] mm: Introduce arch_pgd_init_late()
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Sep 22, 2015 at 11:37 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> kinds of mess.
>
> I don't think that anyone really wants to move #PF to IST, which means
> that we simply cannot handle vmalloc faults that happen when switching
> stacks after SYSCALL, no matter what fanciness we shove into the
> page_fault asm.

But that's fine. The kernel stack is special.  So yes, we want to make
sure that the kernel stack is always mapped in the thread whose stack
it is.

But that's not a big and onerous guarantee to make. Not when the
*real* problem is "random vmalloc allocations made by other processes
that we are not in the least interested in, and we don't want to add
synchronization for".

                         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
