Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73339C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 22:40:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E7342070C
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 22:40:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E7342070C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=perches.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3A0E6B0003; Mon, 12 Aug 2019 18:40:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE90E6B0005; Mon, 12 Aug 2019 18:40:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFF996B0006; Mon, 12 Aug 2019 18:40:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0009.hostedemail.com [216.40.44.9])
	by kanga.kvack.org (Postfix) with ESMTP id 8DDF56B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 18:40:49 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 3F1C452D9
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 22:40:49 +0000 (UTC)
X-FDA: 75815247018.21.owner14_5e6f570b2d85f
X-HE-Tag: owner14_5e6f570b2d85f
X-Filterd-Recvd-Size: 4580
Received: from smtprelay.hostedemail.com (smtprelay0073.hostedemail.com [216.40.44.73])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 22:40:48 +0000 (UTC)
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
	by smtprelay05.hostedemail.com (Postfix) with ESMTP id 9180F18014D2B;
	Mon, 12 Aug 2019 22:40:48 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: cats09_5e29a3c464208
X-Filterd-Recvd-Size: 3130
Received: from XPS-9350.home (cpe-23-242-196-136.socal.res.rr.com [23.242.196.136])
	(Authenticated sender: joe@perches.com)
	by omf18.hostedemail.com (Postfix) with ESMTPA;
	Mon, 12 Aug 2019 22:40:46 +0000 (UTC)
Message-ID: <814c1b19141022946d3e0f7e24d69658d7a512e4.camel@perches.com>
Subject: Re: [PATCH v2] kbuild: Change fallthrough comments to attributes
From: Joe Perches <joe@perches.com>
To: Nathan Huckleberry <nhuck@google.com>, yamada.masahiro@socionext.com, 
	michal.lkml@markovi.net, Nathan Chancellor <natechancellor@gmail.com>
Cc: linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, clang-built-linux@googlegroups.com
Date: Mon, 12 Aug 2019 15:40:45 -0700
In-Reply-To: <20190812221416.139678-1-nhuck@google.com>
References: <20190812214711.83710-1-nhuck@google.com>
	 <20190812221416.139678-1-nhuck@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.30.5-0ubuntu0.18.10.1 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-08-12 at 15:14 -0700, Nathan Huckleberry wrote:
> Clang does not support the use of comments to label
> intentional fallthrough. This patch replaces some uses
> of comments to attributesto cut down a significant number
> of warnings on clang (from ~50000 to ~200). Only comments
> in commonly used header files have been replaced.
> 
> Since there is still quite a bit of noise, this
> patch moves -Wimplicit-fallthrough to
> Makefile.extrawarn if you are compiling with
> clang.

Unmodified clang does not emit this warning without a patch.

> diff --git a/Makefile b/Makefile
[]
> @@ -846,7 +846,11 @@ NOSTDINC_FLAGS += -nostdinc -isystem $(shell $(CC) -print-file-name=include)
>  KBUILD_CFLAGS += -Wdeclaration-after-statement
>  
>  # Warn about unmarked fall-throughs in switch statement.
> +# If the compiler is clang, this warning is only enabled if W=1 in
> +# Makefile.extrawarn
> +ifndef CONFIG_CC_IS_CLANG
>  KBUILD_CFLAGS += $(call cc-option,-Wimplicit-fallthrough,)
> +endif

It'd be better to remove CONFIG_CC_IS_CLANG everywhere
eventually as it adds complexity and makes .config files
not portable to multiple systems.

> diff --git a/include/linux/compiler_attributes.h b/include/linux/compiler_attributes.h
[]
> @@ -253,4 +253,8 @@
>   */
>  #define __weak                          __attribute__((__weak__))
>  
> +#if __has_attribute(fallthrough)
> +#define __fallthrough                   __attribute__((fallthrough))

This should be __attribute__((__fallthrough__))

And there is still no agreement about whether this should
be #define fallthrough or #define __fallthrough

https://lore.kernel.org/patchwork/patch/1108577/

> diff --git a/include/linux/jhash.h b/include/linux/jhash.h
[]
> @@ -86,19 +86,43 @@ static inline u32 jhash(const void *key, u32 length, u32 initval)
[]
> +	case 12:
> +		c += (u32)k[11]<<24;
> +		__fallthrough;

You might consider trying out the scripted conversion tool
attached to this email:

https://lore.kernel.org/lkml/61ddbb86d5e68a15e24ccb06d9b399bbf5ce2da7.camel@perches.com/



