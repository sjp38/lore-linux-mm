Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6A4EC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 16:50:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F58721479
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 16:50:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ZSLGPvOZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F58721479
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECED36B0005; Thu, 18 Apr 2019 12:50:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7F296B0006; Thu, 18 Apr 2019 12:50:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D46F26B0007; Thu, 18 Apr 2019 12:50:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by kanga.kvack.org (Postfix) with ESMTP id B271A6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 12:50:31 -0400 (EDT)
Received: by mail-ua1-f72.google.com with SMTP id x7so330382uap.3
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 09:50:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=3GywmUi66KpKpQU9IlmyohbD35g+PWotSiWItfTBzrM=;
        b=Z7g8/aagdjK7bhG/4JgHJRekk7O661fA6xaCYM0RGpDHnr3qyGCgTbKuEfSdDvJui3
         r16arxtjD8m6i0S63aGIkkBDSjT2qyO3yppwvUVWbWB2TkixByEtMAKGdmwpGfT0hdSY
         fu2YV4a6G9ztt9Clz61/qWZnYNqLqKX3tuTetyI0suk6zj6F9EXYPyGPiLxKd9WjScZg
         x1Onhql9G0pnV8LbEaqqDvd9rv/meyL8tfVBp4nuQr8ppwdrco9hg3bcBhqq5JPsucFc
         ZiE62cxeWXzhfvMZSBHu9Bk1rWJYKRl+6N65VJ6iCvtesXF1vWK1moA6uoleUDZ9Reau
         XaFA==
X-Gm-Message-State: APjAAAVMkQMj1MZbXwT2w4QIq88CSxwR+axzw5PcbhARdr/5zs3IsLaN
	94N5oq0vPbW8ucyhPcY8NGdEW4OewcJjQiCKcnXxk/BJsoy97o7VLME2I8huAjnXsjx6wr/vKil
	flMyE3R+AI7X24SVdZ2Wp3wWjpLeV3p706mc146Funv6UJcq1FdSiHwnkUVsXvc+DpQ==
X-Received: by 2002:ab0:7601:: with SMTP id o1mr4348658uap.138.1555606231408;
        Thu, 18 Apr 2019 09:50:31 -0700 (PDT)
X-Received: by 2002:ab0:7601:: with SMTP id o1mr4348569uap.138.1555606230533;
        Thu, 18 Apr 2019 09:50:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555606230; cv=none;
        d=google.com; s=arc-20160816;
        b=T39Qr/woQgRmP2DOzmMe7ae6uQLlOFgcUYB/ZHaGDoQSSZzSG26Ga9dwN2J3Ahny+3
         nJB/kX2xYPGMOhWk14zBv84SyOzqX+/2/aeA1yHw5KS1U2/nEgqoL/zQGFLfCplRIInC
         nIA/vtCcaBGnRfQWnWS+EXS71RfmpB8/gaMvb+IZ21uI/qTr/66OUvgHOjErQhB2+xBq
         BCNK7DFQ729jidlqC4WatqWXBtFmWBiU1si+hwXSEelmPk2+3FYAXuvuAKB8PwQQiKVY
         9JiX5tyqyE2tFmPjYeSzzLxF1uIyxeqRPbGcTfTHjNlnA5AP2AM8gx1C9KAuhF+qXmUU
         imSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=3GywmUi66KpKpQU9IlmyohbD35g+PWotSiWItfTBzrM=;
        b=0+0reWpEfOTDzVgWg/kRjWaeOjek1RRRMXtqeE1WGl0w4T5NUZASJFGisMDc3k0eLo
         Bvi3eZmPmwm4Y81K0pORPCSSphKqD6M7hcLecEQuA9pZKJZ6q2ibCG44LmWNQhaspv1N
         PjoJjtngKgp2cwrwqegnf2DXG4LL93cjuDOXR93UsMykSDeUT2ugusmacDyfSFQDqj9D
         UFYshEtaHd/frPLX35qp60ijJ9V4pvUvxMM02vzYSXh1YY3iIXaMDuXrcUNnWsvdPw73
         V2gpXNM2hH7otR61YKqStAbBW/6vlb09z7AhtbkKE7RT7Pw+Fmy61X9K5RtCQirNhMZ0
         goeg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZSLGPvOZ;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e20sor1326424vsc.63.2019.04.18.09.50.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 09:50:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZSLGPvOZ;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=3GywmUi66KpKpQU9IlmyohbD35g+PWotSiWItfTBzrM=;
        b=ZSLGPvOZQCvhbwomx0gv2KJNtURxN7em796H/i+CY8JSHB10A7IVj6bI0983tiy05C
         sXGblrmBvnXYVPsFGY78XLlYrtV7RJCNTDnJCue99JfT+0LZTa9pt/kawQ5UJq9xtZEq
         k/Mntynsx1085QGHjRiDaKa4dImiBgifz5/Udg8NvIvu3XnUfCo8W4YfwLHMqGlPsxw5
         K4aIVhcMUGwTa05YUN9fBpQLg4zPFOHYZnnJ2p3qcP3xFDmee/EjUYF4Bm8GYwQxfiE1
         D1rL3xgIXJbQGQ9ILV4judJ94wuIoOZRhFI+20J4cpMXwPJ/y9tOhaUkQqH0c6UovUaa
         Cg4g==
