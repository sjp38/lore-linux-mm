Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.7 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54F58C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:44:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1ED6E22C7D
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:44:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1ED6E22C7D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA1A28E005E; Thu, 25 Jul 2019 05:44:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2BA88E0059; Thu, 25 Jul 2019 05:44:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CAE48E005E; Thu, 25 Jul 2019 05:44:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 654B48E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 05:44:39 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id s25so41767464qkj.18
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:44:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=Pof4060H+0WZOe3+TPTibKOgPWxidKdVhTeF5QVUjzM=;
        b=fZ79i6tOlKZp2fvvv2+ei8BPRmi4+YAnLPDPb+g9Aya2lDo/80rfEEghFtHqjxJkNT
         KEIPNaYLDLNjPwOTW/Qazn/dm72DSR07vvKH+KAvdZIybxZ/+BdyEzTuRG1UU4uxHTqD
         esxqFVwB1uEd2S/n6O6CbZ+QLJvwYw1ja6oF+yiTY+HeYRHm4zA2Do1JQSohSFvfHDoB
         CCEaWn9TuvLKqznlmRPCFzWp01bmTBxYBkEj0nGYl/OVlxdg65gxysb6H1hbTVp+hZda
         F5g+AUxDUCcHU+s/4NxpriLQdbdDEj4/oaknEShTPrJ08PIko5Np6iFnEFpjXmIXWQDe
         UXmQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Gm-Message-State: APjAAAXMvp6qpDU+aVRhWZdauqHcxYdu9YKwNHgNOh3h849Zic91kS/h
	YiXISv/BF7mA3gJAnZ+A46ni3Rx1m381tLhO1iNWajhtIrLSOOA24/+jajwBwx8TyLT7CKr5WwZ
	vEWyT+CgibMkVoiukTmRlZZdr6KNEPy7R5Jxy+DOniO7+d2/685Dzympgx5bo55c=
X-Received: by 2002:a37:e30b:: with SMTP id y11mr60675257qki.100.1564047876961;
        Thu, 25 Jul 2019 02:44:36 -0700 (PDT)
X-Received: by 2002:a37:e30b:: with SMTP id y11mr60675230qki.100.1564047876365;
        Thu, 25 Jul 2019 02:44:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564047876; cv=none;
        d=google.com; s=arc-20160816;
        b=HFLmp76Pqb+Iis/Xn7vRbLhAo2XMKZuhc8IoI4ncMLdjd88oHo6z0BwuOzXuEFLFaV
         LOSqPO0lblKzt23krYGtP6+UwOw0wOAMXtgyfqpz0prgj9NjjP9Wx+chHcI8FV1eViYg
         nGxKY4KgeUxjue45GpJS1vs4xdvNUOqfD+apC5+ZwRBU5VUNNUj7aogLdB4L99Z/JqOf
         CaCf227pRvt0wmlY+bl/UD8UOtW/VrJJWoVnLQFg2CZ23GFA78197O8H8gOAuHyiMytU
         sCI0t/5zGBAoqIsNa3DqMXyj2dFmXhxs7L5sHoRAyhaE0jFgwnwEwEtrMUjFweghrrRw
         XBwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=Pof4060H+0WZOe3+TPTibKOgPWxidKdVhTeF5QVUjzM=;
        b=V8O9CRR/2fm52BpsEWvjVThrK40lhmS/05YWsl3wUn4VLM+L6XaCWj/J+7BNWVSIal
         Rrwro7jvJUWP4SXn+X/eJhi4ZEfyHyf2uCoygiqnYlR0+WFYbEZ9wevEID0vzjGP1BcQ
         weue/JOIufwfxhH8H0MQbS6vD62aRTYmdDWLcTTZxSTW5Wg9t+cAwHayjFmFT0hwRuCi
         P4+0VfYOkqKhUaVM0Pwq73iHGuPZpwCDLYk5TaUmGq8zPTVT2EzgRhWxBj9t82wVXSlf
         nstuz3Z6ukw1RPgsDW98aCC1qmFfbYOTKaEZqnlRY0qiHpJsqBXKc5BmQ9hFU61dnXRc
         8qqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 8sor41786402qvi.5.2019.07.25.02.44.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 02:44:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Google-Smtp-Source: APXvYqyUkLcbdK/4xEhGdKUzXsZ+1mzTNgCWC6lvkMz7VFKnTAlDF0hLMNx8frRTnqWoLVrc/jQ4Y3tpPsOCvI0GlW4=
X-Received: by 2002:a0c:e952:: with SMTP id n18mr59867994qvo.63.1564047875857;
 Thu, 25 Jul 2019 02:44:35 -0700 (PDT)
MIME-Version: 1.0
References: <201907251734.6zC6jamU%lkp@intel.com>
In-Reply-To: <201907251734.6zC6jamU%lkp@intel.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 25 Jul 2019 11:44:19 +0200
Message-ID: <CAK8P3a3Mno1SWTcuAOT0Wa9VS15pdU6EfnkxLbDpyS55yO04+g@mail.gmail.com>
Subject: Re: [mmotm:master 16/120] include/linux/page-flags-layout.h:95:2:
 error: #error "Not enough bits in page flags"
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, 
	Andrey Konovalov <andreyknvl@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Linux Memory Management List <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 11:19 AM kbuild test robot <lkp@intel.com> wrote:
>
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   79b3e476080beb7faf41bddd6c3d7059cd1a5f31
> commit: b7ee4976128763d63714958ad3cb32a6e85554a1 [16/120] page flags: prioritize kasan bits over last-cpuid
> config: mips-fuloong2e_defconfig (attached as .config)
> compiler: mips64el-linux-gcc (GCC) 7.4.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout b7ee4976128763d63714958ad3cb32a6e85554a1
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.4.0 make.cross ARCH=mips
>
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
>
> All errors (new ones prefixed by >>):
>
>    In file included from include/linux/mm_types.h:15:0,
>                     from arch/mips/include/asm/vdso.h:10,
>                     from arch/mips/vdso/vdso.h:23,
>                     from arch/mips/vdso/gettimeofday.c:7:
> >> include/linux/page-flags-layout.h:95:2: error: #error "Not enough bits in page flags"
>     #error "Not enough bits in page flags"
>      ^~~~~
>
> vim +95 include/linux/page-flags-layout.h

I have reproduced the problem and found a solution, adding this in fixes the
build again.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/arch/mips/vdso/vdso.h b/arch/mips/vdso/vdso.h
index 14b1931be69c..b65b169778e3 100644
--- a/arch/mips/vdso/vdso.h
+++ b/arch/mips/vdso/vdso.h
@@ -9,6 +9,7 @@
 #if _MIPS_SIM != _MIPS_SIM_ABI64 && defined(CONFIG_64BIT)

 /* Building 32-bit VDSO for the 64-bit kernel. Fake a 32-bit Kconfig. */
+#define BUILD_VDSO32_64
 #undef CONFIG_64BIT
 #define CONFIG_32BIT 1
 #ifndef __ASSEMBLY__

