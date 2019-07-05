Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAD02C46499
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 11:42:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89CD3218D0
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 11:42:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="CSqLNOgT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89CD3218D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D061D6B0003; Fri,  5 Jul 2019 07:42:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C90568E0003; Fri,  5 Jul 2019 07:42:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B30B38E0001; Fri,  5 Jul 2019 07:42:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 65CD26B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 07:42:42 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id f16so1786976wrw.5
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 04:42:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=01zxlzZZgdQBadoroEenLMip5oJRIQid45uWpbovAgY=;
        b=OKusnnW3lCS8VLc3Pt9GxXrpy/dEvmiABDhLyMJcPUhkafCMRbr0UXduQPdh9WlUKj
         mXKdBUVtpdVQb41YNjCar+IlQsZKB65oab3duG6zh7MCGsGXI10kuQwE8u9sv9ubFwUH
         J8E/ds0O39WwFKSGd0tVYzoZD7GRbsBug6r/Ox7UuCAy22sl6hI/opEMSIg/2aaglFEh
         42rqBR0PySRYtkUjM7PioWZno6LSZYraU/GMFglOixdEZjq8c5J8xIukrJ6u7G8VTPeA
         vh6uXlmemAu7+eo990Oi0O47t7lbBziDrb/usbzNJWiQUc2hPlEiHEdB6Ofm57ts3Wgw
         skLQ==
X-Gm-Message-State: APjAAAWs7eKbBzzUHhJovOlgHHa01oH69MpBhGXKHHj32GHv/WcaHj3l
	WoGGvknSVXtFrDGNrygJphiGsPM0oIWgB/IzDtQ8co56B/8ppOweqvbkOBxpYbsQ+ApW9cCUdrC
	lT2O8/QJTQWBD5n4kapun+Mz8uDa66a+IktGnKgQzzRPARJGrx/7sMDK8v+6fRAxhcQ==
X-Received: by 2002:adf:dcc6:: with SMTP id x6mr3863903wrm.322.1562326961794;
        Fri, 05 Jul 2019 04:42:41 -0700 (PDT)
X-Received: by 2002:adf:dcc6:: with SMTP id x6mr3863839wrm.322.1562326960810;
        Fri, 05 Jul 2019 04:42:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562326960; cv=none;
        d=google.com; s=arc-20160816;
        b=dQM/5/dOiiIpngHkQGQwJMXlX4paLjVfoWlNES1wnl/mqJZZQUZmPvWpV3oL1y6Ebx
         fIXYKRvBjPVw0I/T40XCqfwPHI8fecdhOTQFCHIwmM4WsD+rIRLtVWuRghHuuUzvdKMs
         KFcUaVFR9YhtUe7tToD4LDu01IIgC0z3MOxeA7CJSSOD8v7P8aQqhqpoMYuNX8SoV6pw
         7iAsnjsPSw7bhtUPG8xEQeAJyzivl3orpbVzzL6kvxGJOMnIA7nsttSVhw5IoG8Dsv6z
         Y6u3s+RRVMkX2d5unHPHC/nfX+D+d5BXEXqUvvtQNx15gy6IYRPrdaW13LrZWMLsTHit
         8kZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=01zxlzZZgdQBadoroEenLMip5oJRIQid45uWpbovAgY=;
        b=DxENI+TTbK9h6xOodV24zEXXUp8dekX82y2eUD43UeBJ87yEdGJXM4qE5W8gXxOI1J
         YkePsxRaS91npPxzET0HsKsjPbIf4x+z+65/a+3i9YaEjar/cgBVvic616MulOrwuYCe
         HVJ5GJcgJNve297vJhG5mSLWc4b7CY30rZQcsZfBYldErFuS/0UWdN87tR5E3FJn9WVw
         0nt7X66m4FnsTkSn57T9j3W9UqRSZylcbx8FTjgwj8PRP8QUJKEOLRs84NmTeFJDVQ6W
         YiJra2VAhPXvC+Ph9nPpf9zuZFhmWip3hd84z8xdEe4iNQfmDsVa0myBsu8A+dY1o34N
         q8MQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=CSqLNOgT;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z186sor5036233wmc.10.2019.07.05.04.42.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Jul 2019 04:42:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=CSqLNOgT;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=01zxlzZZgdQBadoroEenLMip5oJRIQid45uWpbovAgY=;
        b=CSqLNOgT3DPRKJOTJhlJPbddgwmpDSYZGH25JEySVHTsu0XU7BDrLa/6bEqcmyCLJs
         Qb5TRJ2k6aC7sg9aofoO9JBUst8Pn8rUrJho+UMWjmmZrBlpYiSUVP7gcPq9UAw3+wYL
         rvo8gnHLtxUKzF+xkzthtpS2LUSoMhgtj58eTveYqB8eyrvf7nTTtfeSK/XECH3hKAuT
         3hyKIx6nHWbkmjTb7bKnetMRot2D/Es/Z/3DASqdgZmezfvSlkQZ2ftFjUI+t1s0mN/d
         k7k7nVA6Dw3d7OPZBDRT7xo6Qm9zmMAetEhtb8sU7hFFYTmpYe/Jn9HcdI3o3ODj0uZQ
         29VQ==
