Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3253C282E3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 12:38:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EDB320661
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 12:38:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EDB320661
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0348E6B0010; Thu, 25 Apr 2019 08:38:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00B226B0269; Thu, 25 Apr 2019 08:38:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEE0B6B026A; Thu, 25 Apr 2019 08:38:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id BBB786B0010
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:38:30 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id f89so20713321qtb.4
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:38:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=ua054raX7RgvFXG7HxNxYdNmgXVEkZGkus5HvqAEFw0=;
        b=SuO9a4yuFOBJuBVIRAzCoModiOhDuvuI9R6uI4A5nVgWM9ETulS20pjMteYnE6SEQo
         ncmjqSAmz7GidCdDkgZ13yFTOq1oXUy9NUvqmCnX7MyqQNqjLHe3GzoOmhIRsmzxud0l
         8xlBtgCEhX6movniQ2MxrxcyDNMy+gibTpDAb/p/uaXsV9stTDyRYYm0TUfdWjgxpfdK
         SH55yLH6bSdgqXf11N1csJnIsS/qLO+n/AKFuzn2Brs9k6Xz5/SpDftlrptmefjt6XQs
         Rh19V2YXOjqz/FB5cr08bsQR5tgE1UB2A6Y+14F7EXxAnlx3yfOVauVj5omgYMP4zIJs
         e4pA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUqIzsBwo1RVgrquiWHTNZaNan8fr56a1dCrcnY5AGS3avy696q
	cj1mN7vD+ZDSOWTSbxkTkg6uPBN6XuGJ/oatVcA/38ISolZ0T4ySDogjVvd1O+AFhMhxKi8sOSE
	VIKzBbc0OkAWk+g30+f6ZNvDervZAvIlzilkrQ5luYNcwuSDpvjX5DiglFx0l1+483w==
X-Received: by 2002:a37:47c9:: with SMTP id u192mr30032369qka.9.1556195910533;
        Thu, 25 Apr 2019 05:38:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJ2O4h8E+W2On/FJYdehJ3MXX478OfRFxNVWi6La0842IBKTJnu+vKenLBRV/BpVZMd9Jt
X-Received: by 2002:a37:47c9:: with SMTP id u192mr30032334qka.9.1556195909719;
        Thu, 25 Apr 2019 05:38:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556195909; cv=none;
        d=google.com; s=arc-20160816;
        b=Bc6pd7KEPNSIndWRiFYB94PUL3ah0fIMsjOpjSXbsJz89e9FKJpNuYLTVS3iQ+P3mB
         gkpYukHrXUEYW5E1Jl2xffWrlQYFEVPsgMMp4e9XLOsCAiD09Bjy2adCnDlY0wcEfDo2
         1JWoBOOlwKWO1aPGk0J5EZc43jpC+tskKE5nlwZrFDlCRWnbeYgBtndlh3goJzhJLVHl
         uLckvIKG167cIndrwLnSMJvR6wCNl8scis5+qIb4KHxtP588qkeyEgxyJrtEz2LR7OnL
         /tLCLGyIkcyFA2dfDWn4Suyrg3UJ8dLT6YO5TIA7oDyJFWZHHPrfxB4TYjjNhXAdzJus
         p2+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=ua054raX7RgvFXG7HxNxYdNmgXVEkZGkus5HvqAEFw0=;
        b=gjWxml16D61Opbd/sB7ywNtrnlk+CJjBDgMFtp8V66vk04C/URCjB1LwYSbKEO5sBV
         ydSC13eaSb1c4C+0qKj/2FE3ffORSGfrQ0KM+MnaxSQUVuhLMDqEcDw12SCpXXd3CKfa
         tdSFc8uaqPj+PbfU7uMMRjBw5/MVs0CwgeE+RwVTbtPJmwdKRuu0IMODqRZKh7+ssq+8
         8obHH11ZkrQEs1HCnHTy2efeRhP98rOGrxPNQgQqaGO6SH1hGsa8duILqnlTDTqSWnkv
         bzj6A7IO5cGgoE4uz56q8vi7Wk8Z1664XdXCYZB8rw7eAlkU0mVBjYUFMcH8+T0L8WzD
         7WuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y24si1802842qkj.218.2019.04.25.05.38.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 05:38:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B21B83099FCA;
	Thu, 25 Apr 2019 12:38:26 +0000 (UTC)
Received: from [10.36.116.47] (ovpn-116-47.ams2.redhat.com [10.36.116.47])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1EA9560C99;
	Thu, 25 Apr 2019 12:38:21 +0000 (UTC)
Subject: Re: [v2 2/2] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Dan Williams <dan.j.williams@intel.com>, James Morris
 <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Keith Busch <keith.busch@intel.com>,
 Vishal L Verma <vishal.l.verma@intel.com>, Dave Jiang
 <dave.jiang@intel.com>, Ross Zwisler <zwisler@kernel.org>,
 Tom Lendacky <thomas.lendacky@amd.com>, "Huang, Ying"
 <ying.huang@intel.com>, Fengguang Wu <fengguang.wu@intel.com>,
 Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>,
 Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
References: <20190421014429.31206-1-pasha.tatashin@soleen.com>
 <20190421014429.31206-3-pasha.tatashin@soleen.com>
 <4ad3c587-6ab8-1307-5a13-a3e73cf569a5@redhat.com>
 <CAPcyv4h3+hU=MmB=RCc5GZmjLW_ALoVg_C4Z7aw8NQ=1LzPKaw@mail.gmail.com>
 <CA+CK2bDB5o4+NMc7==_ipVAZoEo7fdrkjZ4etU0LUCqxnmN-Rg@mail.gmail.com>
 <180d6250-8a6a-0b5d-642a-ec6648cb45b1@redhat.com>
 <CA+CK2bBt0vHr9D+BuvM=GmjCMESu5iBiUTdvid_TaoE6j2daQg@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <115b93eb-d6ae-9c48-f089-e381c9a66ff2@redhat.com>
Date: Thu, 25 Apr 2019 14:38:21 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CA+CK2bBt0vHr9D+BuvM=GmjCMESu5iBiUTdvid_TaoE6j2daQg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Thu, 25 Apr 2019 12:38:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25.04.19 14:30, Pavel Tatashin wrote:
>>
>> Yes, also I think you can let go of the device_lock in
>> check_memblocks_offline_cb, lock_device_hotplug() should take care of
>> this (see Documentation/core-api/memory-hotplug.rst - "locking internals")
>>
> Hi David,
> 
> Thank you for your comments. I went through memory-hotplug.rst, and I
> still think that device_lock() is needed here. In this particular case
> it can be replaced with something like READ_ONCE(), but for simplicity
> it is better to have device_lock()/device_unlock() as this is not a
> performance critical code.
> 
> I do not see any lock ordering issues with this code, as we are
> holding lock_device_hotplug() first that prevents userland from
> adding/removing memory during this check.

Yes, lock ordering is not an issue, I rather think that the device
hotplug lock will guard us in all situations. E.g. remove_memory() also
does not use it when checking if all blocks are offline. But you can
leave it in if you think it is needed.

> 
> https://soleen.com/source/xref/linux/arch/powerpc/platforms/powernv/memtrace.c?r=98fa15f3#248
> 
> Here we have a similar code:
> lock_device_hotplug();
>    online_mem_block();
>     device_online()
>      device_lock(dev);
> 
> Pasha
> 

-- 

Thanks,

David / dhildenb

