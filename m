Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DEC4C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 05:16:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57FBF2084E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 05:16:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57FBF2084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E78906B0005; Wed, 15 May 2019 01:16:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E286C6B0006; Wed, 15 May 2019 01:16:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF1FE6B0007; Wed, 15 May 2019 01:16:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 981AA6B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 01:16:19 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g11so979808plt.23
        for <linux-mm@kvack.org>; Tue, 14 May 2019 22:16:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=CaPoBfwvfHYoUlv6FfiwdTonkmXQ3Vz27zElYB+X6NY=;
        b=Ig5QmqMwFBDO9wHAK5VnS2W5LycbueK603Es+6wXkcowgTCsUOaW2zjQiYj0OjPqu0
         yRmsY05htuxY1ciZcI3SaZaCvCdG9LPbm4HLwWWxgbGO0wuQMWUD0oiZ3iZi4SbEzGaf
         hHd9sh4uR/wZLDK9vm9S+HH3n1SuNq2PCk2zhToteeY2vzs0x9ZZTxkMtPim5ezc3sb3
         cso4t1cmo5WTcKijLldt4M7EFaauPzW4hVEkckM+17u2fjxz9b/znIypAEEwu2KJb3iw
         H6aMwaciGW9FfYrpQ8brKWA6kUmpD7sHVw8xrZzL0StnJf7IOmJCb6UR9I0ZLuhv4Y35
         awiw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhsharma@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhsharma@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUpbkBX7+BLda2l7H9MHONBTqpBPtQblOS2a1QZ9Ke3Bsjt6dP8
	QG6XelIxWLWFUZ6KLEhl9URdO56F1o30koUKafOq/U4Tf8B8MKG/OLl4kIHuygAkhc35ZWEYQfS
	hLpPzhBzRAUbydR+95zEIFx1ZTJMuCysn0qB3J5hcFzcspf77duv+8v++zAiu2OISfQ==
X-Received: by 2002:aa7:86c3:: with SMTP id h3mr43737140pfo.169.1557897377793;
        Tue, 14 May 2019 22:16:17 -0700 (PDT)
X-Received: by 2002:aa7:86c3:: with SMTP id h3mr43737071pfo.169.1557897376689;
        Tue, 14 May 2019 22:16:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557897376; cv=none;
        d=google.com; s=arc-20160816;
        b=yFIkBAwXm9NLtZDza7qdms+/wsv0a4c3fPineghPm6bLnMfJaiL5mRqK3pEmsQexcZ
         fgHemrm/pi0u28ctqcmKQEaFYKxjzr7i0ksyItmmAs/1h3uDOVuXCOVI0CCCrRwjgoBr
         HcL4fOiSUDgo5yfeYyxVXWCHuf5l7Mt1/cfhHxm19VlrN4ak+PlNaCs+QstPIzDqznHo
         lzaMpNBkYsh1oKLF+buND6N9bW9WVHrEG3qXE/ySqtUx8OUIJTRxcCcLjEoVUsWfAHSk
         AIvFhEn5DPaDo7+3+eZkNt7NV9485EANVJR155v7JeQde3bSC/lccd0kL6tv4e9SkMPb
         s2cQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=CaPoBfwvfHYoUlv6FfiwdTonkmXQ3Vz27zElYB+X6NY=;
        b=qah6SMbqrgIauPbM18t3EmicLUCfL9RSvtU6pVTw1kwnNYmeBen/BF9ljHhEivwhlP
         qSjga0oSwJ2GusUU4101rSmLE6+11BW7cmt1uI+Vy1mDv1HQ88osdMih23Y2Evqx6emX
         98iGQxDtyhP8SOGl5/cpyHDvjUAKUVpmetHRvPEWDsDQs1wWNQ5tsFBRNKbEd//K9FYb
         L0VWl1kUGnDOZGKKyUdFgtdkL3rBhc+UilWw5FvM/wOVt1R5XbjiYiEpa+uNS3JikIAB
         OHCkrgM7g24dNwC2hKOpUr1bZ3xV7SlcT2KRh8PZQw8hgdz/S2kkzcnWh6EToZR+zxXc
         57nQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhsharma@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhsharma@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d12sor1150757pfh.21.2019.05.14.22.16.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 22:16:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhsharma@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhsharma@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhsharma@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqy7c4aMXqBtV8RsQz37cPVhnwGAI6b96xSjxoKpUb2R5qSgsCxWAkkxEB8uTYJPawwWOM0xxw==
