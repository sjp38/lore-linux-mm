Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0BE6B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 14:26:53 -0400 (EDT)
Received: by iofb144 with SMTP id b144so23171141iof.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:26:53 -0700 (PDT)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id 72si3679406iot.191.2015.09.22.11.26.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 11:26:52 -0700 (PDT)
Received: by igcrk20 with SMTP id rk20so86354319igc.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:26:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrUv3yV2LBt9b5B_PQdfNOgJtcQrqVatWUU7Aozi4BAfLQ@mail.gmail.com>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
	<1442903021-3893-6-git-send-email-mingo@kernel.org>
	<CA+55aFzyZ6UKb_Ujm3E3eFwW_KUf8Vw3sV6tFpmAAGnificVvQ@mail.gmail.com>
	<CALCETrUv3yV2LBt9b5B_PQdfNOgJtcQrqVatWUU7Aozi4BAfLQ@mail.gmail.com>
Date: Tue, 22 Sep 2015 11:26:52 -0700
Message-ID: <CA+55aFy2oQztH_8TXgyAn944SpvD5wb9k=Os3fSYTB8V1Gc45w@mail.gmail.com>
Subject: Re: [PATCH 05/11] mm: Introduce arch_pgd_init_late()
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Sep 22, 2015 at 11:00 AM, Andy Lutomirski <luto@amacapital.net> wrote:
>
> I really really hate the vmalloc fault thing.  It seems to work,
> rather to my surprise.  It doesn't *deserve* to work, because of
> things like the percpu TSS accesses in the entry code that happen
> without a valid stack.

The thing is, I think you're misguided in your hatred.

The reason I say that is because I think we should just embrace the
fact that faults can and do happen in the kernel in very inconvenient
places, and not just in code we "control".

Even if you get rid of the vmalloc fault, you'll still have debug
faults, and you'll still have NMI's and horrible crazy machine check
faults.

I actually think teh vmalloc fault is a good way to just let people
know "pretty much anything can trap, deal with it".

And I think trying to eliminate them is the wrong thing, because it
forces us to be so damn synchronized. This whole patch-series is a
prime example of why that is a bad bad things. We want to have _less_
synchronization.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
