Return-Path: <SRS0=hkLx=PX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3A8BC43387
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 17:11:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C8CA20675
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 17:11:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="IGysP+d3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C8CA20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2727E8E0004; Tue, 15 Jan 2019 12:11:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F9A28E0002; Tue, 15 Jan 2019 12:11:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 074108E0004; Tue, 15 Jan 2019 12:11:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id D292A8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 12:11:03 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id u2so2484596iob.7
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 09:11:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vtRv+bC2b+ZKIpllhcnEkC8mS52A6059IN3SfIUvhCc=;
        b=k7gLV9O1D25mN+IVMQ6VB0nzY+x2kGph8HV8e9O72PUEDMPpQk6ElF38sD02rJel1g
         tWk8Qrmqgli6Gnva9QvC1FryMumSs7q0A7qx6BOGKQAIPQhrq4uBLwRyI2B7pzPb9XeM
         Zjhc4BLuHMv6TW02+sV3Ke+DFNIasVwVgJzBAj1notahVo2Bp9JT9J7FPGEzo9s7v8EI
         lF1uZkZCKWrOsrMNUiB+RB+xSsaAfBPvxLPALix4nljF3+I11K3TtYzPf0is/UvaphDA
         URn6kIxUiXb3fCLsBfMM31vbbus+w4FBE/6Dexx9nGmNlMw8BFhGxh8SFuFeqa+Lb9Rq
         WSUA==
X-Gm-Message-State: AJcUukfFF0EgizQJJ7O2GW1NkCdCLY6lmXZ3KBsER1NJAJ+VMdxtzmuD
	wKEmixZas19S24leYoWsCtfwgKN7MhJDTPSnyIAhYxDQokrqLqI19TKgPTLErSZpHDRET20ap7e
	aVSr3Kwea86ico4Nxi0wAE0CcKA7Y8ZY2wv1lkkk8CW5iednaprMW6Y69OPBlWGEHxslcttG1Ux
	Is+BKmv/lPHc6J5Xa/wchl4bBzzJtW5fyivJgD14izc8QDnIRg4Re+BQKB8bjyDRL1hCuuY4OHd
	bRZUMMM+yzRog/BYLEY7GLCRR0wZOd4kokrkvuNSrs4GVVVW/OoY7ofrtAPKa6chinqEMLRpa5a
	iu87m32XspayoO/FiSf/dUHMbKGV4FRV4t/O1aT5+g64TF107E2jtokn+Zh9eB+HrMB8pSoqtI9
	P
X-Received: by 2002:a24:c601:: with SMTP id j1mr3400195itg.130.1547572263574;
        Tue, 15 Jan 2019 09:11:03 -0800 (PST)
X-Received: by 2002:a24:c601:: with SMTP id j1mr3400147itg.130.1547572262833;
        Tue, 15 Jan 2019 09:11:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547572262; cv=none;
        d=google.com; s=arc-20160816;
        b=pD3ePf1pMuIKGZyS6Qlc1LHtlyCGLsMmU322TnXKlpQ1YdEI52k85v+XcoE+uCz00g
         vjWvXrcUMeSHFvMjJ9CSUW47rJkaj6d0AmAYBo+G1TE1PdDEjzrFkWtKPY0TTiCEmQ/8
         ckoyDP0aknLP44mQl7o626E6EhVie7ur+vYga0G12314HX16pw6te2bER3dUiHaPGCxw
         skYYcKQe1RJBcPlc8iUWFgUSoTUTOk+kM+mMQ+KcSxtmLP6hUWA1/GbqzduifRgHoNzj
         0nYow2gM/IxVX9Cj285Nd9NHAJprTxrcjWwbPL5+BLWeAfpeoVBvpuFMfJHaN8cCc7js
         ik9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vtRv+bC2b+ZKIpllhcnEkC8mS52A6059IN3SfIUvhCc=;
        b=M3TCmG70F8QGA2fPzfIIweQcSDi20iwuureo7bHhMuMOnji3DiRgaJS9OdGWFj8NMg
         9N1vuFwyQtVxW0Say+eJrsXbB1SC/lTAzyteTuVWe1sag0bymSt5CMXLP97Nq7VMVt6y
         cmergC2cKBG2Mh0T6ROaQ6zV7wL8Y3JKUSv9orvJYEZ7EAbKKrqdu7+75wtJbIqjZENa
         FZjpxstCQ+drULtyXjrENZ8nN1o4gpALwbU4ZNBIK8CXGzCD8cGq3Zzf+xpMxpVdWkvx
         6OS5UcdZFt/FVJ/YJkJ2CvhfQACvFwWU7nu3d8yT3zRxwQ2t+jVYgG6g+yHBLqlmOE/y
         J7xg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IGysP+d3;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t200sor21580397itb.0.2019.01.15.09.11.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 09:11:02 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IGysP+d3;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vtRv+bC2b+ZKIpllhcnEkC8mS52A6059IN3SfIUvhCc=;
        b=IGysP+d3tnbyPkdQg4vGdHxuFQrail167z6JMr/frchJzjv7q3yRaRlzOcRW9l86JL
         wsWZXal0fnZQGv8Glipj9178hYrmvcdVihCkzxW0MQayUNNX/c+amOxro+cWUKhnTtCc
         dWd4a3sTN9rD63+34rBUiOTNhtzvEyhRF3sPnK1ks494cI6mQQk/x+KAHwAfBJuPAt/0
         /tnNQMA2fyVQkBqT8o7k4oupI4yjCD+9wf8/kyA42dXhJ4Ipw3d+wHivQgeWgdXGgJQc
         9BUxZ1P6xYI7OCCnX5Nu9EfCg0dnpL1oEKAECoN7dagit0YeU4KCiqCOhRWvnDb1Gtzs
         QT9Q==
