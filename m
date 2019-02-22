Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24A5DC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 10:12:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB22620823
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 10:12:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB22620823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=inria.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0884E8E00F5; Fri, 22 Feb 2019 05:12:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 037918E00E0; Fri, 22 Feb 2019 05:12:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E429C8E00F5; Fri, 22 Feb 2019 05:12:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E7078E00E0
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 05:12:41 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id e18so796277wrw.10
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 02:12:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=aTMDg7I5fSeDBwRM+ByODZkIydWuxkAcwCQCEJw6ypc=;
        b=afjAlXrHE+JXHav26NItMgJbFup93hLtsxG3HuDiaC5ozouTUHdCBf3f8JpztxHmkP
         WLvSAS9Fr76NWAbVP6ANRV925Zw48hcnXKGrpXX4Qk7TPgArjeXHJCtbesIc4teo2pq1
         Q+hEoJoEvqCqfJUfmf8owEAt9JAK4DOBxiPBAH6WHKJRm0u4+dcnAtnwh9PonIsmE+/2
         a+qKsSZcH70zkCgeyApj3km2RuSzV1j+E9+w85wm9++F0MhIVgSfHYTzziYDw3t25qyR
         P2K5FvtwboIsDI8FS1wHLn1ErgQmVn5dB/eEa4oMxOWNgeGZ0gWOxglxBZVkoqTCHBUi
         9DiA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-Gm-Message-State: AHQUAua60/MOoizpBu0OaL+RMhFqS2b2pZjoooih17igmNFqDTGb24dT
	2XAd7cTpu+UOCHzqSNbYygNK7k2SsBaIqqLX3zTuu+aX1nROmJ4eKM/0nCQPkQIAFL/qVM4AI87
	8TfjSNL9fBAzZmIHRg9JTMFm8mgiChRedMA28nVE0WK9XXUI2YsVTnYGi7KYCFcA21g==
X-Received: by 2002:adf:f691:: with SMTP id v17mr2428524wrp.66.1550830361075;
        Fri, 22 Feb 2019 02:12:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYt1ptFCbRQcN+SGoXd4bKuR9FSwH3lgsXcFNb634QNJG8hlTZIayuQcTnTQSDZ6DJxQdKX
X-Received: by 2002:adf:f691:: with SMTP id v17mr2428455wrp.66.1550830360080;
        Fri, 22 Feb 2019 02:12:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550830360; cv=none;
        d=google.com; s=arc-20160816;
        b=geb+TLmDtWSFNIQMLy0plDWMh4gK5gLozMAx1EngJQ4w9upIx3cI6yOJc68phg6FxZ
         dDwCl8WG7LJH/z2MXqpqwiqW0EUFg/27R/ckJt5ookisRHEU2GSMNSYPIaZeXaMcMi9n
         M2TrQOVN/lteRgTf9x2SeT9zTAmBZxhw/Z92i8AsTpfqaggwlmAHs737iNKHoS8yFksZ
         BvuggThGHZVVeE/Dn1D/OlvRUzoMppvboZvETygmG3PiJ4UjGpG2hajGspj7NJbZ21h6
         BUxcMEkYQVfYx5vKl6ZgRWFj6ujP0fcoujzcAjt35VucL0cG4EY2SijHt0rJWWk47rTH
         6HPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=aTMDg7I5fSeDBwRM+ByODZkIydWuxkAcwCQCEJw6ypc=;
        b=0Vzw7tt3PJ49jrTZghXcMcEV/nVaGDG55eDGb9l+W1vDL7Xe4AUGndZUC9GeJLpZt3
         hsOuf/W7+z64qNYQYXqZdDk/jHHyer2GpPT9ix53V0qd94DJYNIeRKnWA4wl962/FaUv
         P9mNyFtZt0jOeyE1Yl1QM9MxmDyBInQ++WyaM5cBhGmbILX2taAA6U1GFJ4jGVZ60sVE
         d3p9lLma1cNu9kDz4L1t/h8fUzXy7yfV3fYcwtRf9uv1ehUhwUlm3uNYr8T8b6aH9tsw
         043RsQtke6cTj/Jjf5LagqApwIHgjRbcfNIBr7ZCBc4u5CuMqppUKUyX3Ygj65WclIHU
         5aKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
