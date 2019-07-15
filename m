Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 118F1C76190
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 09:33:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C266E2083D
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 09:33:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C266E2083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 540C66B0003; Mon, 15 Jul 2019 05:33:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 518856B0006; Mon, 15 Jul 2019 05:33:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 407366B0007; Mon, 15 Jul 2019 05:33:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 20C346B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 05:33:16 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x7so14292026qtp.15
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 02:33:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=3ypF9L5PHfmASYxDsdG67iNgHd95X/YQ+YKxhqMddlU=;
        b=CH5U4rhI/yW+wT3ZGDhnVhMd/NgCGJtkZCTVo447TKebIe3IHof8CDfkGadEjvyGXj
         845+0CCahoeOVDvEDKynvwFw8ryvypiYhD+u2RLhlCRz12VJpGLRPpbpzWgZNjmC/Q2P
         6aseM0/ZpnedwnLDc5rVMddMVElwCfeaQfbeNonw6fKKPt8zvnfmK196o3gg1YSvGvRD
         6eJCGvzDx6Os60CKdCg2vFnxoV8mFtTbfBqFzQKVt1IoIsmmWniJ7FZjey0Brux3d6vM
         nYsXuppQbujQyIPlhYmTNRwJFvf+v2fA9F8EpCGjE0QLN8/WE1L+Pxj1ykk78eY7+6rY
         k41w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXcgg6SafhMeexYXguSNpb8/IOozoNtrlK9DefKODFiFlHP8tx8
	AuoTRlapbY2dde65TPPndmAJS0Aeq+iiZxkHPupCtLze3zGNf4t5zSYAZfxvOeQ0/wLjaLRUjHW
	6oUJsYoHHI6g+lRPrZn80REFE7PdsFWh9fnMso948BBrm1ZXbsfCscb90t83KLxKgqw==
X-Received: by 2002:a37:b741:: with SMTP id h62mr15987200qkf.490.1563183195888;
        Mon, 15 Jul 2019 02:33:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxi0gTGeTxnkZJh3tGMZ3vHPkM3r5znDe/NMVTXgbnbSqRha0rPLj3Z3teLk/VTnrwsugZn
X-Received: by 2002:a37:b741:: with SMTP id h62mr15987164qkf.490.1563183195365;
        Mon, 15 Jul 2019 02:33:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563183195; cv=none;
        d=google.com; s=arc-20160816;
        b=f3+8uCf0TQB3lKoFOHy84LEGuHN2kqbU9UA2g9i8Prxeb8HSInS9zcX0DXGNh5prvJ
         YJktpAyz6Z5Hz01XIexAbM+DkuEAOKUL4PH0jlUbtGQdJX8+cn9wvsvqKVK7rUawBaQ6
         beJ+NZOJFvIPokuYvUNbq2krePplFljHZhRahRuU/IU4Qydn8rWJAA8grSDc0doiwOtq
         MlEXMmvaNLB/y3Q4vxFlI6/bB5C9LXl/vR/KEDfGlDxdaUaJke3V2Vo7r7xJLKZqeZbL
         K6MSokZ4Z+LC+m8JERsIVntIRKVHbP/LtHmOFRT7NvFMkGMkqpHQvOTLOw9AXNYhWPdh
         e7NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:to:subject;
        bh=3ypF9L5PHfmASYxDsdG67iNgHd95X/YQ+YKxhqMddlU=;
        b=HYopVcCm0aqRyE8Zqn37eNmtCSkfBIKiGTVraSG8Zx/OZPLZDe0B8aKqjDQh9Axznv
         bIrV0rYpcCMGEsCeG3NkoOWVsY4SmgHpZSTMbf/eezOqcV/frmxzlWPjAiSaoJ3VP+SH
         uZdU40F2oCg4Mu1OJ1vpR5/vxNc0p4dAx9B8vM0KFNCebPIx9nYPw+Ru4bW0rDTm2huA
         FYS/GFEgGNx/A64k3o8gW2InnGEXtqLS49it7Thj/Ayy9+VSrTjAu6FE3nejh7wbuiqv
         OK1I3ciaZheerq85q4ciP+XUiSK8o0TmsNyyZb3n54e6Hyy45KCUcbm98Sg973HtwEg5
         Lf4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w64si9990170qkb.254.2019.07.15.02.33.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 02:33:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7342B3084248;
	Mon, 15 Jul 2019 09:33:14 +0000 (UTC)
