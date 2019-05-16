Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EECBFC04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 16:42:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D7BA205ED
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 16:42:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Okxi5lkW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D7BA205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3355D6B0007; Thu, 16 May 2019 12:42:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E58A6B0008; Thu, 16 May 2019 12:42:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D58B6B000A; Thu, 16 May 2019 12:42:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id E5A326B0007
	for <linux-mm@kvack.org>; Thu, 16 May 2019 12:42:50 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id f5so799377vsq.15
        for <linux-mm@kvack.org>; Thu, 16 May 2019 09:42:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=qGP3s0Ih6OqVOl4yoE5OjhGMu8j59fK2Yi9/glM9Xrw=;
        b=I1OeT0e6qNdBb+TqdaA/f0AOtxpHhhw7F7v6Ci0xjRzNsQit296JWj5nbrEbyldVIT
         2N9uj0NDGJZgBrXbvpF9PMHneMuddEZQdQz7FIcxv7TpiztJ5urmV8acj/jJgrdblbgb
         YKRloAwuY1fZQi43q13FH3y22Er862Dk0mlB7Nmi1o9CzJ+Tktv+SVu95b1qa0jUG5+L
         y6OhX/QUM8wXLagnhgHGzJWyixTqnArAFpPeZ/CNp5nGd6YHdmpUhcHkDMyqFbvjMbJF
         eluuqGKW5jRh5IqWLHym5JC0JN3QOqfxxuhLLBMoVgNM7L1T4/is4hYgz+Sh4qK5gxoQ
         QKCw==
X-Gm-Message-State: APjAAAV2IAvxWvfV/Pm3Lwc1PMRRxoVI1CtBosCHdFgWdBuA9zZ4S0uS
	8/6kMt6P+BDgtOZKaUyPiEXaVtWdJ+wy7GrbgQP6P1VBAzIJE81f1fqJZmm2b1B9unx9Rsixi4O
	OYStAk/1q9Woqd3diWSDHc+iMmDA+MwzLpipSUfaneuGAyo4X04AfGJ9kngfJ/MyCQw==
X-Received: by 2002:ab0:740d:: with SMTP id r13mr22610171uap.44.1558024970545;
        Thu, 16 May 2019 09:42:50 -0700 (PDT)
X-Received: by 2002:ab0:740d:: with SMTP id r13mr22610138uap.44.1558024969876;
        Thu, 16 May 2019 09:42:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558024969; cv=none;
        d=google.com; s=arc-20160816;
        b=NWL81QDV0VsO/X5r5leQmI7BUPwmi3qwDOhoF8bY0i9ryoJvsJlTS65SJGcJFlWuWO
         KGRie9lodbGfQQaFUpC6YK6MApT2pZ7Yc2i/CQ96d6BbMvcvSoMaurvjjXDOJvIpK7MA
         qFQ9w67vQtXlUV9WttnLm3QyBIWnCsmivYwn92pcagF/TWC5fXL1ME2p5bjL8nc5ldt9
         lKphI4NB9HvfrJwRE5CkNNUjcW+cWtDSTtCbLg5fUzTfOjdIlPXezu9yP5qf1atGZiXF
         NbBpJCfytbqPq16pkdM+wXzFHbUNu9nsJzHGolzYTiaFLpgVTaW2YHfhHzhe0UByn4EQ
         iuKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=qGP3s0Ih6OqVOl4yoE5OjhGMu8j59fK2Yi9/glM9Xrw=;
        b=rb98rYe2IyNZPPdqTESN/MCNT/VQbPq7YWrKCD7T8Q9Pg6DIBDvHNlILRaWvG6GjPo
         UNyaS7A41S2LB/Nb7DKn/vf7SPzimelbubtq6/dC4qyS54TFAa7F1SyMz+Nf8P/9a9r0
         Nm4T2vDpMZHZmnCCSKI/oElFqoXloV6+jdU1/76ykWzzQpcmOZb7NF0B70qaanja5KxE
         WttauLRV2Q4KZXdd4JS65oPsc8Mjtx6uym3nBC/5FEEE92+VETpwY+YjwKgSftg4TcAD
         /4lYCvzeK6jsaUAO7qDOdAcNy3V8KrdEVL5SsSwC/3TXMohf9CswscSlCal+D9lUDTOv
         bJ8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Okxi5lkW;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v35sor12019541uad.68.2019.05.16.09.42.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 09:42:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Okxi5lkW;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=qGP3s0Ih6OqVOl4yoE5OjhGMu8j59fK2Yi9/glM9Xrw=;
        b=Okxi5lkWUzIdKTINNYUM9x0CnMaOx+4nMm60iubKUC2qCx6xrcp+TpF7VhW0Fisia6
         F0nxNliuFmYXNy3jH/xpwkRoe1hzGWV9CqMzTYNwzraz5N2DueWrpxTEAf82+p1DoA9v
         W7HoBYmrAbuLZJaDIXah0OnRhmBrTDImi1h/vpZe7aomuRRUQhT+21d3qJFMmoGOHGEf
         g/B+yNhFTjBlOi6JP8Arm/xbaNfqiKOALKh2nOYaulXmSpF5zKSdQEmkXWfFFY4ULB68
         Y9Z0a/sxvRghtt+6NzvOiV00D0R8jsBlQzQv5g2tIyt5mrGvwv4P8hjZwAXpWnodcN10
         bJng==
