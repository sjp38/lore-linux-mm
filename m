Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 38EDF6B0292
	for <linux-mm@kvack.org>; Thu, 25 May 2017 20:40:39 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id h4so257285507oib.5
        for <linux-mm@kvack.org>; Thu, 25 May 2017 17:40:39 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q110si4834029ota.1.2017.05.25.17.40.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 17:40:38 -0700 (PDT)
Received: from mail-ua0-f182.google.com (mail-ua0-f182.google.com [209.85.217.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8D4D123A04
	for <linux-mm@kvack.org>; Fri, 26 May 2017 00:40:37 +0000 (UTC)
Received: by mail-ua0-f182.google.com with SMTP id u10so124770572uaf.1
        for <linux-mm@kvack.org>; Thu, 25 May 2017 17:40:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFznnXPDxYy5CN6qVU7QJ3Y9hbSf-s2-w0QkaNJuTspGcQ@mail.gmail.com>
References: <20170525203334.867-1-kirill.shutemov@linux.intel.com> <CA+55aFznnXPDxYy5CN6qVU7QJ3Y9hbSf-s2-w0QkaNJuTspGcQ@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 25 May 2017 17:40:16 -0700
Message-ID: <CALCETrWACTFPDrpuZgoPqeRLU4ZooDjHOpQaNCFmCfVCHM-sHQ@mail.gmail.com>
Subject: Re: [PATCHv1, RFC 0/8] Boot-time switching between 4- and 5-level paging
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, May 25, 2017 at 4:24 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Thu, May 25, 2017 at 1:33 PM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
>> Here' my first attempt to bring boot-time between 4- and 5-level paging.
>> It looks not too terrible to me. I've expected it to be worse.
>
> If I read this right, you just made it a global on/off thing.
>
> May I suggest possibly a different model entirely? Can you make it a
> per-mm flag instead?
>
> And then we
>
>  (a) make all kthreads use the 4-level page tables
>
>  (b) which means that all the init code uses the 4-level page tables
>
>  (c) which means that all those checks for "start_secondary" etc can
> just go away, because those all run with 4-level page tables.
>
> Or is it just much too expensive to switch between 4-level and 5-level
> paging at run-time?
>

Even ignoring expensiveness, I'm not convinced it's practical.  AFAICT
you can't atomically switch the paging mode and CR3, so either you
need some magic page table with trampoline that works in both modes
(which is presumably doable with some trickery) or you need to flip
paging off.  Good luck if an NMI hits in the mean time.  There was
code like that once upon a time for EFI mixed mode, but it got deleted
due to triple-faults.

Doing this in switch_mm() sounds painful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