Received: from mail3-relais-sop.national.inria.fr (mail3-relais-sop.national.inria.fr. [192.134.164.104])
        by mx.google.com with ESMTPS id q9si707852wrv.174.2019.02.22.02.12.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 02:12:40 -0800 (PST)
Received-SPF: pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) client-ip=192.134.164.104;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-IronPort-AV: E=Sophos;i="5.58,399,1544482800"; 
   d="scan'208";a="296991036"
Received: from unknown (HELO [193.50.110.76]) ([193.50.110.76])
  by mail3-relais-sop.national.inria.fr with ESMTP/TLS/AES128-SHA; 22 Feb 2019 11:12:38 +0100
Subject: Re: [PATCHv6 06/10] node: Add memory-side caching attributes
To: Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org,
 linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
 Dan Williams <dan.j.williams@intel.com>
References: <20190214171017.9362-1-keith.busch@intel.com>
 <20190214171017.9362-7-keith.busch@intel.com>
From: Brice Goglin <Brice.Goglin@inria.fr>
Openpgp: preference=signencrypt
Autocrypt: addr=Brice.Goglin@inria.fr; prefer-encrypt=mutual; keydata=
 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
Message-ID: <29336223-b86e-3aca-ee5a-276d1c404b96@inria.fr>
Date: Fri, 22 Feb 2019 11:12:38 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190214171017.9362-7-keith.busch@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 14/02/2019 à 18:10, Keith Busch a écrit :
> System memory may have caches to help improve access speed to frequently
> requested address ranges. While the system provided cache is transparent
> to the software accessing these memory ranges, applications can optimize
> their own access based on cache attributes.
>
> Provide a new API for the kernel to register these memory-side caches
> under the memory node that provides it.
>
> The new sysfs representation is modeled from the existing cpu cacheinfo
> attributes, as seen from /sys/devices/system/cpu/<cpu>/cache/.  Unlike CPU
> cacheinfo though, the node cache level is reported from the view of the
> memory. A higher level number is nearer to the CPU, while lower levels
> are closer to the last level memory.
>
> The exported attributes are the cache size, the line size, associativity,
> and write back policy, and add the attributes for the system memory
> caches to sysfs stable documentation.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  Documentation/ABI/stable/sysfs-devices-node |  35 +++++++
>  drivers/base/node.c                         | 151 ++++++++++++++++++++++++++++
>  include/linux/node.h                        |  34 +++++++
>  3 files changed, 220 insertions(+)
>
> diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> index cd64b62152ba..5c88cb9ca14e 100644
> --- a/Documentation/ABI/stable/sysfs-devices-node
> +++ b/Documentation/ABI/stable/sysfs-devices-node
> @@ -143,3 +143,38 @@ Contact:	Keith Busch <keith.busch@intel.com>
>  Description:
>  		This node's write latency in nanoseconds when access
>  		from nodes found in this class's linked initiators.
> +
> +What:		/sys/devices/system/node/nodeX/memory_side_cache/indexY/
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		The directory containing attributes for the memory-side cache
> +		level 'Y'.
> +
> +		The caches associativity: 0 for direct mapped, non-zero if
> +What:		/sys/devices/system/node/nodeX/memory_side_cache/indexY/associativity
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		The caches associativity: 0 for direct mapped, non-zero if
> +		indexed.
> +
> +What:		/sys/devices/system/node/nodeX/memory_side_cache/indexY/line_size
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		The number of bytes accessed from the next cache level on a
> +		cache miss.
> +
> +What:		/sys/devices/system/node/nodeX/memory_side_cache/indexY/size
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		The size of this memory side cache in bytes.


Hello Keith,

CPU-side cache size is reported in kilobytes:

$ cat
/sys/devices/system/cpu/cpu0/cache/index*/size                                             

32K
32K
256K
4096K

Can you do the same of memory-side caches instead of reporting bytes?

Thanks

Brice



