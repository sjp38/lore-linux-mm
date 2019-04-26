Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74211C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 15:48:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A737205ED
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 15:48:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="HkHXy+C7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A737205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C6DE6B0003; Fri, 26 Apr 2019 11:48:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9755C6B0006; Fri, 26 Apr 2019 11:48:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88D696B000A; Fri, 26 Apr 2019 11:48:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id 64F436B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 11:48:24 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id h6so599160uab.0
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 08:48:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=DMbwsVTmLlgBSQ3AQVV7zhO03Dui6VOqPccFtIRcq3Y=;
        b=LeSSqaGuSwXp3qTZ5zZLx8J90nZFhf8kjD3NPZOLPkMWJMsCCIwJoNzK2TnciDnAsf
         5IcAh0u1QuItypslUUU9/Llf3kUpQARV1Ydg757MLOjZdxIb2L+3MS54SuNr5mNlrHXb
         u/3J2Nqqq/iDk52V7DLm34Qq4fbqkG3kPA/654npuYiajeJMnqgaLmnmjm9FvCxRQ7ty
         j0TzzvzsKKs2BXOrjF5Og5DIUlFkbGvB/l6k41rd2wy2NbX7RO517pBN7ue/xVkSrfAe
         DuWieInhwEj9mqCD2EVQd8f3mqewiMSjptfGl+peDP7u05BPSrMUpe6zMo7Pl6R90hxJ
         iZpA==
X-Gm-Message-State: APjAAAXK0Ogp6CfBs/oFbrhpCd960bPjXFBqC3KoVsGwkXAmNqmKYBWT
	JaJrqaELI2NnqYg3Lb6wyufHbU3gmnOuBE7ukG9zva3cwV1kipN+okFY/VgokhE5PjhkIlc7ujb
	viTjdSPzQCsY5+YfyHozGdOoLppyzkEwHCHd2YeDHaPOQ4GgYVHxondyEEQ7THG/qrQ==
X-Received: by 2002:ab0:2046:: with SMTP id g6mr12010999ual.108.1556293703919;
        Fri, 26 Apr 2019 08:48:23 -0700 (PDT)
X-Received: by 2002:ab0:2046:: with SMTP id g6mr12010964ual.108.1556293702827;
        Fri, 26 Apr 2019 08:48:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556293702; cv=none;
        d=google.com; s=arc-20160816;
        b=ogk2hEFEvGLNAQPr2k9dqWJ1ZsTdfHeuOBmEXadeTsQbm4T91OeVZKU+e4PSvPZ3rY
         7Qznq1Nwz42WxiWLwuVXDp2x1m/HZkmw1GX3CUFKCfDkSQ2S0ap4Z3X96/FnXsNdJr2I
         qUwscI1EEYdBVwZzDoQIN/UoqxuPtfgIOTQEeqqRDw88x9UTenwHwVpwKN/0ojMvhf8W
         mmkPaN/qZRHFIMlqbKKCjRTWPpikX8PgFGqlfVEipeoErG8lStGpWgEGCFjEdisDvHvM
         JMqTeuRWx/K2QgSK62CudG3L9X1jDEp9kmJTm6Bajr3acWA42/UO1imGxs/JMWd0ONL4
         0CXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=DMbwsVTmLlgBSQ3AQVV7zhO03Dui6VOqPccFtIRcq3Y=;
        b=mMeL8GLEkEBrUr1K2zDVqVQF+YJHopmz3psdWWfk/RfMH0CDgVLbWou7IkCW4L/0n0
         K0J31J8QVLwCXYMipGyR79l3CIG8DTp+MHHUD2PuqjQf6NcxIccwU96bnuzE8HagLw+2
         YVGa5ECL2fhuhBRT53apqZic61RefrzlzBlMH6yTwB6AulKmanH0kxzG6KtzeNnvTI+C
         t/IkiuNhpJ6N8QGMIXMAseX0NRJi6ofmW+sDGL5KEgwM+Can5axH8ZI1o0dFJH8hM89z
         QBmSTI9xldoXbBl5jwgUfxUzhdxSggOOpqeD1WDwaJjBYr0QLFtFvoWPSOifAASkJkwk
         +3/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HkHXy+C7;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k2sor8843694vke.14.2019.04.26.08.48.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 08:48:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HkHXy+C7;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=DMbwsVTmLlgBSQ3AQVV7zhO03Dui6VOqPccFtIRcq3Y=;
        b=HkHXy+C75uEgB5TiO0Vne0wSo5yn2vGUtsU6jybLTVPKSb1T63ZmEiaBDbN8EW2xbt
         +orApMccp/6S1dVqxvtK+NUcWVOU8I/1XVk+Qtw739qlHa/XZP65T1BcIBfO9BdGoccC
         Dv9NF52KGawfYlKqzj04fjUkc1RNle2VK64j/nT7U7kUIsvJ3IC583S0kjlc2cvuFvMd
         OiXjjj+S0umBivuYz1hJFjZwJe7zVlPL+1Rg/dra3jcpqHXzPVjNf5gjXsg/xAUZJOFO
         DVtZwIb+aZbKpqpHW9FBplGFNuNcBHbxoMSHzp3Noqf6PWAot9GfK80aZaPI8cRY23ii
         rkRg==
X-Google-Smtp-Source: APXvYqx79Ste/jagBrDiXzEeRcMMHgTKLywIMfjMi3Q+uv4eDclN5Z45Fkcx93NdwD001hssuNLIENwwifs2h9i9o8Q=
X-Received: by 2002:a1f:9487:: with SMTP id w129mr21556719vkd.29.1556293702099;
 Fri, 26 Apr 2019 08:48:22 -0700 (PDT)
MIME-Version: 1.0
References: <20190418154208.131118-1-glider@google.com> <20190418154208.131118-2-glider@google.com>
 <alpine.DEB.2.21.1904260911570.8340@nuc-kabylake> <0100016a5a3f6121-e7ed483e-bc29-4d75-bd0a-8e3b973529f5-000000@email.amazonses.com>
In-Reply-To: <0100016a5a3f6121-e7ed483e-bc29-4d75-bd0a-8e3b973529f5-000000@email.amazonses.com>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 26 Apr 2019 17:48:10 +0200
Message-ID: <CAG_fn=Uj226XJqh_wErBLW6dLvp_eP_KaEJDuqxBhvag1Q=Jwg@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm: security: introduce the init_allocations=1 boot option
To: Christopher Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitriy Vyukov <dvyukov@google.com>, 
	Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, 
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

On Fri, Apr 26, 2019 at 5:24 PM Christopher Lameter <cl@linux.com> wrote:
>
> Hmmmm.... Maybe its better to zero on free? That way you dont need to
> initialize the allocations. You could even check if someone mucked with
> the object during allocation.
As mentioned somewhere in the neighboring threads, Kees requested the
options to initialize on both allocation and free, because we'll need
this functionality for memory tagging someday.
> This is a replication of some of the
> inherent debugging facilities in the allocator though.
I'm curious, how often do people use SL[AU]B poisoning and redzones these d=
ays?
Guess those should be superseded by KASAN already?
I agree it makes sense to reuse the existing debugging code, but on
the other hand we probably want to keep the initialization fast enough
to be used in production.
>
Re: poison_fn, it wasn't a good idea, so I'll be dropping it.

--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

