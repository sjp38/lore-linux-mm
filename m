Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A974AC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:02:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BABD20645
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:02:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="ChnBbYYc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BABD20645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D88128E0006; Mon, 24 Jun 2019 11:02:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D37C18E0002; Mon, 24 Jun 2019 11:02:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C266D8E0006; Mon, 24 Jun 2019 11:02:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 896FF8E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 11:02:22 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 59so7463985plb.14
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 08:02:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=GtAdqPjW6ZZZnXrgGtz9dHnmmTnu4keB507Xrm18218=;
        b=e/gTbeY89knFrbisT9hbAINqs+/fOFGfDEAg4Eg2CO+ponvO7JQl8apWAZ+fi1hKES
         qeXAoPDj3+JmVF2CM0fUPTD00u+siCRplGA0Zcm7vlJfjRviKPLCeGQYENDkfz9wbF3j
         0ydbmcZbhdsHjWYEuOmvKt17YMoJ0NinHHosJ7EN4uGxAhy3SBRvil8Ddg7HhNpTuBTq
         VKEmEAFBivOORwd/qgeoQreApP87b/ze+mU1boXIGZsqwDu+Iv83/yVXEyykQ5yDSfs4
         PZfzQNWNMl8z5xIvg7LCu1KeP2SnvR7NqDTo2FVgN7SvHosDpgXjcSwgEGBQlCqB500b
         AB8Q==
X-Gm-Message-State: APjAAAWki3SPx//grtjeXvSbbgp4goSnIWdaTB1ivhZIIBQjiJcrGZgP
	A6gCow7ZPBz2d7GYHXBXAEbO7g4IN0oOa7z07qzuMHvoGdWtfSz3jJuHQHlfUejQQrgT4dfKkvn
	uIbPv3O4QKK4bT2rjtVOcYRm/ACcPjdd7cLJrO9av6jRBdgqrxS0tdWkalIkm6ncppg==
X-Received: by 2002:a17:902:8ec3:: with SMTP id x3mr61078272plo.313.1561388542207;
        Mon, 24 Jun 2019 08:02:22 -0700 (PDT)
X-Received: by 2002:a17:902:8ec3:: with SMTP id x3mr61078198plo.313.1561388541563;
        Mon, 24 Jun 2019 08:02:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561388541; cv=none;
        d=google.com; s=arc-20160816;
        b=ZUIaeCk2Cjvcfh+oP+64FzDYutMKEvoqRF0hCDyY2y8EM/Nwl+K0vniSq4f1aX1Y1v
         Q7uHDNLH/TBx4WgIQdBuRlghhy+6uEG6JO3Cs18NIUOveUXqrT2imlSG1FLIY3Pj/Omy
         IbaWtJgpA6BY7mMHNJOXbcwNT5u29cFKAPi72QcCMGBgGT9rEPjZFGSMF1IJE+FbPPA+
         BcSoat28utCiE9lvHk4kAM7Br0qyX3QjzdapxLh0Fa5RkVrHG/IE2HfdeEY9ocT9hhpE
         Gn6v98euK3YXhfO8zHtVCElBG4tg2IyE+5PlNHUckJt6NkQK5wWtpKUyScKFebHHTMyB
         ssbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=GtAdqPjW6ZZZnXrgGtz9dHnmmTnu4keB507Xrm18218=;
        b=IDHXPQzHPohEAYwx0eX5zjDNhUz39g61rGQu5a/vTHhjGY3qA0s6ahQ+R9v2JgQfTg
         c1ex+FYQE3UVNpk3i53Qhdw3kYM7N+Aj9FbbvKC+dju72Debgl/qsj7r/XdHTGzMtzDD
         H6MdN+WzHfQpDhjLuVlciQjGc31L0Chm/KZmSV0tIhjgcVD3reHGB3OWFKJR9z8Y2uK0
         nNz/dgM+yTb/ftc9D5Sa7vY/EAa13zJrKrN+Da9mylRASE73blOpti+57N6E327j5Xm/
         2HMnGtKx8dvVruV4vnArIa+aixZe/9bOOeUXeqcgBS6n/xzIl06wdjs6J1C5CA86HJyA
         4WYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=ChnBbYYc;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bc5sor13331155plb.36.2019.06.24.08.02.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 08:02:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=ChnBbYYc;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=GtAdqPjW6ZZZnXrgGtz9dHnmmTnu4keB507Xrm18218=;
        b=ChnBbYYcZq0gQP/sJ3UOuMWBE4sFOJb179x3KxiYoIf9mz01hnbxknC2HoJWZ+GnKo
         I/gVcZavG+bqjHfCSPjI903PM2pF2P+rKnbbNQBP7YiqUkuVedhF+Zt+0nrsisSgO62h
         w1puy7E9AYi+Gooou5JDhG3yaU4cjhKpyOEpU=
X-Google-Smtp-Source: APXvYqw9zabTal+i8jDaBfZR0QmoB7d+QTrClEOLwXBQMsgoLsFLEgEQhYNwi/8CLPRMNc9iVSjF6A==
X-Received: by 2002:a17:902:7687:: with SMTP id m7mr67127539pll.310.1561388541281;
        Mon, 24 Jun 2019 08:02:21 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id e189sm5063967pfh.50.2019.06.24.08.02.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Jun 2019 08:02:20 -0700 (PDT)
