Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1494C32751
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 03:08:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B115A20693
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 03:08:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B115A20693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 501038E0003; Wed, 31 Jul 2019 23:08:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D68D8E0001; Wed, 31 Jul 2019 23:08:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39F658E0003; Wed, 31 Jul 2019 23:08:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E0FD18E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 23:08:28 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n3so43775041edr.8
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 20:08:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ioGyMIf5J87yJPJciga4Wr241nzUrgiMYNiKAP7Dbd4=;
        b=AQFeKxD37fS7QXVttoS796k13KAtjc+edpy3XU5/awEqi0n8E47qu51N1qlDDekPgt
         PIM1GDM4AgTLOXFepYfClGrjGzjGy/yVWbpE2RvlwiOVBQiMToql8yIzy4H8JBwdd4rK
         zgu8hhT/YHJ6CffTylzEeoAyssTyALlXGK3E4oFWP273kmWVAtZqxZkEyL8qEcpyAW5p
         CUJcnsEAlHSc/d9HT3+AlM56LlNnrXHfhCF8Rkj0JP0etiAq1J6zYq+XsQfGdSHDz/df
         mFdo1FuCqyI7DsyXJDh4jBt864X8L4KG71Rth41d/tQFkw22XaK5SNMszOEvspyCFODF
         rmIQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVyG6MmfZOHHjNiNeZgcWhYbt8R0ML5QF2PKeczrQK6f3OvnE3n
	TNGoXweNewprYa39xwwITLAhklSCCvSsSJ9slaX2AKRJ3oPuQL3hegp3V2lZosfaHAuXMnR5kmR
	PcyCkKmrnaAbgwYmewfotyy5pM3db8PTviH4vqbJOCJF5nSW/yH4McLJWz+WCeaIC2g==
X-Received: by 2002:a17:906:304d:: with SMTP id d13mr94531937ejd.99.1564628908478;
        Wed, 31 Jul 2019 20:08:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxupGCKSRqFUIwRhIWn+gU6eQ44mwa3KHZOcDPe2uOeJ0CLfOmRTfqSAJ4EBbF4b1xOg3wj
X-Received: by 2002:a17:906:304d:: with SMTP id d13mr94531902ejd.99.1564628907791;
        Wed, 31 Jul 2019 20:08:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564628907; cv=none;
        d=google.com; s=arc-20160816;
        b=nZmT9Iv+0hB3+I6ZdUHP1xRf3TAy6IjK++wAj+9fpDByzhkrDiVoU2tmbqXWwir4ZN
         gLYuNjHpJE6B16CKQovMSmytAJgAMn3UUZ9G3bPqdUCoMxRUGhiRAf/0U296VkvcbEbk
         YEhmyIQdfdZfMRsjKlGxBCaL/YHSYKpFQHyu9miFbZLS6axYd1pqfNs2M46k5XUnJJRq
         CF2UsKxtJC4kTdKgjXd1QDI+FepFtADf9pIP9d0Gi7wkgyzFAi4mFZr4QwixbVtMXjcy
         hF+QhPdwlTsF3CtlbWLSasM9TDIm1jt/fCMbnLPqPXldjVwcldfbLOLPHmDWmuRu+I5C
         hTag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ioGyMIf5J87yJPJciga4Wr241nzUrgiMYNiKAP7Dbd4=;
        b=macSCtIPf/zO6xemAc7jHjs9o/NxPuLICK23h/lf6eZ13kWCdbXWkmL2cd/LRh2KAW
         fApWUJ4oJ7pP0ezGcdOcS5oSQ/rIjkEOrLUELkjG9QRFav6E14HeDZdFTDPDi1aiSJVG
         lZuBx07ryxyG2EGCeO9ZZ4FfuYcvy3w1/DYqolAxWrJ9wXyxfVAjKLv1WwW0jVFunb+c
         jsbQsR+yKNi1Y7OMqlTmq0ZyWDwHIxCiVVuvYlAY7DEDoiq7+L9bWA+YBdbhjIduTg8A
         rCeZEFfF5bBvW2F5bT8tWH/7xD83yqqlqP4mRP4md/4/g4Gs4cac1/BMm/guGHw4N6DS
         dc7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id rl21si19514340ejb.20.2019.07.31.20.08.27
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 20:08:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E54F5344;
	Wed, 31 Jul 2019 20:08:26 -0700 (PDT)
Received: from [10.163.1.81] (unknown [10.163.1.81])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E31B33F575;
	Wed, 31 Jul 2019 20:08:20 -0700 (PDT)
Subject: Re: [RFC 1/2] mm/sparsemem: Add vmem_altmap support in
 vmemmap_populate_basepages()
To: Will Deacon <will@kernel.org>
Cc: linux-mm@kvack.org, Fenghua Yu <fenghua.yu@intel.com>,
 Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, x86@kernel.org, linux-kernel@vger.kernel.org,
 Andy Lutomirski <luto@kernel.org>, Andrew Morton
 <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org
References: <1561697083-7329-1-git-send-email-anshuman.khandual@arm.com>
 <1561697083-7329-2-git-send-email-anshuman.khandual@arm.com>
 <20190731161047.ypye54x5c5jje5sq@willie-the-truck>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <a753a841-c344-c708-fccd-39d838637bcb@arm.com>
Date: Thu, 1 Aug 2019 08:39:01 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190731161047.ypye54x5c5jje5sq@willie-the-truck>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 07/31/2019 09:40 PM, Will Deacon wrote:
> On Fri, Jun 28, 2019 at 10:14:42AM +0530, Anshuman Khandual wrote:
>> Generic vmemmap_populate_basepages() is used across platforms for vmemmap
>> as standard or as fallback when huge pages mapping fails. On arm64 it is
>> used for configs with ARM64_SWAPPER_USES_SECTION_MAPS applicable both for
>> ARM64_16K_PAGES and ARM64_64K_PAGES which cannot use huge pages because of
>> alignment requirements.
>>
>> This prevents those configs from allocating from device memory for vmemap
>> mapping as vmemmap_populate_basepages() does not support vmem_altmap. This
>> enables that required support. Each architecture should evaluate and decide
>> on enabling device based base page allocation when appropriate. Hence this
>> keeps it disabled for all architectures to preserve the existing semantics.
> 
> This commit message doesn't really make sense to me. There's a huge amount
> of arm64-specific detail, followed by vague references to "this" and
> "those" and "that" and I lost track of what you're trying to solve.

Hmm, will clean up.

> 
> However, I puzzled through the code and I think it does make sense, so:
> 
> Acked-by: Will Deacon <will@kernel.org>
> 
> assuming you rewrite the commit message.

Thanks, will do.

> 
> However, this has a dependency on your hot remove series which has open
> comments from Mark Rutland afaict.

Yeah it has dependency on the hot-remove series. The only outstanding issue
there being whether to call free_empty_tables() in vmemmap tear down path
or not. Mark had asked for more details regarding the implications in cases
where free_empty_tables() is called or is not called. I did evaluate those
details recently and we should be able to take a decision sooner.