Received: from [10.36.117.137] (ovpn-117-137.ams2.redhat.com [10.36.117.137])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2E5745C231;
	Mon, 15 Jul 2019 09:33:01 +0000 (UTC)
Subject: Re: [RFC][Patch v11 1/2] mm: page_hinting: core infrastructure
To: Dave Hansen <dave.hansen@intel.com>,
 Nitesh Narayan Lal <nitesh@redhat.com>, kvm@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, pbonzini@redhat.com,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 yang.zhang.wz@gmail.com, riel@surriel.com, mst@redhat.com,
 dodgen@google.com, konrad.wilk@oracle.com, dhildenb@redhat.com,
 aarcange@redhat.com, alexander.duyck@gmail.com, john.starks@microsoft.com,
 mhocko@suse.com
References: <20190710195158.19640-1-nitesh@redhat.com>
 <20190710195158.19640-2-nitesh@redhat.com>
 <f9bca947-f88e-51a7-fdaf-4403fda1b783@intel.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <46336efb-3243-0083-1d20-7e8578131679@redhat.com>
Date: Mon, 15 Jul 2019 11:33:01 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <f9bca947-f88e-51a7-fdaf-4403fda1b783@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Mon, 15 Jul 2019 09:33:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.07.19 20:21, Dave Hansen wrote:
> On 7/10/19 12:51 PM, Nitesh Narayan Lal wrote:
>> +static void bm_set_pfn(struct page *page)
>> +{
>> +	struct zone *zone = page_zone(page);
>> +	int zone_idx = page_zonenum(page);
>> +	unsigned long bitnr = 0;
>> +
>> +	lockdep_assert_held(&zone->lock);
>> +	bitnr = pfn_to_bit(page, zone_idx);
>> +	/*
>> +	 * TODO: fix possible underflows.
>> +	 */
>> +	if (free_area[zone_idx].bitmap &&
>> +	    bitnr < free_area[zone_idx].nbits &&
>> +	    !test_and_set_bit(bitnr, free_area[zone_idx].bitmap))
>> +		atomic_inc(&free_area[zone_idx].free_pages);
>> +}
> 
> Let's say I have two NUMA nodes, each with ZONE_NORMAL and ZONE_MOVABLE
> and each zone with 1GB of memory:
> 
> Node:         0        1
> NORMAL   0->1GB   2->3GB
> MOVABLE  1->2GB   3->4GB
> 
> This code will allocate two bitmaps.  The ZONE_NORMAL bitmap will
> represent data from 0->3GB and the ZONE_MOVABLE bitmap will represent
> data from 1->4GB.  That's the result of this code:
> 
>> +			if (free_area[zone_idx].base_pfn) {
>> +				free_area[zone_idx].base_pfn =
>> +					min(free_area[zone_idx].base_pfn,
>> +					    zone->zone_start_pfn);
>> +				free_area[zone_idx].end_pfn =
>> +					max(free_area[zone_idx].end_pfn,
>> +					    zone->zone_start_pfn +
>> +					    zone->spanned_pages);
> 
> But that means that both bitmaps will have space for PFNs in the other
> zone type, which is completely bogus.  This is fundamental because the
> data structures are incorrectly built per zone *type* instead of per zone.
> 

I don't think it's incorrect, it's just not optimal in all scenarios.
E.g., in you example, this approach would "waste" 2 * 1GB of tracking
data for the wholes (2* 64bytes when using 1 bit for 2MB).

FWIW, this is not a numa-specific thingy. We can have sparse zones
easily on single-numa systems.

Node:                 0
NORMAL   0->1GB, 2->3GB
MOVABLE  1->2GB, 3->4GB

So tracking it per zones instead instead of zone type is only one part
of the story.

-- 

Thanks,

David / dhildenb