X-Google-Smtp-Source: APXvYqx/OY4zBNwIhW4n7zgDdQYtf734ZBesQ+vDt89ijc88G9R0xwVearpBfsQPk2fpIvYTYJ/QbTwYpm60GfCPAWA=
X-Received: by 2002:a1c:7f93:: with SMTP id a141mr3297458wmd.131.1562326960206;
 Fri, 05 Jul 2019 04:42:40 -0700 (PDT)
MIME-Version: 1.0
References: <20190628093131.199499-1-glider@google.com> <20190628093131.199499-2-glider@google.com>
 <20190702155915.ab5e7053e5c0d49e84c6ed67@linux-foundation.org>
 <CAG_fn=XYRpeBgLpbwhaF=JfNHa-styydOKq8_SA3vsdMcXNgzw@mail.gmail.com> <20190704125349.0dd001629a9c4b8e4cb9f227@linux-foundation.org>
In-Reply-To: <20190704125349.0dd001629a9c4b8e4cb9f227@linux-foundation.org>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 5 Jul 2019 13:42:28 +0200
Message-ID: <CAG_fn=VbxOUS2wqaEbv4C0fG_Ej7sc7Dbymzz6fG8zndCwfasQ@mail.gmail.com>
Subject: Re: [PATCH v10 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@suse.com>, 
	James Morris <jamorris@linux.microsoft.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Hocko <mhocko@kernel.org>, 
	James Morris <jmorris@namei.org>, "Serge E. Hallyn" <serge@hallyn.com>, 
	Nick Desaulniers <ndesaulniers@google.com>, Kostya Serebryany <kcc@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>, Qian Cai <cai@lca.pw>, 
	Linux Memory Management List <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 4, 2019 at 9:53 PM Andrew Morton <akpm@linux-foundation.org> wr=
ote:
>
> On Wed, 3 Jul 2019 13:40:26 +0200 Alexander Potapenko <glider@google.com>=
 wrote:
>
> > > There are unchangelogged alterations between v9 and v10.  The
> > > replacement of IS_ENABLED(CONFIG_PAGE_POISONING)) with
> > > page_poisoning_enabled().
> > In the case I send another version of the patch, do I need to
> > retroactively add them to the changelog?
>
> I don't think the world could stand another version ;)
>
> Please simply explain this change for the reviewers?

As Qian Cai mentioned in the comments to v9:

> Yes, only checking CONFIG_PAGE_POISONING is not enough, and need to check
> page_poisoning_enabled().

Actually, page_poisoning_enabled() is enough, because it checks for
CONFIG_PAGE_POISONING itself.
Therefore I've just replaced IS_ENABLED(CONFIG_PAGE_POISONING)) with
page_poisoning_enabled().

--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

