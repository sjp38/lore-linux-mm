Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9813BC04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 07:14:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63AFE20862
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 07:14:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63AFE20862
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F33816B0005; Wed, 15 May 2019 03:14:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE3216B0006; Wed, 15 May 2019 03:14:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD14A6B0007; Wed, 15 May 2019 03:14:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4786B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 03:14:13 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f41so2483671ede.1
        for <linux-mm@kvack.org>; Wed, 15 May 2019 00:14:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=o5rH6YVmKO4jCp+PFEKStkeanvorAeNQRq8+hiToFrI=;
        b=XcbmIu2a0TLUso4R28RMe/wsnmB6DrHhSWvyT7ioOyBtt901WTZzT+cBj3YWzF1l7L
         df3KOF2Kv2xfoZ1ZYo/DaCVvNfCyOodXHLBIhpUMTfzI6ahRUOeRMDXeWUGzbOH0DGCg
         OHo6BLQw0htYuM62ytg4MEvT4n3paJsS5fmxS/9UPIj6abvQpmbf2MhymFyJ13T17G/i
         CThC/sncZQZ6jhOW0saS1FpElWRNdXeB8tynIVEmnkVW1urc8Om6MRkatcFBbYml2W7K
         vhC4+I5sann0NkmI8eSFqxp68YrKRPpHixZY2EuyOn0hOowLNLgnZrUvgtwOdWszoKH+
         dyvw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWf3M5fU03qou+t4DX/BSpPygsg1DzYt0f4fXiWxtaBjvzfOGHF
	wyNN+hDDuMcdYV1DkFkd+AKhNxg7KsRNYuWKe7GH284Cl4ek7os3miNhWj2+ihEezir3M/XjvC8
	tCNEAu6S0fC5NhdVUqB6FKRie0vBN3FD1UltiPJ14e+R1F8jw2BGUy6k3Ga7Mqymnaw==
X-Received: by 2002:a50:a5b4:: with SMTP id a49mr42314675edc.30.1557904453168;
        Wed, 15 May 2019 00:14:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3WrFomZp8P3D6JUjXv/PpHUvxT+DIYsm7+YqBR0FxfpzexCrBfsFBkPn3p+6Lb/nKpjrm
X-Received: by 2002:a50:a5b4:: with SMTP id a49mr42314622edc.30.1557904452396;
        Wed, 15 May 2019 00:14:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557904452; cv=none;
        d=google.com; s=arc-20160816;
        b=geDvDYB6IT+KsGBtRWwqPipUO/jG/lh7+kMo91U0mjbsbvDuOQqlDJ4lfQ85bMVkdc
         qL0W5htV39q4fIgKgg5xmXDQYswdMbSQrobzDV5KzkMtm8ZkzmEn4ssJZDt5Lcck5bac
         JCkyEhcnqM1j9TDIkoLx5XO3JgkKSRAfOGygBgH3+2Lqe9IryNaR5sXs5GpBp5VE2FOe
         Tpop0T7tWzck4CsJoBFeHwmob9F0GS4GYusJZKHHKiyyHa5FaLLOF/dg156LdSfAvIwc
         MHUUM5W6xwLQ6JBa0POxUpJ6QpJJDGD6lg3yGvcwSZEYjqkM7w7grrLbKXbgflRhvD7q
         sJIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=o5rH6YVmKO4jCp+PFEKStkeanvorAeNQRq8+hiToFrI=;
        b=YwEXifenSVQnawy7lVYhswlxYOx+5VvkE/FUEVEHmoPbX4lBMS74yBW0BI7IV433bc
         wEJlBApi4z5KgjAfiXzWM99vskpNaavuZCg/TDcO/AI2vILF+Tzj9rwTfpnO/lg6Z1C1
         X2foaOng/I2kGQcNPcUplo5AB3ha/55HA2nvSjrrpfDYsS+sLJgd+HUEng0Tr0hEqOGn
         n3I79DjJkkrbwSH2h1wmRfoETp1Dqw5cJcFyW4qSatCfolsTKfayhf5lyBVS3Cv6B4Nc
         a6LMhTOo9Z/31eKDdgzG7I2rz5k4Qfhg6zdPkMIYZZ1nNbLIDYbfOsvlstoU/H3o6VZd
         MIKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ce20si882065ejb.39.2019.05.15.00.14.12
        for <linux-mm@kvack.org>;
        Wed, 15 May 2019 00:14:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 161C9374;
	Wed, 15 May 2019 00:14:11 -0700 (PDT)
Received: from [10.163.1.137] (unknown [10.163.1.137])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C13ED3F71E;
	Wed, 15 May 2019 00:14:07 -0700 (PDT)
Subject: Re: [PATCH RESEND] mm: show number of vmalloc pages in /proc/meminfo
To: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com,
 Johannes Weiner <hannes@cmpxchg.org>
References: <20190514235111.2817276-1-guro@fb.com>
 <20190514235111.2817276-2-guro@fb.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <f0e640c9-2eff-ffc5-8558-4bc1b374eb2a@arm.com>
Date: Wed, 15 May 2019 12:44:16 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190514235111.2817276-2-guro@fb.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/15/2019 05:21 AM, Roman Gushchin wrote:
> Vmalloc() is getting more and more used these days (kernel stacks,
> bpf and percpu allocator are new top users), and the total %
> of memory consumed by vmalloc() can be pretty significant
> and changes dynamically.
> 
> /proc/meminfo is the best place to display this information:
> its top goal is to show top consumers of the memory.
> 
> Since the VmallocUsed field in /proc/meminfo is not in use
> for quite a long time (it has been defined to 0 by the
> commit a5ad88ce8c7f ("mm: get rid of 'vmalloc_info' from
> /proc/meminfo")), let's reuse it for showing the actual
> physical memory consumption of vmalloc().
The primary concern which got addressed with a5ad88ce8c7f was that computing
get_vmalloc_info() was taking long time. But here its reads an already updated
value which gets added or subtracted during __vmalloc_area_node/__vunmap cycle.
Hence this should not cost much (like get_vmalloc_info). But is not this similar
to the caching solution Linus mentioned.

