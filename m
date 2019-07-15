Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB31FC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 14:40:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E76720868
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 14:40:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E76720868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E8276B0008; Mon, 15 Jul 2019 10:40:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 197666B000A; Mon, 15 Jul 2019 10:40:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 060BF6B000D; Mon, 15 Jul 2019 10:40:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D9D736B0008
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 10:40:47 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id t124so13881646qkh.3
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 07:40:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:references:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=mjNFx4G9e5J0YvzQ9Mfbnaf1FCgoi29f7F4/F/9nXUw=;
        b=qA1gPJgkliOq3YkTzm+Q7cljb9uEuLPAzI+Y9T7Tn7R9QO/QzcRZ/dWyWlKqfTqx9T
         nnn3MnHYFjopj+Ep1rjVi0oACpdk3XtVOLfY4ldLLs/3hlqebsD6uCp7FhmF+W/WzLv2
         Ox/dLL++e4FeMsE8YWulzAmfwK8SCIGlo9VpKQXJFpLQfxZ3En4+9PF5p3qQ06G6oIFb
         PUzQgIPsYkXKdbAbc2VlNrmd7PsVcA2Rs6wHu71dqSAOSPx9FWxLymJYn6PaZgynycP3
         DunuAWoC01MntjUm6Xdo1e7fNdU5Ol00HGwvHCsQHx8r4DrO3DONvWWY+wK1kXkl9Cn8
         MUqg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWdZ+utwvPmC59lHKny+TQuYCFkoH06eHBWEHB+vp4xXz2Ixel0
	HDmEbDaXSmu3Ltinpzc1cKu3WFr2KrySI4a+9/4TKNNmgrLW8JoLyFmQXXFtGM4DyfJQqOivS5E
	J6X823MlP64qvTiFrcnjbkecZtsxLMJ9FL0pyLcfA4VRKmopomUdvV/MAhgA/5HTeYQ==
X-Received: by 2002:a37:a388:: with SMTP id m130mr17712570qke.250.1563201647629;
        Mon, 15 Jul 2019 07:40:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsH8yLWr65/ccvQHYrvVoi+uQ3kfTvLRMWRR9eKt1dZVqR1SOuxDGA9xolwoaDaYXHVRzG
X-Received: by 2002:a37:a388:: with SMTP id m130mr17712488qke.250.1563201646579;
        Mon, 15 Jul 2019 07:40:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563201646; cv=none;
        d=google.com; s=arc-20160816;
        b=sTSbEI7DzxiXMTII8ivNTu7UvYHAeXgTAtmQcvKa2RwELbzxgKUX9Nr+vZOQrh7//g
         syylIQ/He8XoiK5Ka2/03EVlwdiKW90P/E2UjB//u7oZRt1g+4HChDT+R1EyP1UtMDnl
         dmwpfc+PWXHqN8WprnLea+X1A8AIadsZAz64hxUUReJgEOOhfYA028yTLaaXa4yB/uGv
         HNC9DcLUeVc/igA/gqCyFX8hsD1hFXIx83KxHCnSB+91TcX9Hg427ChLszSRyDbNeJ3U
         P1Wl/Sm1AQmjiXLTYfj4TiHri7vGwis6hUZVvyn80IAGT4goCXKNkviG41usZUZbA8AC
         d46g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp
         :references:to:from:subject;
        bh=mjNFx4G9e5J0YvzQ9Mfbnaf1FCgoi29f7F4/F/9nXUw=;
        b=gM8B4RbJJPxL10N6pcG+Z1wiWUTaRhq9ZYeX6zYMa0A+X6ejd33itutBEFrRAu02xq
         ywdUEqxrPwT/EpYiO7GK3Dbt7XO3PG/QhUZTmkPwgK2O+po5wdHKfuNiuJk0STXgUfLt
         sUlRhssp+mxjTAmcl+UxaEVVbQvCBr7JIPry6vLOsRSTE5jx2klUTibNYBs3BjsJe6ih
         cAOkssUcjXCacaVpz9K6fhqf93F097IrktK0iyDtSejwZV4gKpFiujwbkclow4XtfFb4
         eifKzsAz+1hySDj+dcOe7GsuyPmukYjftpPu46dA2BXOiQ8jR+F0aPgR08nx9zLYQx25
         QAVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d207si10697142qkc.51.2019.07.15.07.40.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 07:40:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 92433309175E;
	Mon, 15 Jul 2019 14:40:45 +0000 (UTC)