X-Google-Smtp-Source: APXvYqwbSsVeJOYKT02dy71PfyAASXr/lW85K2foIwP5XcCyaonmeusw7x+fi25E9bwj6h3WhjCxvUXCNDXA7mNi/10=
X-Received: by 2002:a67:dd91:: with SMTP id i17mr28847115vsk.217.1555606230011;
 Thu, 18 Apr 2019 09:50:30 -0700 (PDT)
MIME-Version: 1.0
References: <20190418154208.131118-1-glider@google.com> <20190418154208.131118-2-glider@google.com>
 <981d439a-1107-2730-f27e-17635ee4a125@intel.com> <CAG_fn=URD0WL+RE90ZE2FZM4=p2zE9V+YA2RW-LrWnuqYTwvKQ@mail.gmail.com>
In-Reply-To: <CAG_fn=URD0WL+RE90ZE2FZM4=p2zE9V+YA2RW-LrWnuqYTwvKQ@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Thu, 18 Apr 2019 18:50:18 +0200
Message-ID: <CAG_fn=WQJRB_kb79F9ri2_Gj-gh2rmgSDa9WD7wF-pLeCKprjQ@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm: security: introduce the init_allocations=1 boot option
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Dmitriy Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, 
	Laura Abbott <labbott@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 6:43 PM Alexander Potapenko <glider@google.com> wro=
te:
>
> On Thu, Apr 18, 2019 at 6:35 PM Dave Hansen <dave.hansen@intel.com> wrote=
:
> >
> > On 4/18/19 8:42 AM, Alexander Potapenko wrote:
> > > This option adds the possibility to initialize newly allocated pages =
and
> > > heap objects with zeroes. This is needed to prevent possible informat=
ion
> > > leaks and make the control-flow bugs that depend on uninitialized val=
ues
> > > more deterministic.
> >
> > Isn't it better to do this at free time rather than allocation time?  I=
f
> > doing it at free, you can't even have information leaks for pages that
> > are in the allocator.
> I should have mentioned this in the patch description, as this
> question is being asked every time I send a patch :)
> If we want to avoid double initialization and take advantage of
> __GFP_NOINIT (see the second and third patches in the series) we need
> to do initialize the memory at allocation time, because free() and
> free_pages() don't accept GFP flags.

On a second thought, double zeroing on memory reclaim should be quite rare.
Most of the speedup we gain with __GFP_NOINIT is because we assume
it's safe to not initialize memory that'll be overwritten anyway.
I'll need to check how e.g. hackbench behaves if we choose to zero
memory on free() (my guess would be it'll be slower than with
__GFP_NOINIT hack, albeit a little safer)
>
>
> --
> Alexander Potapenko
> Software Engineer
>
> Google Germany GmbH
> Erika-Mann-Stra=C3=9Fe, 33
> 80636 M=C3=BCnchen
>
> Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
> Registergericht und -nummer: Hamburg, HRB 86891
> Sitz der Gesellschaft: Hamburg



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

