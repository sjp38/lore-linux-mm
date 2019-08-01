Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A61EC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 12:22:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06953216C8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 12:22:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06953216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CE6C8E000F; Thu,  1 Aug 2019 08:22:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77E4E8E0001; Thu,  1 Aug 2019 08:22:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 647098E000F; Thu,  1 Aug 2019 08:22:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 141138E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 08:22:37 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b33so44691275edc.17
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 05:22:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=iGfm1JRRz4ktUYDpRIRJfqYB33uBautWbTc4aUfvW3o=;
        b=ndSmHY0pMIL0MZxYruPa7LoV3Xo6Adbbrl5b9+s8+uJSizKQ4GSb5ujBut0mHlhGrL
         t/K7l4d0tUPQ9alre/3nSRcHBmArWFnQUyNLPF15wtd5JwTfJPHpJiYsgPhFaAhDEXgr
         HsoP/NwAXPqYMruNP2c37gXcG46Ln2Ij8mOVPalMXCtSxFdQELJbFLbYIIbrYqV/NAbx
         lqcZsrXsMect5HGGCgQmKF4xe1JHQQfSxmI4WiGNft4vHRbskhjtVZhObVyAqFM1k7+t
         i2NrmKy8N1bPa49HmkzBD4hXiXD87aCn6bxqbhDza0UjdsNwpxFI46U/JvHEO6li+rKM
         In5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVyoKz8gsT0Ij5Q6IWkBpEx1t8kcNHSNNqV1bBz44A+gR3+3/LB
	tVUmgEA5aNxq2wabNpMX53l89GUPJZgjHirCyNERcbsaBfZl1PKh6ff7gW1SwZfUU329JrC4j44
	R+V4E3mjoYGheEzsMpgCb1IB9MeEjQR+7VwD+MA4cccHlM6jUBYX1NkYM0ZK7H7CI3g==
X-Received: by 2002:aa7:d404:: with SMTP id z4mr112776056edq.131.1564662156590;
        Thu, 01 Aug 2019 05:22:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXJan2Q1+g3a5UORRbgWV9jBfEePwDWz6Lb9sCPoVah/8ElL7gfFiq9cRhZOU5MOQrvYid
X-Received: by 2002:aa7:d404:: with SMTP id z4mr112775989edq.131.1564662155600;
        Thu, 01 Aug 2019 05:22:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564662155; cv=none;
        d=google.com; s=arc-20160816;
        b=bQmKK7XlO8eQjiNeQeD5FHFcVqOgafVYMtHAt3jmx2335vEwqQMb0U3JQpeJeYBNmp
         cOAcxB+uylimJZFZunNE2SS7kHvMPsCgcnShUYcBaRdj42r721yBl1/BSnyD8XaL5OD/
         E0P0qw3gMsXRs176oZrDtHMaFU4TLZbPfOqe8aBG5bUqnKYvYMY4z5SKRUzAvcvdYvwK
         sk+7CWk/WdfYviiK49b9iZ3sUt01xz9jjmrBTiDZ70SOkRT8M3oNJHtXlKqVRqm30fL0
         P5XDHynZYYMRrOqBC4kGkxBoZ3izHcpM3eD1qwbalAe8PQ3Pp1YmYu2CZcWNNS85pDXm
         gStw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=iGfm1JRRz4ktUYDpRIRJfqYB33uBautWbTc4aUfvW3o=;
        b=VUCcVvc1C8N2XelzMk0ic99X+inTqVCz77jvbeIcGc8Z08M2EkzcUOHYil0vNnVZo0
         hZ6yO7UX9YEp9EO2Za7WVRjcqEHwiNHMoGrY5UWLX8VcYX9yvGpXuzTviErJtqXBnSlX
         jZerhblT4N7/6p3GrCsmKOlgvOY8cBnjbD8unqpGBYtphhqd/DNJrx796oNyv8v8UMOt
         K3aAP4EBFv3w1P9bplW29fMzbMy+1PCNTtQtHj7WE5TMVUovT8U20s9nS/A7fsQ/EvN9
         MBmgdo5DP016uc3uQXAYtuFPtL9cACW7R+054VzThEAddsOWbAXxbTqktnLUWBsm7a88
         rrjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id gq12si21873265ejb.170.2019.08.01.05.22.35
        for <linux-mm@kvack.org>;
        Thu, 01 Aug 2019 05:22:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 879161570;
	Thu,  1 Aug 2019 05:22:34 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id EF0683F575;
	Thu,  1 Aug 2019 05:22:31 -0700 (PDT)
