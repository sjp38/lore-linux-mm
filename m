Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D42DC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 11:28:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E94D214DA
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 11:28:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="AdP6kqdB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E94D214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CA568E000C; Thu,  1 Aug 2019 07:28:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 953C18E0001; Thu,  1 Aug 2019 07:28:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81B2D8E000C; Thu,  1 Aug 2019 07:28:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3503A8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 07:28:45 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id b6so35335820wrp.21
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 04:28:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=xqlL4i3gNjqYtXtO6TQlV20Xxo/VOCfNj1pkiBeVGDw=;
        b=QcxrH2F8Aj+c9NTzkwsB43j7SYWIGkxebn7YCAlPMrQC0EFnoiXYtOPDRbgt4IYzaC
         gLlz/HgyigshOrCdf8GTWqiKWd+lS5O+1TpHJS6ziKOziICpwQf2yVIBiGK/eK2rJMII
         F2dkJXsE+fpg8RDKIBdpDjNITehdC1OEuoVh3cHr0jCBNdWJrq0xyptR8G1IfaXSZvVF
         LKJGT5dcFdrZ3kPLOs3J0Pe23973pEKIErOX9tuHGbs5Efa5hQmCjDT4LPRduCzq4R5a
         17k6FY1P3kFSHdrWoi2eQjJ1Qz2UqL/KOeRQWrlLr3DxsG8ckegDmXH3lwCpl/GtgsQD
         1EbQ==
X-Gm-Message-State: APjAAAVApAVmLktk2M/uh1HvV6KWEOX42TQkaOyWTT2Q20jzT1WSVf/P
	Zm8wOicLG3NtyfShufzpEfuNKGgQLoJgiuRidxrqgeSnvHRfq6QACg2jeSMlQGAy2msO65SNGmK
	VvuKBmGHyGW+JqYkPHMmtfKcaI95BXy/axFKTd59nHS3VdR+5qEgNRHlflMat1a75JQ==
X-Received: by 2002:a7b:c8c3:: with SMTP id f3mr52875843wml.124.1564658924630;
        Thu, 01 Aug 2019 04:28:44 -0700 (PDT)
X-Received: by 2002:a7b:c8c3:: with SMTP id f3mr52875782wml.124.1564658923831;
        Thu, 01 Aug 2019 04:28:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564658923; cv=none;
        d=google.com; s=arc-20160816;
        b=sYtPUOfZf5Iic55B4GD/LbTsOnJo5sp2Hlb+bikDgU7QMp5WZSSjQ9H2VM4rg4Dq2i
         0T965/KwCYNr635lzwc8eSq02ym426ajy1YNkyCAOcvyDohp/vwNi5haP7Kj3kQb8P43
         Y83oc66YZGy7NWYV5GM/oVKzOZ2U419y4TfRbS+Aw5ytgIkeULDZjCG/rgyGaNd2aAhF
         THbd/SLB+sLan4Aec2+x0minhtNHgkt8bjowFKc+15qthlTHam06xQt5C4Z1QneTBkcG
         LOzfg0dJmYjJl1MYftEc+JbeCpdu9tJp45Wg0XpTr5gI8g4AMg0HmEOllxfY9jOff5Q7
         xnQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=xqlL4i3gNjqYtXtO6TQlV20Xxo/VOCfNj1pkiBeVGDw=;
        b=TCL22eAxlWQIZnstixkHQyY9MkEMMfWhymMK3PdgJ6Bh2//ZipUMvZsAvMArRrKR68
         D+h7Ib2aKsFH/4bp9WXk1+tnTp0ypb1d0oKh6XbRWXoy4g2sz7/lf75WzVhlaCAL8Hf6
         DfH425tlLXUZog6ywW5r8pqAKxNgZbjaNzGWbqmV9mOKjLkcqfMFEpiT5w2NWVLnowPe
         E1m5A74uFeleYeR58/0zpudnFlSVo0ZXmdzUx0hyVG6/UJjCahRPirWTKpe5/3s+DGQK
         jZf5HzV+W3GQ+DG1RTn/2FDPRMnOlxdzGMbnZodgzXEB0apaB8O+IytDtXOTu+JFZVk+
         yu+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=AdP6kqdB;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x6sor40182140wmb.29.2019.08.01.04.28.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 04:28:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=AdP6kqdB;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=xqlL4i3gNjqYtXtO6TQlV20Xxo/VOCfNj1pkiBeVGDw=;
        b=AdP6kqdBNqVzqPbTjcZqUCSeEuNZAZ0N2Hl7V0yyDQ97NwaxFQ3YPSdyfa5WscChBf
         eQGOSebUDGwTIsy3ec9wtj4XhJSdNy2Nm7UQuj6m19HzgAcIqfK5QtKXngKhsE1bAzeh
         Z8MDxuC/JtqX8MJIT/X74Qs9abmRPhqfAm5cJtPevPH0QqRG7ypBFY4LyQVHKu3J+qaA
         Az3nbeoW6l241nTdt1fleedlEYCSx4Y7Xs61bGbsIt2U6eBnBODlCX0nRzxsXY2YSfmG
         kNL4/CyfOJAdHhqkx81K3DomreRUeEF9m8TieokhBXNpFzz1ocBDIayWwDPw/PqD2BSX
         2s0g==
X-Google-Smtp-Source: APXvYqwGETwdoashndHC330DdqucKEGLjf3h8H2eI2Z/vsG8Q0EpDPaNd2yf/onQdcky1xXqUBZxaQrJFZevg/rqT08=
X-Received: by 2002:a1c:770d:: with SMTP id t13mr42679017wmi.79.1564658923216;
 Thu, 01 Aug 2019 04:28:43 -0700 (PDT)
MIME-Version: 1.0
References: <CAG_fn=VBGE=YvkZX0C45qu29zqfvLMP10w_owj4vfFxPcK5iow@mail.gmail.com>
 <20190731193240.29477-1-labbott@redhat.com> <20190731193509.GG4700@bombadil.infradead.org>
 <201907311304.2AAF454F5C@keescook>
In-Reply-To: <201907311304.2AAF454F5C@keescook>
From: Alexander Potapenko <glider@google.com>
Date: Thu, 1 Aug 2019 13:28:31 +0200
Message-ID: <CAG_fn=VJm7M0wzMTti5RoegW56CY2YpikjEZryt8gMN5nOiyqw@mail.gmail.com>
Subject: Re: [PATCH] mm: slub: Fix slab walking for init_on_free
To: Kees Cook <keescook@chromium.org>
Cc: Matthew Wilcox <willy@infradead.org>, Laura Abbott <labbott@redhat.com>, 
	kernel test robot <rong.a.chen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, 
	Christoph Lameter <cl@linux.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, 
	LKP <lkp@01.org>, Linux Memory Management List <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 10:05 PM Kees Cook <keescook@chromium.org> wrote:
>
> On Wed, Jul 31, 2019 at 12:35:09PM -0700, Matthew Wilcox wrote:
> > On Wed, Jul 31, 2019 at 03:32:40PM -0400, Laura Abbott wrote:
> > > Fix this by ensuring the value we set with set_freepointer is either =
NULL
> > > or another value in the chain.
> > >
> > > Reported-by: kernel test robot <rong.a.chen@intel.com>
> > > Signed-off-by: Laura Abbott <labbott@redhat.com>
> >
> > Fixes: 6471384af2a6 ("mm: security: introduce init_on_alloc=3D1 and ini=
t_on_free=3D1 boot options")
>
> Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Alexander Potapenko <glider@google.com>
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

