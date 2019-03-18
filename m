Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9FDEC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 11:33:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 894A820863
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 11:33:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 894A820863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 233426B0003; Mon, 18 Mar 2019 07:33:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E0D46B0006; Mon, 18 Mar 2019 07:33:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F9396B0007; Mon, 18 Mar 2019 07:33:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id AF61E6B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 07:33:26 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id x15so3386774wmc.1
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 04:33:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=bxcVp1aXU07AX4ga6Cz1gLFYwiqZzn/6kcogjfOgwOs=;
        b=k6VF8KOfyfD9XHssTbzUPsY8sYoJg0P/jXU8gVTb5kRgmQRDiwhVaT840UrRezvSiU
         HMtTtYfCy9UwssN2rmZt0kMT0TtsJ8uaaJtLreS/IygXmXiqKgPbV1UbrPITs/OJo+La
         LR6GpbyfgKOYAdZyK3CCpRuMujZ9vX+GXCkFSkfi2CtXr1QnM1No1YhM4rb8oEWTImIi
         uiTKgu/ta+2U6fzyfKhhwuz1lv7VhN+fQhDPfoyq91j/cpQtHP0GCxTug0RTK252eEpP
         xM6bxv6olHd9eTbjAM1NBGZ+aCBkGwv0Xro17dVMjYTR16EqWXLwUMzgAERTp3t8sDIe
         drCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
X-Gm-Message-State: APjAAAUFIbFPynhZzFVc1i7ji23vXuh0lGq4adzsdrN39jK0+TNq0WAF
	TIKH9daY/r7lpRC+TqOohv0Gcn/dN5PW1iMV0L1fK8I/kUK05/azGKKC3LGqwJUXSW2feWt3m3K
	zXr2GGGCEJOcxOZJw/V17XexnwuYTvi0H34dvLrgYMe/9XVX1USsQ+HaxKUlWvxXT7w==
X-Received: by 2002:a1c:700a:: with SMTP id l10mr11499796wmc.13.1552908806167;
        Mon, 18 Mar 2019 04:33:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyI2j0i7Kae6qec1sbxHfMSKnQxpIv1aAnz7c9S9SG7XJAnYR0F93IL0/cEsgzFJznn+zoR
X-Received: by 2002:a1c:700a:: with SMTP id l10mr11499744wmc.13.1552908805234;
        Mon, 18 Mar 2019 04:33:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552908805; cv=none;
        d=google.com; s=arc-20160816;
        b=lSYamjQq/X2wcuBxvKyObuO9F75m1O7ebaCSp9SDFJbvYOYZFzdu45oXKaMOBsgXuV
         yWgX64YPOTzFs5FOcMInZr+M6uyKzws6y+XuYICUJBXMOpNFgKIbiCP5RGaUgc1WMqvk
         GLGmr4snahq8NtwLcDI6q9lKbYq9a8+6K0fnKAqFl6WIpSM8mYFCYNJTYePH+7xJsGJj
         d/dyIXTfBkIuZw4sKWcnZo8/Tr3NK+lUCUB6HlThZ0zoEt/2wu0F1TzhqC7ebiOO+Jr1
         GFPDgFz2pv6KMasSqdKvc5Nso8TARPzFpQpR0yfXtPz5c6l9hT+KT3YvFh4zaqit5Gvp
         yhLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=bxcVp1aXU07AX4ga6Cz1gLFYwiqZzn/6kcogjfOgwOs=;
        b=RQ3HBjCsFf/R0eV69XjhmNdplWOvovqLMr9R58EcD7cyiQSqlztgUQZOtthdlVpGyz
         lzpB4MDpVi+Qa5vrSQjO10lInvjQVSSxW/eUweXjjZ6QpDLCcnbx/jASObE2NKirxF3d
         20jEq/KWoI+FOkrKk0cGgs2fcEdPTNnw/5/eL6p5JQ1zCXBv+vgIQJmmb0hcLXOf0oeZ
         UdCgiSYLVjROBHSyADst2+d4kObevcvbFxcvIjgEkEP5g9xOVtYTy/x8B6H6gliKoEfR
         UorQ0BW1SUvFalrU9Y4+MtkkN8cwBuK2wFVS86+vMPpNPX9IiAfPt242ntZZXmYITjyh
         XxgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t203si6144660wmt.39.2019.03.18.04.33.24
        for <linux-mm@kvack.org>;
        Mon, 18 Mar 2019 04:33:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id DDA741650;
	Mon, 18 Mar 2019 04:33:23 -0700 (PDT)