X-Google-Smtp-Source: ALg8bN4YJbAecTWcw1ox2ZgsKutstrXMrEyF+8QN6Rz+VyO0TybO7s6WPUvJbVowNXYRSzrkq8j1RTB5wb9zgaLVmUQ=
X-Received: by 2002:a05:660c:f94:: with SMTP id x20mr2787821itl.144.1547572262348;
 Tue, 15 Jan 2019 09:11:02 -0800 (PST)
MIME-Version: 1.0
References: <cover.1547289808.git.christophe.leroy@c-s.fr> <0c854dd6b110ac2b81ef1681f6e097f59f84af8b.1547289808.git.christophe.leroy@c-s.fr>
 <CACT4Y+aEsLWqhJmXETNsGtKdbfHDFL1NF8ofv3KwvQPraXdFyw@mail.gmail.com>
 <801c7d58-417d-1e65-68a0-b8cf02f9f956@c-s.fr> <CACT4Y+ZdA-w5OeebZg3PYPB+BX5wDxw_DxNe2==VJfbpy2eJ7A@mail.gmail.com>
 <330696c0-90c6-27de-5eb3-4da2159fdfbc@virtuozzo.com>
In-Reply-To: <330696c0-90c6-27de-5eb3-4da2159fdfbc@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 15 Jan 2019 18:10:51 +0100
Message-ID:
 <CACT4Y+ajgTdDyFFWCp0oRSPKZh9ercDpq3pAq2-ZSx7ouAvZYQ@mail.gmail.com>
Subject: Re: [PATCH v3 1/3] powerpc/mm: prepare kernel for KAsan on PPC32
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Christophe Leroy <christophe.leroy@c-s.fr>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Alexander Potapenko <glider@google.com>, 
	LKML <linux-kernel@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org, 
	kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190115171051.xOmHNFe_74nkVL9QXHrhfkTq5r79DuuveYkjWZuE6XQ@z>

On Tue, Jan 15, 2019 at 6:06 PM Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>
>
>
> On 1/15/19 2:14 PM, Dmitry Vyukov wrote:
> > On Tue, Jan 15, 2019 at 8:27 AM Christophe Leroy
> > <christophe.leroy@c-s.fr> wrote:
> >> On 01/14/2019 09:34 AM, Dmitry Vyukov wrote:
> >>> On Sat, Jan 12, 2019 at 12:16 PM Christophe Leroy
> >>> <christophe.leroy@c-s.fr> wrote:
> >>> &gt;
> >>> &gt; In kernel/cputable.c, explicitly use memcpy() in order
> >>> &gt; to allow GCC to replace it with __memcpy() when KASAN is
> >>> &gt; selected.
> >>> &gt;
> >>> &gt; Since commit 400c47d81ca38 ("powerpc32: memset: only use dcbz once cache is
> >>> &gt; enabled"), memset() can be used before activation of the cache,
> >>> &gt; so no need to use memset_io() for zeroing the BSS.
> >>> &gt;
> >>> &gt; Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> >>> &gt; ---
> >>> &gt;  arch/powerpc/kernel/cputable.c | 4 ++--
> >>> &gt;  arch/powerpc/kernel/setup_32.c | 6 ++----
> >>> &gt;  2 files changed, 4 insertions(+), 6 deletions(-)
> >>> &gt;
> >>> &gt; diff --git a/arch/powerpc/kernel/cputable.c
> >>> b/arch/powerpc/kernel/cputable.c
> >>> &gt; index 1eab54bc6ee9..84814c8d1bcb 100644
> >>> &gt; --- a/arch/powerpc/kernel/cputable.c
> >>> &gt; +++ b/arch/powerpc/kernel/cputable.c
> >>> &gt; @@ -2147,7 +2147,7 @@ void __init set_cur_cpu_spec(struct cpu_spec *s)
> >>> &gt;         struct cpu_spec *t = &amp;the_cpu_spec;
> >>> &gt;
> >>> &gt;         t = PTRRELOC(t);
> >>> &gt; -       *t = *s;
> >>> &gt; +       memcpy(t, s, sizeof(*t));
> >>>
> >>> Hi Christophe,
> >>>
> >>> I understand why you are doing this, but this looks a bit fragile and
> >>> non-scalable. This may not work with the next version of compiler,
> >>> just different than yours version of compiler, clang, etc.
> >>
> >> My felling would be that this change makes it more solid.
> >>
> >> My understanding is that when you do *t = *s, the compiler can use
> >> whatever way it wants to do the copy.
> >> When you do memcpy(), you ensure it will do it that way and not another
> >> way, don't you ?
> >
> > It makes this single line more deterministic wrt code-gen (though,
> > strictly saying compiler can turn memcpy back into inlines
> > instructions, it knows memcpy semantics anyway).
> > But the problem I meant is that the set of places that are subject to
> > this problem is not deterministic. So if we go with this solution,
> > after this change it's in the status "works on your machine" and we
> > either need to commit to not using struct copies and zeroing
> > throughout kernel code or potentially have a long tail of other
> > similar cases, and since they can be triggered by another compiler
> > version, we may need to backport these changes to previous releases
> > too. Whereas if we would go with compiler flags, it would prevent the
> > problem in all current and future places and with other past/future
> > versions of compilers.
> >
>
> The patch will work for any compiler. The point of this patch is to make
> memcpy() visible to the preprocessor which will replace it with __memcpy().

For this single line, yes. But it does not mean that KASAN will work.

> After preprocessor's work, compiler will see just __memcpy() call here.

