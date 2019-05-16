Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D52B6C04E84
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 03:24:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8ED6F2087E
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 03:24:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8ED6F2087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2586C6B0005; Wed, 15 May 2019 23:24:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 207FA6B0006; Wed, 15 May 2019 23:24:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D09F6B0007; Wed, 15 May 2019 23:24:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id D7CAA6B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 23:24:12 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id n21so1033523otq.16
        for <linux-mm@kvack.org>; Wed, 15 May 2019 20:24:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=sLhvt/hb+Hrcs5GGy6Qae9Dh1SE/JgKvAIHN/Ae6ZCc=;
        b=fw3dwRHP910S0zTpcxLDF8JwGElgvVW0Qkhra7KIyv1Zj4iF0tDqEEzmwYVqXkJKk4
         b9neW+AsVpxfPlA2a5pew349nWgknacS/0E1knc0BgHhRAxoczKxi36YQJHaNeoORu4w
         NCRb+sfN9/4sbRca859NQ7CyiAWlUS5kM+a9Tif6xauqHRBgvVXJyY7P4tMjEmJ01WzH
         PfZu8ifVNr8pvOyn4Q9Za/cTzpfurSIweJmWr4r4yJ5OVzNzNmwfJ6jJ04zrGjrEpkp2
         LjqXcAT8/lxuByCezlgB6C15/j08jGMiHWFRiSNZtqgbaEzzlZX3ZPnd7D3ZoVP+PChe
         fPbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAWHF86pfugL/sUHNvLdgmlIVd5E+KO5mhbzgFUALKMpVK4VjIu+
	2Xf9+qtFeCTSq5RWf2Y9ZApuW6s6+0JfcB3iSc94y4qSHnL0ULZfwTjEElcOBMXLP46qCh66r8Q
	xBb0G5jOQvzqAwR7E6G59amW60v0boRqprtzHmuc2bLjPnTTxjQLGvQ6onEGOjHGjdA==
X-Received: by 2002:a9d:6852:: with SMTP id c18mr12518782oto.174.1557977052551;
        Wed, 15 May 2019 20:24:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynADx5joVoHxL458Uxcfth+sxb8Vg5McLys6Yc3MEEgMPUI2bUs6sOHmRp/Ec4Qd1E/wIL
X-Received: by 2002:a9d:6852:: with SMTP id c18mr12518761oto.174.1557977051961;
        Wed, 15 May 2019 20:24:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557977051; cv=none;
        d=google.com; s=arc-20160816;
        b=aTrZJ8b0JNYT6qXlMgRAi4Ka2QQAqHYW9lmw5lijzkusYlxfLqnYFXaDtg0ADJhrkI
         VE54eDNK2ZYucFQIyE574Y1lMtzxFlFSIzZKiC9KndYA+/AnCsNVyDgy9haRxrZJ19g7
         3RLlORtPQa2fwk8DT/6eTE4qrpMQxgMVLQWrE9gUEY2GmydCNMZ/LdvrQ0cVtYtJ47FY
         2SDi9AQZuZ95oOlpuaJrpzVefjsd24o3DSAOz9VbP9zNRRgv8KKFAFvbY2DfEHOC4oGP
         1HB54aEbD47C3PbE3Hjlw10I4Ybdwrodt/eVLxsss2JQPXtBA2p9ZKkx1+4WPAkfHsv+
         +wuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=sLhvt/hb+Hrcs5GGy6Qae9Dh1SE/JgKvAIHN/Ae6ZCc=;
        b=QfUqEIrLYfIxYtEUwXKgFXRicJEGhy2KoZPxx3D/sxdJX3zBR/VD7m7G95U1g/1ubv
         Ty4CupYtrYD66KrkSkjDyRD8XyaZ50uJJCHr0UHswVebHJMImvYbjrCeN0lQZ4oLEdgH
         zn9LCFV/8A09O/FOPkizPdzoUIvFeiCacVHRrN4Rov3D2m1pHe6svUFB0rbEu9tWlqld
         6s6yxRi0fvJuxNQ5dEiWzhTvSS0UUeQ32zbC/4t5Unb4FGZ8zUXTVT74kk1pzb+ITcqi
         jiMALZKXznpWB9WewLd6iwNCNY40W/4a1tXDWo6WQ0S/w2gkV1opl/d34usx/6RWhkul
         VQWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id h26si2106592otq.303.2019.05.15.20.24.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 20:24:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id D09F6FAB343E446E4313;
	Thu, 16 May 2019 11:24:07 +0800 (CST)
