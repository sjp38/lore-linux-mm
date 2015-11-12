Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id B04AA6B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 14:29:33 -0500 (EST)
Received: by ioc74 with SMTP id 74so75475977ioc.2
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 11:29:33 -0800 (PST)
Received: from mail-io0-x22e.google.com (mail-io0-x22e.google.com. [2607:f8b0:4001:c06::22e])
        by mx.google.com with ESMTPS id cj5si186505igc.0.2015.11.12.11.29.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 11:29:32 -0800 (PST)
Received: by iofh3 with SMTP id h3so75667211iof.3
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 11:29:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151112080059.GA6835@gmail.com>
References: <1447111090-8526-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20151110123429.GE19187@pd.tnic>
	<20151110135303.GA11246@node.shutemov.name>
	<20151110144648.GG19187@pd.tnic>
	<20151110150713.GA11956@node.shutemov.name>
	<20151110170447.GH19187@pd.tnic>
	<20151111095101.GA22512@pd.tnic>
	<20151112074854.GA5376@gmail.com>
	<20151112075758.GA20702@node.shutemov.name>
	<20151112080059.GA6835@gmail.com>
Date: Thu, 12 Nov 2015 11:29:32 -0800
Message-ID: <CA+55aFx84N=o=RWJTy2Bjs-GNjKQuCZYyVWDTgOtRq3-qSO-yg@mail.gmail.com>
Subject: Re: [PATCH] x86/mm: fix regression with huge pages on PAE
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Anvin <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, elliott@hpe.com, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Toshi Kani <toshi.kani@hpe.com>

On Thu, Nov 12, 2015 at 12:00 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> So we already have PHYSICAL_PAGE_MASK, why not introduce PHYSICAL_PMD_MASK et al,
> instead of uglifying the code?

I think that's the right thing here.

> But, what problems do you expect with having a wider mask than its primary usage?
> If it's used for 32-bit values it will be truncated down safely. (But I have not
> tested it, so I might be missing some complication.)

No, it will not necessarily be truncated down. If we were to make the
regular PAGE_MASK etc that are normally used for virtual addresses be
"ull", it might easily make some calcyulations be done in 64 bits
instead. Sure, they'll probably be truncated down *eventually* when
you actually store them to some 32-bit thing, but I'd worry about it.

An example of a situation where over-long types cause problems is
simply in variadic functions (typically printk, but they do happen in
other places). Writing

    printk("page offset = %ul\n", address & PAGE_MASK);

makes sense. In the VM, addresses really are "unsigned long". But just
imagine how wrong the above goes if PAGE_MASK was made "ull".

So no, widening masks to the maximal possible type is not the answer.
They need to be the natural size.

Another possibility would be to simply make masks be _signed_ longs.
That can has its own set of problems, but it does mean that when the
mask has high bits set and it gets expanded to a wider type, the
normal C rules just do the RightThing(tm).

We've occasionally done that very explicitly. Just see how
PHYSICAL_PAGE_MASK is defined in terms of a signed PAGE_MASK.

I have this dim memory of us playing around with just making PAGE_SIZE
(and thus PAGE_MASK) always be signed, but that it caused other
problems. Signed types have downsides too.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
