Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4657AC4321B
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:08:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DCE592089E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:08:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="BIlELQVm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DCE592089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A9A36B026B; Mon, 10 Jun 2019 18:08:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 433696B026C; Mon, 10 Jun 2019 18:08:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2ADD56B026D; Mon, 10 Jun 2019 18:08:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E0D806B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 18:08:14 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g11so6475953plt.23
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:08:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=hxeT3uUf9mnQsIc5SwUBRhhpauxTK+cwV1RV7DWd124=;
        b=EcAC1L03i2lXgH/BFVp42EHcOEOrLCPzu42AjBrDFJ7zGXZpCnrKFXFB1nsr1GCeqp
         3LqcHygL5NeEqUmQO8lQ/rln2B7V6iVk1lWvmHDlknHXd+U9x1PjL8J9voBD/XoRHIdU
         JEo1q671Xpty4Z9zrlGCPgx/dE90JAHevNIYVgxx6YQfxJ7DewW7o3Ty0kC4DmaRAmUE
         uQCV63g0KE5ALNQo+HIR0Uu0iQZ7kYh8meoIHa72CTh7ZwTjPf6aUSRxi5/+DONqlAx1
         OcI/Ft7XZ5KtvvkhrvG305wqfsYoR4qmpjlVfyQ0gj4Q/mFkwcl/EksnBLOurBKGpp9j
         1KiQ==
X-Gm-Message-State: APjAAAX97YURcHnOm6VzPI0l3LQutQ47h58geZNaQgcuLoojyLULyzPA
	dlLUSc0CIKRIFbFZ19ONJehpPtDA4Y6yP7cZvVqOfzcxMN+QZmzoCi2LAAsWPd8+h4xbk6C0EUS
	hPT2c/NGiv5pusQOMaBya7wjoi+QCu/RRvkme7RILrkpgHMWen528m/4nqtFOSTcJ3g==
X-Received: by 2002:a17:90a:2430:: with SMTP id h45mr24195923pje.14.1560204494498;
        Mon, 10 Jun 2019 15:08:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyoLpkNOUWO5C6nSH6HpSyeV/K6C2tG+lyPIUzx+VBtXtHS3BgJLMjAL6EKfh3F82XITeFQ
X-Received: by 2002:a17:90a:2430:: with SMTP id h45mr24195872pje.14.1560204493796;
        Mon, 10 Jun 2019 15:08:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560204493; cv=none;
        d=google.com; s=arc-20160816;
        b=cCmLdkPMxVtWUjd02lNk6a/M8ypbjINIGKvwOMmhCoMJmX3RO+dbjsyX23aPgakZg1
         4l+WTG6PehY2oEN46LLBenFoYQS7zDKn/vJTtLJQPi+qHINUfq2XVRcNpSrei1bQpAuX
         dXQAINm+XK6kYXF6051a8qvXjBr8Zbh1kPxYQqWFaLoslsjt9wAvuI7h5dxwbt5zgk4u
         EveCx4OnGp7mnyUdE2Ia/ko/T36c0tDwBfVM00TB8xFjHqVxUxQhpd3PfbulsrJ3naD7
         1NknO6zov4/lzvhFaA74nGuuzt9dHpD32F1825njOMPKvtfyv6Y8FVocRzsYrZdZw9XP
         QD5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=hxeT3uUf9mnQsIc5SwUBRhhpauxTK+cwV1RV7DWd124=;
        b=dfVLyfk8j5i2rXQBUlvqkAmHv68RjbX+Jm61lJBg0M9vg9H8QBkf6iubRcjFYdY6Ra
         IP/pRxlsSXNF47MwlHk3HMFrWTuagvJjFExp3Mvgb6l4e5ZB3iiQyEmE6CsESazH8XYf
         sSzvgs/ZE9Q/ADZstIVRtJ9gIQsCJ821umHUxiFGD6xGviz1iK9uH6FQHE4dwisDbS5R
         HUaymtRxwY2EbortVxlNmtkJjzYczHoOAahrYrxLh7lzsWa/my/xVMG1T55Up0R0/A5G
         v4iGXNHqMSw42zhHbocj6a5Ou5XJfhE+KjaR8cwa1uCuAAcARBf0EH3Z9b+I1xyDfnJo
         ymOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=BIlELQVm;
       spf=pass (google.com: domain of shuah@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=shuah@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 37si9685431pld.231.2019.06.10.15.08.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 15:08:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of shuah@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=BIlELQVm;
       spf=pass (google.com: domain of shuah@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=shuah@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from [192.168.1.112] (c-24-9-64-241.hsd1.co.comcast.net [24.9.64.241])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 317032082E;
	Mon, 10 Jun 2019 22:08:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560204493;
	bh=e8XjUFtZMStDPYS3FRKtj43AwF2CGKnQQ24s2uVvYvo=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=BIlELQVmQiXsINDdVkW14pOS9K8s3Gx2mingJ1IaepHxagdpMTpD4ZzyEKsLXADQu
	 LDDLzvbv2yQR2aXp8ujaMwhG5b7sVH+1JVNw3f8Wr643gACxp2ikFsJnG7lIjoeKQt
	 enV0L8Nd0qyRS4RKerZLlzNTADXiWwd0A8vbWeho=
Subject: Re: [PATCH v16 16/16] selftests, arm64: add a selftest for passing
 tagged pointers to kernel
To: Kees Cook <keescook@chromium.org>,
 Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
 dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
 linux-media@vger.kernel.org, kvm@vger.kernel.org,
 linux-kselftest@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>,
 Vincenzo Frascino <vincenzo.frascino@arm.com>,
 Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling
 <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>,
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
 Szabolcs Nagy <Szabolcs.Nagy@arm.com>, shuah <shuah@kernel.org>
References: <cover.1559580831.git.andreyknvl@google.com>
 <9e1b5998a28f82b16076fc85ab4f88af5381cf74.1559580831.git.andreyknvl@google.com>
 <201906072055.7DFED7B@keescook>
From: shuah <shuah@kernel.org>
Message-ID: <2bc277f8-e67e-30e0-5824-8184c2b03237@kernel.org>
Date: Mon, 10 Jun 2019 16:08:10 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <201906072055.7DFED7B@keescook>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/7/19 9:56 PM, Kees Cook wrote:
> On Mon, Jun 03, 2019 at 06:55:18PM +0200, Andrey Konovalov wrote:
>> This patch is a part of a series that extends arm64 kernel ABI to allow to
>> pass tagged user pointers (with the top byte set to something else other
>> than 0x00) as syscall arguments.
>>
>> This patch adds a simple test, that calls the uname syscall with a
>> tagged user pointer as an argument. Without the kernel accepting tagged
>> user pointers the test fails with EFAULT.
>>
>> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> 
> I'm adding Shuah to CC in case she has some suggestions about the new
> selftest.

Thanks Kees.

> 
> Reviewed-by: Kees Cook <keescook@chromium.org>
> 
> -Kees
> 

Looks good to me.

Acked-by: Shuah Khan <skhan@linuxfoundation.org>

thanks,
-- Shuah

