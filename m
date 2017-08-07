Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8A96B02FA
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 14:57:15 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t18so965428oih.11
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:57:15 -0700 (PDT)
Received: from mail-io0-x235.google.com (mail-io0-x235.google.com. [2607:f8b0:4001:c06::235])
        by mx.google.com with ESMTPS id s67si5509320oig.379.2017.08.07.11.57.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 11:57:14 -0700 (PDT)
Received: by mail-io0-x235.google.com with SMTP id g71so5809488ioe.5
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:57:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFKCwrgp6HDdNJoAUwVdg7szJhZSj26NXF38UOJpp7tWxoXZUg@mail.gmail.com>
References: <CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
 <CAGXu5jJhFt8JNFRnB-oiGjNy=Auo4bGx=i=DDtCa__20acANBQ@mail.gmail.com>
 <CAN=P9pj_jbTgGoiECmu-b=s+NOL6uTkPbXDueXLhs8C6PVbLHg@mail.gmail.com>
 <CAFKCwrjkonmdZ+WC9Vt_xSBgWrJLtQCN812fyxroNNpA-x4TZg@mail.gmail.com>
 <CAGXu5j+dF_2QENUfKB9qTKBgU1V9QEWnXHAaE+66rPw+cAFTYA@mail.gmail.com> <CAFKCwrgp6HDdNJoAUwVdg7szJhZSj26NXF38UOJpp7tWxoXZUg@mail.gmail.com>
From: Kees Cook <keescook@google.com>
Date: Mon, 7 Aug 2017 11:57:13 -0700
Message-ID: <CAGXu5jLrsVLoG-Q8dd=UNJqpNPi90nJqcFPGB4G6fM9U1XLxeQ@mail.gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Evgenii Stepanov <eugenis@google.com>
Cc: Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Micay <danielmicay@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>

On Mon, Aug 7, 2017 at 11:51 AM, Evgenii Stepanov <eugenis@google.com> wrote:
> On Mon, Aug 7, 2017 at 11:40 AM, Kees Cook <keescook@google.com> wrote:
>> On Mon, Aug 7, 2017 at 11:36 AM, Evgenii Stepanov <eugenis@google.com> wrote:
>>> MSan is 64-bit only and does not allow any mappings _outside_ of these regions:
>>> 000000000000 - 010000000000 app-1
>>> 510000000000 - 600000000000 app-2
>>> 700000000000 - 800000000000 app-3
>>>
>>> https://github.com/google/sanitizers/issues/579
>>>
>>> It sounds like the ELF_ET_DYN_BASE change should not break MSan.
>>
>> Hah, so the proposed move to 0x1000 8000 0000 for ASan would break
>> MSan. Lovely! :P
>
> That's unfortunate.
> This will not help existing binaries, but going forward the mapping
> can be adjusted at runtime to anything like
> 000000000000 .. A
> 500000000000 + A .. 600000000000
> 700000000000 .. 800000000000
> i.e. we can look at where the binary is mapped and set A to anything
> in the range of [0, 1000 0000 0000). That's still not compatible with
> 0x1000 8000 0000 though.

So A is considered to be < 0x1000 0000 0000? And a future MSan could
handle a PIE base of 0x2000 0000 0000? If ASan an TSan can handle that
too, then we could use that as the future PIE base. Existing systems
will need some sort of reversion.

The primary concerns with the CVEs fixed with the PIE base commit was
for 32-bit. While it is possible to collide on 64-bit, it is much more
rare. As long as we have no problems with the new 32-bit PIE base, we
can revert the 64-bit base default back to 0x5555 5555 4000.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
