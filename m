Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7F78C43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 10:04:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3996B2082F
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 10:04:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="TF2ylQHQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3996B2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 852798E0003; Wed, 16 Jan 2019 05:04:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DB108E0002; Wed, 16 Jan 2019 05:04:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A4628E0003; Wed, 16 Jan 2019 05:04:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3F8D48E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 05:04:05 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id w15so1366797ita.1
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 02:04:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=1rZmRkYrQKk3sCyEFFu33/UQOzqgS6+8CGeODCvYF/s=;
        b=J0+/Yl2Jip7SPLZktF1lLJRXATx4sXYriK6lstfOQ5wW4ZocrLz1bxOCyadYSmPp7O
         roh4JW7ZEwqpf3wgcmSumYt5rbiUASkhhZRtGtrihM65NHiFZDwaALs4cbcvlrDg4CwC
         J7Sf8jg+cCxmJVlRa49bCQLM0LKTvq5GmR6qEcMB3xeayFmXxJsLR5OtdUMrs3nPot8o
         gs0EXv03ZBx53NpdITmpmTFoVkZGw+F3PzqM/wFWcE87Ww4PtG6URPft5KkSrzkOVmZj
         3p0u9re13rpjofdzbVKjcFrgMbMPlY1YzRxq9iem4NFl8ul3iQRavIubAIQJRwFbGFNc
         tU8w==
X-Gm-Message-State: AJcUukdIwp5jz5X5Phqya9sF20tfhSxZQOmDj26gIRs9T1SpIYpvs0+c
	efhibBAlITLnXZg3T60bHzQ/+i5aKFb7tnSlyYc2lv7Dkxm2mqlSTqKssdQmbQ86mV28O0JIZuX
	1T35f3CRAeuglmCj2+dBYrJz0TotUO/SLrJP2wdeUYiZlRZSfVhuPWCFC4ZIAj9i2S999a73ELR
	Dy7BDmywjavCS+GMfMAEcJXhUEtp1+CnH8bQ37MMwNMGK8eK6c9aOd95CP7THAhoelzwMpTu4jA
	3AZkIcQmIusagg3G7MxOMNW3ARa7rx7tF5OwV0ATP1u8V/vX34YVstX46JLJGvrFYosEp+lfsVP
	Ih5fjdj+ULW2WkiXTY1gxWVW7hOD3HyUazBq0cMjChE74TqmqBbU0REHIjcApW37SdjRbz4BItN
	N
X-Received: by 2002:a24:e44:: with SMTP id 65mr4467946ite.154.1547633044858;
        Wed, 16 Jan 2019 02:04:04 -0800 (PST)
X-Received: by 2002:a24:e44:: with SMTP id 65mr4467921ite.154.1547633043856;
        Wed, 16 Jan 2019 02:04:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547633043; cv=none;
        d=google.com; s=arc-20160816;
        b=LtHoIBqO0nfMXVL/U26KWrptsxaCOsD0ob8rP0qawidX0CY9G0nAd+dHUmwFnTMvAT
         hEP8QHVvChE/iQu3YRPo2NEnoJFyQiIfT+Wg0ssL8f/Dsgah1Tn76W2gpgiyzR/Cc6fp
         QEvQgHmcL0TuiprYzQoVDWGPVyHS35z8vVCfYLE06BPhHcdyx+eSo+X4xE0amq+dngRE
         Rd0P/Nc/Dzb6c+7xiZ69XugHlITe4h0bxveSdJ5XjjmyrI43N/1VgNGAXPoSd9ijqiO0
         Olh31t9sDH35Sj7Ro5k85wT0+a07lgWPhN2B7wQMHnyCIAMC5Fd96o0wUk7v/fiLlrS4
         K3hA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=1rZmRkYrQKk3sCyEFFu33/UQOzqgS6+8CGeODCvYF/s=;
        b=SXN80fWomj4Waz392TO6i/cw0y0JU780ZJuiuIka/V1vi40FvRotjQETxaRn83Xpvp
         VzE8EJczN8K8asvf+zuC7vI1FmaCjcqeCZ7JKZ4Q/gqoa3zLB/vtcW0ZhlSSDYqvda/s
         T9LSoamK/ciL2YfRKtURiK3g+bu8vFvmVNDHVhR2rb4UpHULy9mF3wr8f9br0w/17784
         gWJAoqMGdO1GxgmFUA32afptmH+s8HoW931pTGtstECRvBX4BNi58hPutqcDTKn8hSgL
         7VLA85XFtFfOjSLgHJx3O4dJTMxpn/8GDIVU6VqGWRADbHy9GFhMDPHCRo4DigKfhelN
         Bt7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TF2ylQHQ;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b82sor9647599itb.10.2019.01.16.02.04.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 02:04:03 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TF2ylQHQ;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=1rZmRkYrQKk3sCyEFFu33/UQOzqgS6+8CGeODCvYF/s=;
        b=TF2ylQHQEd5iJSoMu3xW3NRRnQg0nLYymB0YSGlvJyLWjfZEN+1R0SvUAjR3hr3gov
         LE3Bys85UGMon+7lUvmZdB4Zy3zB+9SjOk7TNeynbZX9KgegPPTlSKEJqGFU4eNJBF+E
         0ND+IccUodxtSVBIrEQGYOW+x96X97fHNmyidOlv2zX5EpV5ZdOYtNYmhdHXrmJb0fyk
         iCG4MFql60DSCyCy3ylU1QIrIgfd9DZ9gLwxwh1qEwmpricyEPND87Pk3d3N1Y82cB6f
         mgX3egvRkAQiTqalnc/71+66GrUv9OKvfNVfl7rPqYCPrDSicoMogDMj+b+UN6sVOoez
         xMpA==
