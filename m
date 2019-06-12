Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3ABF4C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:28:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0731208CA
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:28:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0731208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DD176B000D; Wed, 12 Jun 2019 10:28:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 88CEE6B000E; Wed, 12 Jun 2019 10:28:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 756756B0010; Wed, 12 Jun 2019 10:28:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 26B886B000D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:28:24 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b3so25153978edd.22
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:28:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Zqm922sctdNTWPEakgYopTZQEJllsntsHsG0UvCxGtg=;
        b=O+HCRcT2DeEwdVzWyQF9APAxOb/yJl1uxTHdwZQy74TEycbwmYlQjZH+Ux6vugpEE6
         ucwoQ8fUvP+d6jemKo9G2yxVFt67NE6/ooDaDsXsXz9JSGw1QoiLdgBLTTeknYtO7Q9E
         SJAZWVg77ik2zrxfPCJ1b3c0Gb3Ak1yLTxXeSYibi2XI1Dy9ZZrMjeyDPxM/oM+ePZPH
         dmD1dFbGZTR6MPdmZOyqY4yle2xwtGv+g3EoUTYpTQ8iViAjzHE0JuTLB8yhsCzJ5S90
         Ta3BjNPckHa/UBNA6zFnpbgvmUSCXD7kvfEinBRiqeZ8iADNJwZCkkOTUfFpm2xYNoLf
         I07Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAXkFpATa+N8QESjES/v+9T4TWWeb8e+g9BZC1lxXR1D4MhL2DZf
	tFelMySD8P2Hy3pzJd9J/soWbxcHDHHA7wJpuCtBEQscBeGF+TBRVpzYzqmMqb2x67UMkOFcq7T
	y9k3M0zptEK+dovb6nZQPtQynXJvJRdstWBCyP0ByKjs5l33HOhuuuSpIX4i1jdKfGg==
X-Received: by 2002:a50:89a2:: with SMTP id g31mr54210062edg.93.1560349703722;
        Wed, 12 Jun 2019 07:28:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyipuFAXnxhDqAsWqTn+Xn9VujOkr1DOwYj/ijVAakD4HWbJxZMEOaU7OQtWcLt2YzKcJkj
X-Received: by 2002:a50:89a2:: with SMTP id g31mr54210002edg.93.1560349703068;
        Wed, 12 Jun 2019 07:28:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560349703; cv=none;
        d=google.com; s=arc-20160816;
        b=CZheJY2Xl/4NDiUr94v7273kLXIF+vO/3jKe8wzBSzLuJE9qwfBAW5gj2/TRVtq8AD
         yFULfvN4buFB6W9NLSygKzsWd1BBBgVPcX/Q/gVATmCkb19wQTeDcNTVEGZtUx0jeN6I
         Zi2SVxAer2dyavQwHmpWxifiP/FCm2JnA9kKwr2uzcFdFIji2MMaXRc/TkdoI70qT3sm
         fQou1PUG3k021qVApZj9Gn8krXcBAKkifiw7Jdja+ZFOLOILPZkAs4nUyaUbrkldPyRe
         Dj2hPHwcvo2gicxJRX5ArwTGbDYzOZZq8IQHm6E9LeijaTxhXMqqDMMyC8gk8BAGptFI
         iHBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Zqm922sctdNTWPEakgYopTZQEJllsntsHsG0UvCxGtg=;
        b=UBEOR+It6FsgbXWHAdfTwha5htI6j7wSu/COnPDRRmavM2kV5ASfxMHmVAaoDUdafR
         4pCGeNsg3N+axCzDDPTKVG1howvJv/JhzqzM9pcHGg8CRTWw8B0+hOwIh89vBMud9nVK
         lb3bp1WrNTU7Wuia90J67LdrvrS2pDqJ7UA3GhotPQBP7ZtaMw38ZdmlFDVtz+6jgrY+
         9WdORIcC+go2BpmiJaB/boT21z0vekmAPZm7RqTn+W41RZ1J7DERVSOe/xdeZ/Gie7Fr
         ovv7HGHxD3Xp9GhP/k9LFlaUfZvw2PR60XbaYIqVcCKlBokIPdBB6gaeIZ4GK+NJbj8A
         Qj5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id q40si1904701edd.256.2019.06.12.07.28.22
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 07:28:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EFE382B;
	Wed, 12 Jun 2019 07:28:21 -0700 (PDT)
