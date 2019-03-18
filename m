Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2188C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:59:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52CCF205F4
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:59:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="PM9OGKhX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52CCF205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8DC56B0003; Mon, 18 Mar 2019 12:59:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F0A96B0006; Mon, 18 Mar 2019 12:59:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8699E6B0007; Mon, 18 Mar 2019 12:59:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 455C76B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 12:59:17 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h15so8878931pgi.19
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 09:59:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=1qSGcK0R5KM+dkjWC/kauJx8/g6gKZLlVh+46+vQTpk=;
        b=V0BarwpgpZmJmnhrVbPF6Vv8c6JhtZ+C1tIAtXl9WmyH1wff8mdiedIW0PsbP0T0Em
         zEwZnTiIIH53+cFD7iteBu3rOJ6rQcI3sxLbrLrHfSlLsz8YqRJyqFKEY7ROB6GxdEB5
         jU8Ch0QDCURlMezpaDTRaJXNaKAKwoKoKOD1GHh7iKNj6QpyStmuLVPGT1pFdZYMcBLF
         UOnGPHZnyqNeszUEADseBBLrGJ/YalKGksB9zKLs9umSskev8O8AILAlDoBqappoJBSR
         WslaRCO3fzro8Lh34y0iTIIIf+AWnN6q0qIauADgIzORIDRbTZk0k7M42ofKY9sjCWym
         G4nA==
X-Gm-Message-State: APjAAAVtFcw382r97yoKPz+U2JPy8Au30g1RMeyK3xV2JV3IJrIkv3sa
	T6fL/eGHezMfXvIRB+TJNhHgdEJ0xnj97GS82ksws6kYozpRI7BBXYmvw+dWX9BidDVTcQl2UGA
	TK37GshiCWfY0HET5i5890N2qOb6LNP8myLRJW8Lf4XGVtWRBN1ZcRHAFQTLFJ2xaqw==
X-Received: by 2002:a63:4907:: with SMTP id w7mr11635741pga.50.1552928356947;
        Mon, 18 Mar 2019 09:59:16 -0700 (PDT)
X-Received: by 2002:a63:4907:: with SMTP id w7mr11635684pga.50.1552928356040;
        Mon, 18 Mar 2019 09:59:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552928356; cv=none;
        d=google.com; s=arc-20160816;
        b=x8s+eOcD4/kf9t8eo7GJiFowRPf69vCFhqjl6F37nRh4YfWi6Xnmp8YLs6x7UdlTvp
         rp9zYoifawK87hemc/RN5ZHKVbsUvX366s2NXx4Eypk1X0Deqck099Um6ISFWoe6kdg7
         Vw9FPRsG0fX61gK/n12YS0ccD6wD77SojdvNqB1CrUxsUJhWzc1xiDsSTYBOab2/3HxO
         7qDdRP0TS22feZ3kx915LSbGksWCf1ThPNwASQFD4tBqwF/xC24raNFOLQnDtyEzcljh
         JlsoSxHQAeHklUcKKKuWM5egW9wVaqHRSJ/ncvUquLObnrDXnSw9sMlRAoylDFLiv+2M
         otPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=1qSGcK0R5KM+dkjWC/kauJx8/g6gKZLlVh+46+vQTpk=;
        b=FQc8cT3Uw+C+R3PDx5s7DOYBkhkoNWfoA2chVegCo9UocoGyYQNc7J/HYTVerqtMbU
         SZfq6DEsfn/OAgsLauTvoHBvOI+rfjav6o5RDZkRjk46r0WZr0DT+j4fKIGjnzjEzMnT
         ueCShVR2VQgBKQhHxTy53xMjTbg02uekImmuiwZ1m5ugo2VqN/m5DKxZgjgKYFmXSQXu
         8bjR4/EciPnBlmCn6GqTm8D7nTsveWsnpdEgu/jJTuYJci5A1/5B+6pokah0p+63XzLc
         CVOiecGuyfYJmJjRQYXyxm8cSRGGtzrhDOxZh9XpocAA0NfAEcCbhIKefqzV13dmau7e
         8oZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PM9OGKhX;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w20sor16111242pll.13.2019.03.18.09.59.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 09:59:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PM9OGKhX;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=1qSGcK0R5KM+dkjWC/kauJx8/g6gKZLlVh+46+vQTpk=;
        b=PM9OGKhXVFOScoA0U0eJfjlATm68hBokDH3xW76dl2UrhKuLtWfcahYPG5tZzJpWHy
         qPRj7SaRW915MTLp3nmMfjCTbwM9k49VLoIXbp7+HUtgJEDn41oJRmFHkmNkl0nGtUoV
         uL6n5VvrW/nx/l25G3MiK/Y64jrg/oh9SDiXRheAs6X+GRPwJ/gs16ooPLZIU4YLCmlF
         cuz29jZ/UPZ9B4rkBDhhfIYLxO4XIPmsS9g8nQNx0IIiabynJxMZ0OMey+jIZbTbZxlh
         G7oAucvMP+3PhykgPsXecAODKhmrvPM7d48t1eWOqIDKXZrebPqEJ53C0aOsLnrMiwEC
         GWyg==
