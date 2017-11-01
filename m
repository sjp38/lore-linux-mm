Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5EBFB6B026F
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 18:28:50 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id m81so11347604ioi.3
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 15:28:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c6sor888731iob.42.2017.11.01.15.28.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Nov 2017 15:28:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <d7cb1705-5ef0-5f6e-b1cf-e3f28e998477@linux.intel.com>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171101085424.cwvc4nrrdhvjc3su@gmail.com>
 <d7cb1705-5ef0-5f6e-b1cf-e3f28e998477@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Nov 2017 15:28:48 -0700
Message-ID: <CA+55aFw0OF0JSio47KVPrAz6CaJuX8kEvMk0DWVG2HZzRFr_+Q@mail.gmail.com>
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, borisBrian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Thomas Garnier <thgarnie@google.com>, Kees Cook <keescook@google.com>

On Wed, Nov 1, 2017 at 3:14 PM, Dave Hansen <dave.hansen@linux.intel.com> wrote:
>
> I ran some quick tests.  When CONFIG_KAISER=y, but "echo 0 >
> kaiser-enabled", the tests that I ran were within the noise vs. a
> vanilla kernel, and that's with *zero* optimization.

I guess the optimal version just ends up switching between two
different entrypoints for the on/off case.

And the not-quite-as-aggressive, but almost-optimal version would just
be a two-byte asm alternative with an unconditional branch to the
movcr3 code and back, and is turned into a noop when it's off.

But since 99%+ of the cost is going to be that cr3 write, even the
stupid "just load value and branch over the cr3 conditionally" is
going to make things hard to measure.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
