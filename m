Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F6FDC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:44:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8762217D7
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:44:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="j5+tz0AJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8762217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42C966B000A; Thu, 18 Apr 2019 11:44:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B40E6B000C; Thu, 18 Apr 2019 11:44:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27D626B000D; Thu, 18 Apr 2019 11:44:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id F09666B000A
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:44:33 -0400 (EDT)
Received: by mail-ua1-f69.google.com with SMTP id h6so299015uab.0
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:44:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=XKqKQT0z8uVafmk205Lc9H8n7pW8a7n6L2F4uw5JQKI=;
        b=q+6KhZH9GUzMhuiC06ET7Jh/6ZLuKqY3nWjlcz+Rcnro4U2f5eYjKelDHAh7BmCXGx
         v4ETNc+TG6OJxLT1/ynYLsbCvCWGFnol5zxKeNVKYPQv+B16i2IyEZDP9IQZsyK4T3Kt
         pibck3zk6g5WwE7YtF0avs2/vNICKpjZgWoBSVcbQ0dZvhtkzz4eHHFMIxCdetw9TajZ
         hZTvZfo4dGjx3qDDbV5dZiQITmgPgC9yFHL2+tx3V5lg/dIh/tvU1B/6IJ0B4XIoBLLf
         bs9/UBBfNgltnn7ttJa7utryixNQlByadFuLjd3cDPmoYwf7sxBktw2Ue84aKW83mmaT
         V2Tw==
X-Gm-Message-State: APjAAAV7HfXcfUgR2Mfbxanv60w8TOZ0R+r7zqeKg9Awto9gbdUn1FBe
	CWqZtSmcjdX+3n/vak+bAkJ7OGCEZvh6qW06+KF/TWY6trh8PfnjrpdNr+q1xBLpw8OqXJcV+wS
	0N/f9zT+0lOqRRd2nPMDI+PqEw2OkRj5Lg8i6GpibycCYyahjWZsFW3vRZ9cGV/4Vnw==
X-Received: by 2002:a67:ce03:: with SMTP id s3mr25898856vsl.97.1555602273626;
        Thu, 18 Apr 2019 08:44:33 -0700 (PDT)
X-Received: by 2002:a67:ce03:: with SMTP id s3mr25898821vsl.97.1555602273025;
        Thu, 18 Apr 2019 08:44:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555602273; cv=none;
        d=google.com; s=arc-20160816;
        b=BGJmZi4GxVyRev3eC7QnzsA12MG+oFS/95qntc4+acStauZg/J066XbAH4hjlyQtcS
         2kqWUjujqyu2poP78lnFWhKWFn63+aNwFRBO7ABZJAfSDdGF2od1gvGmYvcfbi2Pdvy6
         yluoANJiirKgBldpLTlbS9+inQjhMXH9PJO+PMGFSSeImZ6tadJTB5MIjoI7sHYO+pby
         pjg/3rc/8BbMZbdg2iHhNAXgUIo9nB9JMIqk+fdNeHvRDZTVSl7WJzfEkD2xV9l7jsAR
         aF0QjXOw1q/Om00ICzfaLr7mTO68B4IF7RqJK65CjnUW+sVNW9t40BfO2U+8d+VtnSKW
         kfFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=XKqKQT0z8uVafmk205Lc9H8n7pW8a7n6L2F4uw5JQKI=;
        b=J2yjZur49R2LAmu/WHrPZCglQKTE8NEMjqtRd2V8PCuc3PQLBG7SScNm3wxfpqwBS6
         1nDh9ZdnljesADFUQoiYFDLZUjhz3B3F5vJFoRzKXsu8TnRUxUHINuDk+NwOXlZnMYy7
         zpAt4MknrfTBXaYaFTUy7AEeOTdFv6LorQVRnthwEdxDz5et/uxl0kXtgIXzEV2B4tHW
         XUj0wgZKBsWgzupriCJVQ9Mn3fyy3u/qnQph2zeaWtf0nGLdLQFQ605XzZC7TdyEPIgA
         c58G3iObKCsFUVLhVwrrREhKU4M5CMjcSG7L/3Q+gTw6zI2revbgnG+ebQsgGxESQ1In
         1XzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=j5+tz0AJ;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n5sor1370963uao.72.2019.04.18.08.44.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 08:44:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=j5+tz0AJ;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=XKqKQT0z8uVafmk205Lc9H8n7pW8a7n6L2F4uw5JQKI=;
        b=j5+tz0AJFtyJzHuErEHF+kxnXTWD/csOQdip3YJLRbf7e2jidiWMmZaRCot5M+wrkC
         OujW4JyzRtiVxRMSlxqJdX87IQD7GFwQWET7aDTzZst2Ik2c97BCxX04i9o4H4irSoKK
         u9qLHZ5N5eSwE/Rls2in8Li1OkJzh22uvfVAINwJ47OCiTGWXHPrn5AVqpbc8ISJ0gcE
         QWmGPxUZf41Xr/ql5zusGGOx7fU9U1eEiOJ2oQnOI3og8bWRcHcEH7RZ+CjzwQprFb3q
         x3UBZadD/405RcVSsmUZC4mS4ObTgqxiegY3H9Gt3Nk4HkTBQmp+ShR6w4z/M7LZCZyC
         qJqw==
