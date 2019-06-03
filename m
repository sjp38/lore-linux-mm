Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17A1BC28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 10:51:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C238D280D2
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 10:51:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ui2HFJbr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C238D280D2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BEBB6B0269; Mon,  3 Jun 2019 06:51:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46F106B026B; Mon,  3 Jun 2019 06:51:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35E016B026C; Mon,  3 Jun 2019 06:51:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1469D6B0269
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 06:51:10 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id s2so12705710itl.7
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 03:51:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=JVlFqe9K3dpzMXBqO3onEIwgqdoMrC9jSiKlsTsm+KA=;
        b=eyCtCI4Ze3LqHTZdzqOiGuTx+8PVxn+ZofAa5l0j2vbvJksmePDT1tHKgQxB3a63I4
         HcpeEgiDCiwzyK8ApxPgLqEv/7u2y4Vgc3AigrubXaofQgHo5vneM/0tgivUbSJCCaaP
         KVsZgyZHp7k5hAsoXs70XZchic9b/56L2QOuniiyCjuVci9NytPDAr4gjyffpJnBwIsH
         Mt6L36HY5VbUHYMA4JEkZtlcWhwbVXEXRvSZFYcv4AqTlrL4e17AAtSgn0d3B6n6MBhH
         IdXydfCBpt62pzWQLG2zDzocpJbWSLElH6Dj35birQZgTVRYfCWedMi7I1kdkOoQ6/lz
         7hJA==
X-Gm-Message-State: APjAAAV4tDnZVjhJz3tfkMTf+zRf9aeFFSx0tMAPBG3gGsNmXRK16zwC
	wt3+7ykqGTdRJ/WmlNks8OWYlUQBnoPv8aKpIAiFfDWLKp/5gmxKUhWjOmSN65gPvNGYilmf8rA
	OYRywXYpjwpCPydlULnWxeEH2dUM75lWDRl6bTFpXFz944mapS7Dxz/2IQfyQmprDlg==
X-Received: by 2002:a24:ddd2:: with SMTP id t201mr16952906itf.107.1559559069816;
        Mon, 03 Jun 2019 03:51:09 -0700 (PDT)
X-Received: by 2002:a24:ddd2:: with SMTP id t201mr16952866itf.107.1559559069074;
        Mon, 03 Jun 2019 03:51:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559559069; cv=none;
        d=google.com; s=arc-20160816;
        b=ckEeh5mmFCmhsU/8DpNNUiEcgV2RTWCtSZmmFP9QY5s1AQZ6xW8mo9hiX7yCeX/VDX
         pX5RYfeYv7SCZIe1CGb2eEWg8/eFC6nVsVRHboEBYjDxMsJIPFltPw5E4tV44NTQ0Kji
         O86iw0HzWA5cpaKmq88Qy4Yzv0MXOIxZBhO+thIbA5DNLMwP7g83XJaEcjczt0setOPS
         yw0YOxnvh5JC6kiM0b7qoOxZsGsxS/l04MAuqyyzK7Qo5Avuklc9xoWcUHh+5JkRcnfg
         JCCxpTjMdmB0+9EhsLzCpMGQq88erpkDOZIGVxZwKpRIGZN9QsthPI6YtIK5pMOn0mRb
         hOMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=JVlFqe9K3dpzMXBqO3onEIwgqdoMrC9jSiKlsTsm+KA=;
        b=pFNIXlaSZIMfv0GFySVeHxp8+q/KDFzb3UUbTTMpQfcymmo+Ut6HbCUt3pIiVjHhjY
         6Smkgla9tzaWXWpK1ZEtebtZtZMCA49e37HSkFQI9dYUUvGGc6WkSvowu1DReRc0yU2F
         i/vg8/wgjl9ZI0zd/AC0kh3KryGDeaispvI+IYJmhT0mNLGPE3Jg8PGuKMSH84ibdqRV
         Day7TTLjQbxzAMpLZpyoCoXbxzbHkhj7xAQH3C4x/5Kqj3lNiYYzSi3jPWYXr5ZpQ5wz
         Ty1r+vTVWQ93VERVo18MqfbfkHLInIw94k+bzuRZNYrsoX9bWk2O8/Y2oNM53ZQgKUUO
         DxcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ui2HFJbr;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3sor3460348jaz.3.2019.06.03.03.51.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 03:51:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ui2HFJbr;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JVlFqe9K3dpzMXBqO3onEIwgqdoMrC9jSiKlsTsm+KA=;
        b=ui2HFJbrMgcbCdCR8lZgDXCgpVlJzmJXm/yjyCdTymvUROCbMa4Sn8GwY7R7f3EgB5
         3LXWiuPFHS2SgZK4rx+XDHRSzfiCdz0woo61aiXKUI1EZG9g5o5pWXCF2B6sRHkaatZz
         H6W6O9pmWNtDwlcayUPBzd1lk8bZSA+KMNMwU18GgkiK9gZ3B63kyCncCg+wcbusVhAN
         z83V7dT6ZkXWAdsr0+V3pUhf2OmJMgW5cxtMYwqRd4N6CMX/ffZqGL2hyONTMhikX59n
         /1fizGKsZ/2l5bRBYZNxNpyO/8E3AWVOQGJsb+/2E41ukfV+U6TiSMeUFUpRLPwjDI1Q
         mkkA==
