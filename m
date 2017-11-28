Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id F1B436B0038
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 14:45:28 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id y204so606198qkb.5
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 11:45:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n24sor23004577qta.16.2017.11.28.11.45.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Nov 2017 11:45:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1511845670-12133-1-git-send-email-vinmenon@codeaurora.org>
References: <1511845670-12133-1-git-send-email-vinmenon@codeaurora.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 28 Nov 2017 11:45:27 -0800
Message-ID: <CAADWXX8FmAs1qB9=fsWZjt8xTEnGOAMS=eCHnuDLJrZiX6x=7w@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: make faultaround produce old ptes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, jack@suse.cz, minchan@kernel.org, catalin.marinas@arm.com, Will Deacon <will.deacon@arm.com>, ying.huang@intel.com, riel@redhat.com, dave.hansen@linux.intel.com, mgorman@suse.de

On Mon, Nov 27, 2017 at 9:07 PM, Vinayak Menon <vinmenon@codeaurora.org> wrote:
>
> Making the faultaround ptes old results in a unixbench regression for some
> architectures [3][4]. But on some architectures it is not found to cause
> any regression. So by default produce young ptes and provide an option for
> architectures to make the ptes old.

Ugh. This hidden random behavior difference annoys me.

It should also be better documented in the code if we end up doing it.

The reason x86 seems to prefer young pte's is simply that a TLB lookup
of an old entry basically causes a micro-fault that then sets the
accessed bit (using a locked cycle) and then a restart.

Those microfaults are not visible to software, but they are pretty
expensive in hardware, probably because they basically serialize
execution as if a real page fault had happened.

HOWEVER - and this is the part that annoys me most about the hidden
behavior - I suspect it ends up being very dependent on
microarchitectural details in addition to the actual load. So it might
be more true on some cores than others, and it might be very
load-dependent. So hiding it as some architectural helper function
really feels wrong to me. It would likely be better off as a real
flag, and then maybe we could make the default behavior be set by
architecture (or even dynamically by the architecture bootup code if
it turns out to be enough of an issue).

And I'm actually somewhat suspicious of your claim that it's not
noticeable on arm64. It's entirely possible that the serialization
cost of the hardware access flag is much lower, but I thought that in
virtualization you actually end up taking a SW fault, which in turn
would be much more expensive. In fact, I don't even find that
"Hardware Accessed" bit in my armv8 docs at all, so I'm guessing it's
new to 8.1? So this is very much not about architectures at all, but
about small details in microarchitectural behavior.

Maybe I'm wrong. Will/Catalin?

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
