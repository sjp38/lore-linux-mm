Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EE8DC10F05
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 21:43:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBCB1218A6
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 21:43:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="cq29vIO8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBCB1218A6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1EE2D6B0007; Fri, 29 Mar 2019 17:43:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19C666B0008; Fri, 29 Mar 2019 17:43:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 049426B000A; Fri, 29 Mar 2019 17:43:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id B778E6B0007
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 17:43:00 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d33so2536295pla.19
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 14:43:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=ftvuRkYU+0Pcq3Bvvq5Vs+GUVHhY3V3UTjr/Mr6sOlA=;
        b=GJLyasR8yaa1R+iukdtpxwJQs6f0E5cNOmlqB/d2VvJpT5+ALt4fQUacw0b/jVJDwH
         5iPBd4UJKs7u8QKb53b7I2pEq89NPEPONpsRpDq5COax3jWH3RPhELFP+zkEFyRIhQ4t
         b8fBNwgmra/v4vE8lrK9+Epzar24MiKDYJTEojk+f8NLNgYdO5TqJs4wIBn67vKPjHq+
         njj8FkXLhTa4JRN7slsThNhiuon8k+Q/2j6lRsOChYz2EYqLOKS6B//VOXDzPBjQPfwW
         GZDEKNlw0ppqM/kEj0g+CYVeGtnUo/R+P28iNLdU3AvEC97k5+FiHF3Q5IXQXQBjSLFb
         XG9Q==
X-Gm-Message-State: APjAAAXEJ+RUeL2RSGNRFKs4NYTU/Kik9cWHs82Wqaqm7tJ+XCL4eojP
	6iDONfUcXykikaswBakkMXSSKhFaUbfL3gMxufmgEKFnkjMoitpyCCC1c2e9qqJZkApj0LmBtlk
	2iPicl1PrjvrREVg7O1dwdlrDhLEMSOZI2TozOHEKEIIDK3TiUErH/JLIVVsrTH5QmQ==
X-Received: by 2002:a17:902:8a84:: with SMTP id p4mr50079325plo.2.1553895780193;
        Fri, 29 Mar 2019 14:43:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxt7dFXEHJMnwoiLKRZMAdVS2UaT3c3FHy0Gtn3e46UumbQInQyvCFifzcz22rNBVDo6yRW
X-Received: by 2002:a17:902:8a84:: with SMTP id p4mr50079277plo.2.1553895779468;
        Fri, 29 Mar 2019 14:42:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553895779; cv=none;
        d=google.com; s=arc-20160816;
        b=PplH7cWqXZKVhessi/SNg7eDF7zvssBFqa2hPY/aGR0c174G/MHBbg1IhGS3DhQ96w
         F1Px48iH6dAXjlszX8g+jNwAPPg07kMK29k6iyd9yKNdRRJgVUN0omeJpyI4A47WqN7h
         PcbonRZ3juMloAeridEvCXLJTvQWH6IjrLisnMQvmq/VSlTu2BENgFwEASJ4Tj0V+5dg
         HDNUrfw3neIEHT64SnWV++dsZDDGcme+zOjdVT08B76iGfK3ighfUZ6ibhzJ1BCv7h7b
         06ltxau+/yiyE17oMZBA3CFsoS4/QFjcWhqO7biQFSn4S4Aadxioigg/JMiVePTdxcjz
         9T7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=ftvuRkYU+0Pcq3Bvvq5Vs+GUVHhY3V3UTjr/Mr6sOlA=;
        b=i/OUGxZU+JokBmGA5bqOa5CVM8cGPAsTU+rs2JrIKtjlxsFTCLsEO4uignFPPTCNzX
         yrARDOiDQYitlteFY67oae7UgHIqefI8+vqfdNbByVpauqg5Y4XMOlHyfxfeg/Ivqo39
         2nOBI47aiAo+bCws+uatDi/3nFufEG5lLd+NZRFz97G7tiqOBAXSGpf4rZKpc5M89fNx
         VG+/BmhB+gDbPfPPyJEAIs7FfqGHK2/9Ex8nnUOSBas+43plF/XE+5ueWs/bLWzYIL/I
         smEQVu8VbgjBcF7ti/0hnfH5fENvouQwZLxuARcx4f2AhHr/eaPEXw+HMrJO0cUdXMhh
         g9VQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=cq29vIO8;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id m1si2787405plt.28.2019.03.29.14.42.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 14:42:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=cq29vIO8;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9e91660000>; Fri, 29 Mar 2019 14:43:02 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 29 Mar 2019 14:42:58 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 29 Mar 2019 14:42:58 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 29 Mar
 2019 21:42:58 +0000
