Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE8F7C32754
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:08:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFD06206A3
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:08:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFD06206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FFA98E0006; Thu,  1 Aug 2019 02:08:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BBF78E0001; Thu,  1 Aug 2019 02:08:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49EBA8E0006; Thu,  1 Aug 2019 02:08:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EFA648E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 02:08:55 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id w25so43981835edu.11
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 23:08:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=MU1o63eXjvVOfyHWLw4w2H3Yz2yztz/ZbyQX++989rU=;
        b=FZcyzbXbfFvZKv0WJzMS/AP5PSxqQaCDUrxcYZa+iMKB+jeVt0bkTDu9QDeThP/Jl0
         o7RQozjqZfPTbKgxeSP0ICofKEJ8fNP2tcATE4KGKK0kl90NoS+9guRsd+alZzNSbRb+
         5H9JyhqCP560GQOURzdWtiK8x0U9p5ZoLXp8Rsxm8gMEx72W4eNDwS1LIIonpUYMWn+f
         M/A+NtCKoeuj5OAZeUKmGRHFNobZybVahT71ICh0BA/cJ61pCnHLaXUi+NPE5GUA91Ll
         kDRarZeXxmnrKaau9eXSS3q4A9xJf1icapShhnIgVRiN1pMhIg5X//0BOla/2vLJCt6N
         GgpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWlbXQ1LcwVhRR+8F4yNosmsRwZUMCumsWsLCFQUipm6q/aKfzl
	Kj5sujrSvITag8cI3eBL2Kt0B6SUtPo3RpmxRuGNoXX0FRqqaquAXSKrpb8T1OvuA+5pd61QFKP
	Z9474WW3pUysNF1ULb936TrRBkfG0QM8e3mqKgTE3xbj+ix9lcATKb7KI7NvwkrY8jw==
X-Received: by 2002:a17:906:2314:: with SMTP id l20mr5171998eja.144.1564639735529;
        Wed, 31 Jul 2019 23:08:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysyLF/uKeyHFQCuk7EkLMXhSxMHgrmykSo02lNa7NLfQOTfNfudQSpbtkDvyQjRjcaz+PN
X-Received: by 2002:a17:906:2314:: with SMTP id l20mr5171964eja.144.1564639734669;
        Wed, 31 Jul 2019 23:08:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564639734; cv=none;
        d=google.com; s=arc-20160816;
        b=URO3zv8D25udYKvExeZ/8vvxjjBhjEFrKTpa+K+r2Uf2FlK+LBCI5jUWWlJSvPG7kh
         JX9K5MEetqZ4liHpfWLNkViIbRTk20URrpQm/6BihXM34X4uyfEifUIMrTezgiz0hS44
         rKsQt8LN+u6fJ+OWcQsA9RHWAqVaEYE/xJdRDGCfenLTsWg6VdUspyI9nOdVjSevwY9o
         XDNMntidFhV80sDeHPwmgj5HB+ujeCVKCK/Mv4OHqA0sB+5D/csIZ2x/swiF9+LDZx5V
         E+zuTpLIUl3r60s1O2BeApRtTtg6bQFCSMv04+J/lmLpRPlr8Sf3UaxU/yUeuWUNY3of
         DvsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=MU1o63eXjvVOfyHWLw4w2H3Yz2yztz/ZbyQX++989rU=;
        b=xl5NMCd7UfKACkDwl019644GoA3QFDvxbPrExIr8ZZ55GFzWmEvn63za7ZGcTuhyC8
         J9sugW/JzGSfwImcam0zReaioyVQMmc3J47oq+yxvgERicMPM+X3W8dGR154VZ4jhjPm
         wVKzw/C8E0rx+o9JeBejpj0xE7gOS2HJKOi3+HGli6qaQzKJpMb/xNfMc4nscaFY8rtL
         mitcH4Xjso+xmQYvndQhgy3bFKfM1+unAZXeEin8gdABsDvrPjenhrdkXGzqw8d/XAU6
         SogqcBgYfHDdYJKTPGGf/N7SFFE5Qxpgi1DUmBkTQ02MhFOdUNw9jFBkK6Krz8JuUU3K
         2h3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id no6si20228435ejb.173.2019.07.31.23.08.54
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 23:08:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8F57B337;
	Wed, 31 Jul 2019 23:08:53 -0700 (PDT)
