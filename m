Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 59B7C6B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 14:37:39 -0400 (EDT)
Received: by oixx17 with SMTP id x17so10788826oix.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:37:39 -0700 (PDT)
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com. [209.85.218.47])
        by mx.google.com with ESMTPS id w4si1789544oig.37.2015.09.22.11.37.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 11:37:38 -0700 (PDT)
Received: by oixx17 with SMTP id x17so10788688oix.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:37:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFy2oQztH_8TXgyAn944SpvD5wb9k=Os3fSYTB8V1Gc45w@mail.gmail.com>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
 <1442903021-3893-6-git-send-email-mingo@kernel.org> <CA+55aFzyZ6UKb_Ujm3E3eFwW_KUf8Vw3sV6tFpmAAGnificVvQ@mail.gmail.com>
 <CALCETrUv3yV2LBt9b5B_PQdfNOgJtcQrqVatWUU7Aozi4BAfLQ@mail.gmail.com> <CA+55aFy2oQztH_8TXgyAn944SpvD5wb9k=Os3fSYTB8V1Gc45w@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 22 Sep 2015 11:37:18 -0700
Message-ID: <CALCETrUp2rmUSfKcTphEybfTQ8Kh58kRUekG80vx0TpZURo50g@mail.gmail.com>
Subject: Re: [PATCH 05/11] mm: Introduce arch_pgd_init_late()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Sep 22, 2015 at 11:26 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Tue, Sep 22, 2015 at 11:00 AM, Andy Lutomirski <luto@amacapital.net> wrote:
>>
>> I really really hate the vmalloc fault thing.  It seems to work,
>> rather to my surprise.  It doesn't *deserve* to work, because of
>> things like the percpu TSS accesses in the entry code that happen
>> without a valid stack.
>
> The thing is, I think you're misguided in your hatred.
>
> The reason I say that is because I think we should just embrace the
> fact that faults can and do happen in the kernel in very inconvenient
> places, and not just in code we "control".
>
> Even if you get rid of the vmalloc fault, you'll still have debug
> faults, and you'll still have NMI's and horrible crazy machine check
> faults.
>
> I actually think teh vmalloc fault is a good way to just let people
> know "pretty much anything can trap, deal with it".
>
> And I think trying to eliminate them is the wrong thing, because it
> forces us to be so damn synchronized. This whole patch-series is a
> prime example of why that is a bad bad things. We want to have _less_
> synchronization.

Sure, pretty much anything can trap, but we need to do *something* to
deal with it.

Debug faults can't happen with bad stacks any more (now that we honor
the kprobe blacklist), which means that debug faults could, in theory,
move off the IST stack.  The SYSENTER + debug mess doesn't have any
stack problem.

NMIs and MCEs are special, and we deal with that using IST and all
kinds of mess.

I don't think that anyone really wants to move #PF to IST, which means
that we simply cannot handle vmalloc faults that happen when switching
stacks after SYSCALL, no matter what fanciness we shove into the
page_fault asm.  If we move #PF to IST, then we have to worry about
page_fault -> nmi -> page_fault, which would be a clusterf*ck.

AMD gave us a pile of misguided architectural turds, and we have to
deal with it.  My preference is to simplify dealing with it by getting
rid of vmalloc faults so that we can at least reliably touch percpu
memory without faulting.

--Andy

-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
