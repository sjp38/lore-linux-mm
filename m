Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD238C48BE3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 15:27:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8486C2075E
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 15:27:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8486C2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 339F68E0006; Fri, 21 Jun 2019 11:27:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EA828E0001; Fri, 21 Jun 2019 11:27:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 189C48E0006; Fri, 21 Jun 2019 11:27:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E9D938E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 11:27:14 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id d26so8214951qte.19
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 08:27:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=DX/lH03KdFLhvM7OqxrtXn9Ieu4HCW2XBqcoIJVALug=;
        b=SdcU0JCWp9gv6LlV+kUHrG4LkZGoH5O2h97hn9wXQhuaUKmHdqcuCxG9VxZEJRUiAU
         xSLy6135NDnlIJTF9ACVaqmY0UujcPbLM1mH+tcRIHpD6fAOE8/D6+xtdgW/yRnnxQQ+
         fojlOJbfh79+MDlGw7gHsktQF5jVgQ92VIf/87Wu0pCEjKedbSTjGht+aT3RF6jRwEFx
         7lYywIEMhedtSXPBB6T5nw6xZ227jXlEvYl1tJlKfXXXEPviia7wZyIt0HkqtMkMzZsO
         dLeMXFawb0dP4wF6/v1K4E+WIRt2vuigihQz6cN8XRHwvkjGw86nsQLW/6FFirYMoqwc
         ch7w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV/whAX6CpT78MDrZOhWUpJY9L70v4rDkfGTQA+vJwmWqgYED2s
	MLbPKJnLQaiyO39F73rVHNyHqQBNl7/lYeUp583Zq9HAstYqb5VhdoJFNF40XQ5lBWsINQD5BVO
	U49FsB7WOqCwgLmimszzqfQ8jYLhz7z9I3XT20m1ovszwV2C9i3lE4I706RaaWHq56Q==
X-Received: by 2002:ac8:336a:: with SMTP id u39mr54598717qta.178.1561130834735;
        Fri, 21 Jun 2019 08:27:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKKyRAbD+X600rxTVb79XuxD9wxD+ka/jAQfxWfwse4qaBlnw3JW9LCvhyFRBXBk2HsZon
X-Received: by 2002:ac8:336a:: with SMTP id u39mr54598668qta.178.1561130834088;
        Fri, 21 Jun 2019 08:27:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561130834; cv=none;
        d=google.com; s=arc-20160816;
        b=bBY6B9k2BFiGJwpC66exJGW+wwicXDnxFuQqQkdil8gkzaNaJipNLB9PWj8zuM+lgZ
         fbMbbdCXA1ZEKeI5hZAMAq03AOEh2fGf8OBE3jNNaSGjFysM0jKyu5IqG/oXxx3hlW+a
         L+0FI6zm9pi8IjZcH2bUeFH6CarMnIdvVUjnRILvLYLNsicYxZ9uf0nX/gOIyatln/nh
         oiXtwqBPB4ckKjXIbKehNaDdTtFkIetltt0jAGfr/XRXp8M7wQIorLq6URBtb2UwMjx6
         9PgXI3hEwUio5UwDPLnoImDIF64r0y/Q0SbZY3kLbVCyIo+Qo0FdrurRoYyVZKyelaIp
         SHLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=DX/lH03KdFLhvM7OqxrtXn9Ieu4HCW2XBqcoIJVALug=;
        b=bdS2vkVdd+0Z+CD8DGwvDwun1KiwKHOb9NVJpUz7LY1Kietzd1CdqKK3GB8Xl1ypoL
         qun9f7HHLWEVBs0vNNzVR/yXvenVea0NZiF2FBv4x0NparBdeydugJZx8x3kNe/rSHbP
         Y6scMIOTgZHluVZhLPB2TWklfY/LWuqts5oKQ6B1DGRNDaYODaNOJAZQgtGbmbWbLVRo
         5mqv18km+uVm6h49jMNYMgSp4DgSqKjl1q8ebu2sPpmYPGshnzJxz+EaKiTrVy4LXYzR
         PDv9LqolUHwHsk4a7rxi95gaHFe5thGUjTXDwBclVaGdzXc0BRlEJlf1wBa7G1w/5bDM
         ZEGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o123si1987437qkd.316.2019.06.21.08.27.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 08:27:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D9D3B3001839;
	Fri, 21 Jun 2019 15:26:49 +0000 (UTC)
