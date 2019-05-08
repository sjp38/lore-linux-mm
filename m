Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEE43C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 19:02:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81C9F21019
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 19:02:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="m92uaGS7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81C9F21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E925D6B0003; Wed,  8 May 2019 15:02:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E432E6B0005; Wed,  8 May 2019 15:02:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D57BD6B0007; Wed,  8 May 2019 15:02:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id AD1976B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 15:02:56 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id u7so9308849vke.0
        for <linux-mm@kvack.org>; Wed, 08 May 2019 12:02:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=dX9oXO6R8RSoriR7UuMavFbYp9KwYJM8lFYFBoOuLJY=;
        b=P4/EHTfEd5M/l563nDUkHLTjmBkCdkKOr73WS/ri8feKfUQ6++/IrtdpUIrUvkcCgq
         KO6oW1VTjY/A41hIRuInT8enMxOHDmWqTET8JWQtyONReBS/UxO73W/zWCz6PhG5/PQz
         j/lbI5SSocVZfrD/Rw1lTcHUe0ndKCkdpfYjo5FDBIL8dttHFczR4xKx4UjI2Leb55lg
         Q27Z1P4m+zOAjfXHxADrZ/mwR1l1ZUoxmAojVGyvIzc+n1+Gxva83Zhhu9Cjs3x0SP5p
         q+FBHziuwbZ0rW8hf3Dd9+uUAM5g/9Dn/EQXSYHXF0aXlEAA1cRQA6IpVRSFr5odRF/6
         zk3A==
X-Gm-Message-State: APjAAAVS2C+RvQWoANYM27c/ULKNFEAuBgjOg9zZ/EtmZqgCVJHmRHhp
	2SW0biAAXYa0Siqrmw97RN1qpXmh+b1BB+ToLZd44DPKpfkzKXp5dZSJgCOxU5aWZae0ozTLD6j
	YftpqkKpTOX4SuAbxRgP/2tanN2jM5eRPsQHXsUjVmRbWotHhWyq7HCsDppj/ufhFfA==
X-Received: by 2002:a67:7a87:: with SMTP id v129mr4715209vsc.104.1557342176351;
        Wed, 08 May 2019 12:02:56 -0700 (PDT)
X-Received: by 2002:a67:7a87:: with SMTP id v129mr4715179vsc.104.1557342175656;
        Wed, 08 May 2019 12:02:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557342175; cv=none;
        d=google.com; s=arc-20160816;
        b=J17AaEbK01S+gNpWDq9EwC9Rzi8s094MJ6EXJCOLINDehsIdCy2DCqKHVviiGszF94
         L0t2N2aLKtWO7b9ck7058RwOYO5jwJXvdfi+VRqLKIFqkklqsQ8h2yzCRo6SYLwA/Dn/
         JdbVkLL8K0feo/Q1ovq6G7+CgY7WaPxDEHoyKRvBs3OaiVDAFiuXtIpp5NpuDXXG6iXt
         V20XzAM5+3C3b2WA5ULAfrzl2kbViOavrfIEdE7C8XXe1VOUQ51Qp9+B09Ac2UL/p+ce
         BM/ICwOg6HvgtUKQYjMoa6AChnU7x1vnzBQBB7Gk5syi1lGh+lqtoRmDNffDKCqdUluQ
         /Xtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=dX9oXO6R8RSoriR7UuMavFbYp9KwYJM8lFYFBoOuLJY=;
        b=SRu0qtkBHxPoZR2Ke4bjkwkdZ/gA+Ru/tAGAOvtnDuLp5YXqx8gbz8EiQ7DhcXoy4q
         YWbyNPsr/NukqtsnlG6UIh53dvMgzwggjvjMQr50hoKSxUT+EHi8eGKn8Qy/xyHNTZ26
         isCc+OpotUQBru57h0yYhtxoDoV7EofgIHbWVN2WmWfCY6fKYme4rAjE996qVPL8UgDo
         F1S4+oHNI/hgSAaJnHYkPpld4Kf8/MJwFE18JAEqF36RLsEqnCRaWxH+U1xG+PC0p6Bw
         U5oltQxIbwE8GdGNu4fiOcHN3Fn0KQ9vOaxOjLxqO8OD7OcCTBN70K9NfgZd4xOEzfoi
         JaJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=m92uaGS7;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b131sor5939036vkf.21.2019.05.08.12.02.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 May 2019 12:02:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=m92uaGS7;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=dX9oXO6R8RSoriR7UuMavFbYp9KwYJM8lFYFBoOuLJY=;
        b=m92uaGS7BzxI1wVpXXvaee5KcFPVbYEfR4QwuEzpRo01tnMlXnsfG1+9jSbDgVZcpc
         XNHNcYd8H5QtBO9qWK6wCVr9bpXIoXzsClBTyRoZZCbqfbL+fltIwZpitSG3qyPECNqE
         EJ6/PUuxsKSI0Z7dM32euMjjSJDl+Ux09evt4=
X-Google-Smtp-Source: APXvYqynTX0t8thHC9ry+m04eegMMXxlapOGiLU6D9tyGsOiIHP1IfUmfFJw5QnHCTT5MAIkQEF4qA==
X-Received: by 2002:a1f:3658:: with SMTP id d85mr14487493vka.71.1557342175052;
        Wed, 08 May 2019 12:02:55 -0700 (PDT)
Received: from mail-vs1-f44.google.com (mail-vs1-f44.google.com. [209.85.217.44])
        by smtp.gmail.com with ESMTPSA id x71sm971018vke.13.2019.05.08.12.02.51
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 12:02:51 -0700 (PDT)
Received: by mail-vs1-f44.google.com with SMTP id j184so13321302vsd.11
        for <linux-mm@kvack.org>; Wed, 08 May 2019 12:02:51 -0700 (PDT)
X-Received: by 2002:a67:f849:: with SMTP id b9mr15808201vsp.188.1557342170854;
 Wed, 08 May 2019 12:02:50 -0700 (PDT)
MIME-Version: 1.0
References: <20190508153736.256401-1-glider@google.com> <20190508153736.256401-2-glider@google.com>
In-Reply-To: <20190508153736.256401-2-glider@google.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 8 May 2019 12:02:39 -0700
X-Gmail-Original-Message-ID: <CAGXu5jKfxYfRQS+CouYZc8-BMEWR1U3kwshu4892pM0pmmACGw@mail.gmail.com>
Message-ID: <CAGXu5jKfxYfRQS+CouYZc8-BMEWR1U3kwshu4892pM0pmmACGw@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, 
	Linux-MM <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, James Morris <jmorris@namei.org>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 8, 2019 at 8:38 AM Alexander Potapenko <glider@google.com> wrote:
> The new options are needed to prevent possible information leaks and
> make control-flow bugs that depend on uninitialized values more
> deterministic.

I like having this available on both alloc and free. This makes it
much more configurable for the end users who can adapt to their work
loads, etc.

> Linux build with -j12, init_on_free=1:  +24.42% sys time (st.err 0.52%)
> [...]
> Linux build with -j12, init_on_alloc=1: +0.57% sys time (st.err 0.40%)

Any idea why there is such a massive difference here? This seems to
high just for cache-locality effects of touching all the freed pages.

-- 
Kees Cook