X-Google-Smtp-Source: ALg8bN6OfhZJYhHBs6jSF+6r2V38ZHVwZbvkgMhXsfwfH93O7RWmpMbG6jFEQjktwPrJ6siIxoaEwAd7AdV06eEQVpU=
X-Received: by 2002:a24:6511:: with SMTP id u17mr5175695itb.12.1547633043176;
 Wed, 16 Jan 2019 02:04:03 -0800 (PST)
MIME-Version: 1.0
References: <cover.1547289808.git.christophe.leroy@c-s.fr> <0c854dd6b110ac2b81ef1681f6e097f59f84af8b.1547289808.git.christophe.leroy@c-s.fr>
 <CACT4Y+aEsLWqhJmXETNsGtKdbfHDFL1NF8ofv3KwvQPraXdFyw@mail.gmail.com>
 <801c7d58-417d-1e65-68a0-b8cf02f9f956@c-s.fr> <CACT4Y+ZdA-w5OeebZg3PYPB+BX5wDxw_DxNe2==VJfbpy2eJ7A@mail.gmail.com>
 <330696c0-90c6-27de-5eb3-4da2159fdfbc@virtuozzo.com> <CACT4Y+ajgTdDyFFWCp0oRSPKZh9ercDpq3pAq2-ZSx7ouAvZYQ@mail.gmail.com>
 <301f5826-64ab-1cf4-7e7e-cd026de77bca@c-s.fr>
In-Reply-To: <301f5826-64ab-1cf4-7e7e-cd026de77bca@c-s.fr>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 16 Jan 2019 11:03:51 +0100
Message-ID:
 <CACT4Y+aPsrfaY94tiYGwAUifeLJK3gobMk2Cq=6s_29RWvFZ3g@mail.gmail.com>
Subject: Re: [PATCH v3 1/3] powerpc/mm: prepare kernel for KAsan on PPC32
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Alexander Potapenko <glider@google.com>, 
	LKML <linux-kernel@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org, 
	kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116100351.EU18noFNIEEIstfkIK5DqRza4riT6HgURPDHdBn1-AI@z>