Received: from [127.0.0.1] (10.177.131.64) by DGGEMS414-HUB.china.huawei.com
 (10.3.19.214) with Microsoft SMTP Server id 14.3.439.0; Thu, 16 May 2019
 11:24:00 +0800
Subject: Re: [PATCH 4/4] kdump: update Documentation about crashkernel on
 arm64
To: Bhupesh Sharma <bhsharma@redhat.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>,
	<ard.biesheuvel@linaro.org>, <rppt@linux.ibm.com>, <tglx@linutronix.de>,
	<mingo@redhat.com>, <bp@alien8.de>, <ebiederm@xmission.com>
References: <20190507035058.63992-1-chenzhou10@huawei.com>
 <20190507035058.63992-5-chenzhou10@huawei.com>
 <de5b827f-5db2-2280-b848-c5c887b9bb58@redhat.com>
CC: <wangkefeng.wang@huawei.com>, <linux-mm@kvack.org>,
	<kexec@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<takahiro.akashi@linaro.org>, <horms@verge.net.au>,
	<linux-arm-kernel@lists.infradead.org>, Bhupesh SHARMA
	<bhupesh.linux@gmail.com>
From: Chen Zhou <chenzhou10@huawei.com>
Message-ID: <168b5c80-9a8b-ee94-9cfb-56e4955958c1@huawei.com>
Date: Thu, 16 May 2019 11:23:58 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101
 Thunderbird/45.7.1
MIME-Version: 1.0
In-Reply-To: <de5b827f-5db2-2280-b848-c5c887b9bb58@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.131.64]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/5/15 13:16, Bhupesh Sharma wrote:
> On 05/07/2019 09:20 AM, Chen Zhou wrote:
>> Now we support crashkernel=X,[high,low] on arm64, update the
>> Documentation.
>>
>> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
>> ---
>>   Documentation/admin-guide/kernel-parameters.txt | 6 +++---
>>   1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
>> index 268b10a..03a08aa 100644
>> --- a/Documentation/admin-guide/kernel-parameters.txt
>> +++ b/Documentation/admin-guide/kernel-parameters.txt
>> @@ -705,7 +705,7 @@
>>               memory region [offset, offset + size] for that kernel
>>               image. If '@offset' is omitted, then a suitable offset
>>               is selected automatically.
>> -            [KNL, x86_64] select a region under 4G first, and
>> +            [KNL, x86_64, arm64] select a region under 4G first, and
>>               fall back to reserve region above 4G when '@offset'
>>               hasn't been specified.
>>               See Documentation/kdump/kdump.txt for further details.
>> @@ -718,14 +718,14 @@
>>               Documentation/kdump/kdump.txt for an example.
>>         crashkernel=size[KMG],high
>> -            [KNL, x86_64] range could be above 4G. Allow kernel
>> +            [KNL, x86_64, arm64] range could be above 4G. Allow kernel
>>               to allocate physical memory region from top, so could
>>               be above 4G if system have more than 4G ram installed.
>>               Otherwise memory region will be allocated below 4G, if
>>               available.
>>               It will be ignored if crashkernel=X is specified.
>>       crashkernel=size[KMG],low
>> -            [KNL, x86_64] range under 4G. When crashkernel=X,high
>> +            [KNL, x86_64, arm64] range under 4G. When crashkernel=X,high
>>               is passed, kernel could allocate physical memory region
>>               above 4G, that cause second kernel crash on system
>>               that require some amount of low memory, e.g. swiotlb
>>
> 
> IMO, it is a good time to update 'Documentation/kdump/kdump.txt' with this patchset itself for both x86_64 and arm64, where we still specify only the old format for 'crashkernel' boot-argument:
> 
> Section: Boot into System Kernel
>          =======================
> 
> On arm64, use "crashkernel=Y[@X]".  Note that the start address of
> the kernel, X if explicitly specified, must be aligned to 2MiB (0x200000).
> ...
> 
> We can update this to add the new crashkernel=size[KMG],low or crashkernel=size[KMG],high format as well.
> 
> Thanks,
> Bhupesh
> 
> .

Sure, we can also update here.

Thanks,
Chen Zhou



