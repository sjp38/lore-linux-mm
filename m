Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 585ACC48BEA
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 17:40:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2916220674
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 17:40:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2916220674
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C264C6B0005; Mon, 24 Jun 2019 13:40:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD7E98E0003; Mon, 24 Jun 2019 13:40:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC5F38E0002; Mon, 24 Jun 2019 13:40:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5DE006B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 13:40:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f19so21451018edv.16
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:40:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=s+Xh2TYnNrIx2n0h9z7aaMgV61HbghGFIUGyRKmA/qs=;
        b=KCrCSG68wHNQVJF1qSyRwoAC23KGt1F0iBGqWJcDReFg7T+RSydHoF9WD7e4wN5uEu
         Ch2IIGQEjlftTeOIPpGdrVIitVuV7Zvk3RsVd8xqWnq2eRyRSGLmyLkclya/mNH6TA9O
         899upPyT9GJ+VWI0gsuGAbMsA3ZkdVwmkvWkXv6LVkzosTe9VQLPlRnhKu5IMLC7uM4s
         gWyse4ikLZvhQWDBy99lyHngMa7y8Grl91280AOAZy0XGdAjQ734zQfp9g3wUCvGE911
         TsVU+vxvIvR741Ta2wojupETgsTFR9vlTVbUqeo6AJSdOXebmx/NfQtzJ/g+PRCIirEn
         0bQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUx/VEzdf1LschvSTY/LrrS5Qp+trfhNyGwMDoNCoQHsJx96GvZ
	hkW2duWW1qQ+i5CF1Kjh3wKnjV7J0eX6MfTkOzCnxlhcnN0swukJAUnLxparpcwUG6HcseTIZ41
	zASff9cB0jmT3GJs9lFxstX5FJb2HzMSOXX74ccb3oB1iWkANkoWp3ffnhPhiQ0QKCw==
X-Received: by 2002:a50:95b0:: with SMTP id w45mr44702397eda.12.1561398023948;
        Mon, 24 Jun 2019 10:40:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx69kmhqVsO80jGzhzMmeHhV0fgQiylG4qcoG8NvwGRpnxrY+sCFRaVKyER+Ouvyr5pk1ND
X-Received: by 2002:a50:95b0:: with SMTP id w45mr44702325eda.12.1561398023269;
        Mon, 24 Jun 2019 10:40:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561398023; cv=none;
        d=google.com; s=arc-20160816;
        b=DS0StWHANBGE+FJrZ09MXhvShxn6qnn8iysZb3Cu/MfCVKr+q7MeDrzF3O2aJP8BG4
         Hs3b9tFszNq6rgXmNsPQuAJ6qr+XQvipP6mDWlr0WNM+lwjwhw5QOrVk1ynMc8mYeJWg
         vIFCK+xl+PP+37czfRZs30vvv4MzS3qlN9uzKjIDrtej8zJudAgXgbpsu/FRKsuuVm3T
         BjOW8VazaZHbqVFMNZ2665O/hRJ+41UhDkJue0Z9jOpgg45r/YMTAK3kLZu8ktIt7w6l
         U/1VJ02IWul4ZXJ02MhtHePY4Kwd8R/zbXw0Y5bdKlg7EpTUcYnkml5f0TgH2IpN07tR
         +wnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=s+Xh2TYnNrIx2n0h9z7aaMgV61HbghGFIUGyRKmA/qs=;
        b=m4tmU+PCPXjKGXjoy76iblAmPZhFI0pP86JjqThbWo8xhVoXdP0LTnusny3oY+mwwT
         uBmWwrt624ud7YxZNDi+hU0LPJ/WiXWAL+7CUArkN+w5EtWMkUmN5cBRUgJ3USwJ/tUP
         DYNb52XuwWOX6VwzyI9HPzsPVbpN06PSiw0pcJx6RlXrG/QeOBuR5KzjD07iV4SaVoTQ
         qwGCkoj7nMJW+AqyPu/ktk1E1WbY1qtoJmQYD5pTAs440QOzq0c2sk29Mm0B6SbidWmR
         rh92AGg+SQNSLYxXNaQ8UjhS4AijcXkTL/beMHVuDUHy6SPVHhGuQXiMXhzNdtL94nSE
         bWJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id l1si6998256eja.176.2019.06.24.10.40.23
        for <linux-mm@kvack.org>;
        Mon, 24 Jun 2019 10:40:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 67044C0A;
	Mon, 24 Jun 2019 10:40:22 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B95AE3F718;
	Mon, 24 Jun 2019 10:40:17 -0700 (PDT)
Date: Mon, 24 Jun 2019 18:40:15 +0100
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
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v18 11/15] IB/mlx4: untag user pointers in
 mlx4_get_umem_mr
Message-ID: <20190624174015.GL29120@arrakis.emea.arm.com>
References: <cover.1561386715.git.andreyknvl@google.com>
 <ea0ff94ef2b8af12ea6c222c5ebd970e0849b6dd.1561386715.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ea0ff94ef2b8af12ea6c222c5ebd970e0849b6dd.1561386715.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 04:32:56PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends kernel ABI to allow to pass
> tagged user pointers (with the top byte set to something else other than
> 0x00) as syscall arguments.
> 
> mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
> only by done with untagged pointers.
> 
> Untag user pointers in this function.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

This patch also needs an ack from the infiniband maintainers (Jason).

-- 
Catalin