Received: from [10.163.1.81] (unknown [10.163.1.81])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CF2273F694;
	Wed, 31 Jul 2019 23:10:46 -0700 (PDT)
Subject: Re: [PATCH v9 10/21] mm: Add generic p?d_leaf() macros
To: Steven Price <steven.price@arm.com>, Mark Rutland <mark.rutland@arm.com>
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
 <674bd809-f853-adb0-b1ab-aa4404093083@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <0979d4b4-7a97-2dc3-67cf-3aa6569bfdcd@arm.com>
Date: Thu, 1 Aug 2019 11:39:18 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <674bd809-f853-adb0-b1ab-aa4404093083@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 07/29/2019 05:08 PM, Steven Price wrote:
> On 28/07/2019 12:44, Anshuman Khandual wrote:
>>
>>
>> On 07/23/2019 03:11 PM, Mark Rutland wrote:
>>> On Mon, Jul 22, 2019 at 04:41:59PM +0100, Steven Price wrote:
>>>> Exposing the pud/pgd levels of the page tables to walk_page_range() means
>>>> we may come across the exotic large mappings that come with large areas
>>>> of contiguous memory (such as the kernel's linear map).
>>>>
>>>> For architectures that don't provide all p?d_leaf() macros, provide
>>>> generic do nothing default that are suitable where there cannot be leaf
>>>> pages that that level.
>>>>
>>>> Signed-off-by: Steven Price <steven.price@arm.com>
>>>
>>> Not a big deal, but it would probably make sense for this to be patch 1
>>> in the series, given it defines the semantic of p?d_leaf(), and they're
>>> not used until we provide all the architectural implemetnations anyway.
>>
>> Agreed.
>>
>>>
>>> It might also be worth pointing out the reasons for this naming, e.g.
>>> p?d_large() aren't currently generic, and this name minimizes potential
>>> confusion between p?d_{large,huge}().
>>
>> Agreed. But these fallback also need to first check non-availability of large
>> pages. I am not sure whether CONFIG_HUGETLB_PAGE config being clear indicates
>> that conclusively or not. Being a page table leaf entry has a broader meaning
>> than a large page but that is really not the case today. All leaf entries here
>> are large page entries from MMU perspective. This dependency can definitely be
>> removed when there are other types of leaf entries but for now IMHO it feels
>> bit problematic not to directly associate leaf entries with large pages in
>> config restriction while doing exactly the same.
> 
> The intention here is that the page walkers are able to walk any type of
> page table entry which the kernel may use. CONFIG_HUGETLB_PAGE only
> controls whether "huge TLB pages" are used by user space processes. It's
> quite possible that option to not be selected but the linear mapping to
> have been mapped using "large pages" (i.e. leaf entries further up the
> tree than normal).

I understand that kernel page table might use large pages where as user space
never enabled HugeTLB. The point to make here was CONFIG_HUGETLB approximately
indicates the presence of large pages though the absence of same does not
conclusively indicate that large pages are really absent on the MMU. Perhaps it
will requires something new like MMU_[LARGE|HUGE]_PAGES.

> 
> One of the goals was to avoid tying the new functions to a configuration
> option but instead match the hardware architecture. Of course this isn't
> possible in the most general case (e.g. an architecture may have
> multiple hardware page table formats). But to the extent that other
> functions like p?d_none() work the desire is that p?d_leaf() should also
> work.

It is fair enough to assume that a platform can decide wisely and provide
accurate definition for p?d_leaf() functions. Anyways its okay not to make
this more complex by tying with a new config option which does not exist.

