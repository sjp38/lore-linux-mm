Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E29FC48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:27:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13420204FD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:27:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="LA9vnejy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13420204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F98F8E0005; Wed, 26 Jun 2019 08:27:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 982398E0002; Wed, 26 Jun 2019 08:27:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8231D8E0005; Wed, 26 Jun 2019 08:27:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 55ED38E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:27:10 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id a185so714187vkb.0
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:27:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=6kfkIhuHoPIjfMfVB0Ztiwt1Me6klHBycZVbDOiK0gk=;
        b=lKDTEVENBrRHG1/zJydt0Qq6gIyxpG+JbNN8pq6Aqsb7dzSmEJdp+LOjIRymYM9pwx
         GPWeAb5ayuv2TCKMreW8TnEoqQpSwuY3D5rk+BXAC+vUbB81ZVQFQxSFc/Nwz3dhOd/5
         OsqGTY0rmoBE0SGJJioHCoLvhbWCo2gi8wHX2yws85woLOVD3xfImQwKKRrrqftC3V0/
         Ac6f74sJ4I4pa3133Om6Q/IyUUDUTzpaQjcrglHE0UeVXFOgeR1AS+xFyihWKp2uyOF6
         Ebj+cItJaGT02pezhY6k4rkyLoSgY47HF6U5dOzjbNP67Q9gf8u9JLQehb0PW1kLvfCE
         +SOg==
X-Gm-Message-State: APjAAAXFNYnhYirqCbfoDB2FJZAg0950kIpIus05SurkMxRShGwTeO4Z
	7fOVQCWRRkrFCW+izNUwKJC06VuqcxD1SOZYFcrgDA3zTI1/YgWLz8jWM4PiUQKKGwLeBn7PbEh
	oyeEtxAHvsQlbwSytOFHpnSp7ELH4a1ggUeMpQbMAMSj3ykXQZZV7D0WHSTPhtdUVKA==
X-Received: by 2002:a67:ee8d:: with SMTP id n13mr2853394vsp.49.1561552030060;
        Wed, 26 Jun 2019 05:27:10 -0700 (PDT)
X-Received: by 2002:a67:ee8d:: with SMTP id n13mr2853369vsp.49.1561552029468;
        Wed, 26 Jun 2019 05:27:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552029; cv=none;
        d=google.com; s=arc-20160816;
        b=mH0bzqzOgLCUOkG0vY/cnR8siXhSCR5GtLh+JD+eycRJ1Vo6EyvhBVxI7yXgcX2krk
         RV5EFKVp4XmidHyGSf+IsYPyhqyio+kP9uyo8wZv86Oz5CEVpcFSkoGwo2DgaC4lwCvB
         G8eID66yM9kDqygJz6KKjTp1c9bnAUfIPPiXcNyJpNnrr4RgYN2LS9rLyMPC9hxtIWkV
         CRrT00MfnLODHB2FnIReuoVM4olNb9KblJpewq6KZH5R/jQ54YjbHdXjeoKTxgos6Pv8
         T5arsFSAYg5OpNQfk4WKKxc2NopT4qYPO90KGFGX0mcJ7X2HhqF6YJlncpBWJm0urKV6
         jkqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=6kfkIhuHoPIjfMfVB0Ztiwt1Me6klHBycZVbDOiK0gk=;
        b=rKuwTBN0a1xEybgKZvQQ5CUvoiOXs2AlEy3Aj1xk+zfJQD+HbA/9KnuAIy4dwPz1b4
         anUkVTrpCX0OyGllKPFyALST0rw349s1fuC6HWJFkDGkF+GvGrLkB04XK9ilELaw41Wo
         tPlme7azQ/q24f8SfsVNorSoTADw/Nj+eDI+priXAUdwKjTvJiuj9c433KmS0LcHQcS1
         gicu8R+aL5IpSScmUlUC36EtGGw+408y3qk3e2JCIwrI+6eYYVrpDcjkCfw7Et3ZWAMk
         kOv+1/Z1NVo2R9nqt7ozskJWw4kw1xtgZvImPzgYJGt9OM/amOXPAjn/nlnjJkx/m0kb
         9jpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LA9vnejy;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l127sor9021491vsd.5.2019.06.26.05.27.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 05:27:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LA9vnejy;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=6kfkIhuHoPIjfMfVB0Ztiwt1Me6klHBycZVbDOiK0gk=;
        b=LA9vnejysG80LoRMNK06zRKNClzSYlPIdhO2BG8R5WimhgksbZNGFBE1+GUiQLEifw
         eagA1Ss7o118bXvq49QRHs+qJqELP+XQixvQAYDIsNY3C8BcfX7mpLNtT8ORoVLO0I87
         c0MDtIeXo60EqlRh1gnyMvvuq9qf0CzKX64dtRn0ifZI4hXXE0kqy16Q5v4HugyKWeK2
         UuwCITTAl5UFtiD9Rs4b/geol+F+Nyj5TAz6c5zFvVJKZYPyKWMPY2Z6T+8dQC+CzHVK
         xBAsf8dcoFTgafsDg4Thp/2Chqjg9t5WhkYXBT/PqOpgZF0AEy8MdUMfUE56k+QPMpzj
         VlTw==