X-Google-Smtp-Source: APXvYqy2REoK/bFJdMT+jP45oghXzeqqEWNYTxO2L5mIesKVuNRVMBGEHfYVUcO7LbBmGg2mFlf7+UWbkbruYIsS5Do=
X-Received: by 2002:ab0:44e:: with SMTP id 72mr50490792uav.110.1555602272470;
 Thu, 18 Apr 2019 08:44:32 -0700 (PDT)
MIME-Version: 1.0
References: <20190418154208.131118-1-glider@google.com>
In-Reply-To: <20190418154208.131118-1-glider@google.com>
From: Alexander Potapenko <glider@google.com>
Date: Thu, 18 Apr 2019 17:44:20 +0200
Message-ID: <CAG_fn=WZbf8CfxHB2SXpR5OON3NP3GkfPWQ1OeooqJRBao28rQ@mail.gmail.com>
Subject: Re: [PATCH 0/3] RFC: add init_allocations=1 boot option
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Dmitriy Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, 
	Laura Abbott <labbott@redhat.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 5:42 PM Alexander Potapenko <glider@google.com> wro=
te:
>
> Following the recent discussions here's another take at initializing
> pages and heap objects with zeroes. This is needed to prevent possible
> information leaks and make the control-flow bugs that depend on
> uninitialized values more deterministic.
>
> The patchset introduces a new boot option, init_allocations, which
> makes page allocator and SL[AOU]B initialize newly allocated memory.
> init_allocations=3D0 doesn't (hopefully) add any overhead to the
> allocation fast path (no noticeable slowdown on hackbench).
>
> With only the the first of the proposed patches the slowdown numbers are:
>  - 1.1% (stdev 0.2%) sys time slowdown building Linux kernel
>  - 3.1% (stdev 0.3%) sys time slowdown on af_inet_loopback benchmark
>  - 9.4% (stdev 0.5%) sys time slowdown on hackbench
>
> The second patch introduces a GFP flag that allows to disable
> initialization for certain allocations. The third page is an example of
> applying it to af_unix.c, which helps hackbench greatly.
>
> Slowdown numbers for the whole patchset are:
>  - 1.8% (stdev 0.8%) on kernel build
>  - 6.5% (stdev 0.2%) on af_inet_loopback
>  - 0.12% (stdev 0.6%) on hackbench
>
>
> Alexander Potapenko (3):
>   mm: security: introduce the init_allocations=3D1 boot option
>   gfp: mm: introduce __GFP_NOINIT
>   net: apply __GFP_NOINIT to AF_UNIX sk_buff allocations
Oops, I was hoping git send-email would pull all the Cc: tags from the
patches and actually use them.
>  drivers/infiniband/core/uverbs_ioctl.c |  2 +-
>  include/linux/gfp.h                    |  6 ++++-
>  include/linux/mm.h                     |  8 +++++++
>  include/linux/slab_def.h               |  1 +
>  include/linux/slub_def.h               |  1 +
>  include/net/sock.h                     |  5 +++++
>  kernel/kexec_core.c                    |  4 ++--
>  mm/dmapool.c                           |  2 +-
>  mm/page_alloc.c                        | 18 ++++++++++++++-
>  mm/slab.c                              | 14 ++++++------
>  mm/slab.h                              |  1 +
>  mm/slab_common.c                       | 15 +++++++++++++
>  mm/slob.c                              |  3 ++-
>  mm/slub.c                              |  9 ++++----
>  net/core/sock.c                        | 31 +++++++++++++++++++++-----
>  net/unix/af_unix.c                     | 13 ++++++-----
>  16 files changed, 104 insertions(+), 29 deletions(-)
>
> --
> 2.21.0.392.gf8f6787159e-goog
>


--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

