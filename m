Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DA37C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:35:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 342B5208CA
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:35:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 342B5208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C33956B000E; Wed, 12 Jun 2019 10:35:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0A9C6B026A; Wed, 12 Jun 2019 10:35:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD30C6B026B; Wed, 12 Jun 2019 10:35:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6044C6B000E
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:35:35 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i44so26205293eda.3
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:35:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=k6mFP7+3kljKTiUG3KJLD1eJ9mBoWJVeZG/bqEQg9YE=;
        b=QCb6OsQtg39QqySDb+EqpKWeIrsSzYyBi56tE4J78JKh2pYKUyCsbiWUEEuN46Gb7/
         o9YCJIbhf2Ba8gRZEftxyg5PEPYfF5JI8kjFqcFRJuAeb/aTZR19Bboc9mvJ/W5fiQQb
         J8Qbc/3q8JdlvxEaIEEQP7cYsO0ae6alG/DreYx2reec7h49aUmoAJ2h8XUrZmw8lqxn
         3u2nSAtleqehRolh5jWdwyvsUT/rSUrKbTgMh8SHH9W2ilJjUaInWntqqv5zBbrslFsz
         8f24KqEtTQfpiB3aWpE76sNDrhi6HXoB0cvheXllzOPbgXiguCTgitRYc7yT/WIONmMF
         XugA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAVzH2WZ3uFHa0uU++Wltix13iTKLvxIq1FvoC6QA0iGkEiM3Vzl
	wHPYlFj9z/umj+vQBM4PTDRid1JT1TLa8/lkG8xkDC5Y5JM5/6bJQ4Vbuo+Qprm3pEz3nXUn+ji
	Y9lqPM9pCLPIhHOQ1JkdHfjQ/F5Sa+NIjg8DTGoogFqjWRYmPSU8J4KvCmCcqOp+kow==
X-Received: by 2002:a50:8bfa:: with SMTP id n55mr53587245edn.9.1560350134978;
        Wed, 12 Jun 2019 07:35:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqVommmzzLxu3SK/TfPTkAR2E+lg8uXfuJ4IQb7qQp/h2wjZEcuBaHcZDi714qbJFEr1de
X-Received: by 2002:a50:8bfa:: with SMTP id n55mr53587153edn.9.1560350134138;
        Wed, 12 Jun 2019 07:35:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560350134; cv=none;
        d=google.com; s=arc-20160816;
        b=Q71GNtmoeotORiy+7q20lSj0dHRgA632ZWMc+OdRpQrCVEXraCIsjlQRGHFhOVCQFc
         V4yne1A6Q+I2e/jJQTA8zITpUg7tM4p4lgGIhQr3CN9YW87o5jo3c0IPze1KfFRwjctq
         AW7UnNjwpFW8S93RboFyjtcUZQvC4SfwMSPjiQRqJRkFn4J5KokmbElct7jrDs4eTtqf
         KDLtsYrRMhcd9T4se7rV12dgVXtr1/UcU4aII2Bo1x98RzmQsmrOFfh4RMlDd1aLIbsB
         bzsIOvV2htTUZpMQ8v1gFr8spuFqwPY0vbBz0UhFumgEyuGNceRj8rf8z1NBhXHqQnk3
         QUdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=k6mFP7+3kljKTiUG3KJLD1eJ9mBoWJVeZG/bqEQg9YE=;
        b=SeMo7J8RFjrvD4JBGULAWIg+4S1NTqkiULjyqwC4iahpRXHlt6Mw+TAGEf/YIPg1Rb
         nYZieJtc8wYc5fkFeGzntDCNhRi0PaMJD9gS1YX2ovh4+s1V3TTBmsKuk++zP4ShgOIe
         BlGSOu31tp+wgww3BgraFTa8HY0pyJNq0pueCb7Bd/oxmRXhVQEmrvtuKgaJe6QJRFWi
         4i3TzOWfvmjeW7Zd/SavR0j+Hq0ziGySJ0XOEJ42xflweVbzuh1ZaONDLwaLdcDVekQC
         2IUwc11638hCrK9Jom1exLg5e7mKZoZvAZ9bV5HeugGy269Jguq9imZbdJxMAe9Bxd8w
         x/QQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id g23si65500eje.302.2019.06.12.07.35.33
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 07:35:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2A2822B;
	Wed, 12 Jun 2019 07:35:33 -0700 (PDT)
Received: from [10.1.196.72] (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1FAE33F557;
	Wed, 12 Jun 2019 07:35:27 -0700 (PDT)
Subject: Re: [PATCH v17 07/15] fs, arm64: untag user pointers in
 copy_mount_options
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
 <4ed871e14cc265a519c6ba8660a1827844371791.1560339705.git.andreyknvl@google.com>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <4a70a119-e40d-3fa3-8426-ba946e1af76a@arm.com>
Date: Wed, 12 Jun 2019 15:35:27 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <4ed871e14cc265a519c6ba8660a1827844371791.1560339705.git.andreyknvl@google.com>
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
> In copy_mount_options a user address is being subtracted from TASK_SIZE.
> If the address is lower than TASK_SIZE, the size is calculated to not
> allow the exact_copy_from_user() call to cross TASK_SIZE boundary.
> However if the address is tagged, then the size will be calculated
> incorrectly.
> 
> Untag the address before subtracting.
> 
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>

> ---
>  fs/namespace.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index b26778bdc236..2e85712a19ed 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -2993,7 +2993,7 @@ void *copy_mount_options(const void __user * data)
>  	 * the remainder of the page.
>  	 */
>  	/* copy_from_user cannot cross TASK_SIZE ! */
> -	size = TASK_SIZE - (unsigned long)data;
> +	size = TASK_SIZE - (unsigned long)untagged_addr(data);
>  	if (size > PAGE_SIZE)
>  		size = PAGE_SIZE;
>  
> 

-- 
Regards,
Vincenzo