Received: from [10.1.199.35] (e107154-lin.cambridge.arm.com [10.1.199.35])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 973303F614;
	Mon, 18 Mar 2019 04:33:17 -0700 (PDT)
Subject: Re: [PATCH v11 03/14] lib, arm64: untag user pointers in strn*_user
To: Andrey Konovalov <andreyknvl@google.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>,
 Kate Stewart <kstewart@linuxfoundation.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Shuah Khan <shuah@kernel.org>, Vincenzo Frascino
 <vincenzo.frascino@arm.com>, Eric Dumazet <edumazet@google.com>,
 "David S. Miller" <davem@davemloft.net>, Alexei Starovoitov
 <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>,
 Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Arnaldo Carvalho de Melo <acme@kernel.org>,
 linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org,
 bpf@vger.kernel.org, linux-kselftest@vger.kernel.org,
 linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>,
 Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Jacob Bramley <Jacob.Bramley@arm.com>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Chintan Pandya <cpandya@codeaurora.org>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
 Dave Martin <Dave.Martin@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
References: <cover.1552679409.git.andreyknvl@google.com>
 <f7fa36ec55ed4b45f61d841f9b726772a04cc0a5.1552679409.git.andreyknvl@google.com>
From: Kevin Brodsky <kevin.brodsky@arm.com>
Message-ID: <5de82e7d-6091-e694-8397-fbcfd59f9d0b@arm.com>
Date: Mon, 18 Mar 2019 11:33:14 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <f7fa36ec55ed4b45f61d841f9b726772a04cc0a5.1552679409.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 15/03/2019 19:51, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
>
> strncpy_from_user and strnlen_user accept user addresses as arguments, and
> do not go through the same path as copy_from_user and others, so here we
> need to handle the case of tagged user addresses separately.
>
> Untag user pointers passed to these functions.
>
> Note, that this patch only temporarily untags the pointers to perform
> validity checks, but then uses them as is to perform user memory accesses.

Thank you for this new version, looks good to me.

To give a bit of context to the readers, I asked Andrey to make this change, because 
it makes a difference with hardware memory tagging. Indeed, in that situation, it is 
always preferable to access the memory using the user-provided tag, so that tag 
checking can take place; if there is a mismatch, a tag fault will occur (which is 
handled in a way similar to a page fault). It is also preferable not to assume that 
an untagged user pointer (tag 0x0) bypasses tag checks.

Kevin

>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>   lib/strncpy_from_user.c | 3 ++-
>   lib/strnlen_user.c      | 3 ++-
>   2 files changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/lib/strncpy_from_user.c b/lib/strncpy_from_user.c
> index 58eacd41526c..6209bb9507c7 100644
> --- a/lib/strncpy_from_user.c
> +++ b/lib/strncpy_from_user.c
> @@ -6,6 +6,7 @@
>   #include <linux/uaccess.h>
>   #include <linux/kernel.h>
>   #include <linux/errno.h>
> +#include <linux/mm.h>
>   
>   #include <asm/byteorder.h>
>   #include <asm/word-at-a-time.h>
> @@ -107,7 +108,7 @@ long strncpy_from_user(char *dst, const char __user *src, long count)
>   		return 0;
>   
>   	max_addr = user_addr_max();
> -	src_addr = (unsigned long)src;
> +	src_addr = (unsigned long)untagged_addr(src);
>   	if (likely(src_addr < max_addr)) {
>   		unsigned long max = max_addr - src_addr;
>   		long retval;
> diff --git a/lib/strnlen_user.c b/lib/strnlen_user.c
> index 1c1a1b0e38a5..8ca3d2ac32ec 100644
> --- a/lib/strnlen_user.c
> +++ b/lib/strnlen_user.c
> @@ -2,6 +2,7 @@
>   #include <linux/kernel.h>
>   #include <linux/export.h>
>   #include <linux/uaccess.h>
> +#include <linux/mm.h>
>   
>   #include <asm/word-at-a-time.h>
>   
> @@ -109,7 +110,7 @@ long strnlen_user(const char __user *str, long count)
>   		return 0;
>   
>   	max_addr = user_addr_max();
> -	src_addr = (unsigned long)str;
> +	src_addr = (unsigned long)untagged_addr(str);
>   	if (likely(src_addr < max_addr)) {
>   		unsigned long max = max_addr - src_addr;
>   		long retval;

