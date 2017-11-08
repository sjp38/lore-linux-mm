Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4FD0A44043C
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 16:23:39 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id h64so6514916itb.6
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 13:23:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s22sor2419205ios.78.2017.11.08.13.23.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Nov 2017 13:23:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171108211525.4kxwj5ygg3kvfl2a@pd.tnic>
References: <nycvar.YFH.7.76.1711082103320.6470@cbobk.fhfr.pm>
 <alpine.DEB.2.20.1711082133410.1962@nanos> <CA+55aFz5Z8dfLp1swfOaEomH21mvCFEy=4w6L0cWska=He45FQ@mail.gmail.com>
 <20171108211525.4kxwj5ygg3kvfl2a@pd.tnic>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 8 Nov 2017 13:23:37 -0800
Message-ID: <CA+55aFwNgm9qkptXTwVbN6Krwki+zvJD1M9UiGppX+Eb1yvfoQ@mail.gmail.com>
Subject: Re: [PATCH] x86/mm: Unbreak modules that rely on external PAGE_KERNEL availability
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: Thomas Gleixner <tglx@linutronix.de>, Jiri Kosina <jikos@kernel.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Greg KH <greg@kroah.com>

On Wed, Nov 8, 2017 at 1:15 PM, Borislav Petkov <bp@suse.de> wrote:
>
> Right, AFAIRC, the main reason for this being an export was because if
> we hid it in a function, you'd have all those function calls as part of
> the _PAGE_* macros and that's just crap.

Yes, that would be worse.

I was thinking that maybe we could have a fixed "encrypt" bit in our
PTE, and then replace that "software bit" with whatever the real
hardware mask is (if any).

Because it's nasty to have these constants that _used_ to be
constants, and still _look_ like constants, suddely do stupid memory
reads from random kernel data.

So _this_ is the underflying problem:

  #define _PAGE_ENC  (_AT(pteval_t, sme_me_mask))

because that is simply not how the _PAGE_xyz macros should work!

So it should have been a fixed bit to begin with, and the dynamic part
should have been elsewhere.

The whole EXPORT_SYMBOL() thing is just a symptom of that fundamental
error. Modules - GPL or not - should _never_ have to know or care
about this _PAGE_ENC bit madness, simply because it shouldn't have
been there.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
