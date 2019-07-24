Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1231C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 13:48:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A240A22ADB
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 13:48:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A240A22ADB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34CB96B0003; Wed, 24 Jul 2019 09:48:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FD028E0003; Wed, 24 Jul 2019 09:48:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C67E8E0002; Wed, 24 Jul 2019 09:48:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C5E4A6B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 09:48:19 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o13so30252216edt.4
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 06:48:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=UoiB9jSnHt/Asq0GvczBoHnDRnKVxHUzqwDXUw8XErc=;
        b=fPrtA4meLLdftSpv5KfbvlNBC6DP8X4DYyJOwGoAkhvYPzk6KBK+1xLleCp6/Z9ULm
         KUvMbPhoiMIyhC6UJOgO61iKJSSlzlcPS4YS5OspIk3CxrtHxs0AWxkLTk1g2/DgDEw/
         BUPrtR45QlVSsiKccPz9lvbuh1114nybce9HVPqPuXAC3Vu/3W4V2YhMAcjL2RuPDNQS
         lrYaavkW/gRrw70UmXQsFoDpmOdL/lcDUGbTom1tFTEjbyfWB/EJDdqQIcUvYIIAtcw5
         xLY5kwykmPkI2Fk6rDrjtc/rSEk5Q/X3cAKTto3n/K9WBxSft8IrzY+TxTdoCPZVExGr
         naXg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUEvrwiMZ1Bc33i8gtzR4QXYBVQ2hbdWDqolOl/Rydbq2bQs5qF
	PPbwZ2y8Ssrx43dKAqU/2vnM1mmxbVDRm4YQAYYKALNOC4/cMs3vbsbiOJP3+tfZWGHz2D8aBw6
	6zZRqlBdlbykWX3Da/kWDbKYdshH20foD5CS9q0h9iZeY/qbk5xgBIYveHATtJfPG/Q==
X-Received: by 2002:aa7:cf90:: with SMTP id z16mr69567618edx.228.1563976099377;
        Wed, 24 Jul 2019 06:48:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvvGjEhUlMpOzJrbfjgiWBbZaD0Fppa+bWqou2qJmVR+QTBWKjNK+EGLl0xATxH5WAAbZr
X-Received: by 2002:aa7:cf90:: with SMTP id z16mr69567559edx.228.1563976098509;
        Wed, 24 Jul 2019 06:48:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563976098; cv=none;
        d=google.com; s=arc-20160816;
        b=ZUSPWNkKvx7LY2QsbsjSdmYy+ZCqfzIISfkCluXzyY41aefcNvnqjOxhysP/1/BH1U
         D5iQW2AKjmZlxLGB0IhokqjuPbVrDAWwTpfs2ehpzhHUIbCVbeyfZYPwqtC//Xq8q1K3
         d1/vUcZW8p2hXihIRxuK9DfquBFf8G9fkljn9o4XCqtUYYvmGvvE+zsdCks0Z3iKXAT4
         2h21xgI0fEph7QQzme1tVDjwpIzLaTtMJAFFODczSLaqKvaZor16Xqjat1Wn7to25EIP
         WWe+Immy0Hzx91PuUV9yELsP0tSenA1oxg03SkLhHPaSMcI3teNQOsLOkox+nE/BIntx
         baJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=UoiB9jSnHt/Asq0GvczBoHnDRnKVxHUzqwDXUw8XErc=;
        b=Kwzc68DQELI7F6ew5BMRVqk6V0bl+luYNro+AnrRkow/XJqiu/+pT9Np11KbVMR/Fl
         u8b0CjE/9vIR7TekusS4vS1AUVXKbxFbtWelKpND70KVfSKy6emuZVo2bXyfCcRg7gfA
         2GArolqUxp9TYI0qAsvBROhQnOCjidgWrNTg6v7bT2eVxHbQwf8SiTjI3mX4//invhjc
         HeHvv/dGfYH7YW6VReYbMxSa6Mf1KwR8uE5E2cSC/rJbT66ajf1PHttC0awXqcPlStHn
         nsjR5e/ODks7M23YxzXlp7P2lGq7tFkwr179TY57WdZXKpsYCFZRw1VWStnO760I02U1
         Xisw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id o15si7828295ejj.248.2019.07.24.06.48.18
        for <linux-mm@kvack.org>;
        Wed, 24 Jul 2019 06:48:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6868828;
	Wed, 24 Jul 2019 06:48:17 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A85F23F71A;
	Wed, 24 Jul 2019 06:48:14 -0700 (PDT)
Subject: Re: [PATCH v9 10/21] mm: Add generic p?d_leaf() macros
To: Mark Rutland <mark.rutland@arm.com>
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
From: Steven Price <steven.price@arm.com>
Message-ID: <4366c0d8-6175-88d0-8cf2-938dff56f1ac@arm.com>
Date: Wed, 24 Jul 2019 14:48:13 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190723094113.GA8085@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 23/07/2019 10:41, Mark Rutland wrote:
> On Mon, Jul 22, 2019 at 04:41:59PM +0100, Steven Price wrote:
>> Exposing the pud/pgd levels of the page tables to walk_page_range() means
>> we may come across the exotic large mappings that come with large areas
>> of contiguous memory (such as the kernel's linear map).
>>
>> For architectures that don't provide all p?d_leaf() macros, provide
>> generic do nothing default that are suitable where there cannot be leaf
>> pages that that level.
>>
>> Signed-off-by: Steven Price <steven.price@arm.com>
> 
> Not a big deal, but it would probably make sense for this to be patch 1
> in the series, given it defines the semantic of p?d_leaf(), and they're
> not used until we provide all the architectural implemetnations anyway.

Sure, I'll move it. When it was named p?d_large() this had to come after
some architectures that implement p?d_large() as static inline. But
p?d_leaf() doesn't have that issue.

> It might also be worth pointing out the reasons for this naming, e.g.
> p?d_large() aren't currently generic, and this name minimizes potential
> confusion between p?d_{large,huge}().

Ok, how about:

The name p?d_leaf() is chosen because to minimize the confusion with
existing uses of "large" pages and "huge" pages which do not necessary
mean that the entry is a leaf (for example it may be a set of contiguous
entries that only take 1 TLB slot). For the purpose of walking the page
tables we don't need to know how it will be represented in the TLB, but
we do need to know for sure if it is a leaf of the tree.

>> ---
>>  include/asm-generic/pgtable.h | 19 +++++++++++++++++++
>>  1 file changed, 19 insertions(+)
>>
>> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
>> index 75d9d68a6de7..46275896ca66 100644
>> --- a/include/asm-generic/pgtable.h
>> +++ b/include/asm-generic/pgtable.h
>> @@ -1188,4 +1188,23 @@ static inline bool arch_has_pfn_modify_check(void)
>>  #define mm_pmd_folded(mm)	__is_defined(__PAGETABLE_PMD_FOLDED)
>>  #endif
>>  
>> +/*
>> + * p?d_leaf() - true if this entry is a final mapping to a physical address.
>> + * This differs from p?d_huge() by the fact that they are always available (if
>> + * the architecture supports large pages at the appropriate level) even
>> + * if CONFIG_HUGETLB_PAGE is not defined.
>> + */
> 
> I assume it's only safe to call these on valid entries? I think it would
> be worth calling that out explicitly.

Yes only meaningful on valid entries - I'll add that as a comment.

> Otherwise, this looks sound to me:
> 
> Acked-by: Mark Rutland <mark.rutland@arm.com>

Thanks for the review

Steve

