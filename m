Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38B63C48BD9
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 10:06:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F170B2083B
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 10:06:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="WJWfF4PV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F170B2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89CAD8E0003; Thu, 27 Jun 2019 06:06:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84CDC8E0002; Thu, 27 Jun 2019 06:06:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73B418E0003; Thu, 27 Jun 2019 06:06:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 51DA08E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 06:06:07 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id j140so535979vke.10
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 03:06:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=d3Ru/epqcKSdd6urtlGQx+RBPxT9C1o3y8n/GaRj0IQ=;
        b=IqfY+ziXNmTzcZH//IRMXI+ZOIKl7F80i+MaPGWYv3/T5Hn6Wk1mrBRdzRy8YHWSCB
         GJqjjYtgYAEl5Ci6dZLSYBJp+9v/+Joja/TvJ6YKQBYRPoZSoLHdJsaQFaTe4JQsLgo7
         zK4NqMKEdUbSdBDPVNcqgbJGmHzO4OEHO6LJyrIGdxZzNUmSDJDz+KBgmxKA37rkNeAy
         S0o+Q/n5AaGU2lC959JkZRgo755GFvEl/yVHeO5PY/WLKh0lv8jLRF3LL6ftcAf0V7Im
         +bFAKAWR4+J2NFFJ7O6ja8WYvJbgEtEhP2N4/M9mf5MpM313Dgcv5xEKYmOaaKgwLsF/
         SJOQ==
X-Gm-Message-State: APjAAAUULSypLLj4016tMsIz0YidgPv7YDFTpM1qMukeabYxNRns9SGa
	L2Cgi5LyaPK1Ffh37HSDpHKJBmafNitG9U3A0bwp8DFg7JHRmonl9ZTeaLyKyTLsPlq1ocUXM1g
	Ie4+TNzQAWjBboIvCPKgc939nRQ9bRqa3cDMHACZh8CDc5A1gUafU4ns+L9S8MGvDeA==
X-Received: by 2002:ab0:4a6:: with SMTP id 35mr1800931uaw.123.1561629967050;
        Thu, 27 Jun 2019 03:06:07 -0700 (PDT)
X-Received: by 2002:ab0:4a6:: with SMTP id 35mr1800903uaw.123.1561629966502;
        Thu, 27 Jun 2019 03:06:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561629966; cv=none;
        d=google.com; s=arc-20160816;
        b=ulJ+2obLBzt/jMLH0ZeT6ckzJQ7TWM4WTRxOy58UZBgk90APdhCyUIDr1wVQZKRHIi
         5GNIzqwkb3d2oQKMH+1/h8xy2BAARda18bc3PQpfiSljvH2c8fE5nTcTcIBe+oAZ5hW/
         zzokzf8BSHTvjq2R8vFn25mIyQarJQcxhc+og9y6aZdG/tm1iWdv6/QL7m5twtmOK1kJ
         V3rxX6YfPKl5FI8DPhICra4uWmjGaiX+ziWFJLxft8yIyXBfybISfngo0lsnodXRzhl5
         RYM2BxsQ9oPQuyg5WkTy9T42/MlAFDRhK9HTkjWCr9Q4yEP/gmGn3O4RJiISraKzTbd3
         Vo9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=d3Ru/epqcKSdd6urtlGQx+RBPxT9C1o3y8n/GaRj0IQ=;
        b=ZaXSPvK2guSKO7PXDg2y8kGbXc9zbnK/iHOmmqNxUJE8Xexv3Sb+QSLQxR1/lX72/G
         gN/GaauNwpYwWw9x+w1gXT6osFUzQj6F2sxn3H10H4qIuWeyhN6/jRdcvtEGHArhm90B
         u73e/r8v3JSfxbH4bY1M5cZWXpbC8tJUD2Nm3GN6NDGFja4jtKbWOIw42cxnFg7fC/yR
         hZj2CRNpkg9df3iYwtSpfxuitdDUj1d5gYOXzC3igNWg+SNCDVJFgXLuHbl9OCyMWqp1
         augPNuH4GV+0d2WtqP59KyZ5h5oY96cFLwrF4cg03IKN5xCDEg3o+qgO5Awkc08lwlMF
         JdxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WJWfF4PV;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n1sor806307uad.28.2019.06.27.03.06.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 03:06:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WJWfF4PV;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=d3Ru/epqcKSdd6urtlGQx+RBPxT9C1o3y8n/GaRj0IQ=;
        b=WJWfF4PVo0+95PvGT5hg2e4Xeu/u3T/2L4nJe69VTor4JJVxeDdlqbkIbil08BQcFq
         4WNizc0907sGpZ4DC8lCEjX+TqmlXc6gNLvaAixKpQpcDzXZ/csQnyTyJ9LyWnlKP5XK
         DfzkoEGW0SfvupgEB+clKSA6s//2MV85T08hiVgG34Mr+wMKt1v7ZYUd4D5ntgPfiIWT
         BQIO/8nMl3PMVW49ehtZAe939r/ma8rq5oFi0/exvVxF+r/wj/vRmU7YNMfyJa4c2yiW
         3wy4T1Z6Y7C0Nl2uGzKVuMCPOreBitQMkM5u9hBPZtV3zoOH/jyJBhyExmyBNM5uutqZ
         op6A==
