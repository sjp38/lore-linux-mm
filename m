Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71057C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 10:22:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C1CE20823
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 10:22:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C1CE20823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=inria.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF53C8E00F8; Fri, 22 Feb 2019 05:22:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA2728E00EA; Fri, 22 Feb 2019 05:22:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6A7E8E00F8; Fri, 22 Feb 2019 05:22:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4DDDE8E00EA
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 05:22:14 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id h65so799832wrh.16
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 02:22:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=BLSWqi13NeQ6VkahE3IehIo5IrXyRv0YvTHIoVRA7hY=;
        b=PfXYiMWYm0oDP70mSPXhozEOcxtow74jn3g6Gkh2kdq3vkfNFLCXX9h5/aB9nmArMU
         1XJFSQKuWBCGTi423XUqm87DaTFUauzEJae8QE7igrwK7/xNCOOAJyUi+zJqRjPrJKkl
         ntrq+lq2bzKYpitW3JpzNF+fL1mdcIbvIs9GC4J4vuAYSW8uj/tRKfQI+yWp2j/ZnEzW
         UAx9Ldm+EvLDxD1geT9RpR7EWZ60vzsGuEmvlWVRg0EpiSL3AagTLxo3F9MKdxZsEpu8
         RZZkSuh/rKl+p+qnziSaMcOetoNAUletxQ7vDUHEoG6Pp0jjN/prxOoCkZeGL92w7/Rj
         7fEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-Gm-Message-State: AHQUAuYuxBRoQBnLpLmQZed1MG46NAa8ILiCzVJCdf6FiKEFriKiCvzi
	zJdGVRmol+0/tkxuAhY5KSFnD9us3Xt/kCgioUOjpisr/kY81cAfPPH7B8N7dMAFEsFp5jGCjJI
	tP8lVmZ/WdaU/mIX8vpFon3P9MkTdXKcVlo2dM10avwa31zPxhyjKPyA1mbRFtJaFuw==
X-Received: by 2002:a5d:4711:: with SMTP id y17mr2467028wrq.141.1550830933889;
        Fri, 22 Feb 2019 02:22:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia7FcgYKeYgRFHpqB8lUDeqSlR1LO8M5lRrNX7pusnqITNEuMK3GtG8gEgTufvS5acpje0k
X-Received: by 2002:a5d:4711:: with SMTP id y17mr2466980wrq.141.1550830933124;
        Fri, 22 Feb 2019 02:22:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550830933; cv=none;
        d=google.com; s=arc-20160816;
        b=s+QZffxIKBhtM2nguhOlR6EAP4sQVm9R5zaOJ3UYq0/mTLhEu/4s8udMKQ0hm3VJLR
         sxUoODN6cM1T3UuooA/sbD7hcT4xJsNsVkf/KAyEuJ1Z5Pzj/zEnd4tpSEzlf1jIJJZ0
         WzaVxez5o2olHyzWh64JOS9l2KSeLspnI/WKDzGpyLOcGO/YRD0jVSeWtkLnPZMCq4nR
         fDrtK8ScZr3lebbGhEre4kNc+Q2DsRcEjK2bt4VeLqBpulldEqSILM7qjkryOJm7GT7k
         ceECb/tIOhWVUERJ44IUU5oE6q72dAdq1QSh7V1gyNpkyOKlMA4Lfcn9uIZoQuZyW9JX
         kGFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=BLSWqi13NeQ6VkahE3IehIo5IrXyRv0YvTHIoVRA7hY=;
        b=F0UiE19l5GLHJl/L1LJgYNNhYL7ezSUple9ZEblkT69MzJWm/51w353YurmRwBW22I
         QTHmLhuvDIDWadk0VGmMCxzScZi+ftD/y2nS+VkuaLL9rUw9m0AGynSfvnyKEA0KGtot
         xFtOyYnFokkiWgg6J46NOERRSa46sLvXar55BQ7LPK+Xts+a+5Ho8ccm2dZuyxd2/4Mf
         s6PPVIETW4Nc1LpAQPIoTvhEUxB/jP5WQ8phLRUkRhYBvmBmtRgB1uXUYSwCyaJ266E1
         am8pzWk5JwpVaPLJnK1ZTA5NohHVQc423ZkT2sJsSCAsjvVXOaf3FZyEEt7qhi/+330Y
         YpxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
Received: from mail3-relais-sop.national.inria.fr (mail3-relais-sop.national.inria.fr. [192.134.164.104])
        by mx.google.com with ESMTPS id m14si810005wrj.161.2019.02.22.02.22.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 02:22:13 -0800 (PST)
Received-SPF: pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) client-ip=192.134.164.104;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-IronPort-AV: E=Sophos;i="5.58,399,1544482800"; 
   d="scan'208";a="296992401"
Received: from unknown (HELO [193.50.110.76]) ([193.50.110.76])
  by mail3-relais-sop.national.inria.fr with ESMTP/TLS/AES128-SHA; 22 Feb 2019 11:22:12 +0100
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
Message-ID: <16221be9-2f60-3a39-fd6c-5299cd94dc02@inria.fr>
Date: Fri, 22 Feb 2019 11:22:12 +0100
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


Should we rename "associativity" into "indexing" or something else?

When I see "associativity" that contains 0, I tend to interpret this as
the associativity value itself, which would mean fully-associative here
(as in CPU-side cache "ways_of_associativity" attribute), while actually
0 means direct-mapped (ie 1-associative) with yout semantics.

Brice



