Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 812A0C28CC5
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 03:51:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 41AA92146F
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 03:51:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="RYl1PwRk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41AA92146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B21386B0276; Fri,  7 Jun 2019 23:51:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD10C6B0278; Fri,  7 Jun 2019 23:51:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 998F86B0279; Fri,  7 Jun 2019 23:51:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 610B86B0276
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 23:51:11 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id a21so2684788pgh.11
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 20:51:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=3wKfqS97rJvrbhUUDlvq7gOlHPn2Fxrd7rOcfg+ujIw=;
        b=kJ5vQRjXMkYFCcq85lLLqrHzTKD4LsAqJOZU2JachKeY0HYufQW9Miaf14ST2juMMI
         NKMGgjUdLQMDjOt9uibNW8AxO7Imh8O6CLm0BDeU5xhmTIOvhpkHUJ0eVSmveEwCdvUk
         Epx7fxg4jKrngGVxdI4dz7LFE2yI1xM6FXNtVHrpiX236DamOqLzaH/Ybn/EjOq+k6Ty
         9wZlJ6E3G9S2E06WY89K3K+dfNINMlzRYxXd56aMVo8+R6Uxzq2MVzqPucgYK4T2FliS
         k11IIkCYtlPlxEp1X7qLYn+cT8z7tckEgwqJMeMyENEmiv2kAJuB0vXGN08ElmzUxT0g
         9pEw==
X-Gm-Message-State: APjAAAVCffu/v7GZdiW1MwSukruziiKiLPwZH40nkjkFeaDMSQnQj01A
	QhuAMBOf1AbT5PqxQ9ediF+574G2eGGNfRfXwxOdljAx+1dSyn28R3l+YhnQWClDpjUiCh1IK5e
	zZc2dMB79pvV+MEyrSrQM2g82cVnghyR+m4MInWdOtxiU9pHQo7y+nfnpf7ZhovlfpA==
X-Received: by 2002:a17:90a:1902:: with SMTP id 2mr9309304pjg.113.1559965871006;
        Fri, 07 Jun 2019 20:51:11 -0700 (PDT)
X-Received: by 2002:a17:90a:1902:: with SMTP id 2mr9309274pjg.113.1559965870374;
        Fri, 07 Jun 2019 20:51:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559965870; cv=none;
        d=google.com; s=arc-20160816;
        b=A9cLkARaOwSLwCf20rFatveQkwj92g5tfsVbhI1ovKHWq45uPK6QO3kaLjOQc9rO2i
         mGJZbE/mbe25J4zGPbyFcp7PBpBKjRHlfwhvyZBLizPfHSKis5tsjJKnIwVfkwrplbC5
         ebTpK11H5HethUFjYZvm1MojOSvFaJjCWuLluSV84KwFebmroWtd7RI4BQegvvtcDctZ
         m5TYS6pRfk/JinNCEB12YmeiIa12WZfXasrgz5HP1fV9VTOcxWyDmzwpGinfTFra0rEe
         k0tCw0JGxLV5ScU6YobBwymK+8chU9c996eJxI0JLrNUXApWrW23rx8xx8PpiIstW9yl
         XqwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=3wKfqS97rJvrbhUUDlvq7gOlHPn2Fxrd7rOcfg+ujIw=;
        b=eC0RAXXrtVuWv40YxLl8+a3zunN1aolZj7/ILHQbx77U4hV+uF2vp4e94aaUTxwpwp
         LtGm2v+rW+6pgTUr8ryCkQv9HDGBmmNtFc0T0+u4/scQph/xtlSxcQXLXxxCEi86uZSF
         kFLjSC1u1j9PCnuj0fN43tT3yOCgKxlITY54KxdBbXinUapbafhpARUAsMBGLsKUzwGG
         +v1BElRinaGfI5BnpvchMXYoOWEZ5doRantyeN2nuzdmsSKx2VoqN5WjI9vkxViw/+gZ
         iCP3lekyMpKNi130Y7QARxB1EVVi8cbSGIOEdQUTLyGsd2Q+tyajmQb7yVnXj5ez7q6c
         mD2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=RYl1PwRk;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r3sor3652720pgh.12.2019.06.07.20.51.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 20:51:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=RYl1PwRk;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=3wKfqS97rJvrbhUUDlvq7gOlHPn2Fxrd7rOcfg+ujIw=;
        b=RYl1PwRkMzex6A4O7SLxvvwiq5dij7m4eHDLUNE4a3aGBYLeVjbDL8gLqao1EoQT+p
         YQb1mF9o9UcoV8td3+9AP7z+CkGq6mDaNnYR3pzaWwp8gUl1cHoE4YNqEbgWKNWvGAFB
         0KAoZe50aGSCoeHmlFMZ5SpxFp6+d2TadDVto=
X-Google-Smtp-Source: APXvYqw907PVDblcTVkonPdzATNJGir/Lb4Vx1Ol6psoQ6Dh4wHkfs9go3mE5W0bvdvS6vG2+lgMCw==
X-Received: by 2002:a63:161b:: with SMTP id w27mr5796313pgl.338.1559965870042;
        Fri, 07 Jun 2019 20:51:10 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id e4sm3563052pgi.80.2019.06.07.20.51.09
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 20:51:09 -0700 (PDT)
Date: Fri, 7 Jun 2019 20:51:08 -0700
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
Subject: Re: [PATCH v16 02/16] arm64: untag user pointers in access_ok and
 __uaccess_mask_ptr
Message-ID: <201906072051.3047B3DC56@keescook>
References: <cover.1559580831.git.andreyknvl@google.com>
 <4327b260fb17c4776a1e3c844f388e4948cfb747.1559580831.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4327b260fb17c4776a1e3c844f388e4948cfb747.1559580831.git.andreyknvl@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 06:55:04PM +0200, Andrey Konovalov wrote:
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
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  arch/arm64/include/asm/uaccess.h | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
> index e5d5f31c6d36..9164ecb5feca 100644
> --- a/arch/arm64/include/asm/uaccess.h
> +++ b/arch/arm64/include/asm/uaccess.h
> @@ -94,7 +94,7 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
>  	return ret;
>  }
>  
> -#define access_ok(addr, size)	__range_ok(addr, size)
> +#define access_ok(addr, size)	__range_ok(untagged_addr(addr), size)
>  #define user_addr_max			get_fs
>  
>  #define _ASM_EXTABLE(from, to)						\
> @@ -226,7 +226,8 @@ static inline void uaccess_enable_not_uao(void)
>  
>  /*
>   * Sanitise a uaccess pointer such that it becomes NULL if above the
> - * current addr_limit.
> + * current addr_limit. In case the pointer is tagged (has the top byte set),
> + * untag the pointer before checking.
>   */
>  #define uaccess_mask_ptr(ptr) (__typeof__(ptr))__uaccess_mask_ptr(ptr)
>  static inline void __user *__uaccess_mask_ptr(const void __user *ptr)
> @@ -234,10 +235,11 @@ static inline void __user *__uaccess_mask_ptr(const void __user *ptr)
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
> -- 
> 2.22.0.rc1.311.g5d7573a151-goog
> 

-- 
Kees Cook

