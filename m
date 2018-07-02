Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3A16B027D
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 16:54:41 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id s14-v6so12895464ybg.7
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 13:54:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x76-v6sor4164734ywx.457.2018.07.02.13.54.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Jul 2018 13:54:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0076b929-4785-0665-0e08-789c504f6b78@redhat.com>
References: <1530101255-13988-1-git-send-email-crecklin@redhat.com>
 <CAGXu5jLDULvf-VBhUfBXtSNaSWpq8irgg56LT3nHDft5gZg5Lw@mail.gmail.com>
 <5506a72f-99ac-b47c-4ace-86c43b17b5c5@redhat.com> <CAGXu5jL8XDYE+B=a_TBM2K8F-c3f4Jz6zcm3ggacbPNN2wCtpg@mail.gmail.com>
 <0076b929-4785-0665-0e08-789c504f6b78@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 2 Jul 2018 13:54:36 -0700
Message-ID: <CAGXu5jLXG6YKruuNc3Bnx3tuKZjNfavRwKxk-e4_-Q5mEzy5rw@mail.gmail.com>
Subject: Re: [PATCH v3] add param that allows bootline control of hardened usercopy
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris von Recklinghausen <crecklin@redhat.com>
Cc: Laura Abbott <labbott@redhat.com>, Paolo Abeni <pabeni@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On Mon, Jul 2, 2018 at 11:55 AM, Christoph von Recklinghausen
<crecklin@redhat.com> wrote:
> On 07/02/2018 02:43 PM, Kees Cook wrote:
>> On Sat, Jun 30, 2018 at 1:43 PM, Christoph von Recklinghausen
>> <crecklin@redhat.com> wrote:
>>> The last issue I'm chasing is build failures on ARCH=m68k. The error is
>>> atomic_read and friends needed by the jump label code not being found.
>>> The config has CONFIG_BROKEN_ON_SMP=y, so the jump label calls I added
>>> will only be made #ifndef CONFIG_BROKEN_ON_SMP. Do you think that's
>>> worth a mention in the blurb that's added to
>>> Documentation/admin-guide/kernel-parameters.txt?
>> Uhm, that's weird -- I think the configs on m68k need fixing then? I
>> don't want to have to sprinkle that ifdef in generic code.
>>
>> How are other users of static keys and jump labels dealing with m68k weirdness?
>>
> There's also CONFIG_JUMP_LABEL which is defined in x86_64 but not
> defined in the m68k configs. I'll use that instead. In hindsight I
> should have spotted that but didn't.

I think what I mean is that jump labels should always work. There
shouldn't be a need to #ifdef the common usercopy code. i.e.
include/linux/jump_label.h should work on all architectures already. I
see HAVE_JUMP_LABEL tests there, for example:

#if defined(CC_HAVE_ASM_GOTO) && defined(CONFIG_JUMP_LABEL)
# define HAVE_JUMP_LABEL
#endif

Other core code uses static keys without this; what is the failing combination?

-Kees

-- 
Kees Cook
Pixel Security