Received: from [10.36.118.55] (unknown [10.36.118.55])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 647E9196EA;
	Fri, 21 Jun 2019 15:26:41 +0000 (UTC)
Subject: Re: [PATCH v3 5/6] mm/memory_hotplug: Move and simplify
 walk_memory_blocks()
To: linux-kernel@vger.kernel.org
Cc: Dan Williams <dan.j.williams@intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org,
 linux-acpi@vger.kernel.org, linux-mm@kvack.org,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>,
 Stephen Rothwell <sfr@canb.auug.org.au>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Andrew Banman <andrew.banman@hpe.com>,
 "mike.travis@hpe.com" <mike.travis@hpe.com>,
 Oscar Salvador <osalvador@suse.com>, Michal Hocko <mhocko@suse.com>,
 Wei Yang <richard.weiyang@gmail.com>, Arun KS <arunks@codeaurora.org>,
 Qian Cai <cai@lca.pw>
References: <20190620183139.4352-1-david@redhat.com>
 <20190620183139.4352-6-david@redhat.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <fb2a4fc7-bf96-3703-db84-b1e5dd0986b8@redhat.com>
Date: Fri, 21 Jun 2019 17:26:40 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190620183139.4352-6-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Fri, 21 Jun 2019 15:27:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 20.06.19 20:31, David Hildenbrand wrote:
> Let's move walk_memory_blocks() to the place where memory block logic
> resides and simplify it. While at it, add a type for the callback function.
> 
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Andrew Banman <andrew.banman@hpe.com>
> Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
> Cc: Oscar Salvador <osalvador@suse.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Qian Cai <cai@lca.pw>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  drivers/base/memory.c          | 42 ++++++++++++++++++++++++++
>  include/linux/memory.h         |  3 ++
>  include/linux/memory_hotplug.h |  2 --
>  mm/memory_hotplug.c            | 55 ----------------------------------
>  4 files changed, 45 insertions(+), 57 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index c54e80fd25a8..0204384b4d1d 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -44,6 +44,11 @@ static inline unsigned long pfn_to_block_id(unsigned long pfn)
>  	return base_memory_block_id(pfn_to_section_nr(pfn));
>  }
>  
> +static inline unsigned long phys_to_block_id(unsigned long phys)
> +{
> +	return pfn_to_block_id(PFN_DOWN(phys));
> +}
> +
>  static int memory_subsys_online(struct device *dev);
>  static int memory_subsys_offline(struct device *dev);
>  
> @@ -851,3 +856,40 @@ int __init memory_dev_init(void)
>  		printk(KERN_ERR "%s() failed: %d\n", __func__, ret);
>  	return ret;
>  }
> +
> +/**
> + * walk_memory_blocks - walk through all present memory blocks overlapped
> + *			by the range [start, start + size)
> + *
> + * @start: start address of the memory range
> + * @size: size of the memory range
> + * @arg: argument passed to func
> + * @func: callback for each memory section walked
> + *
> + * This function walks through all present memory blocks overlapped by the
> + * range [start, start + size), calling func on each memory block.
> + *
> + * In case func() returns an error, walking is aborted and the error is
> + * returned.
> + */
> +int walk_memory_blocks(unsigned long start, unsigned long size,
> +		       void *arg, walk_memory_blocks_func_t func)
> +{
> +	const unsigned long start_block_id = phys_to_block_id(start);
> +	const unsigned long end_block_id = phys_to_block_id(start + size - 1);
> +	struct memory_block *mem;
> +	unsigned long block_id;
> +	int ret = 0;

I *guess* the stall we are seeing is when size = 0.

(via ACPI, if info->length is 0)

if (!size)
	return 0;

... but that is just a wild guess. Will have a look after my vacation.

-- 

Thanks,

David / dhildenb