X-Google-Smtp-Source: APXvYqzn0MRLC5N5kcLdHOnSaIKD6r+ynGuCBp764dPnHmhCDmTV9GXCNDSm1bMvcjXHvRrT92XY8gPCGXxPCmcW8f4=
X-Received: by 2002:a02:22c6:: with SMTP id o189mr3896549jao.35.1559559068416;
 Mon, 03 Jun 2019 03:51:08 -0700 (PDT)
MIME-Version: 1.0
References: <20190603091148.24898-1-anders.roxell@linaro.org>
In-Reply-To: <20190603091148.24898-1-anders.roxell@linaro.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 3 Jun 2019 12:50:56 +0200
Message-ID: <CACT4Y+Yes1Fxk24qemvB6b7NWzSD24ciqZsm0UN61jph46EdOQ@mail.gmail.com>
Subject: Re: [PATCH] mm: kasan: mark file report so ftrace doesn't trace it
To: Anders Roxell <anders.roxell@linaro.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, 
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 3, 2019 at 11:11 AM Anders Roxell <anders.roxell@linaro.org> wrote:
>
> __kasan_report() triggers ftrace and the preempt_count() in ftrace
> causes a call to __asan_load4(), breaking the circular dependency by
> making report as no trace for ftrace.
>
> Signed-off-by: Anders Roxell <anders.roxell@linaro.org>
> ---
>  mm/kasan/Makefile | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
> index 08b43de2383b..2b2da731483c 100644
> --- a/mm/kasan/Makefile
> +++ b/mm/kasan/Makefile
> @@ -3,12 +3,14 @@ KASAN_SANITIZE := n
>  UBSAN_SANITIZE_common.o := n
>  UBSAN_SANITIZE_generic.o := n
>  UBSAN_SANITIZE_generic_report.o := n
> +UBSAN_SANITIZE_report.o := n
>  UBSAN_SANITIZE_tags.o := n
>  KCOV_INSTRUMENT := n
>
>  CFLAGS_REMOVE_common.o = $(CC_FLAGS_FTRACE)
>  CFLAGS_REMOVE_generic.o = $(CC_FLAGS_FTRACE)
>  CFLAGS_REMOVE_generic_report.o = $(CC_FLAGS_FTRACE)
> +CFLAGS_REMOVE_report.o = $(CC_FLAGS_FTRACE)
>  CFLAGS_REMOVE_tags.o = $(CC_FLAGS_FTRACE)
>
>  # Function splitter causes unnecessary splits in __asan_load1/__asan_store1
> @@ -17,6 +19,7 @@ CFLAGS_REMOVE_tags.o = $(CC_FLAGS_FTRACE)
>  CFLAGS_common.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
>  CFLAGS_generic.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
>  CFLAGS_generic_report.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
> +CFLAGS_report.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
>  CFLAGS_tags.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
>
>  obj-$(CONFIG_KASAN) := common.o init.o report.o


Acked-by: Dmitry Vyukov <dvyukov@google.com>

Is it needed in all section? Or you just followed the pattern?
Different flag changes were initially done on very specific files for
specific reasons. E.g. -fno-conserve-stack is only for performance
reasons, so report* should not be there. But I see Peter already added
generic_report.o there. Perhaps we need to give up on selective
per-file changes, because this causes constant flow of new bugs in the
absence of testing and just do something like:

KASAN_SANITIZE := n
KCOV_INSTRUMENT := n
UBSAN_SANITIZE := n
CFLAGS_REMOVE = $(CC_FLAGS_FTRACE)
CFLAGS := $(call cc-option, -fno-conserve-stack -fno-stack-protector)