X-Google-Smtp-Source: APXvYqzFVn7+Sobi3957YqMqzgXYiYzf1aj+EhLLCRNEuqntRTM8bUrv2ro9eKC8ad0q35LYmIjx6cO3FPMvsDikbes=
X-Received: by 2002:a67:11c1:: with SMTP id 184mr2733987vsr.217.1561552028933;
 Wed, 26 Jun 2019 05:27:08 -0700 (PDT)
MIME-Version: 1.0
References: <20190626121943.131390-1-glider@google.com>
In-Reply-To: <20190626121943.131390-1-glider@google.com>
From: Alexander Potapenko <glider@google.com>
Date: Wed, 26 Jun 2019 14:26:57 +0200
Message-ID: <CAG_fn=V5o-wt5PQ4LSarpXrEGfbrdbtSFqOOag=nmMrxf4gfnA@mail.gmail.com>
Subject: Re: [PATCH v8 0/3] add init_on_alloc/init_on_free boot options
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Kees Cook <keescook@chromium.org>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Hocko <mhocko@kernel.org>, 
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

On Wed, Jun 26, 2019 at 2:19 PM Alexander Potapenko <glider@google.com> wro=
te:
>
> Provide init_on_alloc and init_on_free boot options.
akpm: May I kindly ask you to replace the two patches from this series
in the -mm tree with their newer versions?

> These are aimed at preventing possible information leaks and making the
> control-flow bugs that depend on uninitialized values more deterministic.
>
> Enabling either of the options guarantees that the memory returned by the
> page allocator and SL[AU]B is initialized with zeroes.
> SLOB allocator isn't supported at the moment, as its emulation of kmem
> caches complicates handling of SLAB_TYPESAFE_BY_RCU caches correctly.
>
> Enabling init_on_free also guarantees that pages and heap objects are
> initialized right after they're freed, so it won't be possible to access
> stale data by using a dangling pointer.
>
> As suggested by Michal Hocko, right now we don't let the heap users to
> disable initialization for certain allocations. There's not enough
> evidence that doing so can speed up real-life cases, and introducing
> ways to opt-out may result in things going out of control.
>
> To: Andrew Morton <akpm@linux-foundation.org>
> To: Christoph Lameter <cl@linux.com>
> To: Kees Cook <keescook@chromium.org>
> Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: James Morris <jmorris@namei.org>
> Cc: "Serge E. Hallyn" <serge@hallyn.com>
> Cc: Nick Desaulniers <ndesaulniers@google.com>
> Cc: Kostya Serebryany <kcc@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Sandeep Patil <sspatil@android.com>
> Cc: Laura Abbott <labbott@redhat.com>
> Cc: Randy Dunlap <rdunlap@infradead.org>
> Cc: Jann Horn <jannh@google.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Marco Elver <elver@google.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: linux-mm@kvack.org
> Cc: linux-security-module@vger.kernel.org
> Cc: kernel-hardening@lists.openwall.com
>
> Alexander Potapenko (2):
>   mm: security: introduce init_on_alloc=3D1 and init_on_free=3D1 boot
>     options
>   mm: init: report memory auto-initialization features at boot time
>
>  .../admin-guide/kernel-parameters.txt         |  9 +++
>  drivers/infiniband/core/uverbs_ioctl.c        |  2 +-
>  include/linux/mm.h                            | 22 ++++++
>  init/main.c                                   | 24 +++++++
>  mm/dmapool.c                                  |  4 +-
>  mm/page_alloc.c                               | 71 +++++++++++++++++--
>  mm/slab.c                                     | 16 ++++-
>  mm/slab.h                                     | 19 +++++
>  mm/slub.c                                     | 43 +++++++++--
>  net/core/sock.c                               |  2 +-
>  security/Kconfig.hardening                    | 29 +++++++++
>  12 files changed, 204 insertions(+), 19 deletions(-)
> ---
>  v3: dropped __GFP_NO_AUTOINIT patches
>  v5: dropped support for SLOB allocator, handle SLAB_TYPESAFE_BY_RCU
>  v6: changed wording in boot-time message
>  v7: dropped the test_meminit.c patch (picked by Andrew Morton already),
>      minor wording changes
>  v8: fixes for interoperability with other heap debugging features
> --
> 2.22.0.410.gd8fdbe21b5-goog
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