Subject: Re: [PATCH v9 10/21] mm: Add generic p?d_leaf() macros
To: Anshuman Khandual <anshuman.khandual@arm.com>,
 Mark Rutland <mark.rutland@arm.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
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
 <0979d4b4-7a97-2dc3-67cf-3aa6569bfdcd@arm.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <ae073f1f-7c39-7e6d-0e6b-54978f0d3fdf@arm.com>
Date: Thu, 1 Aug 2019 13:22:30 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <0979d4b4-7a97-2dc3-67cf-3aa6569bfdcd@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01/08/2019 07:09, Anshuman Khandual wrote:
> 
> 
> On 07/29/2019 05:08 PM, Steven Price wrote:
>> On 28/07/2019 12:44, Anshuman Khandual wrote:
>>>
>>>
>>> On 07/23/2019 03:11 PM, Mark Rutland wrote:
>>>> On Mon, Jul 22, 2019 at 04:41:59PM +0100, Steven Price wrote:
>>>>> Exposing the pud/pgd levels of the page tables to walk_page_range() means
>>>>> we may come across the exotic large mappings that come with large areas
>>>>> of contiguous memory (such as the kernel's linear map).
>>>>>
>>>>> For architectures that don't provide all p?d_leaf() macros, provide
>>>>> generic do nothing default that are suitable where there cannot be leaf
>>>>> pages that that level.
>>>>>
>>>>> Signed-off-by: Steven Price <steven.price@arm.com>
>>>>
>>>> Not a big deal, but it would probably make sense for this to be patch 1
>>>> in the series, given it defines the semantic of p?d_leaf(), and they're
>>>> not used until we provide all the architectural implemetnations anyway.
>>>
>>> Agreed.
>>>
>>>>
>>>> It might also be worth pointing out the reasons for this naming, e.g.
>>>> p?d_large() aren't currently generic, and this name minimizes potential
>>>> confusion between p?d_{large,huge}().
>>>
>>> Agreed. But these fallback also need to first check non-availability of large
>>> pages. I am not sure whether CONFIG_HUGETLB_PAGE config being clear indicates
>>> that conclusively or not. Being a page table leaf entry has a broader meaning
>>> than a large page but that is really not the case today. All leaf entries here
>>> are large page entries from MMU perspective. This dependency can definitely be
>>> removed when there are other types of leaf entries but for now IMHO it feels
>>> bit problematic not to directly associate leaf entries with large pages in
>>> config restriction while doing exactly the same.
>>
>> The intention here is that the page walkers are able to walk any type of
>> page table entry which the kernel may use. CONFIG_HUGETLB_PAGE only
>> controls whether "huge TLB pages" are used by user space processes. It's
>> quite possible that option to not be selected but the linear mapping to
>> have been mapped using "large pages" (i.e. leaf entries further up the
>> tree than normal).
> 
> I understand that kernel page table might use large pages where as user space
> never enabled HugeTLB. The point to make here was CONFIG_HUGETLB approximately
> indicates the presence of large pages though the absence of same does not
> conclusively indicate that large pages are really absent on the MMU. Perhaps it
> will requires something new like MMU_[LARGE|HUGE]_PAGES.

CONFIG_HUGETLB doesn't necessarily mean leaf entries can appear anywhere
other than PTE. Some architectures always have a full tree of page
tables, but can program their TLBs with larger entries - I think all the
architectures I've come across have software page table walking, but in
theory the arm64 contiguous hint bit could be considered similar.

Steve