Subject: Re: [PATCH v2 01/11] mm/hmm: select mmu notifier when selecting HMM
To: Jerome Glisse <jglisse@redhat.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Ralph Campbell
	<rcampbell@nvidia.com>, Andrew Morton <akpm@linux-foundation.org>, Dan
 Williams <dan.j.williams@intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-2-jglisse@redhat.com>
 <d4889f44-0cc5-3ef6-deeb-7302c93c1f90@nvidia.com>
 <20190329211529.GA6124@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <c05dabd3-dd06-74d9-951c-ae409da31cd5@nvidia.com>
Date: Fri, 29 Mar 2019 14:42:58 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190329211529.GA6124@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553895782; bh=ftvuRkYU+0Pcq3Bvvq5Vs+GUVHhY3V3UTjr/Mr6sOlA=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=cq29vIO84NPcmqlscz0xP2ghrrNtfG58xG8IeG2S5j3JMf2uMQT2PbH4VUxI9JrVP
	 YSrp9EQQsZHAtWMWBtnl7retYbnRyovtnqaerVcmXnAOptOmijP2pAS+DDBDcUI2XV
	 uzPDI4uNt/Zmk38Rokgisgmha45YMUJkFE+coI1kNeRRtFRXwOeq0N1hOO8GhS+vtW
	 j88vpq+OMnYzqXEtRMs/2M5fedthcQaMTjshAXQErGygJCi3iPMAmnuUtCYyFkkwOv
	 LvbNp2IIQSTJgXNxT+63xnvFbHhQmI47l2Y9D9+bDu1W79BhHAxT6jlsQ7+Ni19/dC
	 YkX7pItTbh6gg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/29/19 2:15 PM, Jerome Glisse wrote:
[...]
>> Yes, this is a good move, given that MMU notifiers are completely,
>> indispensably part of the HMM design and implementation.
>>
>> The alternative would also work, but it's not quite as good. I'm
>> listing it in order to forestall any debate: 
>>
>>   config HMM
>>   	bool
>>  +	depends on MMU_NOTIFIER
>>   	select MIGRATE_VMA_HELPER
>>
>> ...and "depends on" versus "select" is always a subtle question. But in
>> this case, I'd say that if someone wants HMM, there's no advantage in
>> making them know that they must first ensure MMU_NOTIFIER is enabled.
>> After poking around a bit I don't see any obvious downsides either.
> 
> You can not depend on MMU_NOTIFIER it is one of the kernel config
> option that is not selectable. So any config that need MMU_NOTIFIER
> must select it.
> 

aha, thanks for explaining that point about the non-user-selectable items,
I wasn't aware of that. (I had convinced myself that those were set by
hard-coding a choice in one of the Kconfig files.)

>>
>> However, given that you're making this change, in order to avoid odd
>> redundancy, you should also do this:
>>
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 0d2944278d80..2e6d24d783f7 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -700,7 +700,6 @@ config HMM
>>  config HMM_MIRROR
>>         bool "HMM mirror CPU page table into a device page table"
>>         depends on ARCH_HAS_HMM
>> -       select MMU_NOTIFIER
>>         select HMM
>>         help
>>           Select HMM_MIRROR if you want to mirror range of the CPU page table of a
> 
> Because it is a select option no harm can come from that hence i do
> not remove but i can remove it.
> 

Yes, this is just a tiny housecleaning point, not anything earthshaking.

thanks,
-- 
John Hubbard
NVIDIA

