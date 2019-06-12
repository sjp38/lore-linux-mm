Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AADEAC31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:40:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7092D20B1F
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:40:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7092D20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 096C96B000E; Wed, 12 Jun 2019 10:40:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0475B6B0266; Wed, 12 Jun 2019 10:40:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E784D6B0269; Wed, 12 Jun 2019 10:40:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8D16B000E
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:40:24 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i9so10754574edr.13
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:40:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=QUclQzbR/gE703+0j0Dltao83T2ZQMnOXnwwPZMnVdc=;
        b=TJkH+TLmqVEaNCHmMZL7WkIpG5Tsqf2Urha+BZJAe3tlO+5ktVca3oJjeHZfuGrrCo
         nEvUWdVdXAF3ejQkSH7TsssykLBHboNtrvnfRCUQh/CIjoo8frdSw0vc6aWshTyXOwB1
         u/3JrZLrzgUupIlEEHiCiHZufEfCoFfFhORI8ygdc2CcQLYFRnqzGNG2Jn5m42fAuDpE
         XHKDTjUKJNUohWO+5KkYX+AqSBw94n0fJ1DmVbBr0TflcgrmgUZIrp8gJwJTXeNCX+/I
         ziro7J/D54HvoRyA8NrJHea4fniewvTtY9he70lBRn+WFG91FslIhPoCpE9jSMwssS/K
         AxZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAWBYwDBwTZiS5zow8xgqRbyBtJfBoIVFpjEUdW3HooLTQA0lQvL
	S7+5knc/nc5CwhQMEfFGkWFHoXz5XcQZTGmkElYpbuUpr4VLBwN+lu/0ae96K3JWCajZLo/03AN
	Pb48ydYf9hxLYU7tMHaxw8vAGIyW/AuECisrqFWzGwtXxDLUjo7H2kGAwmp9ndqlc1Q==
X-Received: by 2002:a50:8934:: with SMTP id e49mr60587854ede.156.1560350424082;
        Wed, 12 Jun 2019 07:40:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCZtyQPoAe9jLJc3llbGsyEXEySe6ljEXltH1sBqxwA7jKjQPxZiIT6Urb+C36Rz3wLi2/
X-Received: by 2002:a50:8934:: with SMTP id e49mr60587770ede.156.1560350423230;
        Wed, 12 Jun 2019 07:40:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560350423; cv=none;
        d=google.com; s=arc-20160816;
        b=Ey0iVQKnbhw8CDNAzRJVnzQ1sHp8hF7P/MuMtsIcqUq6Y2oXnQY0YhF8c73OXNHH16
         vJNC0s0mHQZqk6hYlOJOFc5m6jZyUWtEtEqYUOu0UR7VbNhZYvW/GNYogJYLaqRwMRkZ
         GXVehqnRZFM+nB7mQwOsVzkn4k/wv5ZTcQqiPu9jEN6wJpnkB7jnZ8GcHqHn9ZTFS6dq
         tnMuKVlGLMVL8tL6AajDHL0ESwMi5bFbdwBVdygAszAVKQ9V9rJ35dlxePxoT9PJXOWC
         R+LIKY8Tv+i1Zgatzu7cWh70EdRbyU3wX1Q753fGNVYXHVG20+HupD7GXaY5aQoj8Hva
         Q7Dw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=QUclQzbR/gE703+0j0Dltao83T2ZQMnOXnwwPZMnVdc=;
        b=HIxXmSN+oh2MuEcpyU28pgBmXvJcikgSh9JHAe6RgKpXexMUVIybACn7GLKEI1VBXt
         kPREQ1n36+vHW37BHQy0gMkaNKEWFZF0rn5ji5SQb0D5GWKJZdHshNFW3FTgxYS7m76d
         knaXMNNfw7xlnLRu6cscrPAaVr/S4SDbXtz9+ge4CB/K3ZCnXnWzQZZfSM3iJeWwuAJ8
         Sl0f6GG6Fwzv3n5m/aW4z/InArV0+U+eDBSFXJTZlHkddyi3sfd8JicdXZbTfcWObOSt
         7fjsiTcyEc4NH+w0KUp6mLBJx2xuQaVN7hre2mplX/Q2RUe5CU6RdBZuzBp0g59pYKWB
         Kw1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id c11si6010026ede.72.2019.06.12.07.40.22
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 07:40:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 373762B;
	Wed, 12 Jun 2019 07:40:22 -0700 (PDT)
