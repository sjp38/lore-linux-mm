Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A86EC31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 10:39:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DED1C20874
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 10:39:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DED1C20874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89FFB6B0003; Wed, 12 Jun 2019 06:39:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8766B6B0005; Wed, 12 Jun 2019 06:39:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 765E06B0006; Wed, 12 Jun 2019 06:39:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 26C2A6B0003
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 06:39:21 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l53so25257274edc.7
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 03:39:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=X8fz9jLbHBDr51Zrby/4VNbgXtXoE1deh93Qry4o0Aw=;
        b=cEAN4cwrK1A8Iwv7CjBTzrY1MLpSo0wBs9thSztmkwr4iZfpZvVgn9cxPLhbsi+Luq
         fAMtWC8tTjQjW6smc3Huqq+L9bCe92ozyS1jdlgMYugrCvqR0LXpRNXzibsm+BnWfZn8
         B7L3Sk7xUjXkTRm54MhsBXGNqOZtm6wrGHKP/pyYFtcXOCArQPDkVVCDY08224FbPq4I
         Q/tYXj0lySNeu/rSObT7uB+SZvxoy5xLwQZ20oCyK80oaMId1qXp39vvOKefWYuaj+9h
         mclvaPTHgq94p3oxHHBfyWhGuXmr9rqM1c+aK8v24opI1sRRSjk3wAIbxY7gVfViJ6Hc
         iXrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVM+gnTZ4/7gxVX+EeDwhMbzbXt1/dTSWouDx5dJjUpJTnPYes4
	Rsd7jC1voZl/BLkHaRrsdeS+q+FZw+W9sqtFkLDqk8zV2/BeGnjeXZjlts37a6+TeIReODj6qNI
	Lnz1Ur7unYaGG6C+Ji0gi9H6N8VuaGFK18VVd3sHqpI0B34LPPhpXyhbywuKQrbnS3w==
X-Received: by 2002:aa7:dd92:: with SMTP id g18mr32394516edv.194.1560335960751;
        Wed, 12 Jun 2019 03:39:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzF8PA/C8Ro7bv9/myv8IJ27fgDeQSLjF4MMR/Tf7TLTkeWTIPoOyMz7axekM4cG38nFYmE
X-Received: by 2002:aa7:dd92:: with SMTP id g18mr32394464edv.194.1560335960144;
        Wed, 12 Jun 2019 03:39:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560335960; cv=none;
        d=google.com; s=arc-20160816;
        b=v8QvuYM1rk1WdpfP7wLlvrQFTsF1PkvuB2a4WrRK9TPsR8yQDuQZhwI9SxCFSUqH/f
         6QjOVTjyLU2QtV6JebU26x/fGDAqiaXYqrH/D1TgyjvURc53F/IzLhFmJHuTeX5zRZ3R
         YpDA5k/IN/AnIpFeB7hecADQKBACq46Gf2nRm9SAl+/Ib1QhAQ+88EAnHfeRgzOxn7gN
         lHwAyCoXS8W7xYzVifUnQOB8csiyyVpQMAVGlDJS/16GgHF9sCcdYPgOyK2/S2vgTJ8a
         1heqMvUmttSes3ObSOLECkICjOfKnd4LRQB/k3u7Xpvf4Jrxz4MDrnS+TnAZqZCQv9Az
         snxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=X8fz9jLbHBDr51Zrby/4VNbgXtXoE1deh93Qry4o0Aw=;
        b=cn1MLZbgusZfrJyZhPzsLtwqjczM8+qn/aMcdY4uzTmNTLGHxyN6JR0bIq10AMcnhs
         +Any05G3jONIMgqzupPERmE+0b87c7kPrPKxCn8ttCpLymFS/jF4NlpAI5kMsBzB7qOc
         VRvxFvYaBTL0SXNUUUzNISt4MFW3zA0iZgCd9RIGNo9/zPrp+ScgTNu+Boq0K7ERhkAy
         uLt3/2SfNl16W0rBp0lIqh1RT9MyX/GmaNPBtCk051wnxsufzwj5pGIDiH+6aW5NYvAS
         kDhTvjn1EEcl1R67xbYN06jetPJ77em2m4xy6Qin8V0T8gHUbgT+w1bH0cdCb9AwIYjD
         7/LA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id ec4si1901328ejb.68.2019.06.12.03.39.19
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 03:39:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 29FDA28;
	Wed, 12 Jun 2019 03:39:19 -0700 (PDT)
Received: from C02TF0J2HF1T.local (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0039F3F246;
	Wed, 12 Jun 2019 03:40:38 -0700 (PDT)
Date: Wed, 12 Jun 2019 11:38:49 +0100
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
Subject: Re: [PATCH v16 15/16] vfio/type1, arm64: untag user pointers in
 vaddr_get_pfn
Message-ID: <20190612103848.GA28951@C02TF0J2HF1T.local>
References: <cover.1559580831.git.andreyknvl@google.com>
 <c529e1eeea7700beff197c4456da6a882ce2efb7.1559580831.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c529e1eeea7700beff197c4456da6a882ce2efb7.1559580831.git.andreyknvl@google.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 06:55:17PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> vaddr_get_pfn() uses provided user pointers for vma lookups, which can
> only by done with untagged pointers.
> 
> Untag user pointers in this function.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

