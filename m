Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99D7AC4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 17:51:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 586F520673
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 17:51:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 586F520673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6C6D6B0005; Mon, 24 Jun 2019 13:51:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF6B18E0003; Mon, 24 Jun 2019 13:51:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A97468E0002; Mon, 24 Jun 2019 13:51:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 540FF6B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 13:51:30 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i44so21536192eda.3
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:51:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Gxjd11yV0Ia19zh10BBj/AvZTvdHe01ikz1U0z2OgTc=;
        b=dzq9iRzBYN/Kg/nTs4v32UCtQtLLS7p8JDzQZnly2HgfhDrEQaUlHjHNve0Pnqul6P
         zanwGHiYVljLXoorJhfy+cvuSY7SJQ9NJcz/3Za0SJzrg2mTLspgbKvv/GTnoFgcVlqa
         ulgGyiHlpjmXXhAJDZvm927VTOClMwCgT4Hdd2OsLIMMXPzoe08BVSfbR4uBrf0GyC85
         jcQNXS7Aib+sKj2Sbljpv/CxOc5sT9R5b4upaPi2ZilBeZC+EBE2WVFFoRzvfFIB56Ej
         NFdC/wmr3HxQMcYUfuAyE+AFOZZX4fNK/P/KHrHEbZSyuDCwbCqHvRIWkcc5qJYvAetV
         o8VA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUSzeykxuya3lPGWKEMwCSEJtCLX7MiHB4yGbASybR1hOcnBDLW
	h/oAPoQ2i+ZlEGW807+rZaB5xFF023JRiiWHD/0pXoCs4QD0S9IM+e0rqH6l6oSm82Oj6mM/1Sz
	7JHhSBvlCCdSOI1coLWe/HiA4GfpOYtbffZ7DoXKKEvS9mmJGz5TUUjvMyyfcZS9a1w==
X-Received: by 2002:a17:906:304d:: with SMTP id d13mr4697392ejd.99.1561398689873;
        Mon, 24 Jun 2019 10:51:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyjidTgu3uu64jpu/wCU72U9H5SVyjJa1YpB+tscfgeqANh4wKFHlPO+rXJqLkSs9I9B6c
X-Received: by 2002:a17:906:304d:: with SMTP id d13mr4697354ejd.99.1561398689094;
        Mon, 24 Jun 2019 10:51:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561398689; cv=none;
        d=google.com; s=arc-20160816;
        b=LxclkpuLyvq/9kRFRLf06IXqYBoviWX5J6r1IQQxyJTLT/HJPCvHDQ7LeHvQdudunZ
         Pb/XeYP0N30nxgmr0okrQ0r8cqs2JI8p5NbFLAhBfvkXOWiWG/bd1uK4Q7f1RtSruBvw
         Wj7dDcTkwlSyl0gNT49MTSnG5Xyu4j20YXlNyD3Eqvi53oXqr8xoa4/iSdZV893NDI5f
         7AM6fzd/czR65T2pl/sDZCedMbI37oiQIh2BvQsR3zg34Ih9S2OJ9fbJzPjNSgeUZZWa
         1365SKwnf4GeFHFqWEiI6DwDy5MVgUsdsYyath9aU6GgqVobEjIe8kOz7Jre7ROrRK8h
         JhTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Gxjd11yV0Ia19zh10BBj/AvZTvdHe01ikz1U0z2OgTc=;
        b=HwvP2WEKsqvbUTxpMg5yys471wMoKGf9+7TfP1n8nZF6JV681m6EuLGadaOyR+o8t/
         ardKdm1sXxZrP45iL0JVj0q5dof/PTTMzzU7tp0jwvuZT1Ot20ltGFNmQ+ps/cGK3Nn4
         h/zsisNO3hcRH3W96YJDSRZA+pL6UNcWtakD20BvaJ0Unbd2xRcbwhAZwbr7wdLGIKXm
         0IqR8vdWfgv4PNWEYrNQNuA/f+1FmeXyykm09ykA7EET4yzAQGkRQYrJ1IbsesIt6u63
         KF0zkAkX51W7AI4BA7Ty7hwZTWGvyK6xAZV990XYl2b0lPrSl7UNrSIFkr1JyOHla2Ef
         03YA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id w8si7091213eji.270.2019.06.24.10.51.28
        for <linux-mm@kvack.org>;
        Mon, 24 Jun 2019 10:51:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 25DB8360;
	Mon, 24 Jun 2019 10:51:28 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 606C33F718;
	Mon, 24 Jun 2019 10:51:23 -0700 (PDT)
