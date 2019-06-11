Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 134D7C43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 10:19:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC3FC205F4
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 10:19:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC3FC205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 67E7B6B0005; Tue, 11 Jun 2019 06:19:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 607B86B0006; Tue, 11 Jun 2019 06:19:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CFB36B0007; Tue, 11 Jun 2019 06:19:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id F2BB66B0005
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 06:19:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y3so8591070edm.21
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 03:19:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=cqgnL/EYzNk8EhINHvBbAgA/qxmIwSRASlgqfrCxBXg=;
        b=g10RAzPwU1iFA4kCqf1mOagg+ABa7DrJ6tCq0nuh7En54kqOGxJkYg4IXUU0sSqRA7
         P3kalFU2cG99G6rJ/go+HZZAoLgzT71BuAipbZcjYebTcCIOKUD/b2hEYp3OTAAUjziu
         nI2h8Z0XvWwcqp1dIHWdTfVQbFQOvgcuttOeAcJxzWwaNDuia6wVJrygPtM61rrh8X7A
         VXoedBE9djKeGAp+IxNXJbDT/HbxSvvLUjFuysyKqIwC2JfXRZYdwaIsCL2p01yvXPQx
         0ZK/DxIkImjl58otwYfU73LEB0o3r4vA2+iD7QnxPO0rUMH5yq/TqoX/0pwvP6d4+AHi
         pBsQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
X-Gm-Message-State: APjAAAW8Us2SDPc6/DfJY9nX04B6VrnRaRfIUYfBj7391Yk4WxOwcjyX
	eJuNCIOU+IoKRP1o7i/id1ImiByZxn6X74IoPxXgb/Jn4L8xQXYTtGeopr9PG4ptWLg3p7084Xd
	ZriNN9PxTUzaZ+I2+L7ZmqICBTX2kiBhB4g6SqHVAgRt+T83QDPEu3OAEfP3r3/f0ww==
X-Received: by 2002:a17:906:4948:: with SMTP id f8mr16488340ejt.79.1560248368547;
        Tue, 11 Jun 2019 03:19:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyDem/uLNI3hC+IR0meQuU0TDx6Ih5/SbDmWep1xaE2P0tsDn6JUJt2JD0whCjsMjgr69Y
X-Received: by 2002:a17:906:4948:: with SMTP id f8mr16488298ejt.79.1560248367885;
        Tue, 11 Jun 2019 03:19:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560248367; cv=none;
        d=google.com; s=arc-20160816;
        b=oGrv1OwO2D0LaA1ORTmBzaJGcIF/uwIVSvLwdtn3BNjlb35g99ii8YZxRbmLw4YYpn
         nkEGZp3sbCzTpMA8QwXwujkjiwvLpsZxcQX3DFHvyHAPrGONr74XymufvP7FYKQcmneq
         rmC7PnAp3lsLFH5jDZAsGOay1XWZMpoUBI8KTjiPIgAwsEXaBXOqkDJU/OTg79MnNl4W
         20qQpIQys5R+iGuSrxAFI6fKnOK2ruij4eTLT288ucqwsDM6W/wYxs1v4I1h1jbScF1F
         zPSFdGOkP2Cpa0d0yqVDPym8385Yf4cjgQpSKi+yLOA3xTK1cpyaM7xFSb6PUMYbvnLu
         fi5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=cqgnL/EYzNk8EhINHvBbAgA/qxmIwSRASlgqfrCxBXg=;
        b=fEcru1Dvzq1BG1Yvuq/w4ceZQ8zrVkUDleJBCYyc+eJZiMAhOf4yYgyj86M6GbQ/lZ
         ffoBvF3QaEicd28uUESB+valw+MW31K7VFwACnGHnodQoBlpD6yQjIR91KbEHFRu8hNo
         7AjH+MiFOujk5NVXKs2uU4IDEMxGvBCAVicuJlXRMTMxzJtZnjp2JkQkjPCCTzI3ifiE
         WoNdici4uP9X9rFMKKIJET9kSFHmOrsWO27dMtpLXjjaQrFUgADcTdh7aqkMvrmxwxV7
         yYZFNtXSn38kbmHELrXjMleywCAnqH9e9gopkuizvw2QwESwW3i6Ov2OCpvXcexKpQdw
         yOeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id k5si1926024ejc.241.2019.06.11.03.19.27
        for <linux-mm@kvack.org>;
        Tue, 11 Jun 2019 03:19:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B8662337;
	Tue, 11 Jun 2019 03:19:26 -0700 (PDT)
