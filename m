Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 71D856B028C
	for <linux-mm@kvack.org>; Tue,  8 May 2018 10:50:15 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id c8so8848454uae.5
        for <linux-mm@kvack.org>; Tue, 08 May 2018 07:50:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s66-v6sor11067316vkg.224.2018.05.08.07.50.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 07:50:14 -0700 (PDT)
MIME-Version: 1.0
References: <20180508121638.174022-1-glider@google.com> <1f69bdb6-df5e-d709-064a-4f6fdd6e11a7@linux.intel.com>
In-Reply-To: <1f69bdb6-df5e-d709-064a-4f6fdd6e11a7@linux.intel.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 08 May 2018 14:50:02 +0000
Message-ID: <CAG_fn=Xv74c80swzFjKyybQpRj7Qj9K1NVH-D6gcxcYEoUJ1xA@mail.gmail.com>
Subject: Re: [PATCH] x86/boot/64/clang: Use fixup_pointer() to access '__supported_pte_mask'
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@linux.intel.com
Cc: Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Matthias Kaehlcke <mka@chromium.org>, Dmitriy Vyukov <dvyukov@google.com>, Michael Davidson <md@google.com>

On Tue, May 8, 2018 at 4:30 PM Dave Hansen <dave.hansen@linux.intel.com>
wrote:

> On 05/08/2018 05:16 AM, Alexander Potapenko wrote:
> > Similarly to commit 187e91fe5e91
> > ("x86/boot/64/clang: Use fixup_pointer() to access 'next_early_pgt'"),
> > '__supported_pte_mask' must be also accessed using fixup_pointer() to
> > avoid position-dependent relocations.
> >
> > Signed-off-by: Alexander Potapenko <glider@google.com>
> > Fixes: fb43d6cb91ef ("x86/mm: Do not auto-massage page protections")

> In the interests of standalone changelogs, I'd really appreciate an
> actual explanation of what's going on here.  Your patch makes the code
> uglier and doesn't fix anything functional from what I can see.
You're right, sure. I'll send a patch with an updated description.

> The other commit has some explanation, so it seems like the rules for
> accessing globals in head64.c are different than other files because...
> something.
The problem as far as I understand it is that the code in __startup_64()
can be relocated during execution, but the compiler doesn't have to
generate PC-relative relocations when accessing globals from that function.

> The functional problem here is that it causes insta-reboots?
True.

> Do we have anything we can do to keep us from recreating these kinds of
> regressions all the time?
I'm not really aware of the possible options in the kernel land. Looks like
a task for some objtool-like utility?
As long as these regressions are caught with Clang, setting up a 0day Clang
builder might help.
At least I should've added a comment regarding this to __startup_64() last
time.



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
