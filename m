Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 44DF5828E1
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 11:42:54 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id n59so402954002uan.1
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 08:42:54 -0700 (PDT)
Received: from mail-vk0-x232.google.com (mail-vk0-x232.google.com. [2607:f8b0:400c:c05::232])
        by mx.google.com with ESMTPS id j2si3205045vkc.27.2016.08.05.08.42.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Aug 2016 08:42:53 -0700 (PDT)
Received: by mail-vk0-x232.google.com with SMTP id x130so194694063vkc.0
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 08:42:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1470404259-26290-1-git-send-email-bigeasy@linutronix.de>
References: <1470404259-26290-1-git-send-email-bigeasy@linutronix.de>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 5 Aug 2016 08:42:32 -0700
Message-ID: <CALCETrV9n=-Zi2KBT7i-WLrYGffXy1ha+M=_PhvnuOiG7pim8A@mail.gmail.com>
Subject: Re: [PATCH] x86/mm: disable preemption during CR3 read+write
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bp@suse.de>, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Fri, Aug 5, 2016 at 6:37 AM, Sebastian Andrzej Siewior
<bigeasy@linutronix.de> wrote:
> Usually current->mm (and therefore mm->pgd) stays the same during the
> lifetime of a task so it does not matter if a task gets preempted during
> the read and write of the CR3.
>
> But then, there is this scenario on x86-UP:
> TaskA is in do_exit() and exit_mm() sets current->mm = NULL followed by
> mmput() -> exit_mmap() -> tlb_finish_mmu() -> tlb_flush_mmu() ->
> tlb_flush_mmu_tlbonly() -> tlb_flush() -> flush_tlb_mm_range() ->
> __flush_tlb_up() -> __flush_tlb() ->  __native_flush_tlb().
>
> At this point current->mm is NULL but current->active_mm still points to
> the "old" mm.
> Let's preempt taskA _after_ native_read_cr3() by taskB. TaskB has its
> own mm so CR3 has changed.
> Now preempt back to taskA. TaskA has no ->mm set so it borrows taskB's
> mm and so CR3 remains unchanged. Once taskA gets active it continues
> where it was interrupted and that means it writes its old CR3 value
> back. Everything is fine because userland won't need its memory
> anymore.

This should affect kernel threads too, right?

Acked-by: Andy Lutomirski <luto@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
