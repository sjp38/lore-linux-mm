Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D71BAC04E53
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 01:02:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F55B20843
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 01:02:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="leKX6iwd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F55B20843
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29A1C6B0005; Wed, 15 May 2019 21:02:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24B256B0006; Wed, 15 May 2019 21:02:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13A026B0007; Wed, 15 May 2019 21:02:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id CFD776B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 21:02:04 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id f7so932206plm.15
        for <linux-mm@kvack.org>; Wed, 15 May 2019 18:02:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=kB1kmUsnU0wPfFGEdIrU26lZ3ENdFfZVOF7R429DJpY=;
        b=n0h/S75JVn8CcTNuLmwkb0kJmXToV73LCV5qBmq9RmuM1DjIKLvD8YY52r/wZOXERq
         3pG2RpfIuGu30F9qH/l3v0xB3tEA6zMCZD4k4yXsw0vZROl7WT1aOoPkXsP0PKIM+XsJ
         HGwgQRdmDQQoiPlATEQPbL891wD5ky2BuIPb+sl8dSl7qGVKrJKmcNQ7xrHfXaNl09tl
         lesTHRP2q0Axrzs3RmzX9KBAX6AQcvpkKthvFVmujWzdo76WnbXy/+rqWN5wV0+askIU
         R5C92LU7xmBxhNKkNIEhkcgtsMq9NrilxP81OfWhIVo8xi2aeT+zvoz4iSVLVB+OZgPK
         LbGw==
X-Gm-Message-State: APjAAAV7pT+oRqHfLr+IUXZWRWYuody6gJiWFjLOZDJ9K87qAQ+c5Hgy
	7V9+S4aVoE/O7DutipL4ZXJYTMG6sDI5DRdAB3bjNhEX605YjidAl/vU5UBEJzE7EcB5knT36JA
	gcCKUVlmULjuwjuY5/XXlnXts571o3Utbj6FET5kbqLsKIsuWuC4LwA4I4CFM3xz3XQ==
X-Received: by 2002:a63:9d8d:: with SMTP id i135mr47728871pgd.245.1557968524255;
        Wed, 15 May 2019 18:02:04 -0700 (PDT)
X-Received: by 2002:a63:9d8d:: with SMTP id i135mr47728795pgd.245.1557968523343;
        Wed, 15 May 2019 18:02:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557968523; cv=none;
        d=google.com; s=arc-20160816;
        b=0bbKGO3xw+HPk1qvFY2ZoY0Rkp4g0xGkkUeGEWZI3p64HufCkPI91HnoVKNSmpq8JR
         nlxRtRkwsgfw0d4r7lS4fcmdVG5wd8Px9uoRoMq0KxYIawA/Z8pSnAbS2KbURl6K7F7g
         l3TF6OLk78Jg2PrBMPmEqUqGOvmCUK6GboCInC7iWpxBlMUkucENq+VvMQOvzAqa8mdz
         vrRIyHLM57FoKUrGCTY7b+YwEnMbHEzR0fBeXYXIpmGkB34vZcXj82gxOlV4BeZWQleq
         7YZm+CiQTQX5naC9ajThLqSo4ikNYQcr4sqi5Xawu9m3edUenjHv4lszrfkzY2NGOeE6
         hayQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=kB1kmUsnU0wPfFGEdIrU26lZ3ENdFfZVOF7R429DJpY=;
        b=jq6BH4cmynW8HmWhGEJPyL1MkP+dVBpbpN2ciOeAPAdsqPUSkSf+Mb/uaLA69VUvN4
         cAkUXgZv9kmbnhgUqbWqHprGx4dwod+FVXNQNMAo8KpYrigyQjYfZbn5GVLzxHCNQyFD
         nUAev47xLI8rXcarEl/cQ29U2x7+J3onqUEEJIGCUTFRtcGpW3ZPaGmf4cHcH1tBmgi4
         R67Dbd9q6w7dzGt4JsZtWa52Znz90xPe+rerKDco2K2Yp2PxME6j8rGV6qrIzP8ClNgU
         3/BHQSwqnAGgozziwpUYfjcW9ZtJK6BEkMDjyIYe2UjGjXAfre1afsnFHEuwwio8nSn7
         pyzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=leKX6iwd;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i8sor3774107pgj.71.2019.05.15.18.02.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 18:02:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=leKX6iwd;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=kB1kmUsnU0wPfFGEdIrU26lZ3ENdFfZVOF7R429DJpY=;
        b=leKX6iwd+E3ikfGY1//ltoNgIH4UsQxaJiOP4LVdzgDaHwTPnmCflqgZj3iMSpPogi
         PgC4m5zp6O/OVfdH+hwsuGJbVzzncxBPRxzYWSA2cFKS10nMMGAdTlvTBBz9PRWqBtXG
         0IY/4ObX8iKZI38lWxYnqS+6NDlXUzJI3O9zY=
X-Google-Smtp-Source: APXvYqwVz17Dgzf/syT6+WT0zM62IWrmEQAWI9YG2skem8A0ptTGY41DM3GMUa2e6NgcM+k+1vVkWw==
X-Received: by 2002:a63:c046:: with SMTP id z6mr47778396pgi.387.1557968522985;
        Wed, 15 May 2019 18:02:02 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id e16sm3288629pgv.89.2019.05.15.18.02.01
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 15 May 2019 18:02:02 -0700 (PDT)
Date: Wed, 15 May 2019 18:02:00 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexander Potapenko <glider@google.com>
Cc: akpm@linux-foundation.org, cl@linux.com,
	kernel-hardening@lists.openwall.com,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>, Jann Horn <jannh@google.com>,
	linux-mm@kvack.org, linux-security-module@vger.kernel.org
Subject: Re: [PATCH v2 2/4] lib: introduce test_meminit module
Message-ID: <201905151752.2BD430A@keescook>
References: <20190514143537.10435-1-glider@google.com>
 <20190514143537.10435-3-glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190514143537.10435-3-glider@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 04:35:35PM +0200, Alexander Potapenko wrote:
> Add tests for heap and pagealloc initialization.
> These can be used to check init_on_alloc and init_on_free implementations
> as well as other approaches to initialization.

This is nice! Easy way to test the results. It might be helpful to show
here what to expect when loading this module:

with either init_on_alloc=1 or init_on_free=1, I happily see:

	test_meminit: all 10 tests in test_pages passed
	test_meminit: all 40 tests in test_kvmalloc passed
	test_meminit: all 20 tests in test_kmemcache passed
	test_meminit: all 70 tests passed!

and without:

	test_meminit: test_pages failed 10 out of 10 times
	test_meminit: test_kvmalloc failed 40 out of 40 times
	test_meminit: test_kmemcache failed 10 out of 20 times
	test_meminit: failures: 60 out of 70


> 
> Signed-off-by: Alexander Potapenko <glider@google.com>

Reviewed-by: Kees Cook <keescook@chromium.org>
Tested-by: Kees Cook <keescook@chromium.org>

note below...

> [...]
> diff --git a/lib/test_meminit.c b/lib/test_meminit.c
> new file mode 100644
> index 000000000000..67d759498030
> --- /dev/null
> +++ b/lib/test_meminit.c
> @@ -0,0 +1,205 @@
> +// SPDX-License-Identifier: GPL-2.0
> [...]
> +module_init(test_meminit_init);

I get a warning at build about missing the license:

WARNING: modpost: missing MODULE_LICENSE() in lib/test_meminit.o

So, following the SPDX line, just add:

MODULE_LICENSE("GPL");

-- 
Kees Cook