X-Google-Smtp-Source: APXvYqy1VuDI7sbqIeBSUq7vxcBjJYXZpt3wUC0XAgfrB4Epp7KDM4s3DQdaAV9PG0f2kxYun1qfBmQzNSJDtinvt9w=
X-Received: by 2002:ab0:29cc:: with SMTP id i12mr16086901uaq.12.1558024969202;
 Thu, 16 May 2019 09:42:49 -0700 (PDT)
MIME-Version: 1.0
References: <20190514143537.10435-1-glider@google.com> <20190514143537.10435-2-glider@google.com>
 <201905160907.92FAC880@keescook>
In-Reply-To: <201905160907.92FAC880@keescook>
From: Alexander Potapenko <glider@google.com>
Date: Thu, 16 May 2019 18:42:37 +0200
Message-ID: <CAG_fn=VsJmyuEUYy16R_M5Hu2CX-PJkz9Kw4rdy9XUCAYHwV5g@mail.gmail.com>
Subject: Re: [PATCH v2 1/4] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, James Morris <jmorris@namei.org>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>, Linux Memory Management List <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Kees Cook <keescook@chromium.org>
Date: Thu, May 16, 2019 at 6:20 PM
To: Alexander Potapenko
Cc: <akpm@linux-foundation.org>, <cl@linux.com>,
<kernel-hardening@lists.openwall.com>, Masahiro Yamada, James Morris,
Serge E. Hallyn, Nick Desaulniers, Kostya Serebryany, Dmitry Vyukov,
Sandeep Patil, Laura Abbott, Randy Dunlap, Jann Horn, Mark Rutland,
<linux-mm@kvack.org>, <linux-security-module@vger.kernel.org>

> On Tue, May 14, 2019 at 04:35:34PM +0200, Alexander Potapenko wrote:
> > Slowdown for the new features compared to init_on_free=3D0,
> > init_on_alloc=3D0:
> >
> > hackbench, init_on_free=3D1:  +7.62% sys time (st.err 0.74%)
> > hackbench, init_on_alloc=3D1: +7.75% sys time (st.err 2.14%)
>
> I wonder if the patch series should be reorganized to introduce
> __GFP_NO_AUTOINIT first, so that when the commit with benchmarks appears,
> we get the "final" numbers...
>
> > Linux build with -j12, init_on_free=3D1:  +8.38% wall time (st.err 0.39=
%)
> > Linux build with -j12, init_on_free=3D1:  +24.42% sys time (st.err 0.52=
%)
> > Linux build with -j12, init_on_alloc=3D1: -0.13% wall time (st.err 0.42=
%)
> > Linux build with -j12, init_on_alloc=3D1: +0.57% sys time (st.err 0.40%=
)
>
> I'm working on reproducing these benchmarks. I'd really like to narrow
> down the +24% number here. But it does
I suspect the slowdown of init_on_free is bigger than that of
PAX_SANITIZE_MEMORY, as we've set the goal to have fully zeroed memory
at alloc time.
If we want a mode that only wipes the user data upon free() but
doesn't eliminate all uninit memory, then we can make it faster.
> > The slowdown for init_on_free=3D0, init_on_alloc=3D0 compared to the
> > baseline is within the standard error.
>
> I think the use of static keys here is really great: this is available
> by default for anyone that wants to turn it on.
>
> I'm thinking, given the configuable nature of this, it'd be worth adding
> a little more detail at boot time. I think maybe a separate patch could
> be added to describe the kernel's memory auto-initialization features,
> and add something like this to mm_init():
>
> +void __init report_meminit(void)
> +{
> +       const char *stack;
> +
> +       if (IS_ENABLED(CONFIG_INIT_STACK_ALL))
> +               stack =3D "all";
> +       else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL))
> +               stack =3D "byref_all";
> +       else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF))
> +               stack =3D "byref";
> +       else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_USER))
> +               stack =3D "__user";
> +       else
> +               stack =3D "off";
> +
> +       /* Report memory auto-initialization states for this boot. */
> +       pr_info("mem auto-init: stack:%s, heap alloc:%s, heap free:%s\n",
> +               stack, want_init_on_alloc(GFP_KERNEL) ? "on" : "off",
> +               want_init_on_free() ? "on" : "off");
> +}
>
> To get a boot line like:
>
>         mem auto-init: stack:off, heap alloc:off, heap free:on
For stack there's no binary on/off, as you can potentially build half
of the kernel with stack instrumentation and another half without it.
We could make the instrumentation insert a static global flag into
each translation unit, but this won't give us any interesting info.

> And one other thought I had was that in the init_on_free=3D1 case, there =
is
> a large pause at boot while memory is being cleared. I think it'd be hand=
y
> to include a comment about that, just to keep people from being surprised=
:
>
> diff --git a/init/main.c b/init/main.c
> index cf0c3948ce0e..aea278392338 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -529,6 +529,8 @@ static void __init mm_init(void)
>          * bigger than MAX_ORDER unless SPARSEMEM.
>          */
>         page_ext_init_flatmem();
> +       if (want_init_on_free())
> +               pr_info("Clearing system memory ...\n");
>         mem_init();
>         kmem_cache_init();
>         pgtable_init();
>
> Beyond these thoughts, I think this series is in good shape.
>
> Andrew (or anyone else) do you have any concerns about this?
>
> --
> Kees Cook



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