On Tue, Jan 15, 2019 at 6:25 PM Christophe Leroy
<christophe.leroy@c-s.fr> wrote:
>
> Le 15/01/2019 =C3=A0 18:10, Dmitry Vyukov a =C3=A9crit :
> > On Tue, Jan 15, 2019 at 6:06 PM Andrey Ryabinin <aryabinin@virtuozzo.co=
m> wrote:
> >>
> >> On 1/15/19 2:14 PM, Dmitry Vyukov wrote:
> >>> On Tue, Jan 15, 2019 at 8:27 AM Christophe Leroy
> >>> <christophe.leroy@c-s.fr> wrote:
> >>>> On 01/14/2019 09:34 AM, Dmitry Vyukov wrote:
> >>>>> On Sat, Jan 12, 2019 at 12:16 PM Christophe Leroy
> >>>>> <christophe.leroy@c-s.fr> wrote:
> >>>>> &gt;
> >>>>> &gt; In kernel/cputable.c, explicitly use memcpy() in order
> >>>>> &gt; to allow GCC to replace it with __memcpy() when KASAN is
> >>>>> &gt; selected.
> >>>>> &gt;
> >>>>> &gt; Since commit 400c47d81ca38 ("powerpc32: memset: only use dcbz =
once cache is
> >>>>> &gt; enabled"), memset() can be used before activation of the cache=
,
> >>>>> &gt; so no need to use memset_io() for zeroing the BSS.
> >>>>> &gt;
> >>>>> &gt; Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> >>>>> &gt; ---
> >>>>> &gt;  arch/powerpc/kernel/cputable.c | 4 ++--
> >>>>> &gt;  arch/powerpc/kernel/setup_32.c | 6 ++----
> >>>>> &gt;  2 files changed, 4 insertions(+), 6 deletions(-)
> >>>>> &gt;
> >>>>> &gt; diff --git a/arch/powerpc/kernel/cputable.c
> >>>>> b/arch/powerpc/kernel/cputable.c
> >>>>> &gt; index 1eab54bc6ee9..84814c8d1bcb 100644
> >>>>> &gt; --- a/arch/powerpc/kernel/cputable.c
> >>>>> &gt; +++ b/arch/powerpc/kernel/cputable.c
> >>>>> &gt; @@ -2147,7 +2147,7 @@ void __init set_cur_cpu_spec(struct cpu_=
spec *s)
> >>>>> &gt;         struct cpu_spec *t =3D &amp;the_cpu_spec;
> >>>>> &gt;
> >>>>> &gt;         t =3D PTRRELOC(t);
> >>>>> &gt; -       *t =3D *s;
> >>>>> &gt; +       memcpy(t, s, sizeof(*t));
> >>>>>
> >>>>> Hi Christophe,
> >>>>>
> >>>>> I understand why you are doing this, but this looks a bit fragile a=
nd
> >>>>> non-scalable. This may not work with the next version of compiler,
> >>>>> just different than yours version of compiler, clang, etc.
> >>>>
> >>>> My felling would be that this change makes it more solid.
> >>>>
> >>>> My understanding is that when you do *t =3D *s, the compiler can use
> >>>> whatever way it wants to do the copy.
> >>>> When you do memcpy(), you ensure it will do it that way and not anot=
her
> >>>> way, don't you ?
> >>>
> >>> It makes this single line more deterministic wrt code-gen (though,
> >>> strictly saying compiler can turn memcpy back into inlines
> >>> instructions, it knows memcpy semantics anyway).
> >>> But the problem I meant is that the set of places that are subject to
> >>> this problem is not deterministic. So if we go with this solution,
> >>> after this change it's in the status "works on your machine" and we
> >>> either need to commit to not using struct copies and zeroing
> >>> throughout kernel code or potentially have a long tail of other
> >>> similar cases, and since they can be triggered by another compiler
> >>> version, we may need to backport these changes to previous releases
> >>> too. Whereas if we would go with compiler flags, it would prevent the
> >>> problem in all current and future places and with other past/future
> >>> versions of compilers.
> >>>
> >>
> >> The patch will work for any compiler. The point of this patch is to ma=
ke
> >> memcpy() visible to the preprocessor which will replace it with __memc=
py().
> >
> > For this single line, yes. But it does not mean that KASAN will work.
> >
> >> After preprocessor's work, compiler will see just __memcpy() call here=
.
>
> This problem can affect any arch I believe. Maybe the 'solution' would
> be to run a generic script similar to
> arch/powerpc/kernel/prom_init_check.sh on all objects compiled with
> KASAN_SANITIZE_object.o :=3D n don't include any reference to memcpy()
> memset() or memmove() ?


We do this when building user-space sanitizers runtime. There all code
always runs with sanitizer enabled, but at the same time must not be
instrumented. So we committed to changing all possible memcpy/memset
injection points and have a script that checks that we indeed have no
such calls at any paths. There problem is a bit simpler as we don't
have gazillion combinations of configs and the runtime is usually
self-hosted (as it is bundled with compiler), so we know what compiler
is used to build it. And that all is checked on CI.
I don't know how much work it is to do the same for kernel, though.
Adding -ffreestanding, if worked, looked like a cheap option to
achieve the same.

Another option is to insert checks into KASAN's memcpy/memset that at
least some early init has completed. If early init hasn't finished
yet, then they could skip all additional work besides just doing
memcpy/memset. We can't afford this for memory access instrumentation
for performance reasons, but it should be bearable for memcpy/memset.