Date: Mon, 24 Jun 2019 18:51:21 +0100
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
	Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v18 08/15] userfaultfd: untag user pointers
Message-ID: <20190624175120.GN29120@arrakis.emea.arm.com>
References: <cover.1561386715.git.andreyknvl@google.com>
 <d8e3b9a819e98d6527e506027b173b128a148d3c.1561386715.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d8e3b9a819e98d6527e506027b173b128a148d3c.1561386715.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 04:32:53PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends kernel ABI to allow to pass
> tagged user pointers (with the top byte set to something else other than
> 0x00) as syscall arguments.
> 
> userfaultfd code use provided user pointers for vma lookups, which can
> only by done with untagged pointers.
> 
> Untag user pointers in validate_range().
> 
> Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  fs/userfaultfd.c | 22 ++++++++++++----------
>  1 file changed, 12 insertions(+), 10 deletions(-)

Same here, it needs an ack from Al Viro.

> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index ae0b8b5f69e6..c2be36a168ca 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -1261,21 +1261,23 @@ static __always_inline void wake_userfault(struct userfaultfd_ctx *ctx,
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
> @@ -1325,7 +1327,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
>  		goto out;
>  	}
>  
> -	ret = validate_range(mm, uffdio_register.range.start,
> +	ret = validate_range(mm, &uffdio_register.range.start,
>  			     uffdio_register.range.len);
>  	if (ret)
>  		goto out;
> @@ -1514,7 +1516,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
>  	if (copy_from_user(&uffdio_unregister, buf, sizeof(uffdio_unregister)))
>  		goto out;
>  
> -	ret = validate_range(mm, uffdio_unregister.start,
> +	ret = validate_range(mm, &uffdio_unregister.start,
>  			     uffdio_unregister.len);
>  	if (ret)
>  		goto out;
> @@ -1665,7 +1667,7 @@ static int userfaultfd_wake(struct userfaultfd_ctx *ctx,
>  	if (copy_from_user(&uffdio_wake, buf, sizeof(uffdio_wake)))
>  		goto out;
>  
> -	ret = validate_range(ctx->mm, uffdio_wake.start, uffdio_wake.len);
> +	ret = validate_range(ctx->mm, &uffdio_wake.start, uffdio_wake.len);
>  	if (ret)
>  		goto out;
>  
> @@ -1705,7 +1707,7 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
>  			   sizeof(uffdio_copy)-sizeof(__s64)))
>  		goto out;
>  
> -	ret = validate_range(ctx->mm, uffdio_copy.dst, uffdio_copy.len);
> +	ret = validate_range(ctx->mm, &uffdio_copy.dst, uffdio_copy.len);
>  	if (ret)
>  		goto out;
>  	/*
> @@ -1761,7 +1763,7 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
>  			   sizeof(uffdio_zeropage)-sizeof(__s64)))
>  		goto out;
>  
> -	ret = validate_range(ctx->mm, uffdio_zeropage.range.start,
> +	ret = validate_range(ctx->mm, &uffdio_zeropage.range.start,
>  			     uffdio_zeropage.range.len);
>  	if (ret)
>  		goto out;
> -- 
> 2.22.0.410.gd8fdbe21b5-goog

