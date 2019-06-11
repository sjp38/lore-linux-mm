Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7459AC4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 06:17:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19C3920820
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 06:17:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19C3920820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CA516B0008; Tue, 11 Jun 2019 02:17:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97AFA6B000A; Tue, 11 Jun 2019 02:17:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 869BF6B000C; Tue, 11 Jun 2019 02:17:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 382DA6B0008
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 02:17:24 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s7so19041985edb.19
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 23:17:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=VMA1V2SYl9MqMA7TCePeyFyZDA4n1fXXCBan9BmdIdM=;
        b=r/Fg1B+zDEDoxsKBkuke5YA2nKo4ArWXvfUyCRafK8mLBQIwu4dJA7JdKS4GTpYRT4
         taBuJadtRdKD5HYfZtbgLx1PAzHM7vgHo8esSv0Y5gIFhp1usAQEQizA/oc4R7Q1C5b6
         E5BNfngOVmO9tVA9b3LeBs3g+xWfITn64fXCH0TBhTprKtILGWlb3WJ4JCjF061sqvRJ
         G2J6T5CYFX5p/R4mymNItPlnfrjjohQBicWV1RXnd6ZFdhK7a7FsMiM853dwUyNMfxCv
         l+p0ZhypgzdA+96W/TKCE0zPuheUZNKeKB19f+/cQI5WTYS8CObypf2NzmlDGSZlbOus
         rgSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAW/5s4IM5sBR1D2u+4AtDK2KHsB5WW2aBxTd8kIL/IvLH1wbcLL
	2+JhtZeiOhR8X/+xaFe7VjnqLZb+Q2j0Ge4hUQhubmiJtq4h9QsIffBV/gNCP5Ulq9LeP55zZpM
	j0Q/TZjSmRf8hCvvIvpSFkSGyDNFpZKkY1RxvjJWBg1RYHZl9Pq2fzgRyoeEVemU8OQ==
X-Received: by 2002:a50:be42:: with SMTP id b2mr76871015edi.228.1560233843721;
        Mon, 10 Jun 2019 23:17:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYq2srj22hLKlHTQTH2CP1PjnwxqCH1c8lZGt4GgS7g63xq//RhQNdeHazgrXC+4vScxFh
X-Received: by 2002:a50:be42:: with SMTP id b2mr76870954edi.228.1560233843034;
        Mon, 10 Jun 2019 23:17:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560233843; cv=none;
        d=google.com; s=arc-20160816;
        b=Y8G42kYB0MlxYDEwNxd2xw6+bv1cvBdcTTrgF8zXZX61C6vTMbCAZYyFep6FqPzo2h
         oh4IHLV3vXmHtSoJfSrsVnJJfEg1hurSrtZpEu85djyW8YKgdVH+wqww1TjhPAaHnnTx
         BGjctVqc5vN9h6RgEaRcNZwEy8+Hx96DALWP+hpFihC8CHJZh+jRXtLPjaCmYsQQYxAe
         N++u57IADKTvSrUZUIO1ipnJ1nkIU5IrAWJ/byGI/8W8O1dMZtY/B+pYQOoWx+Sxy+DR
         S5eW94CFi/rcyWkv3DMS82l1JAH/Ufw5senNTcBC/jAZTxSl7Xs3KcqbyGzFQ4s9DX06
         uueg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=VMA1V2SYl9MqMA7TCePeyFyZDA4n1fXXCBan9BmdIdM=;
        b=Yejt8it8FbryPRA+5lO7YZyOkHZ6pdUfax5CmTXE+xtpJrYrGF36ywOWKCg7Yci5Bp
         dVpEkObbluhDcz1mNIkStGDN7iQMu5EcQHHnfZUeOa77/M453oZpS8qjONzCxh+s8WXK
         +CWl5TX58tw9DXZoNGCOciuEp/j75MVjYuN7rZczoEio3qMUrIxiez/6ePcX1++tGeLr
         4XQPxm3qbCMiJnd3oV5yqY6rhL2XIyFvrf1JSiDwC2eByE7N08qTVhdlcZ8fyY2267+Z
         J9FONzFabQOtVDGKikE92tiiqBZXkXdJq/uVwDHRfbiLkzcK9asKhnElV9SdY7DcmpeB
         ckag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id b10si2433448ejh.360.2019.06.10.23.17.22
        for <linux-mm@kvack.org>;
        Mon, 10 Jun 2019 23:17:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 04483344;
	Mon, 10 Jun 2019 23:17:22 -0700 (PDT)
Received: from [10.162.43.135] (p8cg001049571a15.blr.arm.com [10.162.43.135])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 847F13F73C;
	Mon, 10 Jun 2019 23:17:20 -0700 (PDT)
Subject: Re: [PATCH 4/4] mm/vmalloc: Hugepage vmalloc mappings
To: Nicholas Piggin <npiggin@gmail.com>, Mark Rutland <mark.rutland@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 linuxppc-dev@lists.ozlabs.org
References: <20190610043838.27916-1-npiggin@gmail.com>
 <20190610043838.27916-4-npiggin@gmail.com>
 <20190610141036.GA16989@lakrids.cambridge.arm.com>
 <1560177786.t6c5cn5hw4.astroid@bobo.none>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <a1747247-f4f6-ea9a-149c-07c7eb9193d8@arm.com>
Date: Tue, 11 Jun 2019 11:47:39 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <1560177786.t6c5cn5hw4.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/10/2019 08:14 PM, Nicholas Piggin wrote:
> Mark Rutland's on June 11, 2019 12:10 am:
>> Hi,
>>
>> On Mon, Jun 10, 2019 at 02:38:38PM +1000, Nicholas Piggin wrote:
>>> For platforms that define HAVE_ARCH_HUGE_VMAP, have vmap allow vmalloc to
>>> allocate huge pages and map them
>>>
>>> This brings dTLB misses for linux kernel tree `git diff` from 45,000 to
>>> 8,000 on a Kaby Lake KVM guest with 8MB dentry hash and mitigations=off
>>> (performance is in the noise, under 1% difference, page tables are likely
>>> to be well cached for this workload). Similar numbers are seen on POWER9.
>>
>> Do you happen to know which vmalloc mappings these get used for in the
>> above case? Where do we see vmalloc mappings that large?
> 
> Large module vmalloc could be subject to huge mappings.
> 
>> I'm worried as to how this would interact with the set_memory_*()
>> functions, as on arm64 those can only operate on page-granular mappings.
>> Those may need fixing up to handle huge mappings; certainly if the above
>> is all for modules.
> 
> Good point, that looks like it would break on arm64 at least. I'll
> work on it. We may have to make this opt in beyond HUGE_VMAP.

This is another reason we might need to have an arch opt-ins like the one
I mentioned before.

