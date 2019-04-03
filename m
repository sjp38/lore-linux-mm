Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3428C10F06
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:20:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BD6421473
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:20:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BD6421473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 398036B0008; Wed,  3 Apr 2019 04:20:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36FE36B000A; Wed,  3 Apr 2019 04:20:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25EA56B000C; Wed,  3 Apr 2019 04:20:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 081F06B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 04:20:40 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id z34so16104975qtz.14
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 01:20:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=pdrGnibi9CY36LQxVDUKmhIkfYPLUJxTINRB43JrB5M=;
        b=ByNRMbliHkx+M7ckYTYkapg84Fyilyx1pCaoyMRWgx17dhS5Fx1I50Mft2e7GZhrom
         JwqdMjeqPvynbE8bHAynwe6R0NNhgP8U/ba5DXe7O+GDXOAxJW7RTbqVQHKK2nu06YuY
         oidYEomrYPOPV7nExBH5zgP/RrCkPj+UKM+1gzt1pdtfPuCTKAbtNQ2ZMjahuKLbmk56
         3bJMOddBQ56s3pk/TCpn1DYA3KJ92s37TKAoSCQSa9+axNIqKGknTAjn4L1kywtG8R6L
         7N9v4a+zAn4bRlvEiuTu3kFoDqEJ86SFkO/0jh9dWDdXQcOWauiMXvKSyXp5HePg6Fic
         YVEA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWnIFDKDi74tLiyeanamezTFYECsOSb+A0E+pBg+hpUedyuKjLf
	GbGp1ZSMZ9TfIUkY4sZEeOsVv2b0SkbNAa5z+WgYQ3UTJsyPM7zHtre32haERbnZseyYou5Ym6+
	iy1flWs/PgLhl6ObNxo2I291eHp6TRO5KJm6WehU786W9jVpHN0BCYZsV3SpDB89PXw==
X-Received: by 2002:ae9:e109:: with SMTP id g9mr56306528qkm.251.1554279639771;
        Wed, 03 Apr 2019 01:20:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3+rSlvNyGJB75o9IzzEPjBPD4ypafc/iYxHGy2jwPUgT3NRSWCxe4QGq/u6OMoPOnvR40
X-Received: by 2002:ae9:e109:: with SMTP id g9mr56306482qkm.251.1554279638990;
        Wed, 03 Apr 2019 01:20:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554279638; cv=none;
        d=google.com; s=arc-20160816;
        b=YytNRtzC4WJExhp/ePwr9i+/R1BtSU3GYuAleEbTWMuvAeeqB2kPecxJrHMuvIQqqb
         j7HYzLb3HipvLuaYfS3oP0PHn3cko+4p3HMd8t3we51SlomuJee5zI9f/QxKdF8y+0Sl
         NON8PSLG6FmZdAOnBe7+AVTAN6P+KfuJRX3V6UZreWru8qVeUSNqeqMiqTydhWmWZOyC
         RaXtHvzkdueFoxwS3G66xVIbCWHsow5GSA0xSwf9MiUkHmG9hl/PTgR2s6p8UawtHuhV
         zgSxIy/C8LK533ujcGnlr30pmSpJV4sXqTCaCC4R+gTXR5mI3cuWi0HFiQdutj6Bqr/j
         UTFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=pdrGnibi9CY36LQxVDUKmhIkfYPLUJxTINRB43JrB5M=;
        b=zyGlQnAJfTbfvViSyJIq3DZHXW3ffVXiFACvddVpAJsCkivLrQAWawWTz+mvsSMMls
         GLYjuM1ZYYL29F/SYKU/Yl5xzT6cFf8ybj4pY/dgIrkHi8Dj7HdxBJAHapKL2ZLlBXH5
         TzljJnkB0YK/7wKH/BAlD8lnApdWvylZAwIcaD3fKtmOjXGljxoyERrqYWGHqVyBlcVF
         nSVHnWlfPvsoiFnJKf4EQRjYFrYLl6AawTvDobk24pcvSa7lPg7kNqwXBm3aMUQh54mB
         1mYudVdqAT9ilWiZGZRLK6fJA9uam9pkxHVG7Mf7xROEqWuGPRcUD0iJeOrkMThllNVA
         Ngdw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a62si3275695qke.96.2019.04.03.01.20.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 01:20:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 52B1E2026B;
	Wed,  3 Apr 2019 08:20:37 +0000 (UTC)
Received: from [10.36.117.246] (ovpn-117-246.ams2.redhat.com [10.36.117.246])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 79C4E17AF3;
	Wed,  3 Apr 2019 08:20:33 +0000 (UTC)
Subject: Re: [PATCH 1/6] arm64/mm: Enable sysfs based memory hot add interface
To: Anshuman Khandual <anshuman.khandual@arm.com>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
 catalin.marinas@arm.com
Cc: mhocko@suse.com, mgorman@techsingularity.net, james.morse@arm.com,
 mark.rutland@arm.com, robin.murphy@arm.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com, osalvador@suse.de,
 logang@deltatee.com, pasha.tatashin@oracle.com, cai@lca.pw
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-2-git-send-email-anshuman.khandual@arm.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <4b9dd2b0-3b11-608c-1a40-9a3d203dd904@redhat.com>
Date: Wed, 3 Apr 2019 10:20:32 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <1554265806-11501-2-git-send-email-anshuman.khandual@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 03 Apr 2019 08:20:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03.04.19 06:30, Anshuman Khandual wrote:
> Sysfs memory probe interface (/sys/devices/system/memory/probe) can accept
> starting physical address of an entire memory block to be hot added into
> the kernel. This is in addition to the existing ACPI based interface. This
> just enables it with the required config CONFIG_ARCH_MEMORY_PROBE.
> 

We recently discussed that the similar interface for removal should
rather be moved to a debug/test module

I wonder if we should try to do the same for the sysfs probing
interface. Rather try to get rid of it than open the doors for more users.

> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>  arch/arm64/Kconfig | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 7e34b9e..a2418fb 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -266,6 +266,15 @@ config HAVE_GENERIC_GUP
>  config ARCH_ENABLE_MEMORY_HOTPLUG
>  	def_bool y
>  
> +config ARCH_MEMORY_PROBE
> +	bool "Enable /sys/devices/system/memory/probe interface"
> +	depends on MEMORY_HOTPLUG
> +	help
> +	  This option enables a sysfs /sys/devices/system/memory/probe
> +	  interface for testing. See Documentation/memory-hotplug.txt
> +	  for more information. If you are unsure how to answer this
> +	  question, answer N.
> +
>  config SMP
>  	def_bool y
>  
> 


-- 

Thanks,

David / dhildenb

