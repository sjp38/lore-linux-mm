Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4326B0254
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 14:00:33 -0400 (EDT)
Received: by oibi136 with SMTP id i136so10171842oib.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:00:32 -0700 (PDT)
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com. [209.85.218.54])
        by mx.google.com with ESMTPS id x19si1716059oia.57.2015.09.22.11.00.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 11:00:32 -0700 (PDT)
Received: by oibi136 with SMTP id i136so10171672oib.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:00:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzyZ6UKb_Ujm3E3eFwW_KUf8Vw3sV6tFpmAAGnificVvQ@mail.gmail.com>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
 <1442903021-3893-6-git-send-email-mingo@kernel.org> <CA+55aFzyZ6UKb_Ujm3E3eFwW_KUf8Vw3sV6tFpmAAGnificVvQ@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 22 Sep 2015 11:00:12 -0700
Message-ID: <CALCETrUv3yV2LBt9b5B_PQdfNOgJtcQrqVatWUU7Aozi4BAfLQ@mail.gmail.com>
Subject: Re: [PATCH 05/11] mm: Introduce arch_pgd_init_late()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Sep 22, 2015 at 10:55 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Mon, Sep 21, 2015 at 11:23 PM, Ingo Molnar <mingo@kernel.org> wrote:
>> Add a late PGD init callback to places that allocate a new MM
>> with a new PGD: copy_process() and exec().
>>
>> The purpose of this callback is to allow architectures to implement
>> lockless initialization of task PGDs, to remove the scalability
>> limit of pgd_list/pgd_lock.
>
> Do we really need this?
>
> Can't we just initialize the pgd when we allocate it, knowing that
> it's not in sync, but just depend on the vmalloc fault to add in any
> kernel entries that we might have missed?

I really really hate the vmalloc fault thing.  It seems to work,
rather to my surprise.  It doesn't *deserve* to work, because of
things like the percpu TSS accesses in the entry code that happen
without a valid stack.

For all I know, there's a long history of this hitting on monster
non-SMAP systems that are all buggy and rootable but no one notices
because it's rare.  On SMAP with non-malicious userspace, it's an
instant double fault.  With malicious userspace, it's rootable
regardless of SMAP, but it's much harder with SMAP.

If we start every mm with a fully zeroed pgd (which is what I think
you're suggesting), then this starts affecting small systems as in
addition to monster systems.

I'd really rather go in the other directoin and completely eliminate
vmalloc faults.  We could do that by eagerly initializing all pgd, or
we could do it by tracking, per-pgd, how up-to-date it is and fixing
it up in switch_mm.  The latter is a bit nasty on SMP.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
