Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3F10C43219
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 10:35:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EB0F206C3
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 10:35:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EB0F206C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6AE96B0003; Fri,  3 May 2019 06:35:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1E066B0005; Fri,  3 May 2019 06:35:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D58CF6B0007; Fri,  3 May 2019 06:35:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D7FE6B0003
	for <linux-mm@kvack.org>; Fri,  3 May 2019 06:35:10 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r48so3332421eda.11
        for <linux-mm@kvack.org>; Fri, 03 May 2019 03:35:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=dRRya0l1zg6XF0HbdfXH1fvsDHOoXb8ntfeqNEI9Gxg=;
        b=bJIDoFBeSm0im6cKV1QwND/VrYrQZblP4G7n20kPlP1G4GSlzhZQN0U8+QfcnjZaMe
         HmkRDNV6V/6h32Xcrki5vv1Q7mbGmAVorwuSc1h2UcddwZ4UvtcLMGD0P6kkndqciTGd
         OJ+7B+1ydanZp2uOI0XxJuYZu4fSvof+1QpE5k3LCtSmI1NBH1kGk3RUz7GfdVU4x8k3
         0s2TJBvW9/TxeDq4rso5yP3yzwQEfZSlkqwFk7wfNzxlgmD/8/NbItt7bDR+2OSSzPud
         OCQwswgVyzCrZy/cxZHWCQ6O4TcAu1ghzEcD8DTf/wTdKJd4NDndrI1C5MSBH1zi8Fpg
         UPTw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAWA64Qfs+4SNlRyjR2omIB4t++RuUmGjcEUiGP6s3/tokiWnaVC
	YkK8HjZ99JPwk1YMpzkATGUKGwf084pksp6GUDihKTvTqxnZjUrYMNvcMHbMqU5Rx6g/6NE2muv
	p1zak1ghzfZK8egqArWTx5X8CbNDgxYp33GcJw7bGnnOfupF+YDKGUGk4jYFGbgaXGw==
X-Received: by 2002:a50:9016:: with SMTP id b22mr7072665eda.99.1556879710136;
        Fri, 03 May 2019 03:35:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1fIhJwDeveV/8w1R9jBagjPT6m2tI1Pvl03SarnWlhJ30kZ3jVMZRa1OPYb0HjtRCvGnT
X-Received: by 2002:a50:9016:: with SMTP id b22mr7072576eda.99.1556879709041;
        Fri, 03 May 2019 03:35:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556879709; cv=none;
        d=google.com; s=arc-20160816;
        b=mN1Pey+Bf2yP66n0GodAKMr8SKIdNIR4xrMEYuRG07RBiG6ZQIg+/mf6Awdf7Ig3gp
         3OkGFsZaFZHRY1KEouvkaUrw7LsIh9mFhFsfSu7jJtkSvqoINtCG+XjYFoC/J0WxWJ1c
         0bzgnOZwXPsOCmeEKrkX0NJ9d1EHRci9nyepj3Xb9o+5mkjFu0e5xu5Kbb9o7RmTT4Rg
         9asUbH9ahfXRF3cgIQmX/ARhkVoZG+9yV5OjQCZSNLSvqYMtmWSRko81SwSJnO4lJEQa
         C3ZgEGKlV7F6Zfi+WkE2mSH2Aa4FtaYk8PNyYODITuKnD8vZZTz73tCX0A3EKvg1xpcH
         rtTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=dRRya0l1zg6XF0HbdfXH1fvsDHOoXb8ntfeqNEI9Gxg=;
        b=V0SGAeSkcizYA/GIU2zutRbsTD6OlgHWfMr5rR9bEodMzI9zx9PfZRRQ0qUN1E1CF5
         FS0gMkamP2ojb5s5qhodbU4sznsRcxjtFZaOv56cdH/ZoKAGNnMFcjEwpMyl/Y4dQzWj
         rjvlmQnXcDvqlmYaiK7cdBErdkAFXAqmEg3qx/BHB42NFr6KDcdCtu0MAyROh6PEni/n
         06JZplykqtp+3cNvm9PLe+7JY5wkv0ozCQduJUvdIpKyXqV2/1eJyuG3uvfi/hcBhLzM
         N+GpOvjMDGryzOuSaoYQUWGP6UvClrS9pdZlC3pU4tmDm+/GsGzappoYkA71q7NMPQfh
         v1RA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b33si806030edb.233.2019.05.03.03.35.08
        for <linux-mm@kvack.org>;
        Fri, 03 May 2019 03:35:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 934EF374;
	Fri,  3 May 2019 03:35:07 -0700 (PDT)
Received: from [10.1.196.75] (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B0F653F557;
	Fri,  3 May 2019 03:35:05 -0700 (PDT)
Subject: Re: [PATCH v6 02/12] mm/sparsemem: Introduce common definitions for
 the size and mask of a section
To: Dan Williams <dan.j.williams@intel.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko
 <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Logan Gunthorpe <logang@deltatee.com>, linux-mm <linux-mm@kvack.org>,
 linux-nvdimm <linux-nvdimm@lists.01.org>, LKML
 <linux-kernel@vger.kernel.org>, David Hildenbrand <david@redhat.com>
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552634586.2015392.2662168839054356692.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CA+CK2bCkqLc82G2MW+rYrKTi4KafC+tLCASkaT8zRfVJCCe8HQ@mail.gmail.com>
 <CAPcyv4g+KNu=upejy7Xm=jWR0cdhygPAdSRbkfFGpJeHFGc4+w@mail.gmail.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <bd76cb2f-7cdc-f11b-11ec-285862db66f3@arm.com>
Date: Fri, 3 May 2019 11:35:04 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4g+KNu=upejy7Xm=jWR0cdhygPAdSRbkfFGpJeHFGc4+w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/05/2019 01:41, Dan Williams wrote:
> On Thu, May 2, 2019 at 7:53 AM Pavel Tatashin <pasha.tatashin@soleen.com> wrote:
>>
>> On Wed, Apr 17, 2019 at 2:52 PM Dan Williams <dan.j.williams@intel.com> wrote:
>>>
>>> Up-level the local section size and mask from kernel/memremap.c to
>>> global definitions.  These will be used by the new sub-section hotplug
>>> support.
>>>
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Cc: Vlastimil Babka <vbabka@suse.cz>
>>> Cc: Jérôme Glisse <jglisse@redhat.com>
>>> Cc: Logan Gunthorpe <logang@deltatee.com>
>>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>>
>> Should be dropped from this series as it has been replaced by a very
>> similar patch in the mainline:
>>
>> 7c697d7fb5cb14ef60e2b687333ba3efb74f73da
>>   mm/memremap: Rename and consolidate SECTION_SIZE
> 
> I saw that patch fly by and acked it, but I have not seen it picked up
> anywhere. I grabbed latest -linus and -next, but don't see that
> commit.
> 
> $ git show 7c697d7fb5cb14ef60e2b687333ba3efb74f73da
> fatal: bad object 7c697d7fb5cb14ef60e2b687333ba3efb74f73da

Yeah, I don't recognise that ID either, nor have I had any notifications 
that Andrew's picked up anything of mine yet :/

Robin.

