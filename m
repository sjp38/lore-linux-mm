Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 583C8C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:49:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F9D5206DF
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:49:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F9D5206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC1B56B000A; Wed,  3 Apr 2019 04:49:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B48906B000C; Wed,  3 Apr 2019 04:49:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9ED216B000D; Wed,  3 Apr 2019 04:49:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 499B96B000A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 04:49:17 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id s27so7114064eda.16
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 01:49:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Z0tDoZbzg33buiDMajLxjCBA8GzwquOkrqu3d4/ds3k=;
        b=grEg/pmmiW6QVt547mOOxYgedU2wY1sC4WZaghVgGJHSThHIzw0tkYp1zr+Xq4Gj1I
         Z57m+nQj3DJuhB37pAzIxAQzFmU5Fr+3mfB/mn9w45DXE2APa2Za4/t1I8cyogDDa6El
         2EvSQXyKosku9Kagen0QeDjFgCErzQFpAELhz+GhFhv4EsI6RpMh1Vr503EAM48JLHxP
         eiJU47Huu8B/n+BrPxtkT03/a7ynGh2CdAguPSBv55rjzy9g/lGxVFz5ayPmGsqfmObW
         phzDAP241xKf2z5hNfRFQz59DrrZd6a7H6dqO6VJhD7uoXgos0PBOCcoUI80YtwGesOz
         7ssg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVqGSi33qfDBEM5oKYWui5gnpdnf4Nj6CrWEIQdokcejmkUUNYy
	wBcQDEQap2GRImqCvz0npXrlx1psyd9kOTLrtriY7xHLdVC2iflY9MmR7dJnYgi/H1bSHlsFvab
	48o1/ENCBfWdO2rXvG8RQHTHM2RoGv4gl2Hc/Ke2WuPyVq7HDD70KDfrqOhdlSqI=
X-Received: by 2002:a50:90ee:: with SMTP id d43mr51841724eda.220.1554281356875;
        Wed, 03 Apr 2019 01:49:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYL78Nckg2S3a7sjtIy8ys6snJXr3S1e84vzFAP075C6Bn3rsuVRHewyUUb4qxjy5OKxI+
X-Received: by 2002:a50:90ee:: with SMTP id d43mr51841695eda.220.1554281356253;
        Wed, 03 Apr 2019 01:49:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554281356; cv=none;
        d=google.com; s=arc-20160816;
        b=U2IRseGMpitkdSSXs4mYqY89RRmxXX+wemh1TzSPIclHcaBBUfDAgk2E9adWyQNo+O
         4CtRUhxnIdmalTrSZ22XjmKDCyeS1btG4DJhRxq4w6R4WMSGQEGbEFHd8Sjn0t5Sk3f9
         bGUYzvFMQZZsngTzobis3aD33RWszKfzKazVwYT+g4LbAjsf8s418cgz4/MBiz1FVk0+
         swxwjThliE3KwVh/WIwBxYBGlMQxwG4+1n3ZybAS2UXc3BBK8FP1MWI0H4XmCxSQR3sX
         J+uxlBUXDKXQYRlzpjG0lLbvwJ2Ze9ColiYGoDr1gJu+Aj6h32iKVfHCwpoFvsPApmaN
         jK/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Z0tDoZbzg33buiDMajLxjCBA8GzwquOkrqu3d4/ds3k=;
        b=ZoeG4bEW1K55HsBeKU6TcmVwZwJQElD8Y1fmrmhH88scfoJm6q2XM4OejlJZnackJH
         68Z+qJr8z3U9qDmXf/5KJaIOOn6bKpBzZCLymGiNCDNgCyTsuSH4UXgQcbFwd3RnNPq0
         GsGMjmaXBvkcPm0OqN7n0TNFcRJR4puRoXWI/068Vm9pfuchX31tBuBJ9LiwGyxm89S9
         t+8CpcrEQO5SILE8+TQzR+nO0zNSCBFAFZWF7/nYevOI1hiEWyxqpoQqqkE23D69i+Qg
         KRkqIeU3deNsnwtts2Gbw7xkBKxcx3ThcqxRxEbT93EfE5BjIq9/1c4KTsoBtgEl9cpo
         NyJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f21si625451edy.208.2019.04.03.01.49.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 01:49:16 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BBDCCADA3;
	Wed,  3 Apr 2019 08:49:15 +0000 (UTC)
Date: Wed, 3 Apr 2019 10:49:15 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org,
	dan.j.williams@intel.com, Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
Message-ID: <20190403084915.GF15605@dhcp22.suse.cz>
References: <20190329134243.GA30026@dhcp22.suse.cz>
 <20190401075936.bjt2qsrhw77rib77@d104.suse.de>
 <20190401115306.GF28293@dhcp22.suse.cz>
 <20190402082812.fefamf7qlzulb7t2@d104.suse.de>
 <20190402124845.GD28293@dhcp22.suse.cz>
 <20190403080113.adj2m3szhhnvzu56@d104.suse.de>
 <20190403081232.GB15605@dhcp22.suse.cz>
 <d55aa259-56c0-9601-ffce-997ea1fb3ac5@redhat.com>
 <20190403083757.GC15605@dhcp22.suse.cz>
 <04a5b856-c8e0-937b-72bb-b9d17a12ccc7@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <04a5b856-c8e0-937b-72bb-b9d17a12ccc7@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 03-04-19 10:41:35, David Hildenbrand wrote:
> On 03.04.19 10:37, Michal Hocko wrote:
[...]
> > That being said it should be the caller of the hotplug code to tell
> > the vmemmap allocation strategy. For starter, I would only pack vmemmaps
> > for "regular" kernel zone memory. Movable zones should be more careful.
> > We can always re-evaluate later when there is a strong demand for huge
> > pages on movable zones but this is not the case now because those pages
> > are not really movable in practice.
> 
> Remains the issue with potential different user trying to remove memory
> it didn't add in some other granularity. We then really have to identify
> and isolate that case.

Can you give an example of a sensible usecase that would require this?
-- 
Michal Hocko
SUSE Labs

