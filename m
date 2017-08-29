Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 990606B02F4
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 15:16:51 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 190so4731700itx.7
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 12:16:51 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 64sor1617867ioc.159.2017.08.29.12.16.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Aug 2017 12:16:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFy=+ipEWKYwckee7-QodyfwufejNq1WA3rSNUHKJiw+6g@mail.gmail.com>
References: <20170829190526.8767-1-jglisse@redhat.com> <CA+55aFy=+ipEWKYwckee7-QodyfwufejNq1WA3rSNUHKJiw+6g@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 29 Aug 2017 12:16:49 -0700
Message-ID: <CA+55aFynq_N8bYy2bKmp8eWnCbrFBpboeHCWJ92MF3zJ++V8og@mail.gmail.com>
Subject: Re: [RFC PATCH] mm/rmap: do not call mmu_notifier_invalidate_page() v3
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Andrea Arcangeli <aarcange@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Aug 29, 2017 at 12:09 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So any approach like this is fundamentally garbage. Really. Stop
> sending crap. This is exactly tehe same thing that we already reverted
> because it was broken shit. Why do you re-send it without actually
> fixing the fundamental problems that were pointed out?

Here's what I think might work:

 - put mmu_notifier_invalidate_range_start() before the rmap lock is
taken (and yes, this means that you don't know if it actually will do
anyhting)

 - put mmu_notifier_invalidate_range_end() after the lock is released.
And yes, this means that it will be unconditional and regardless of
whether anything happened)

And then you can check if something actually happened by catching the
*ATOMIC* call to mmu_notifier_invalidate_page(), setting a flag, and
then doing something blocking at mmu_notifier_invalidate_range_end()
time.

Maybe.

I don't know what the KVM issues are.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
