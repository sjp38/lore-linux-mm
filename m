Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6663F44043C
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 16:46:26 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id 72so6842678itl.1
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 13:46:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d93sor2417086ioj.39.2017.11.08.13.46.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Nov 2017 13:46:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwNgm9qkptXTwVbN6Krwki+zvJD1M9UiGppX+Eb1yvfoQ@mail.gmail.com>
References: <nycvar.YFH.7.76.1711082103320.6470@cbobk.fhfr.pm>
 <alpine.DEB.2.20.1711082133410.1962@nanos> <CA+55aFz5Z8dfLp1swfOaEomH21mvCFEy=4w6L0cWska=He45FQ@mail.gmail.com>
 <20171108211525.4kxwj5ygg3kvfl2a@pd.tnic> <CA+55aFwNgm9qkptXTwVbN6Krwki+zvJD1M9UiGppX+Eb1yvfoQ@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 8 Nov 2017 13:46:24 -0800
Message-ID: <CA+55aFxik=Z+aSvQd8jqy3uO58G_2X+kWV_DWH1jgRGveOkz3Q@mail.gmail.com>
Subject: Re: [PATCH] x86/mm: Unbreak modules that rely on external PAGE_KERNEL availability
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: Thomas Gleixner <tglx@linutronix.de>, Jiri Kosina <jikos@kernel.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Greg KH <greg@kroah.com>

On Wed, Nov 8, 2017 at 1:23 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So _this_ is the underlying problem:
>
>   #define _PAGE_ENC  (_AT(pteval_t, sme_me_mask))
>
> because that is simply not how the _PAGE_xyz macros should work!
>
> So it should have been a fixed bit to begin with, and the dynamic part
> should have been elsewhere.

Hmm. It's not an entirely new problem. We have that
"cachemode2protval()" thing, which causes he exact same thing, except
it accesses the __cachemode2pte_tbl[] array instead.

Which we also EXPORT_SYMBOL().

So I guess _PAGE_ENC isn't any worse than what we already had.

Of course, that at least doesn't trigger for the simple cases - only
_PAGE_CACHE_WP and _PAGE_NOCACHE end up triggering that
"cachemode2protval()" case.

I do wonder if we could perhaps at least try to unify these things a
bit, and export just one thing.

And maybe avoid accessing two completely different memory locasions
every time we use _PAGE_KERNEL or whatever.

But it all looks rather nasty, so for 4.14 clearly I should just apply
that trivial one-liner patch for now.

           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
