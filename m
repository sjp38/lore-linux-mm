Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB6B1C31E58
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 13:56:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D77C2084A
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 13:56:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D77C2084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2843D8E0004; Mon, 17 Jun 2019 09:56:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20CDC8E0001; Mon, 17 Jun 2019 09:56:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0AEB48E0004; Mon, 17 Jun 2019 09:56:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AED758E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 09:56:46 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n49so16514531edd.15
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 06:56:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zbagTZrPyLr6fLVky4mTwh/eJX34k6YcjR+iSHxkEqU=;
        b=L+ehF2AM8Ry8ztV32Au+wCnNoDBKSV1ID6mjUOYXEGjUNmFfvdrj+vIsYjkY/0PQ+c
         QfMz+R2UFBQrOsX9JozCkhFfPbyaL8MN9tARNEJ7oTOOxqPp6uR4CkHDYgtwzI9gEpmj
         PLKMljlKfIT3KW/dIZ1Pw4hyENd2cXavZt4754WnGgVnjTHMovzNRYeOCgYlWL5SvbhK
         B7yxYCSd/LFi093RIkSEEnG/jX3toeUdpjI+83KO1SOQJQ7J4Ok6fmQ0qAz101MjGh5f
         3CrCCJV9fcUAgnsRDo8aZGV93SK+oSO6EdaKiGRRYfAPRfugL6Nx8U5qp7d0z5gDVuF3
         Usxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAV675qJF5xIC0kidrEhZLfYYSK5SpMD/rsri+FwqskqeA2qjhi7
	zJfWGHnLXuLNQbJ8u3G6mm1wDv1vdJMqIss3v66/CviEof8sB6Rjsp2MbTUOEKWAwht+Ab55ys4
	UECZoQ6GwIR2RJ+532SsHfp/v/5h/GOHbIYiSI/j+vcHcRfxiJkHdSwI6vg6yHxG2yw==
X-Received: by 2002:a50:b6e6:: with SMTP id f35mr79359417ede.82.1560779806272;
        Mon, 17 Jun 2019 06:56:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8Ed9y17RJHGXBBTyIngxLJ9sC7d69FbG4YuZn/zX4H7LKtU4J/borykWdExXWaEFoPY42
X-Received: by 2002:a50:b6e6:: with SMTP id f35mr79359365ede.82.1560779805627;
        Mon, 17 Jun 2019 06:56:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560779805; cv=none;
        d=google.com; s=arc-20160816;
        b=zmC7e9iKfnfrB3xMUHWHpxXqbMuObFGQpRv0LRHcBrjy/QWZwqhazfTXUG8EsreL2N
         C8xT1JdYW71VxVOoa9/34K77eYn/9B+rsnVEEdvlYyT3JUDzq9xCgJnmyFRLArPhEFWG
         /VkIa+ZbGdCtTYFfdz8k+4Eq2kaR/a2vMn4hPKJb7xY6r4zDlacOxsR98Y00b6ApDWfj
         mGHCbnzEBnI4DS8MYXQpsGozs1EkEn75IHhIUs2HbO3Wg05kuYbEcLNGEtruM3TKQX3X
         b+LG0wxUXwkF6zeMuRD1RfhHbf7aiQYO2UucvFudBerdbidYMTUlCGm1XKmj4sg2gR7K
         tmGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zbagTZrPyLr6fLVky4mTwh/eJX34k6YcjR+iSHxkEqU=;
        b=PRYNemBOlvxO5j6Il4LkZAlPvYBOz5NmeCA0YCP6pZCvuqK5IIpjKlhdtwO+/mQlT5
         E0ZgTmd1UjX3UMxlhG+Esl3kwLTvC3nljnUTntKEWSNfOXVRq3f/AQye34DlrxlHif9s
         gBgij7hO3IS4B3pDdAKZQNXdcLCe7jVH6UwtSNjUEMzfKcjNsqLhCMJ9u+3qc67Ouc0e
         QqQwBbquTuHR/FvUmYlez/TKgX+95fPUPbFHgVFrTi39dynVMfB4A1YVUgU6lgx8NOp8
         LWVGqG8p1/Kh3grQAkEJYkQhKVxpUwclWTe/uoVTl5w1Z9heBIuHb5oMr+vDW14DV0Wn
         h6UQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id d18si6302757ejj.245.2019.06.17.06.56.45
        for <linux-mm@kvack.org>;
        Mon, 17 Jun 2019 06:56:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BCD2D28;
	Mon, 17 Jun 2019 06:56:44 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1625E3F246;
	Mon, 17 Jun 2019 06:56:39 -0700 (PDT)
Date: Mon, 17 Jun 2019 14:56:37 +0100
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
Subject: Re: [PATCH v17 03/15] arm64: Introduce prctl() options to control
 the tagged user addresses ABI
Message-ID: <20190617135636.GC1367@arrakis.emea.arm.com>
References: <cover.1560339705.git.andreyknvl@google.com>
 <a7a2933bea5fe57e504891b7eec7e9432e5e1c1a.1560339705.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a7a2933bea5fe57e504891b7eec7e9432e5e1c1a.1560339705.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 01:43:20PM +0200, Andrey Konovalov wrote:
> From: Catalin Marinas <catalin.marinas@arm.com>
> 
> It is not desirable to relax the ABI to allow tagged user addresses into
> the kernel indiscriminately. This patch introduces a prctl() interface
> for enabling or disabling the tagged ABI with a global sysctl control
> for preventing applications from enabling the relaxed ABI (meant for
> testing user-space prctl() return error checking without reconfiguring
> the kernel). The ABI properties are inherited by threads of the same
> application and fork()'ed children but cleared on execve().
> 
> The PR_SET_TAGGED_ADDR_CTRL will be expanded in the future to handle
> MTE-specific settings like imprecise vs precise exceptions.
> 
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>

A question for the user-space folk: if an application opts in to this
ABI, would you want the sigcontext.fault_address and/or siginfo.si_addr
to contain the tag? We currently clear it early in the arm64 entry.S but
we could find a way to pass it down if needed.

-- 
Catalin