X-Received: by 2002:a63:d4c:: with SMTP id 12mr28791554pgn.30.1557897374744;
        Tue, 14 May 2019 22:16:14 -0700 (PDT)
Received: from localhost.localdomain ([106.215.121.117])
        by smtp.gmail.com with ESMTPSA id 135sm1321765pfb.97.2019.05.14.22.16.07
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 22:16:13 -0700 (PDT)
Subject: Re: [PATCH 4/4] kdump: update Documentation about crashkernel on
 arm64
To: Chen Zhou <chenzhou10@huawei.com>, catalin.marinas@arm.com,
 will.deacon@arm.com, akpm@linux-foundation.org, ard.biesheuvel@linaro.org,
 rppt@linux.ibm.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de,
 ebiederm@xmission.com
Cc: wangkefeng.wang@huawei.com, linux-mm@kvack.org,
 kexec@lists.infradead.org, linux-kernel@vger.kernel.org,
 takahiro.akashi@linaro.org, horms@verge.net.au,
 linux-arm-kernel@lists.infradead.org,
 "kexec@lists.infradead.org" <kexec@lists.infradead.org>,
 Bhupesh SHARMA <bhupesh.linux@gmail.com>
References: <20190507035058.63992-1-chenzhou10@huawei.com>
 <20190507035058.63992-5-chenzhou10@huawei.com>
From: Bhupesh Sharma <bhsharma@redhat.com>
Message-ID: <de5b827f-5db2-2280-b848-c5c887b9bb58@redhat.com>
Date: Wed, 15 May 2019 10:46:05 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.2.1
MIME-Version: 1.0
In-Reply-To: <20190507035058.63992-5-chenzhou10@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05/07/2019 09:20 AM, Chen Zhou wrote:
> Now we support crashkernel=X,[high,low] on arm64, update the
> Documentation.
> 
> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
> ---
>   Documentation/admin-guide/kernel-parameters.txt | 6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
> index 268b10a..03a08aa 100644
> --- a/Documentation/admin-guide/kernel-parameters.txt
> +++ b/Documentation/admin-guide/kernel-parameters.txt
> @@ -705,7 +705,7 @@
>   			memory region [offset, offset + size] for that kernel
>   			image. If '@offset' is omitted, then a suitable offset
>   			is selected automatically.
> -			[KNL, x86_64] select a region under 4G first, and
> +			[KNL, x86_64, arm64] select a region under 4G first, and
>   			fall back to reserve region above 4G when '@offset'
>   			hasn't been specified.
>   			See Documentation/kdump/kdump.txt for further details.
> @@ -718,14 +718,14 @@
>   			Documentation/kdump/kdump.txt for an example.
>   
>   	crashkernel=size[KMG],high
> -			[KNL, x86_64] range could be above 4G. Allow kernel
> +			[KNL, x86_64, arm64] range could be above 4G. Allow kernel
>   			to allocate physical memory region from top, so could
>   			be above 4G if system have more than 4G ram installed.
>   			Otherwise memory region will be allocated below 4G, if
>   			available.
>   			It will be ignored if crashkernel=X is specified.
>   	crashkernel=size[KMG],low
> -			[KNL, x86_64] range under 4G. When crashkernel=X,high
> +			[KNL, x86_64, arm64] range under 4G. When crashkernel=X,high
>   			is passed, kernel could allocate physical memory region
>   			above 4G, that cause second kernel crash on system
>   			that require some amount of low memory, e.g. swiotlb
> 

IMO, it is a good time to update 'Documentation/kdump/kdump.txt' with 
this patchset itself for both x86_64 and arm64, where we still specify 
only the old format for 'crashkernel' boot-argument:

Section: Boot into System Kernel
          =======================

On arm64, use "crashkernel=Y[@X]".  Note that the start address of
the kernel, X if explicitly specified, must be aligned to 2MiB (0x200000).
...

We can update this to add the new crashkernel=size[KMG],low or 
crashkernel=size[KMG],high format as well.

Thanks,
Bhupesh