Received: from [10.1.196.72] (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E45733F557;
	Wed, 12 Jun 2019 07:28:16 -0700 (PDT)
Subject: Re: [PATCH v17 02/15] lib, arm64: untag user pointers in strn*_user
To: Andrey Konovalov <andreyknvl@google.com>,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
 dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
 linux-media@vger.kernel.org, kvm@vger.kernel.org,
 linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>,
 Felix Kuehling <Felix.Kuehling@amd.com>,
 Alexander Deucher <Alexander.Deucher@amd.com>,
 Christian Koenig <Christian.Koenig@amd.com>,
 Mauro Carvalho Chehab <mchehab@kernel.org>,
 Jens Wiklander <jens.wiklander@linaro.org>,
 Alex Williamson <alex.williamson@redhat.com>,
 Leon Romanovsky <leon@kernel.org>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
 Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>,
 enh <enh@google.com>, Jason Gunthorpe <jgg@ziepe.ca>,
 Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>,
 Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>,
 Lee Smith <Lee.Smith@arm.com>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Jacob Bramley <Jacob.Bramley@arm.com>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Robin Murphy <robin.murphy@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>,
 Szabolcs Nagy <Szabolcs.Nagy@arm.com>
References: <cover.1560339705.git.andreyknvl@google.com>
 <a76c014f9b12a082d31ef1459907cabdab78491e.1560339705.git.andreyknvl@google.com>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <0bbc5f4f-9812-463c-48c1-4929bef801da@arm.com>
Date: Wed, 12 Jun 2019 15:28:15 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <a76c014f9b12a082d31ef1459907cabdab78491e.1560339705.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 12/06/2019 12:43, Andrey Konovalov wrote:
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
> 
> Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
> Acked-by: Kees Cook <keescook@chromium.org>
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>

> ---
>  lib/strncpy_from_user.c | 3 ++-
>  lib/strnlen_user.c      | 3 ++-
>  2 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/lib/strncpy_from_user.c b/lib/strncpy_from_user.c
> index 023ba9f3b99f..dccb95af6003 100644
> --- a/lib/strncpy_from_user.c
> +++ b/lib/strncpy_from_user.c
> @@ -6,6 +6,7 @@
>  #include <linux/uaccess.h>
>  #include <linux/kernel.h>
>  #include <linux/errno.h>
> +#include <linux/mm.h>
>  
>  #include <asm/byteorder.h>
>  #include <asm/word-at-a-time.h>
> @@ -108,7 +109,7 @@ long strncpy_from_user(char *dst, const char __user *src, long count)
>  		return 0;
>  
>  	max_addr = user_addr_max();
> -	src_addr = (unsigned long)src;
> +	src_addr = (unsigned long)untagged_addr(src);
>  	if (likely(src_addr < max_addr)) {
>  		unsigned long max = max_addr - src_addr;
>  		long retval;
> diff --git a/lib/strnlen_user.c b/lib/strnlen_user.c
> index 7f2db3fe311f..28ff554a1be8 100644
> --- a/lib/strnlen_user.c
> +++ b/lib/strnlen_user.c
> @@ -2,6 +2,7 @@
>  #include <linux/kernel.h>
>  #include <linux/export.h>
>  #include <linux/uaccess.h>
> +#include <linux/mm.h>
>  
>  #include <asm/word-at-a-time.h>
>  
> @@ -109,7 +110,7 @@ long strnlen_user(const char __user *str, long count)
>  		return 0;
>  
>  	max_addr = user_addr_max();
> -	src_addr = (unsigned long)str;
> +	src_addr = (unsigned long)untagged_addr(str);
>  	if (likely(src_addr < max_addr)) {
>  		unsigned long max = max_addr - src_addr;
>  		long retval;
> 

-- 
Regards,
Vincenzo

