Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C81C1C28CC5
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 03:56:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 759A22146F
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 03:56:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="dA3axcy3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 759A22146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F12E6B0276; Fri,  7 Jun 2019 23:56:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37A8D6B0278; Fri,  7 Jun 2019 23:56:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F6056B0279; Fri,  7 Jun 2019 23:56:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D60506B0276
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 23:56:27 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id bc12so2543920plb.0
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 20:56:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=Sg8hZnfRQyshVayh9AfBUaCUwYP0fG+PoifVRoQ1/2U=;
        b=F5aT4r/Nvfo7iTcfJ2T1re8Cox9HTOXRt4ouDEqMJt7xvFrmFYEeR6xHNOM+xyDWNl
         30vumQC25MKuIJy2XAR0XdUFV5MdtF3Mnmy2KmPrjE7RGDYioXBpOrPWMt2CQHsbEzzg
         Xe/IfB1jA3worldIVbAsD5uXkEyIelIs+PX5DblkYF323Jw2KvkSaRGgZWRbYC6/KHRQ
         JjudYyhvNQ4dYXANXSfF0eyyvoEAVKb24U+5cBPLSN8re5v8zRbUsMERePPJDwD78nQI
         I6cgPl5AQ1sxM2d/dgOK3qtfRROIRklJr5gegxG9OFxVLH+2siK5DSBC5CTt/by9Z/jz
         G06w==
X-Gm-Message-State: APjAAAVV1nSgmd/P8xFu0OW6onGwwVwCLTWWMwod+FMETwbd9KI4YUB3
	HX8hxOE4xC6gGg3lKvjUOl4DQjbjNx0/BpjkSoPAwqBECcdQHuWpy45/sH7+KJr5rX10CWXmEOA
	tDMnZNLc32OqJYKOC/mecMNxI20PGyfYKNggm9WopK9rBvi4KFmwGjf2BRP7HB2vkPQ==
X-Received: by 2002:a63:e10d:: with SMTP id z13mr5828275pgh.116.1559966187414;
        Fri, 07 Jun 2019 20:56:27 -0700 (PDT)
X-Received: by 2002:a63:e10d:: with SMTP id z13mr5828225pgh.116.1559966186349;
        Fri, 07 Jun 2019 20:56:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559966186; cv=none;
        d=google.com; s=arc-20160816;
        b=RhjxkOOJNaxzEgIRJ5pruH9b2vQw+On+Gd1WMXI7S4xfLj8kpPImFWacXVqieffg/4
         neClUL7EQd9lQbxGpLlc8YgCmlbMbcJjLxknn3Atyk8VXAW4kCAyUz/ycqILaEFN8VMO
         m5N8uBJJOrMpgPYvrAZNeqNpivjanz2qFJ5uT3kWSve5BjB6rHj9hQZY09gfyhUn0ul7
         Tozr3fwf4hW9NN6XkgJCQo3cHn/SMFXx7Am4XK+h0VP56un+dhkr/lVRLEoV6iJEA0hU
         LGAsysI/F3jcqLULmH/Z6EHwNKMcBhU2Did94E8gfEx7dAA2Qz4UNObGwxs86wemxfaF
         uhiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=Sg8hZnfRQyshVayh9AfBUaCUwYP0fG+PoifVRoQ1/2U=;
        b=ZuQNNQoNDkDZTBz1rDAmBFg2aHHJwQO9FbPj0dp2NU64s4iK8epgbUkJb91vQzjn1L
         Fa/zb50HolhMbt6e66e94BuhIgx0C+F4YagWy4YyaTs5c/bSIGKd8kku2HlSCv4wIILj
         cudwghPuoQQa+pHXCPqUoQKsRoAfuayCgba5LmQZCwvYkcOhIAfKq6moh1Lt4Jw/7alg
         xLydLDnAIrwTNFCKJffnCIS90wlQTwdNaADWQIOj/2VKe3+HJNfA6nURbQCRc3KER6V3
         oEQzTKNZkvvAlrKQB8INh17DIBEmuXoFSBaO0tdOvNWjrLxmkzSx3RbfP5sK1FveTUlg
         fT9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=dA3axcy3;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q9sor4737850plr.63.2019.06.07.20.56.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 20:56:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=dA3axcy3;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=Sg8hZnfRQyshVayh9AfBUaCUwYP0fG+PoifVRoQ1/2U=;
        b=dA3axcy3OSjQBllR3jO2rSL28yV4HEUJp/aPnDeszFXA+QJykqsQIUJ72CJFJfYEfw
         wdg907Km6KiqXC2789/OeRpcFlLBSZiEqKz1cQEJwy/XIHhLz8qR/HqqVrGp+0QeTjJc
         WftaB+rnktSZBXZ74MuozosAkMHfiOKMwo6jY=
X-Google-Smtp-Source: APXvYqxOa+LbIfSKzO98kP7ZimZglTjC5TFvL11aIkaQBz55ZFGw6dQUA6lPd2PVhnyZkGPHF3XY8g==
X-Received: by 2002:a17:902:6948:: with SMTP id k8mr59073078plt.81.1559966186036;
        Fri, 07 Jun 2019 20:56:26 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id c6sm6781898pfm.163.2019.06.07.20.56.25
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 20:56:25 -0700 (PDT)
Date: Fri, 7 Jun 2019 20:56:24 -0700
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
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Shuah Khan <shuah@kernel.org>
Subject: Re: [PATCH v16 16/16] selftests, arm64: add a selftest for passing
 tagged pointers to kernel