Received: from [10.1.29.141] (e121487-lin.cambridge.arm.com [10.1.29.141])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AC6DF3F557;
	Tue, 11 Jun 2019 03:21:07 -0700 (PDT)
Subject: Re: [PATCH 03/17] mm/nommu: fix the MAP_UNINITIALIZED flag
To: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>, linux-riscv@lists.infradead.org,
 uclinux-dev@uclinux.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190610221621.10938-1-hch@lst.de>
 <20190610221621.10938-4-hch@lst.de>
From: Vladimir Murzin <vladimir.murzin@arm.com>
Message-ID: <c902f38f-071d-cc83-801d-04d600f5ec12@arm.com>
Date: Tue, 11 Jun 2019 11:19:23 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190610221621.10938-4-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/10/19 11:16 PM, Christoph Hellwig wrote:
> We can't expose UAPI symbols differently based on CONFIG_ symbols, as
> userspace won't have them available.  Instead always define the flag,
> but only repsect it based on the config option.
           ^^^^^^^
           respect
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/xtensa/include/uapi/asm/mman.h    | 6 +-----
>  include/uapi/asm-generic/mman-common.h | 8 +++-----
>  mm/nommu.c                             | 4 +++-
>  3 files changed, 7 insertions(+), 11 deletions(-)

FWIW:

Reviewed-by: Vladimir Murzin <vladimir.murzin@arm.com>

> 
> diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
> index be726062412b..ebbb48842190 100644
> --- a/arch/xtensa/include/uapi/asm/mman.h
> +++ b/arch/xtensa/include/uapi/asm/mman.h
> @@ -56,12 +56,8 @@
>  #define MAP_STACK	0x40000		/* give out an address that is best suited for process/thread stacks */
>  #define MAP_HUGETLB	0x80000		/* create a huge page mapping */
>  #define MAP_FIXED_NOREPLACE 0x100000	/* MAP_FIXED which doesn't unmap underlying mapping */
> -#ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
> -# define MAP_UNINITIALIZED 0x4000000	/* For anonymous mmap, memory could be
> +#define MAP_UNINITIALIZED 0x4000000	/* For anonymous mmap, memory could be
>  					 * uninitialized */
> -#else
> -# define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
> -#endif
>  
>  /*
>   * Flags for msync
> diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
> index abd238d0f7a4..cb556b430e71 100644
> --- a/include/uapi/asm-generic/mman-common.h
> +++ b/include/uapi/asm-generic/mman-common.h
> @@ -19,15 +19,13 @@
>  #define MAP_TYPE	0x0f		/* Mask for type of mapping */
>  #define MAP_FIXED	0x10		/* Interpret addr exactly */
>  #define MAP_ANONYMOUS	0x20		/* don't use a file */
> -#ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
> -# define MAP_UNINITIALIZED 0x4000000	/* For anonymous mmap, memory could be uninitialized */
> -#else
> -# define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
> -#endif
>  
>  /* 0x0100 - 0x80000 flags are defined in asm-generic/mman.h */
>  #define MAP_FIXED_NOREPLACE	0x100000	/* MAP_FIXED which doesn't unmap underlying mapping */
>  
> +#define MAP_UNINITIALIZED 0x4000000	/* For anonymous mmap, memory could be
> +					 * uninitialized */
> +
>  /*
>   * Flags for mlock
>   */
> diff --git a/mm/nommu.c b/mm/nommu.c
> index d8c02fbe03b5..ec75a0dffd4f 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -1349,7 +1349,9 @@ unsigned long do_mmap(struct file *file,
>  	add_nommu_region(region);
>  
>  	/* clear anonymous mappings that don't ask for uninitialized data */
> -	if (!vma->vm_file && !(flags & MAP_UNINITIALIZED))
> +	if (!vma->vm_file &&
> +	    (!IS_ENABLED(CONFIG_MMAP_ALLOW_UNINITIALIZED) ||
> +	     !(flags & MAP_UNINITIALIZED)))
>  		memset((void *)region->vm_start, 0,
>  		       region->vm_end - region->vm_start);
>  
> 

