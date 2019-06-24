Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7923C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 17:50:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA02320645
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 17:50:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA02320645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F3296B0005; Mon, 24 Jun 2019 13:50:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4570E8E0003; Mon, 24 Jun 2019 13:50:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F6FB8E0002; Mon, 24 Jun 2019 13:50:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF9906B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 13:50:18 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m23so21504966edr.7
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:50:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pGxAcVZb2pu4qCgsMauriEtCQ2yZkNo4J7UHDlOo+NQ=;
        b=sE1QwyzM0VVup/W1B284yPgTYLtFsitn5qxMtA3hV1vYFkbPrlMdh0ZWnmilyAAamZ
         U81BWflVd6LGzI16f3+4NTaQhshw863FnFQHKPOHkCwCmGOSm41XkIGWpVPBZEz1RUOF
         ROhsHpzBtLk98iywuqaYVZELiEr5I8hVAqY9w8sPZaZtGJmNOm1ZRYwFC1GHkn6Rlihb
         gf3ZSwh5s34oRuG89SGAGUYf7KZ3XtNa5/qMLrERHTVZjvr0eGBkwP1mrl0oUgEaAwfH
         OSEhEY7W4Vp1qT38usbjTRR3gplEau9T+2kGmNoYgR6GftfRIdkhz2as6xsrxlYLyWMR
         WvYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAU+tA22kFmug7O1NoqVZrbSQll3rx1rYXBvYwM7Gs1PwdQUHX8E
	oTLwxt4UlCzI4qT1yn/3VMPd+vnO3OlrBDS+zbZKZk+k3VtyRDy5ZxCrQ1iWTa3RRaOgwbC9/aF
	1IgD3pJ4SU86RbG3N7kYHZuy8JxYcoW69xD44bSRLkgNOZG3TMQRtCwAzJLW1Glif8Q==
X-Received: by 2002:aa7:ca41:: with SMTP id j1mr112332854edt.149.1561398618415;
        Mon, 24 Jun 2019 10:50:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWiU1QxAlYis47waRAmniJjB8p7IhOup+EODBbQLdbufoGvKnrk/dPm9gWdWpFInA/+YBe
X-Received: by 2002:aa7:ca41:: with SMTP id j1mr112332794edt.149.1561398617726;
        Mon, 24 Jun 2019 10:50:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561398617; cv=none;
        d=google.com; s=arc-20160816;
        b=LSGH7zlLBnV5BmEc5EknN+X/CX2t9diDd1oVkr558ZlG91u1tIT8LB0pQwzTeyNABd
         BtgMYidKMeykbMwlhZljjXb5E7R7yZbevI0rOQaWEQWSLSa2tlFLILeb15QbSCR3GfbV
         3Y6EKoo+wTgk6UGYCVsl1cpuL8QAKS+oW4g/SvTJhNicUmSWxJOG8VHxO6A2lTc+smma
         Y6KPXOv4WRcKXEyRFzIddnMFZmKB0B9b+qM1gPLvVf4ztaZsI5R0Z3oWp+A4uL/echYn
         uGDa/Txf3mSYZqHfcCXnBfzI1Tkk8S743DLYaTJ7MTVJe3BtHKWCwXBmpatERF3LRjVQ
         BH8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pGxAcVZb2pu4qCgsMauriEtCQ2yZkNo4J7UHDlOo+NQ=;
        b=vXO1OyVXOKFRE2AqIbnWDd/31Dz6pFg2CLbObbJ/CP4VYeuOqDMIT/bRiBvBxVWmzG
         B38O/1tIYnMcVA7nVlyKiRLRd7AIkEWxxg/SZvfNhN9UmiIqa98mLR2xR0IKg9vVmtXN
         7UuM8xRAOKzzofoVoJEka59jV0ycPsU3cQ8TAxy2gXqmY59t80v52FC1rC+Q3Pdh8t9G
         lgPQGtkiHU+e7ayhk8CLPJqhSL2+g3swEIQ50YfCf5X6o7zF35Ce85P7iTGROPILLdE2
         SLi3TutItEenCFgS8WThTfZ9f3XxA9d7hDdiA4KCluc7fpcdaDv9fJ6kt9A0TXcd/WP9
         N46g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id r16si10152236eda.14.2019.06.24.10.50.17
        for <linux-mm@kvack.org>;
        Mon, 24 Jun 2019 10:50:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B0CA2360;
	Mon, 24 Jun 2019 10:50:16 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E5FBC3F718;
	Mon, 24 Jun 2019 10:50:11 -0700 (PDT)
Date: Mon, 24 Jun 2019 18:50:09 +0100
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
Subject: Re: [PATCH v18 07/15] fs/namespace: untag user pointers in
 copy_mount_options
Message-ID: <20190624175009.GM29120@arrakis.emea.arm.com>
References: <cover.1561386715.git.andreyknvl@google.com>
 <41e0a911e4e4d533486a1468114e6878e21f9f84.1561386715.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41e0a911e4e4d533486a1468114e6878e21f9f84.1561386715.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 04:32:52PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends kernel ABI to allow to pass
> tagged user pointers (with the top byte set to something else other than
> 0x00) as syscall arguments.
> 
> In copy_mount_options a user address is being subtracted from TASK_SIZE.
> If the address is lower than TASK_SIZE, the size is calculated to not
> allow the exact_copy_from_user() call to cross TASK_SIZE boundary.
> However if the address is tagged, then the size will be calculated
> incorrectly.
> 
> Untag the address before subtracting.
> 
> Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
> Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  fs/namespace.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 7660c2749c96..ec78f7223917 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -2994,7 +2994,7 @@ void *copy_mount_options(const void __user * data)
>  	 * the remainder of the page.
>  	 */
>  	/* copy_from_user cannot cross TASK_SIZE ! */
> -	size = TASK_SIZE - (unsigned long)data;
> +	size = TASK_SIZE - (unsigned long)untagged_addr(data);
>  	if (size > PAGE_SIZE)
>  		size = PAGE_SIZE;

I think this patch needs an ack from Al Viro (cc'ed).

-- 
Catalin