Date: Mon, 24 Jun 2019 08:02:19 -0700
From: Kees Cook <keescook@chromium.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Catalin Marinas <catalin.marinas@arm.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v18 15/15] selftests, arm64: add a selftest for passing
 tagged pointers to kernel
Message-ID: <201906240802.29EB80F@keescook>
References: <cover.1561386715.git.andreyknvl@google.com>
 <0999c80cd639b78ae27c0674069d552833227564.1561386715.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0999c80cd639b78ae27c0674069d552833227564.1561386715.git.andreyknvl@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 04:33:00PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends kernel ABI to allow to pass
> tagged user pointers (with the top byte set to something else other than
> 0x00) as syscall arguments.
> 
> This patch adds a simple test, that calls the uname syscall with a
> tagged user pointer as an argument. Without the kernel accepting tagged
> user pointers the test fails with EFAULT.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  tools/testing/selftests/arm64/.gitignore      |  1 +
>  tools/testing/selftests/arm64/Makefile        | 11 +++++++
>  .../testing/selftests/arm64/run_tags_test.sh  | 12 ++++++++
>  tools/testing/selftests/arm64/tags_test.c     | 29 +++++++++++++++++++
>  4 files changed, 53 insertions(+)
>  create mode 100644 tools/testing/selftests/arm64/.gitignore
>  create mode 100644 tools/testing/selftests/arm64/Makefile
>  create mode 100755 tools/testing/selftests/arm64/run_tags_test.sh
>  create mode 100644 tools/testing/selftests/arm64/tags_test.c
> 
> diff --git a/tools/testing/selftests/arm64/.gitignore b/tools/testing/selftests/arm64/.gitignore
> new file mode 100644
> index 000000000000..e8fae8d61ed6
> --- /dev/null
> +++ b/tools/testing/selftests/arm64/.gitignore
> @@ -0,0 +1 @@
> +tags_test
> diff --git a/tools/testing/selftests/arm64/Makefile b/tools/testing/selftests/arm64/Makefile
> new file mode 100644
> index 000000000000..a61b2e743e99
> --- /dev/null
> +++ b/tools/testing/selftests/arm64/Makefile
> @@ -0,0 +1,11 @@
> +# SPDX-License-Identifier: GPL-2.0
> +
> +# ARCH can be overridden by the user for cross compiling
> +ARCH ?= $(shell uname -m 2>/dev/null || echo not)
> +
> +ifneq (,$(filter $(ARCH),aarch64 arm64))
> +TEST_GEN_PROGS := tags_test
> +TEST_PROGS := run_tags_test.sh
> +endif
> +
> +include ../lib.mk
> diff --git a/tools/testing/selftests/arm64/run_tags_test.sh b/tools/testing/selftests/arm64/run_tags_test.sh
> new file mode 100755
> index 000000000000..745f11379930
> --- /dev/null
> +++ b/tools/testing/selftests/arm64/run_tags_test.sh
> @@ -0,0 +1,12 @@
> +#!/bin/sh
> +# SPDX-License-Identifier: GPL-2.0
> +
> +echo "--------------------"
> +echo "running tags test"
> +echo "--------------------"
> +./tags_test
> +if [ $? -ne 0 ]; then
> +	echo "[FAIL]"
> +else
> +	echo "[PASS]"
> +fi
> diff --git a/tools/testing/selftests/arm64/tags_test.c b/tools/testing/selftests/arm64/tags_test.c
> new file mode 100644
> index 000000000000..22a1b266e373
> --- /dev/null
> +++ b/tools/testing/selftests/arm64/tags_test.c
> @@ -0,0 +1,29 @@
> +// SPDX-License-Identifier: GPL-2.0
> +
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <unistd.h>
> +#include <stdint.h>
> +#include <sys/prctl.h>
> +#include <sys/utsname.h>
> +
> +#define SHIFT_TAG(tag)		((uint64_t)(tag) << 56)
> +#define SET_TAG(ptr, tag)	(((uint64_t)(ptr) & ~SHIFT_TAG(0xff)) | \
> +					SHIFT_TAG(tag))
> +
> +int main(void)
> +{
> +	static int tbi_enabled = 0;
> +	struct utsname *ptr, *tagged_ptr;
> +	int err;
> +
> +	if (prctl(PR_SET_TAGGED_ADDR_CTRL, PR_TAGGED_ADDR_ENABLE, 0, 0, 0) == 0)
> +		tbi_enabled = 1;
> +	ptr = (struct utsname *)malloc(sizeof(*ptr));
> +	if (tbi_enabled)
> +		tagged_ptr = (struct utsname *)SET_TAG(ptr, 0x42);
> +	err = uname(tagged_ptr);
> +	free(ptr);
> +
> +	return err;
> +}
> -- 
> 2.22.0.410.gd8fdbe21b5-goog
> 

-- 
Kees Cook

