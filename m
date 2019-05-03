Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E3AAC004C9
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 16:56:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 437A52081C
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 16:56:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 437A52081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5DCF6B0005; Fri,  3 May 2019 12:56:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0EAF6B0006; Fri,  3 May 2019 12:56:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFD936B0007; Fri,  3 May 2019 12:56:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 847B76B0005
	for <linux-mm@kvack.org>; Fri,  3 May 2019 12:56:58 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x16so4338128edm.16
        for <linux-mm@kvack.org>; Fri, 03 May 2019 09:56:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ENbtQpFt3sEuMYjGHDVNvGcvWl+GCRjxGcQzBU3BVY0=;
        b=CX/zMKHm6NjNcQBRVeHwRox6Tul5B9+tHpWgGwFgjVSrmF7pFzTofZTqaLi3MDT5ld
         Jjk1X49l9PmuJ6VvJPezh+MKRQpsNiS5RMSj7lfeVM5FTcqJuQvIP4AqES8ya5nW7Zyh
         v+pwQfpNGJxRrONFiFl61SmnPauz39YrEaJJ4jI1+q3IwlcRfV690tejD6+vOE6pkdcw
         D2dphPHmglyGPcv1obcglXzweX+s4N4cdk+HJVDQdS7YLVy58r937WY/L2dGtlgjl3WC
         IKHw2qnPlcMDMwznxC7d+YNtfs9j//dBI3eTTAgtX1JI827KhWbI3ZyJ8IIJT/t2Jwyl
         7nhA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVbUQPraraRSjoZa9EpOQXB5UFgsIyAOSfjasHY8oOHZmb51lS/
	pKVFhH7CKqbwulBnMeqHIRy2OIhSDWVQspnW3ppWi86DoWGxW433DssMzXPuSBmZ3rUQYlqZpa0
	5X2pYObPIrOpBLEMexYLjiwGhN370yqlVLJrCybWJund7HhuDp2BeGduUuQkbL6x7xw==
X-Received: by 2002:a50:97d2:: with SMTP id f18mr9555620edb.130.1556902618111;
        Fri, 03 May 2019 09:56:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUbFQIoLNw6tRWEINYIyka7YWFiLC7cXSWQPfhhRzfuN3r/GvU3q8ZIpDjG/Z5LshwtbLT
X-Received: by 2002:a50:97d2:: with SMTP id f18mr9555546edb.130.1556902617231;
        Fri, 03 May 2019 09:56:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556902617; cv=none;
        d=google.com; s=arc-20160816;
        b=tvybaougF2Xu8teIbkBRb6CXXvoAqfyIVewZWwFJ0pshSJLlDz50Ti+F2wyDqXtG2b
         TsMIfi+t1hyxGoj4G+WllD1dSTuAKSO9NA38iSFoFGYe6SzzAn1C+hnPyNQa6io340vj
         BU9hu0IGyWVnhgTplRBsXDzsDVc1YRM6xu9ZHUzzHPG7dMDz9r8AQnKzdcujjs9WT4iv
         teqT8+A+igBagCudFdY8/vNCrIC0h7AQF6S4qi5Jcob9uz9SqcEKT57BBGq36d4OuKbs
         Rz9y6SEHGV5lE90ksQ/JndogTkp16UD7UkQXDvvfeJCqtI6rBDqK7tt1rowA7lo8FYGt
         cBng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ENbtQpFt3sEuMYjGHDVNvGcvWl+GCRjxGcQzBU3BVY0=;
        b=wMXcqYJmKNfdd9hYxVedvBT564JDYlmtOkVfjSr7stsOdOrleVaRot0SLTzx4AAmQp
         gtFPMitYTS5iPSBKnI6a+9VNVhXMg30aiIyYJFGsYyGp/JGFeHYyn+DlmZwQItwLVxOo
         6iNRNlsdeaIelySHXwMnIKppEPaVuIbcoZ79SrCdMeQPl9BM7esw5S8H3LyK/Qr04w7U
         STAjRqxOrqY7lIoA1i0kS1qwZI49Y8Bnw6MrK5UOlQPto8DwnRwuBtCHMQ+MUNZr3skB
         2ZLnw+w7yEhFpLd9qJbbQIY/W9RfPwrUa95atafE3OGv4OnH4wB7UdKEw8Rk+Cu2fW1g
         Up1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j17si287589eds.281.2019.05.03.09.56.56
        for <linux-mm@kvack.org>;
        Fri, 03 May 2019 09:56:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 091DE15A2;
	Fri,  3 May 2019 09:56:56 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7F2813F557;
	Fri,  3 May 2019 09:56:49 -0700 (PDT)
Date: Fri, 3 May 2019 17:56:46 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>, Kuehling@google.com,
	Felix <Felix.Kuehling@amd.com>, Deucher@google.com,
	Alexander <Alexander.Deucher@amd.com>, Koenig@google.com,
	Christian <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v14 10/17] fs, arm64: untag user pointers in
 fs/userfaultfd.c
Message-ID: <20190503165646.GK55449@arrakis.emea.arm.com>
References: <cover.1556630205.git.andreyknvl@google.com>
 <7d3b28689d47c0fa1b80628f248dbf78548da25f.1556630205.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7d3b28689d47c0fa1b80628f248dbf78548da25f.1556630205.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 03:25:06PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> userfaultfd_register() and userfaultfd_unregister() use provided user
> pointers for vma lookups, which can only by done with untagged pointers.
> 
> Untag user pointers in these functions.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  fs/userfaultfd.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index f5de1e726356..fdee0db0e847 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -1325,6 +1325,9 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
>  		goto out;
>  	}
>  
> +	uffdio_register.range.start =
> +		untagged_addr(uffdio_register.range.start);
> +
>  	ret = validate_range(mm, uffdio_register.range.start,
>  			     uffdio_register.range.len);
>  	if (ret)
> @@ -1514,6 +1517,8 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
>  	if (copy_from_user(&uffdio_unregister, buf, sizeof(uffdio_unregister)))
>  		goto out;
>  
> +	uffdio_unregister.start = untagged_addr(uffdio_unregister.start);
> +
>  	ret = validate_range(mm, uffdio_unregister.start,
>  			     uffdio_unregister.len);
>  	if (ret)

Wouldn't it be easier to do this in validate_range()? There are a few
more calls in this file, though I didn't check whether a tagged address
would cause issues.

-- 
Catalin

