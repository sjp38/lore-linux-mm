Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99ED3C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 23:29:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52ADC205C9
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 23:29:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="r6sx7bI3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52ADC205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2C7A6B0006; Tue, 27 Aug 2019 19:29:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F03F26B0008; Tue, 27 Aug 2019 19:29:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E19D86B000A; Tue, 27 Aug 2019 19:29:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0071.hostedemail.com [216.40.44.71])
	by kanga.kvack.org (Postfix) with ESMTP id BEC976B0006
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 19:29:54 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 61F37181AC9AE
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 23:29:54 +0000 (UTC)
X-FDA: 75869802708.16.skin58_566fa9e441e19
X-HE-Tag: skin58_566fa9e441e19
X-Filterd-Recvd-Size: 6193
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 23:29:53 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id i30so380017pfk.9
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 16:29:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yds4L+UJYT1pT6WHSiYBmKMudGdkG8XzlFIeiqJMzEk=;
        b=r6sx7bI3PgBNa6FxFEHKlJPtuDvELAH8de2/OFdvTmIpUrnl9yE6tEMdNBY8AEJdjS
         0PGJ5YGLrTQacEXgvnw6l4fL0Qn126PuDsaYpKEUT8b8on/A5SgC9IJVbqJaruCBkRvz
         VK0HTDQzQ4+spB3DDUcgPRMe4WRJvpTPfgehp37PP+h7Or9MQKrMC0AaltBjUoZgGQ8p
         Hk086oQ6ISZVCHizoiDx+AqYtPgz55NfVEmYa5+rFtlp2LLEdORWbUPM+If09QHLGrDe
         bSfkfKpCRerqWg7NIM3PYqXUyNgdVTmQOrQMvrKEn7/0OaPOjnEHs5o2C5yya3HxxLQg
         DA9A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=yds4L+UJYT1pT6WHSiYBmKMudGdkG8XzlFIeiqJMzEk=;
        b=VLS+MMjFpmoZJxTGDWEMm0QXXO0S82YpFgTYeMFfu+8hQbkWG9wU45PGNsXagC+6WW
         fU+NYvZCz9KAjkj0YNLVMERCKHb+ZSLHQ9aCwswcTjDuhsbp0rFmPcaazaP4ZZYhF7q4
         e352CqlkBtXtXGd+isBN+gHO0FUTl58Ep95Uu/uMpqTUOQJQTRkkQ92EiwIuz04uoDZS
         fAgoHMrmFzM+XKrLB9N4tBTWGrvmLAZ8gFJ/uAZWxnU+2DlHhbkK/r5rjbJMaJjd5Tyb
         RaPyX+UUukYz4Le6XW0aSxYc90TVrygWXPqalNdejCuxOS3Lb3f8t27EWWWUADlEzzzJ
         9zMQ==
X-Gm-Message-State: APjAAAUhyavv+Er0xJSJXN+k+nWH61aPb2dbjbDLeX3seRL/ysm8WN9L
	ewZwGWoG9JjSb523eXfRQRgx8CW1Nzm9gJ4pUXveKw==
X-Google-Smtp-Source: APXvYqx6ne4ZoU3BCMk6Y43R3NjGX+2Xnil3HjQOaE1WyLPSLxWdH2x2nH3M9xIn8QTTxUx4sUfEIAFixbKnzTKHFsA=
X-Received: by 2002:a63:60a:: with SMTP id 10mr832395pgg.381.1566948592560;
 Tue, 27 Aug 2019 16:29:52 -0700 (PDT)
