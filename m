Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34EEDC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:27:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D143C20B1F
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:27:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D143C20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F80E6B0007; Wed, 12 Jun 2019 10:27:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A8136B000A; Wed, 12 Jun 2019 10:27:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 497F06B000D; Wed, 12 Jun 2019 10:27:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC9C16B0007
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:27:06 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b12so18849427eds.14
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:27:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=AAsGbSjrzJNC8UtXNhagwF0qpLPgD5tu0pqmHamUm44=;
        b=ntYNoimtCRC9racMo5NRVzRpP0zSJbmzeKocnRhC+JUhcLcoQqxId9BSkUkyWqVBSL
         zJ9VAioWcJOLRGZefD/wVEBY1NDtu5lNzjeLFaSdLpFUaIiomGWSl1iOoX/0uQtxauz7
         /nwg9B19kL+xPc+qhlbvbcD17VHwPPWMiysJN74TlVk47AB7s62V8hUXxMwu6xM9XpH7
         YZuEMFIEchkJ6FNfYENNqu1cF2WM8Z9D/l/BN0lZDGeO3pwRt9Zf65zJELu6Z8+l/aUb
         +I9A+RCCy00rrd43sGgDvZpWAZMOHtN7Rziiy2q/+q02PgrVVkNmOAaTY7+TJgeTYBs2
         6WyQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAX9OoLCzxwKh0tPcj1SaYgD0NSu5f1innXSCUJXaRpFH57xIN6f
	QMHFpr3+Iu48ajA20flX1LQ672Awg54X7+JMYYT6xRf2yivF3XW5sLtmtoohdVSzUVoqfjtQjFJ
	E6iaccEQb2ix8kQrmxNwl/touGiFqsinru1jeD6U8BJROmG+B6EU8DoXq04Tk7mJ4Hg==
X-Received: by 2002:a17:906:670c:: with SMTP id a12mr25057093ejp.290.1560349626496;
        Wed, 12 Jun 2019 07:27:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOzpGRoLkdxhuGC7Gcrc7oelPEFm+IM1Hc3Z9o4n3ZLixlG6BKt+NMkK2OeQOFWslc161o
X-Received: by 2002:a17:906:670c:: with SMTP id a12mr25057019ejp.290.1560349625694;
        Wed, 12 Jun 2019 07:27:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560349625; cv=none;
        d=google.com; s=arc-20160816;
        b=aLRC0+Dv1VZu7XqC64Hw02TXEW/kXHSqw28RO3OKbIvU6TMBgELiEbLjCEaXhaP6r6
         n673ciNlwHJ0ePkV8YHOt48eJYWwqCidcjofWDTqYX5zDdDLK02fGzOnYEZWtfw1OhBt
         IqK7uxyiV2NGZRWkI5EQvmuXJTaxbtS5px4B//WS7EsfQP5F2aqEO0eWbLUpioVKszqh
         7wCgZKc3lsSQf8/GxVd1OKMjA2WDuawEzdEpjUe8Mx3j9ERKHXQkU6Cn9nstLabfvucs
         ZHr7q0MJaOWtRtUmRC+d+kuiwfgt+oAXAoHusHqMwdkAgXbumg0J0o2JOcCpzay7O1Fz
         oaTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=AAsGbSjrzJNC8UtXNhagwF0qpLPgD5tu0pqmHamUm44=;
        b=UEt8V5H0fhLyHSXsemrCtqQOZQcPUCqXwN7BmYuzGCK564kTTv1wkRosCTEsnwjUgV
         eClSG7rp68DA9I/zcdGXSMCcXrxNLfzrZBludZlcbuCmiPmKrS3DUfJnCwm3u+i5TfDR
         9z9MdMqdvjgSSaju0TZGvBk9GVp1/5XbMuVCTIgC7ycLtYF9Fmy/UV4iGRLUOe+QolFW
         en4cltAakcNSIOJed9RWhdHeSTtCuLV9ptL/TLNaBOO6dTMVS74lDr+kjYGDGQmbcaA9
         iTbhCNWUFiY8XRtzYDqbqvkX29V68h15FgkkjXMZJdxy+ZYlu6aZIYJDc3HujBDl77sM
         kWug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id g23si8946489edg.314.2019.06.12.07.27.05
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 07:27:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A1BAA2B;
	Wed, 12 Jun 2019 07:27:04 -0700 (PDT)
Received: from [10.1.196.72] (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3DCE73F557;
	Wed, 12 Jun 2019 07:26:59 -0700 (PDT)
Subject: Re: [PATCH v17 01/15] arm64: untag user pointers in access_ok and
 __uaccess_mask_ptr
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
 <9ed583c1a3acf014987e3aef12249506c1c69146.1560339705.git.andreyknvl@google.com>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <52e93b24-3302-e890-5799-6502042ea5c9@arm.com>
Date: Wed, 12 Jun 2019 15:26:58 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <9ed583c1a3acf014987e3aef12249506c1c69146.1560339705.git.andreyknvl@google.com>
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
> copy_from_user (and a few other similar functions) are used to copy data
> from user memory into the kernel memory or vice versa. Since a user can
> provided a tagged pointer to one of the syscalls that use copy_from_user,
> we need to correctly handle such pointers.
> 
> Do this by untagging user pointers in access_ok and in __uaccess_mask_ptr,
> before performing access validity checks.
> 
> Note, that this patch only temporarily untags the pointers to perform the
> checks, but then passes them as is into the kernel internals.
> 
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>

> ---
>  arch/arm64/include/asm/uaccess.h | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
> index e5d5f31c6d36..df729afca0ba 100644
> --- a/arch/arm64/include/asm/uaccess.h
> +++ b/arch/arm64/include/asm/uaccess.h
> @@ -73,6 +73,8 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
>  {
>  	unsigned long ret, limit = current_thread_info()->addr_limit;
>  
> +	addr = untagged_addr(addr);
> +
>  	__chk_user_ptr(addr);
>  	asm volatile(
>  	// A + B <= C + 1 for all A,B,C, in four easy steps:
> @@ -226,7 +228,8 @@ static inline void uaccess_enable_not_uao(void)
>  
>  /*
>   * Sanitise a uaccess pointer such that it becomes NULL if above the
> - * current addr_limit.
> + * current addr_limit. In case the pointer is tagged (has the top byte set),
> + * untag the pointer before checking.
>   */
>  #define uaccess_mask_ptr(ptr) (__typeof__(ptr))__uaccess_mask_ptr(ptr)
>  static inline void __user *__uaccess_mask_ptr(const void __user *ptr)
> @@ -234,10 +237,11 @@ static inline void __user *__uaccess_mask_ptr(const void __user *ptr)
>  	void __user *safe_ptr;
>  
>  	asm volatile(
> -	"	bics	xzr, %1, %2\n"
> +	"	bics	xzr, %3, %2\n"
>  	"	csel	%0, %1, xzr, eq\n"
>  	: "=&r" (safe_ptr)
> -	: "r" (ptr), "r" (current_thread_info()->addr_limit)
> +	: "r" (ptr), "r" (current_thread_info()->addr_limit),
> +	  "r" (untagged_addr(ptr))
>  	: "cc");
>  
>  	csdb();
> 

-- 
Regards,
Vincenzo