Received: from [10.1.196.72] (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 9DE913F557;
	Wed, 12 Jun 2019 07:40:17 -0700 (PDT)
Subject: Re: [PATCH v17 08/15] userfaultfd, arm64: untag user pointers
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
 <e2f35a0400150594a39d9c3f4b3088601fd5dc30.1560339705.git.andreyknvl@google.com>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <48893efc-039a-f7e8-19f0-1bd7b188b2c1@arm.com>
Date: Wed, 12 Jun 2019 15:40:16 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <e2f35a0400150594a39d9c3f4b3088601fd5dc30.1560339705.git.andreyknvl@google.com>
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
> userfaultfd code use provided user pointers for vma lookups, which can
> only by done with untagged pointers.
> 
> Untag user pointers in validate_range().
> 
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>

> ---
>  fs/userfaultfd.c | 22 ++++++++++++----------
>  1 file changed, 12 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 3b30301c90ec..24d68c3b5ee2 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -1263,21 +1263,23 @@ static __always_inline void wake_userfault(struct userfaultfd_ctx *ctx,
>  }
>  
>  static __always_inline int validate_range(struct mm_struct *mm,
> -					  __u64 start, __u64 len)
> +					  __u64 *start, __u64 len)
>  {
>  	__u64 task_size = mm->task_size;
>  
> -	if (start & ~PAGE_MASK)
> +	*start = untagged_addr(*start);
> +
> +	if (*start & ~PAGE_MASK)
>  		return -EINVAL;
>  	if (len & ~PAGE_MASK)
>  		return -EINVAL;
>  	if (!len)
>  		return -EINVAL;
> -	if (start < mmap_min_addr)
> +	if (*start < mmap_min_addr)
>  		return -EINVAL;
> -	if (start >= task_size)
> +	if (*start >= task_size)
>  		return -EINVAL;
> -	if (len > task_size - start)
> +	if (len > task_size - *start)
>  		return -EINVAL;
>  	return 0;
>  }
> @@ -1327,7 +1329,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
>  		goto out;
>  	}
>  
> -	ret = validate_range(mm, uffdio_register.range.start,
> +	ret = validate_range(mm, &uffdio_register.range.start,
>  			     uffdio_register.range.len);
>  	if (ret)
>  		goto out;
> @@ -1516,7 +1518,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
>  	if (copy_from_user(&uffdio_unregister, buf, sizeof(uffdio_unregister)))
>  		goto out;
>  
> -	ret = validate_range(mm, uffdio_unregister.start,
> +	ret = validate_range(mm, &uffdio_unregister.start,
>  			     uffdio_unregister.len);
>  	if (ret)
>  		goto out;
> @@ -1667,7 +1669,7 @@ static int userfaultfd_wake(struct userfaultfd_ctx *ctx,
>  	if (copy_from_user(&uffdio_wake, buf, sizeof(uffdio_wake)))
>  		goto out;
>  
> -	ret = validate_range(ctx->mm, uffdio_wake.start, uffdio_wake.len);
> +	ret = validate_range(ctx->mm, &uffdio_wake.start, uffdio_wake.len);
>  	if (ret)
>  		goto out;
>  
> @@ -1707,7 +1709,7 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
>  			   sizeof(uffdio_copy)-sizeof(__s64)))
>  		goto out;
>  
> -	ret = validate_range(ctx->mm, uffdio_copy.dst, uffdio_copy.len);
> +	ret = validate_range(ctx->mm, &uffdio_copy.dst, uffdio_copy.len);
>  	if (ret)
>  		goto out;
>  	/*
> @@ -1763,7 +1765,7 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
>  			   sizeof(uffdio_zeropage)-sizeof(__s64)))
>  		goto out;
>  
> -	ret = validate_range(ctx->mm, uffdio_zeropage.range.start,
> +	ret = validate_range(ctx->mm, &uffdio_zeropage.range.start,
>  			     uffdio_zeropage.range.len);
>  	if (ret)
>  		goto out;
> 

-- 
Regards,
Vincenzo