MIME-Version: 1.0
References: <1566920867-27453-1-git-send-email-cai@lca.pw> <CAKwvOdmEZ6ADQyquRYmr+uNFXyZ0wpBZxNCrQnn8qaRZADzjRw@mail.gmail.com>
In-Reply-To: <CAKwvOdmEZ6ADQyquRYmr+uNFXyZ0wpBZxNCrQnn8qaRZADzjRw@mail.gmail.com>
From: Nick Desaulniers <ndesaulniers@google.com>
Date: Tue, 27 Aug 2019 16:29:41 -0700
Message-ID: <CAKwvOd=eAzohWEHhQqX8K7LDqYQJvRn=-h2q3me8uUUpyWzEBQ@mail.gmail.com>
Subject: Re: [PATCH] mm: silence -Woverride-init/initializer-overrides
To: Qian Cai <cai@lca.pw>, Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	clang-built-linux <clang-built-linux@googlegroups.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Mark Rutland <mark.rutland@arm.com>, Arnd Bergmann <arnd@arndb.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 27, 2019 at 4:25 PM Nick Desaulniers
<ndesaulniers@google.com> wrote:
>
> On Tue, Aug 27, 2019 at 8:49 AM Qian Cai <cai@lca.pw> wrote:
> >
> > When compiling a kernel with W=1, there are several of those warnings
> > due to arm64 override a field by purpose. Just disable those warnings
> > for both GCC and Clang of this file, so it will help dig "gems" hidden
> > in the W=1 warnings by reducing some noises.
> >
> > mm/init-mm.c:39:2: warning: initializer overrides prior initialization
> > of this subobject [-Winitializer-overrides]
> >         INIT_MM_CONTEXT(init_mm)
> >         ^~~~~~~~~~~~~~~~~~~~~~~~
> > ./arch/arm64/include/asm/mmu.h:133:9: note: expanded from macro
> > 'INIT_MM_CONTEXT'
> >         .pgd = init_pg_dir,
> >                ^~~~~~~~~~~
> > mm/init-mm.c:30:10: note: previous initialization is here
> >         .pgd            = swapper_pg_dir,
> >                           ^~~~~~~~~~~~~~
> >
> > Note: there is a side project trying to support explicitly allowing
> > specific initializer overrides in Clang, but there is no guarantee it
> > will happen or not.
> >
> > https://github.com/ClangBuiltLinux/linux/issues/639
> >
> > Signed-off-by: Qian Cai <cai@lca.pw>
> > ---
> >  mm/Makefile | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> > diff --git a/mm/Makefile b/mm/Makefile
> > index d0b295c3b764..5a30b8ecdc55 100644
> > --- a/mm/Makefile
> > +++ b/mm/Makefile
>
> Hi Qian, thanks for the patch.
> Rather than disable the warning outright, and bury the disabling in a
> directory specific Makefile, why not move it to W=2 in
> scripts/Makefile.extrawarn?
>
>
> I think even better would be to use pragma's to disable the warning in
> mm/init.c.  Looks like __diag support was never ported for clang yet
> from include/linux/compiler-gcc.h to include/linux/compiler-clang.h.
>
> Then you could do:
>
>  28 struct mm_struct init_mm = {
>  29   .mm_rb    = RB_ROOT,
>  30   .pgd    = swapper_pg_dir,
>  31   .mm_users = ATOMIC_INIT(2),
>  32   .mm_count = ATOMIC_INIT(1),
>  33   .mmap_sem = __RWSEM_INITIALIZER(init_mm.mmap_sem),
>  34   .page_table_lock =
> __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
>  35   .arg_lock =  __SPIN_LOCK_UNLOCKED(init_mm.arg_lock),
>  36   .mmlist   = LIST_HEAD_INIT(init_mm.mmlist),
>  37   .user_ns  = &init_user_ns,
>  38   .cpu_bitmap = { [BITS_TO_LONGS(NR_CPUS)] = 0},
> __diag_push();
> __diag_ignore(CLANG, 4, "-Winitializer-overrides")
>  39   INIT_MM_CONTEXT(init_mm)
> __diag_pop();
>  40 };
>
>
> I mean, the arm64 case is not a bug, but I worry about turning this
> warning off.  I'd expect it to only warn once during an arm64 build,
> so does the warning really detract from "W=1 gem finding?"
>
> > @@ -21,6 +21,9 @@ KCOV_INSTRUMENT_memcontrol.o := n
> >  KCOV_INSTRUMENT_mmzone.o := n
> >  KCOV_INSTRUMENT_vmstat.o := n
> >
> > +CFLAGS_init-mm.o += $(call cc-disable-warning, override-init)
>
> -Woverride-init isn't mentioned in the commit message, so not sure if
> it's meant to ride along?
>
> > +CFLAGS_init-mm.o += $(call cc-disable-warning, initializer-overrides)

That said, it's not too bad to disable it for one object file that
contains a single struct definition.

-- 
Thanks,
~Nick Desaulniers