X-Google-Smtp-Source: APXvYqw/WB6apBZfCC4Z3gtQWYzVAj6LMOzybqti6+WMrkpj4eKj2bUipEWmGt4Rw1lWbJw06V7FSeVN09pOsBX0P44=
X-Received: by 2002:a17:902:8203:: with SMTP id x3mr20736629pln.159.1552928355544;
 Mon, 18 Mar 2019 09:59:15 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com> <bf0abceeaf32e6b9cdbc9dde45cc5966b5747ec4.1552679409.git.andreyknvl@google.com>
 <81bc3110-b638-4545-1270-26baec3d59e7@arm.com>
In-Reply-To: <81bc3110-b638-4545-1270-26baec3d59e7@arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 18 Mar 2019 17:59:04 +0100
Message-ID: <CAAeHK+yrAPOyuEyLCygrwQxCztb8P-9BBj-6RP6=iG-GGBkkQw@mail.gmail.com>
Subject: Re: [PATCH v11 13/14] arm64: update Documentation/arm64/tagged-pointers.txt
To: Kevin Brodsky <kevin.brodsky@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	netdev <netdev@vger.kernel.org>, bpf <bpf@vger.kernel.org>, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 18, 2019 at 2:26 PM Kevin Brodsky <kevin.brodsky@arm.com> wrote:
>
> On 15/03/2019 19:51, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > Document the ABI changes in Documentation/arm64/tagged-pointers.txt.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >   Documentation/arm64/tagged-pointers.txt | 18 ++++++++----------
> >   1 file changed, 8 insertions(+), 10 deletions(-)
> >
> > diff --git a/Documentation/arm64/tagged-pointers.txt b/Documentation/arm64/tagged-pointers.txt
> > index a25a99e82bb1..07fdddeacad0 100644
> > --- a/Documentation/arm64/tagged-pointers.txt
> > +++ b/Documentation/arm64/tagged-pointers.txt
> > @@ -17,13 +17,15 @@ this byte for application use.
> >   Passing tagged addresses to the kernel
> >   --------------------------------------
> >
> > -All interpretation of userspace memory addresses by the kernel assumes
> > -an address tag of 0x00.
> > +The kernel supports tags in pointer arguments (including pointers in
> > +structures) of syscalls, however such pointers must point to memory ranges
> > +obtained by anonymous mmap() or brk().
> >
> > -This includes, but is not limited to, addresses found in:
> > +The kernel supports tags in user fault addresses. However the fault_address
> > +field in the sigcontext struct will contain an untagged address.
> >
> > - - pointer arguments to system calls, including pointers in structures
> > -   passed to system calls,
> > +All other interpretations of userspace memory addresses by the kernel
> > +assume an address tag of 0x00, in particular:
> >
> >    - the stack pointer (sp), e.g. when interpreting it to deliver a
> >      signal,
> > @@ -33,11 +35,7 @@ This includes, but is not limited to, addresses found in:
> >
> >   Using non-zero address tags in any of these locations may result in an
> >   error code being returned, a (fatal) signal being raised, or other modes
> > -of failure.
> > -
> > -For these reasons, passing non-zero address tags to the kernel via
> > -system calls is forbidden, and using a non-zero address tag for sp is
> > -strongly discouraged.
> > +of failure. Using a non-zero address tag for sp is strongly discouraged.
>
> I don't understand why we should keep such a limitation. For MTE, tagging SP is
> something we are definitely considering. This does bother userspace software in some
> rare cases, but I'm not sure in what way it bothers the kernel.

I don't mind allowing tagged sp as well, but it seems that it's
another ABI relaxation that needs to be handled separately. I'm not
sure if we want to include that into this patchset, which is supposed
to allow tagged pointers to be passed to syscalls.

>
> Kevin
>
> >
> >   Programs maintaining a frame pointer and frame records that use non-zero
> >   address tags may suffer impaired or inaccurate debug and profiling
>