Received: from [10.36.118.52] (unknown [10.36.118.52])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 781AD5D9C8;
	Mon, 15 Jul 2019 14:40:31 +0000 (UTC)
Subject: Re: [RFC][Patch v11 1/2] mm: page_hinting: core infrastructure
From: David Hildenbrand <david@redhat.com>
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
 <46336efb-3243-0083-1d20-7e8578131679@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <c978542a-6535-634f-b07a-0a158993bada@redhat.com>
Date: Mon, 15 Jul 2019 16:40:30 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <46336efb-3243-0083-1d20-7e8578131679@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Mon, 15 Jul 2019 14:40:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 15.07.19 11:33, David Hildenbrand wrote:
> On 11.07.19 20:21, Dave Hansen wrote:
>> On 7/10/19 12:51 PM, Nitesh Narayan Lal wrote:
>>> +static void bm_set_pfn(struct page *page)
>>> +{
>>> +	struct zone *zone = page_zone(page);
>>> +	int zone_idx = page_zonenum(page);
>>> +	unsigned long bitnr = 0;
>>> +
>>> +	lockdep_assert_held(&zone->lock);
>>> +	bitnr = pfn_to_bit(page, zone_idx);
>>> +	/*
>>> +	 * TODO: fix possible underflows.
>>> +	 */
>>> +	if (free_area[zone_idx].bitmap &&
>>> +	    bitnr < free_area[zone_idx].nbits &&
>>> +	    !test_and_set_bit(bitnr, free_area[zone_idx].bitmap))
>>> +		atomic_inc(&free_area[zone_idx].free_pages);
>>> +}
>>
>> Let's say I have two NUMA nodes, each with ZONE_NORMAL and ZONE_MOVABLE
>> and each zone with 1GB of memory:
>>
>> Node:         0        1
>> NORMAL   0->1GB   2->3GB
>> MOVABLE  1->2GB   3->4GB
>>
>> This code will allocate two bitmaps.  The ZONE_NORMAL bitmap will
>> represent data from 0->3GB and the ZONE_MOVABLE bitmap will represent
>> data from 1->4GB.  That's the result of this code:
>>
>>> +			if (free_area[zone_idx].base_pfn) {
>>> +				free_area[zone_idx].base_pfn =
>>> +					min(free_area[zone_idx].base_pfn,
>>> +					    zone->zone_start_pfn);
>>> +				free_area[zone_idx].end_pfn =
>>> +					max(free_area[zone_idx].end_pfn,
>>> +					    zone->zone_start_pfn +
>>> +					    zone->spanned_pages);
>>
>> But that means that both bitmaps will have space for PFNs in the other
>> zone type, which is completely bogus.  This is fundamental because the
>> data structures are incorrectly built per zone *type* instead of per zone.
>>
> 
> I don't think it's incorrect, it's just not optimal in all scenarios.
> E.g., in you example, this approach would "waste" 2 * 1GB of tracking
> data for the wholes (2* 64bytes when using 1 bit for 2MB).
> 
> FWIW, this is not a numa-specific thingy. We can have sparse zones
> easily on single-numa systems.
> 
> Node:                 0
> NORMAL   0->1GB, 2->3GB
> MOVABLE  1->2GB, 3->4GB
> 
> So tracking it per zones instead instead of zone type is only one part
> of the story.
> 

Oh, and FWIW,

in setups like

Node:                 0               1
NORMAL   4->5GB, 6->7GB  5->6GB, 8->9GB

What Nitesh proposes is actually better. So it really depends on the use
case - but in general sparsity is the issue.

-- 

Thanks,

David / dhildenb

