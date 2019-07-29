Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8685AC7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 11:38:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4732D20651
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 11:38:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4732D20651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C31908E0005; Mon, 29 Jul 2019 07:38:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBB3E8E0002; Mon, 29 Jul 2019 07:38:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A82488E0005; Mon, 29 Jul 2019 07:38:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 573DF8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 07:38:50 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m23so38063272edr.7
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 04:38:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=tdXnCls1/dKVBUI6AJDlG+b/2njgx4f0JtKfYJzU9tk=;
        b=ulHHPK0DR0EBMyy7DyNMlyRuxtjCQ6x2495E09RK0nW4jTdH6J4ftP+B+JA+RNTP1n
         wMMS99o7hJMQNCf7N0wVu1xmODkX8vIS0+IdI+cK3FHepIpLRzfVC7WQa8RV/wb1KREt
         UfjLi9TtXdvo98S0jJPDz4dXvW+0OH8AMgJTA4M9Xy2DfDkMIPmdd3nuCmqHTPuxSFQz
         +q10NRVGpVbVKynDTjw3AT0fyO14lz3mYSOpKXbZpY9xbkKo367dxRIDgM349d12rgNK
         l763XtSlZnh/VsH4RzvNx/+PNMirEISGdFY86f5jpMAe2oAsrcs1EBMPKBZQkS8qp+H+
         wOUg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXqzQkosJp8fnZZMkEszxW7M09qwp9zc0pVbcVQDLATWbuJuhcC
	aOSEY9nRth8EycqO23ITBW/av5U1vm8t4ntgTU1vaTnK3P4OOU3DvqqbuSlutWno1oR3qyYhpFE
	c/DVFHOX+4oJKgq2m3+SDpOXtFVQ+3awYkev9WvFFYbrCz0wsxFk4v3J6ljsprshIDQ==
X-Received: by 2002:a50:ec98:: with SMTP id e24mr95262609edr.264.1564400329917;
        Mon, 29 Jul 2019 04:38:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6tpOiTFVsaKJprz3Bk4aGlbd5qUJDdS11/kgHFydm1ghpttOIPhWdH0g4wlA8z+02n7it
X-Received: by 2002:a50:ec98:: with SMTP id e24mr95262558edr.264.1564400329123;
        Mon, 29 Jul 2019 04:38:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564400329; cv=none;
        d=google.com; s=arc-20160816;
        b=afCQ7ByTMdoRhTDtSxVuCsGdArE2+RWipH1HvKvs+HejiR3bZuRQ015OuQJJhhmYUs
         TZQiLOXU0QTGbIomgHbviTh1YzfY5HZJAroz6yLkRKQO2wvRFUwpaqMKDyaJxQqyrmCc
         nvaMWe8lYW3g82NnOHVno6nUaw4zkfTjA9m7OuC1XGQnReW1fa4tBrMoiPehGQaXlP49
         keeSFZPmAVBcSYZqW01c4XNaHpYv0sPKsrpvG1zMw6o2oVs3N5d8TF64GL6pBUDYTJ/s
         ble4d530PE4SbUM3HLqjHA6SJ3zLW4QyCEY6Uv73IF0it9WPAtno1/JDM2nf7h4iuEI/
         5izg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=tdXnCls1/dKVBUI6AJDlG+b/2njgx4f0JtKfYJzU9tk=;
        b=0PR87RjLB8XeCFMK74Sgz+veMozeVPiAULMJ8PbzEoJhBH/5IS+X9UaPFasHHnP+xl
         JsVPO864ooP5cC4JhrTp+LTEolmYZlZqMZvj7h9QARDj0zovuR+RnbqIZvBRz9zZawu0
         ZpBiYcmk4PO1vRUBZdBPznwMdRu84jw+GfaphHcEIhJ00JEXMISd8klpQt0hSVwA9DSn
         Zf2hZjU6tJ8jwBVEhWDH0cijeAHlso/oHeChstxJv9C+zexuXyUy7D40DUVYbQFTyY5I
         Mt0YJe22C04OarHlNjHsQKyF5pJOTEt4DKR653yxhPZfur+7wf1BXbixgiWjY0RrDLTc
         LetQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id f53si16797856edf.85.2019.07.29.04.38.48
        for <linux-mm@kvack.org>;
        Mon, 29 Jul 2019 04:38:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id ECCD228;
	Mon, 29 Jul 2019 04:38:47 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4E2E03F694;
	Mon, 29 Jul 2019 04:38:45 -0700 (PDT)
Subject: Re: [PATCH v9 10/21] mm: Add generic p?d_leaf() macros
To: Anshuman Khandual <anshuman.khandual@arm.com>,
 Mark Rutland <mark.rutland@arm.com>
Cc: x86@kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 Will Deacon <will@kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190722154210.42799-1-steven.price@arm.com>
 <20190722154210.42799-11-steven.price@arm.com>
 <20190723094113.GA8085@lakrids.cambridge.arm.com>
 <ce4e21f2-020f-6677-d79c-5432e3061d6e@arm.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <674bd809-f853-adb0-b1ab-aa4404093083@arm.com>
Date: Mon, 29 Jul 2019 12:38:44 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <ce4e21f2-020f-6677-d79c-5432e3061d6e@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28/07/2019 12:44, Anshuman Khandual wrote:
> 
> 
> On 07/23/2019 03:11 PM, Mark Rutland wrote:
>> On Mon, Jul 22, 2019 at 04:41:59PM +0100, Steven Price wrote:
>>> Exposing the pud/pgd levels of the page tables to walk_page_range() means
>>> we may come across the exotic large mappings that come with large areas
>>> of contiguous memory (such as the kernel's linear map).
>>>
>>> For architectures that don't provide all p?d_leaf() macros, provide
>>> generic do nothing default that are suitable where there cannot be leaf
>>> pages that that level.
>>>
>>> Signed-off-by: Steven Price <steven.price@arm.com>
>>
>> Not a big deal, but it would probably make sense for this to be patch 1
>> in the series, given it defines the semantic of p?d_leaf(), and they're
>> not used until we provide all the architectural implemetnations anyway.
> 
> Agreed.
> 
>>
>> It might also be worth pointing out the reasons for this naming, e.g.
>> p?d_large() aren't currently generic, and this name minimizes potential
>> confusion between p?d_{large,huge}().
> 
> Agreed. But these fallback also need to first check non-availability of large
> pages. I am not sure whether CONFIG_HUGETLB_PAGE config being clear indicates
> that conclusively or not. Being a page table leaf entry has a broader meaning
> than a large page but that is really not the case today. All leaf entries here
> are large page entries from MMU perspective. This dependency can definitely be
> removed when there are other types of leaf entries but for now IMHO it feels
> bit problematic not to directly associate leaf entries with large pages in
> config restriction while doing exactly the same.

The intention here is that the page walkers are able to walk any type of
page table entry which the kernel may use. CONFIG_HUGETLB_PAGE only
controls whether "huge TLB pages" are used by user space processes. It's
quite possible that option to not be selected but the linear mapping to
have been mapped using "large pages" (i.e. leaf entries further up the
tree than normal).

One of the goals was to avoid tying the new functions to a configuration
option but instead match the hardware architecture. Of course this isn't
possible in the most general case (e.g. an architecture may have
multiple hardware page table formats). But to the extent that other
functions like p?d_none() work the desire is that p?d_leaf() should also
work.

Steve

