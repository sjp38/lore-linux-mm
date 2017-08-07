Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 38F0F6B02F3
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 14:51:23 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id p62so940821oih.12
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:51:23 -0700 (PDT)
Received: from mail-io0-x22d.google.com (mail-io0-x22d.google.com. [2607:f8b0:4001:c06::22d])
        by mx.google.com with ESMTPS id d64si4993940oig.39.2017.08.07.11.51.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 11:51:22 -0700 (PDT)
Received: by mail-io0-x22d.google.com with SMTP id c74so5776257iod.4
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:51:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+dF_2QENUfKB9qTKBgU1V9QEWnXHAaE+66rPw+cAFTYA@mail.gmail.com>
References: <CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
 <CAGXu5jJhFt8JNFRnB-oiGjNy=Auo4bGx=i=DDtCa__20acANBQ@mail.gmail.com>
 <CAN=P9pj_jbTgGoiECmu-b=s+NOL6uTkPbXDueXLhs8C6PVbLHg@mail.gmail.com>
 <CAFKCwrjkonmdZ+WC9Vt_xSBgWrJLtQCN812fyxroNNpA-x4TZg@mail.gmail.com> <CAGXu5j+dF_2QENUfKB9qTKBgU1V9QEWnXHAaE+66rPw+cAFTYA@mail.gmail.com>
From: Evgenii Stepanov <eugenis@google.com>
Date: Mon, 7 Aug 2017 11:51:20 -0700
Message-ID: <CAFKCwrgp6HDdNJoAUwVdg7szJhZSj26NXF38UOJpp7tWxoXZUg@mail.gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Micay <danielmicay@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>

On Mon, Aug 7, 2017 at 11:40 AM, Kees Cook <keescook@google.com> wrote:
> On Mon, Aug 7, 2017 at 11:36 AM, Evgenii Stepanov <eugenis@google.com> wrote:
>> MSan is 64-bit only and does not allow any mappings _outside_ of these regions:
>> 000000000000 - 010000000000 app-1
>> 510000000000 - 600000000000 app-2
>> 700000000000 - 800000000000 app-3
>>
>> https://github.com/google/sanitizers/issues/579
>>
>> It sounds like the ELF_ET_DYN_BASE change should not break MSan.
>
> Hah, so the proposed move to 0x1000 8000 0000 for ASan would break
> MSan. Lovely! :P

That's unfortunate.
This will not help existing binaries, but going forward the mapping
can be adjusted at runtime to anything like
000000000000 .. A
500000000000 + A .. 600000000000
700000000000 .. 800000000000
i.e. we can look at where the binary is mapped and set A to anything
in the range of [0, 1000 0000 0000). That's still not compatible with
0x1000 8000 0000 though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