Message-ID: <201906072055.7DFED7B@keescook>
References: <cover.1559580831.git.andreyknvl@google.com>
 <9e1b5998a28f82b16076fc85ab4f88af5381cf74.1559580831.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9e1b5998a28f82b16076fc85ab4f88af5381cf74.1559580831.git.andreyknvl@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 06:55:18PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> This patch adds a simple test, that calls the uname syscall with a
> tagged user pointer as an argument. Without the kernel accepting tagged
> user pointers the test fails with EFAULT.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

I'm adding Shuah to CC in case she has some suggestions about the new
selftest.

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  tools/testing/selftests/arm64/.gitignore      |  1 +
>  tools/testing/selftests/arm64/Makefile        | 22 ++++++++++
>  .../testing/selftests/arm64/run_tags_test.sh  | 12 ++++++
>  tools/testing/selftests/arm64/tags_lib.c      | 42 +++++++++++++++++++
>  tools/testing/selftests/arm64/tags_test.c     | 18 ++++++++
>  5 files changed, 95 insertions(+)
>  create mode 100644 tools/testing/selftests/arm64/.gitignore
>  create mode 100644 tools/testing/selftests/arm64/Makefile
>  create mode 100755 tools/testing/selftests/arm64/run_tags_test.sh
>  create mode 100644 tools/testing/selftests/arm64/tags_lib.c
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
> index 000000000000..9dee18727923
> --- /dev/null
> +++ b/tools/testing/selftests/arm64/Makefile
> @@ -0,0 +1,22 @@
> +# SPDX-License-Identifier: GPL-2.0
> +
> +include ../lib.mk
> +
> +# ARCH can be overridden by the user for cross compiling
> +ARCH ?= $(shell uname -m 2>/dev/null || echo not)
> +
> +ifneq (,$(filter $(ARCH),aarch64 arm64))
> +
> +TEST_CUSTOM_PROGS := $(OUTPUT)/tags_test
> +
> +$(OUTPUT)/tags_test: tags_test.c $(OUTPUT)/tags_lib.so
> +	$(CC) -o $@ $(CFLAGS) $(LDFLAGS) $<
> +
> +$(OUTPUT)/tags_lib.so: tags_lib.c
> +	$(CC) -o $@ -shared $(CFLAGS) $(LDFLAGS) $^
> +
> +TEST_PROGS := run_tags_test.sh
> +
> +all: $(TEST_CUSTOM_PROGS)
> +
> +endif
> diff --git a/tools/testing/selftests/arm64/run_tags_test.sh b/tools/testing/selftests/arm64/run_tags_test.sh
> new file mode 100755
> index 000000000000..2bbe0cd4220b
> --- /dev/null
> +++ b/tools/testing/selftests/arm64/run_tags_test.sh
> @@ -0,0 +1,12 @@
> +#!/bin/sh
> +# SPDX-License-Identifier: GPL-2.0
> +
> +echo "--------------------"
> +echo "running tags test"
> +echo "--------------------"
> +LD_PRELOAD=./tags_lib.so ./tags_test
> +if [ $? -ne 0 ]; then
> +	echo "[FAIL]"
> +else
> +	echo "[PASS]"
> +fi
> diff --git a/tools/testing/selftests/arm64/tags_lib.c b/tools/testing/selftests/arm64/tags_lib.c
> new file mode 100644
> index 000000000000..8a674509216e
> --- /dev/null
> +++ b/tools/testing/selftests/arm64/tags_lib.c
> @@ -0,0 +1,42 @@
> +#include <stdlib.h>
> +
> +#define TAG_SHIFT	(56)
> +#define TAG_MASK	(0xffUL << TAG_SHIFT)
> +
> +void *__libc_malloc(size_t size);
> +void __libc_free(void *ptr);
> +void *__libc_realloc(void *ptr, size_t size);
> +void *__libc_calloc(size_t nmemb, size_t size);
> +
> +static void *tag_ptr(void *ptr)
> +{
> +	unsigned long tag = rand() & 0xff;
> +	if (!ptr)
> +		return ptr;
> +	return (void *)((unsigned long)ptr | (tag << TAG_SHIFT));
> +}
> +
> +static void *untag_ptr(void *ptr)
> +{
> +	return (void *)((unsigned long)ptr & ~TAG_MASK);
> +}
> +
> +void *malloc(size_t size)
> +{
> +	return tag_ptr(__libc_malloc(size));
> +}
> +
> +void free(void *ptr)
> +{
> +	__libc_free(untag_ptr(ptr));
> +}
> +
> +void *realloc(void *ptr, size_t size)
> +{
> +	return tag_ptr(__libc_realloc(untag_ptr(ptr), size));
> +}
> +
> +void *calloc(size_t nmemb, size_t size)
> +{
> +	return tag_ptr(__libc_calloc(nmemb, size));
> +}
> diff --git a/tools/testing/selftests/arm64/tags_test.c b/tools/testing/selftests/arm64/tags_test.c
> new file mode 100644
> index 000000000000..263b302874ed
> --- /dev/null
> +++ b/tools/testing/selftests/arm64/tags_test.c
> @@ -0,0 +1,18 @@
> +// SPDX-License-Identifier: GPL-2.0
> +
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <unistd.h>
> +#include <stdint.h>
> +#include <sys/utsname.h>
> +
> +int main(void)
> +{
> +	struct utsname *ptr;
> +	int err;
> +
> +	ptr = (struct utsname *)malloc(sizeof(*ptr));
> +	err = uname(ptr);
> +	free(ptr);
> +	return err;
> +}
> -- 
> 2.22.0.rc1.311.g5d7573a151-goog
> 

-- 
Kees Cook

