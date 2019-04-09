Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75D8AC10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 05:20:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3712520883
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 05:20:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3712520883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A400B6B000C; Tue,  9 Apr 2019 01:20:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EE4D6B0010; Tue,  9 Apr 2019 01:20:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DC5D6B0266; Tue,  9 Apr 2019 01:20:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 564F86B000C
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 01:20:26 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id j1so11582260pll.13
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 22:20:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=1YUfMPM7RT1o5URCsP5/A8wjExy9E/3T5zL1WxdDFpI=;
        b=ocT8ZfxKCO1z/eF5PshUiuu2hMYworhHYMbqqJ1F0tPqnUU1vxaz/3h8KOJK0rt8b/
         NwZbllRxECoHhgWEHrVCCBMBX2gUMMkeQ+lyRg/h8ZxSUD12BHuqeHNUXYoYZIPhtY4T
         yr7aPEQJjE8UfAPMFsSRr455J13JqLOBTUNa1s4DPU/V8dZ678W3nsF7xETc19OmRSxr
         WTt1Cn3YUGeT1YvAKTfbBNJW6tbiSMsKVCI7ZH47VkI7VhznBqYPuL+Yf3Rl0loYBaDH
         +hpClDqVjDH7GVckqJirGl/YFWIU6JAGSTX7w4XlbrqiTlLZhLIWaNgoOzODX6Uyecdm
         pHhQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhsharma@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhsharma@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXGrZo15Q/eSEGqurYu2x6vEHJuudmDtyyhBZtuFeKYSDUtQWKl
	MX7V+MfyTiigppFyYnupNbIoVSw/HQ04HMNXpaNQsfMiFdCprmOOT6BKKtXTXL6R+GcKpacUln+
	l9tEqEbWf+BEYnOto572LDtMX8o7B14A382qLbDr8bZXwr9QA6KuUUYLCkJZsZobpMA==
X-Received: by 2002:a17:902:8ecc:: with SMTP id x12mr34809440plo.0.1554787225964;
        Mon, 08 Apr 2019 22:20:25 -0700 (PDT)
X-Received: by 2002:a17:902:8ecc:: with SMTP id x12mr34809389plo.0.1554787225216;
        Mon, 08 Apr 2019 22:20:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554787225; cv=none;
        d=google.com; s=arc-20160816;
        b=Z/CvFE/lXM6eCsDFshkAS2iraIxnEozbehNdlpDe0qq8cjcdzui4jNqXvHYYrwlaPk
         ghb7R2v6bTLAbsxZMLFZXosVolvRvDiUPk4hLUs1RfUcnTn9+haNloEceZiVwg/SQRlv
         0VvIXKRPX8EAR+ID8odYxJNCSO9ODgKtgUvJ9zU7ytnagBlJlioA+ovrsPAus7MimAdo
         UTSC+eRNFFWBg1feuRknJjlNRMcdsZmTQI5mxMaO6h7oaeN7GM4Wifc23FnD7P7Yv2kj
         X2P+CYVHnnydI9V+uUAB/eubUp8p6T75yScibIrBHRVaSTsX0ctZi8uIFx9Ytg6kKPup
         EuCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=1YUfMPM7RT1o5URCsP5/A8wjExy9E/3T5zL1WxdDFpI=;
        b=lvqxqHGd+Tuxt17cA2CZSFQ0DqAR3Kafzo7pghp/i+18PzHroj64hV16h64/XQEbD7
         mSBIjKpsvwx7EuebvYpBAb+4U0z7uPEGuUnagUgO1+LUFfbhc+4nO0VcYQiMIBl9uzVb
         Nx69zyZ7j0ma5w/eKTlAbjF8D3I7/dT3hhxT3QmXwRLrJsk7qL9yRv/Xgn+h8LadRNHb
         lsbmf+jY8QgEH2OS8L7QtK9DY1+HlVsetCMgJbY8APEnUT/NhEzk8MytwhiVWO5QP+2g
         d6cj1Zb8McgWBC4ZJeAKruTdQEENU7LRTtLQD6JUNM6KDlcT5ViWFI7KB01qsixl1G1K
         Ozmg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhsharma@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhsharma@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 38sor39518916pln.23.2019.04.08.22.20.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Apr 2019 22:20:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhsharma@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhsharma@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhsharma@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzhrg94zZKMqARZTPlnpBF65FbExNLYEDlH8PaVsNnFFrNS5x/xA9UeSdVBUIhP+KvcD/Laog==
X-Received: by 2002:a17:902:b715:: with SMTP id d21mr35489861pls.103.1554787224724;
        Mon, 08 Apr 2019 22:20:24 -0700 (PDT)
Received: from localhost.localdomain ([209.132.188.81])
        by smtp.gmail.com with ESMTPSA id y19sm43192451pfn.164.2019.04.08.22.20.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 22:20:23 -0700 (PDT)
Subject: Re: [PATCH 0/3] support reserving crashkernel above 4G on arm64 kdump
To: Chen Zhou <chenzhou10@huawei.com>, catalin.marinas@arm.com,
 will.deacon@arm.com, akpm@linux-foundation.org, rppt@linux.ibm.com,
 ard.biesheuvel@linaro.org, takahiro.akashi@linaro.org
Cc: wangkefeng.wang@huawei.com, kexec@lists.infradead.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-arm-kernel@lists.infradead.org
References: <20190403030546.23718-1-chenzhou10@huawei.com>
From: Bhupesh Sharma <bhsharma@redhat.com>
Message-ID: <49012d55-2020-e2ac-1102-59a5f3911a29@redhat.com>
Date: Tue, 9 Apr 2019 13:20:16 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.2.1
MIME-Version: 1.0
In-Reply-To: <20190403030546.23718-1-chenzhou10@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Chen,

Thanks for the patchset.

Before I review the patches in detail, I have a couple of generic 
queries. Please see them in-line:

On 04/03/2019 11:05 AM, Chen Zhou wrote:
> When crashkernel is reserved above 4G in memory, kernel should reserve
> some amount of low memory for swiotlb and some DMA buffers. So there may
> be two crash kernel regions, one is below 4G, the other is above 4G.
> 
> Crash dump kernel reads more than one crash kernel regions via a dtb
> property under node /chosen,
> linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>.
> 
> Besides, we need to modify kexec-tools:
>    arm64: support more than one crash kernel regions
> 
> Chen Zhou (3):
>    arm64: kdump: support reserving crashkernel above 4G
>    arm64: kdump: support more than one crash kernel regions
>    kdump: update Documentation about crashkernel on arm64
> 
>   Documentation/admin-guide/kernel-parameters.txt |   4 +-
>   arch/arm64/kernel/setup.c                       |   3 +
>   arch/arm64/mm/init.c                            | 108 ++++++++++++++++++++----
>   include/linux/memblock.h                        |   1 +
>   mm/memblock.c                                   |  40 +++++++++
>   5 files changed, 139 insertions(+), 17 deletions(-)

I am wondering about the use-case for the same. I remember normally 
fedora-based arm64 systems can do well with a maximum crashkernel size 
of <=512MB reserved below the 4G boundary.

So, do you mean that for your use-case (may be a huawei board based 
setup?), you need:

- more than 512MB of crashkernel size, or
- you want to split the crashkernel reservation across the 4GB boundary 
irrespective of the crashkernel size value.

Thanks,
Bhupesh