X-Google-Smtp-Source: APXvYqy57wqyZI8LbJdgFCXKbEYhDUuoxxAgY0BAe68utv9cKzvGiUTExbd/UyfLgBKJ4hy2WFzLkW2oZMYLWpxsMYo=
X-Received: by 2002:ab0:64cc:: with SMTP id j12mr1845628uaq.110.1561629965902;
 Thu, 27 Jun 2019 03:06:05 -0700 (PDT)
MIME-Version: 1.0
References: <20190626121943.131390-1-glider@google.com> <20190626121943.131390-2-glider@google.com>
 <20190626162835.0947684d36ef01639f969232@linux-foundation.org>
In-Reply-To: <20190626162835.0947684d36ef01639f969232@linux-foundation.org>
From: Alexander Potapenko <glider@google.com>
Date: Thu, 27 Jun 2019 12:05:54 +0200
Message-ID: <CAG_fn=XF1C-3CCKGCHTrgCtcsh-u390hjM=rp5ZRv3ijTH5YgQ@mail.gmail.com>
Subject: Re: [PATCH v8 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Kees Cook <keescook@chromium.org>, 
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

On Thu, Jun 27, 2019 at 1:28 AM Andrew Morton <akpm@linux-foundation.org> w=
rote:
>
> On Wed, 26 Jun 2019 14:19:42 +0200 Alexander Potapenko <glider@google.com=
> wrote:
>
> >  v8:
> >   - addressed comments by Michal Hocko: revert kernel/kexec_core.c and
> >     apply initialization in dma_pool_free()
> >   - disable init_on_alloc/init_on_free if slab poisoning or page
> >     poisoning are enabled, as requested by Qian Cai
> >   - skip the redzone when initializing a freed heap object, as requeste=
d
> >     by Qian Cai and Kees Cook
> >   - use s->offset to address the freeptr (suggested by Kees Cook)
> >   - updated the patch description, added Signed-off-by: tag
>
> v8 failed to incorporate
>
> https://ozlabs.org/~akpm/mmots/broken-out/mm-security-introduce-init_on_a=
lloc=3D1-and-init_on_free=3D1-boot-options-fix.patch
> and
> https://ozlabs.org/~akpm/mmots/broken-out/mm-security-introduce-init_on_a=
lloc=3D1-and-init_on_free=3D1-boot-options-fix-2.patch
>
> it's conventional to incorporate such fixes when preparing a new
> version of a patch.
>

Ah, sorry about that.
I'll probably send out v9 with proper poison handling and will pick
those two patches as well.
--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

