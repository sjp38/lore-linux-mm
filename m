Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82AF5C76196
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 08:14:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20DFC21849
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 08:14:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20DFC21849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75FE66B0005; Fri, 19 Jul 2019 04:14:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70F786B0006; Fri, 19 Jul 2019 04:14:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FCF98E0001; Fri, 19 Jul 2019 04:14:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5556B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 04:14:12 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id q26so26953344qtr.3
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 01:14:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=3OO5cLeVcleH2agv1aRrrTa1uDKni+pDXM/xS4oocAA=;
        b=IcCGFjrMdhC8DoD8dezmNMSUkFGXYzeBSZltTI8+gt7ET0OMYCsM7nx4kGcoVjDZgm
         bkr8xaq6J2K46tudkqIkeuWW2bcTzouEO7+tyCVM6g0+r4Z31hYZ2XhLdR6C6HjWNMZl
         qAlgHRi9IjOdryVU5EQq93fi4QRpGCXMHJtKFALRc0ifN5qwmt0HBp/AVRpX2EMTuwF1
         4ZEcMlr7vVH5UaJQiZP9X0lAfOID90KqT05jl9Kk8eIVrqYEzpMpdtJFn/AOghdRvpZ9
         uAwJXy/Lq7AXzPzOqnJKr22Sjadt0iz4XYhQcgtElt+FkPWrNuqslU8baQwLu3QTvNB6
         xxmQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXNKHPPOleIKkczJa6JdxPEAAfxr7MbTzY58Lj2MFhCLS7VDfJA
	l0Q5QIiNR1eGthZGg+J4PyGzmtEseQ4mNhdx0Ac7ODdTeSqYnC65wZ5SwMTipzDwq2eSGEXMe06
	U5a42nee8GIorJkKJlUudnkFXu/lcZTxEHIpn5ZtNJTZRuzDal9nVlinMookEO+cqkw==
X-Received: by 2002:aed:3ed5:: with SMTP id o21mr36102990qtf.369.1563524052004;
        Fri, 19 Jul 2019 01:14:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0qoeRfTFrTvMXLFPp5IhXKTp6kHwSHjR+O9maP1emGVfFBLGx3/3OR6xDu0CqQ78zwSX1
X-Received: by 2002:aed:3ed5:: with SMTP id o21mr36102928qtf.369.1563524050783;
        Fri, 19 Jul 2019 01:14:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563524050; cv=none;
        d=google.com; s=arc-20160816;
        b=qoLQa8XqUnSJbsH5rp4nST4pxzzwzdyYAp11dmRO2PQeraDkHhyCia8th5DyAk2KEN
         FFPcFtl8ShBATCeFFUDE1lKTnbc/JNVPt/kYgDT5yCJMku3T1cv2YRBXgC4Ri6Nax05u
         hE9vt3/LiQpWRdpDzzkDCZq4nG5ScQGj1cxeDJucFQmVb6UXlOxk4fqZAEbIgD/Um2D0
         +ONkRwqJO9jvT7XUYp2v8Zl7h+wdYsXSfg7NVgZU6b85Wx2ZMYQV9pDhk3dwAN4j/zGq
         p7BMKj/wIqGvVH5GCBuvcV7hmY8qGeGhCfPD37rCLaee0a1hagsX//BvkvhHxZpmPNRJ
         Fn5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=3OO5cLeVcleH2agv1aRrrTa1uDKni+pDXM/xS4oocAA=;
        b=Li0TGwEeCe5QcY6lKfIeRS5siM/fHTdfGqw4xG+OyLEnAV6mjllvO8UIhBGk0mGBpr
         6JgaoRKo+ygZTAKEcPfyYkWp3QPR4yhrRyrSv7bDpX6S5vOFpJXvr7uyLhv2g6lFE88M
         QZbyQ9XcXomX4rSjuEFNH8kcr3jGDlaFe8R6AnkVACGiSiRDtVq5hgwaV1ET5qoXNbDo
         7ieQ1RFpjMeoRkeuMmS8R29AiykUpm5xuLYqH77KkP7drspPqEH5PUQpHCXxGZdcfiuk
         CQMoGuk9rdufmW2azUCIX3h+IqKfvAw50ikJ5lAbvGuqAz0Q1IieuEG14xaDLkgac6YU
         gjrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k55si10070551qtb.327.2019.07.19.01.14.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 01:14:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AFC3E309264C;
	Fri, 19 Jul 2019 08:14:09 +0000 (UTC)
Received: from [10.36.117.221] (ovpn-117-221.ams2.redhat.com [10.36.117.221])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8C9A260126;
	Fri, 19 Jul 2019 08:14:07 +0000 (UTC)
Subject: Re: [PATCH v1] drivers/base/node.c: Simplify
 unregister_memory_block_under_nodes()
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Stephen Rothwell <sfr@canb.auug.org.au>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, Michal Hocko <mhocko@suse.com>,
 Oscar Salvador <osalvador@suse.de>
References: <20190718142239.7205-1-david@redhat.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <334e0392-54d3-648b-f441-20359343d845@redhat.com>
Date: Fri, 19 Jul 2019 10:14:06 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190718142239.7205-1-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Fri, 19 Jul 2019 08:14:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 18.07.19 16:22, David Hildenbrand wrote:
> We don't allow to offline memory block devices that belong to multiple
> numa nodes. Therefore, such devices can never get removed. It is
> sufficient to process a single node when removing the memory block.
> 
> Remember for each memory block if it belongs to no, a single, or mixed
> nodes, so we can use that information to skip unregistering or print a
> warning (essentially a safety net to catch BUGs).
> 
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  drivers/base/memory.c  |  1 +
>  drivers/base/node.c    | 40 ++++++++++++++++------------------------
>  include/linux/memory.h |  4 +++-
>  3 files changed, 20 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 20c39d1bcef8..154d5d4a0779 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -674,6 +674,7 @@ static int init_memory_block(struct memory_block **memory,
>  	mem->state = state;
>  	start_pfn = section_nr_to_pfn(mem->start_section_nr);
>  	mem->phys_device = arch_get_memory_phys_device(start_pfn);
> +	mem->nid = NUMA_NO_NODE;
>  
>  	ret = register_memory(mem);
>  
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 75b7e6f6535b..29d27b8d5fda 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -759,8 +759,6 @@ static int register_mem_sect_under_node(struct memory_block *mem_blk,
>  	int ret, nid = *(int *)arg;
>  	unsigned long pfn, sect_start_pfn, sect_end_pfn;
>  
> -	mem_blk->nid = nid;
> -
>  	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
>  	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
>  	sect_end_pfn += PAGES_PER_SECTION - 1;
> @@ -789,6 +787,13 @@ static int register_mem_sect_under_node(struct memory_block *mem_blk,
>  			if (page_nid != nid)
>  				continue;
>  		}
> +
> +		/* this memory block spans this node */
> +		if (mem_blk->nid == NUMA_NO_NODE)
> +			mem_blk->nid = nid;
> +		else
> +			mem_blk->nid = NUMA_NO_NODE - 1;
> +

Although I am not sure if it can happen, I think it is better to have

if (mem_blk->nid == NUMA_NO_NODE)
	mem_blk->nid = nid;
else if (mem_blk->nid != nid)
	mem_blk->nid = NUMA_NO_NODE - 1;

-- 

Thanks,

David / dhildenb

