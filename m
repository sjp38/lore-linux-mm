Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF3AEC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 09:49:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CCE62075C
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 09:49:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CCE62075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB1A16B0003; Wed, 27 Mar 2019 05:49:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5EF16B0006; Wed, 27 Mar 2019 05:49:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4DA46B0007; Wed, 27 Mar 2019 05:49:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 781766B0003
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 05:49:21 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k8so3304484edl.22
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 02:49:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=KRQOYa8+1E/3fz3sNF3uRKhF9otmQPsHxlcaig41dTs=;
        b=QvG2Dn8lFQKEz3WTR5nyEFwSk/Z0Rs7S9LAgVhccYR5LCiY/87N80/LVBGU4vRdY9C
         46yOb386LokMCH7LOOfcuAlWVeQX2nQ88Z/3bgiw1REV/c5H+jLD6eEPLWIBPrlzBZDG
         UeHGPZjLAlPYrRrLHEMCR5cs+eGpFyrz0VyxtzlNCPdyGuz1U+ce+nxC73XD38/G3MJC
         uqpl28VeM4siJruiWpAeWftFvcPQltDgudq/8dxSwNsvaVrpDZzjIN/H0F0uK0CL1wAp
         ClzxytYoxY2gyn+uXcbOl16JPZfsm4groUop3HmEKo71MR/oTdZK1QVjpcqwMvyUke1O
         pamA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUqddiyKKBb+tTiuk4Ohgux4lbYOMAMKCVfKhbxhvRncYAAw0Pj
	dHJjfqzaJJqH+isZf2oi6C4JiYhihwP+2WCPi8KuBvmutFTi3RhjiIN7w9TyCszkOtMuDanxf9s
	JA/yvFhvvdCR+iKC9ilzE1BUuW4wvRzC17RpuSb4sErxggzVT42YitXZU6MB4hgk=
X-Received: by 2002:a50:ad72:: with SMTP id z47mr23559987edc.270.1553680161017;
        Wed, 27 Mar 2019 02:49:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZAKDfY0O36UvVg8C8TO1TqBh7GtrmylLXKqibvpRpg3NA3SZdUIJUGLSuAgCnOSHiqh78
X-Received: by 2002:a50:ad72:: with SMTP id z47mr23559939edc.270.1553680160013;
        Wed, 27 Mar 2019 02:49:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553680160; cv=none;
        d=google.com; s=arc-20160816;
        b=THW/kUUPMRONUi8oT9nMwsiNRqpWhmo8bCJQ7dyTDvTXBVmFRQaPtAjSThjmb0CGCs
         kWWX81A2bPAXKpjpucUhANJfRyxAFfuXLBogbe6mxvRTeHzydDmv1whYm+tIeXWyrUAw
         0sUXTI6GzuPqkIqDWSXr5rBoDOnzUXcPVBudNMbQq1TQ0ogEAeml7hPyeLwuO83rL+WD
         mN7AqrXyxAx19J+wub7I3Wxnl16lFMLiyt93QXVnwtpj89Jbh6r/K1lniQaodDyU0TkE
         vcjgf1cMx9tl8n5fCiHcI5xEZyGuwgncoMkfn5aqoOAbPxMH/llDvRTaA0/W7f4yHdln
         YhRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=KRQOYa8+1E/3fz3sNF3uRKhF9otmQPsHxlcaig41dTs=;
        b=Ls33dONBpMfmDxYmL3HIKe0cnbUTinVatazepopCLhrad70KftPqYlm/J/5a+XOP5Q
         Fw+5Rz8zyiFJQt+ZR8M1ts22RZBqS64Pgshl8Oy8TM9jkXuDNfnETD/FdROiRURQSMYX
         8IyUf7/NIrV11PXubS1JLxOjJXeLvDESZAfxpDf+mf1B5HGv+tWLo1NQMrG8oF5yq/dS
         Sxk/X99CUvpOOoq71oiP+X3a3eCHsJVa0LvJKqvZJ1JwU4HpNT/YNiuVqjUOQnHYVNL2
         M1yPNybdvs0VzRKj02pkOYRJ85RY3Sr4H5A4ftrSg7+HQqzrD0pHyTBXMWg4ap4xRN+t
         vybA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay12.mail.gandi.net (relay12.mail.gandi.net. [217.70.178.232])
        by mx.google.com with ESMTPS id x9si369746ejs.189.2019.03.27.02.49.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Mar 2019 02:49:19 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.232;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay12.mail.gandi.net (Postfix) with ESMTPSA id 2175620000E;
	Wed, 27 Mar 2019 09:49:13 +0000 (UTC)
Subject: Re: [PATCH v8 4/4] hugetlb: allow to free gigantic pages regardless
 of the configuration
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, mpe@ellerman.id.au,
 Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 "David S . Miller" <davem@davemloft.net>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org
References: <20190327063626.18421-1-alex@ghiti.fr>
 <20190327063626.18421-5-alex@ghiti.fr>
 <f6e74ad8-acca-3b1e-27eb-a2881ac8437d@linux.ibm.com>
 <fbae7220-2e6f-8516-cf93-fbe430452043@ghiti.fr>
 <aabfc780-1681-c69a-9927-4645d6499984@linux.ibm.com>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <e7637427-5f17-b4f4-93a2-70cac9b3a264@ghiti.fr>
Date: Wed, 27 Mar 2019 10:48:54 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.5.2
MIME-Version: 1.0
In-Reply-To: <aabfc780-1681-c69a-9927-4645d6499984@linux.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: fr
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/27/2019 09:55 AM, Aneesh Kumar K.V wrote:
> On 3/27/19 2:14 PM, Alexandre Ghiti wrote:
>>
>>
>> On 03/27/2019 08:01 AM, Aneesh Kumar K.V wrote:
>>> On 3/27/19 12:06 PM, Alexandre Ghiti wrote:
>>>> On systems without CONTIG_ALLOC activated but that support gigantic 
>>>> pages,
>>>> boottime reserved gigantic pages can not be freed at all. This patch
>>>> simply enables the possibility to hand back those pages to memory
>>>> allocator.
>>>>
>>>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
>>>> Acked-by: David S. Miller <davem@davemloft.net> [sparc]
>>>>
>>>> diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h 
>>>> b/arch/powerpc/include/asm/book3s/64/hugetlb.h
>>>> index ec2a55a553c7..7013284f0f1b 100644
>>>> --- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
>>>> +++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
>>>> @@ -36,8 +36,8 @@ static inline int hstate_get_psize(struct hstate 
>>>> *hstate)
>>>>       }
>>>>   }
>>>>   -#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
>>>> -static inline bool gigantic_page_supported(void)
>>>> +#define __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED
>>>> +static inline bool gigantic_page_runtime_supported(void)
>>>>   {
>>>>       /*
>>>>        * We used gigantic page reservation with hypervisor assist 
>>>> in some case.
>>>> @@ -49,7 +49,6 @@ static inline bool gigantic_page_supported(void)
>>>>         return true;
>>>>   }
>>>> -#endif
>>>>     /* hugepd entry valid bit */
>>>>   #define HUGEPD_VAL_BITS        (0x8000000000000000UL)
>>>
>>> Is that correct when CONTIG_ALLOC is not enabled? I guess we want
>>>
>>> gigantic_page_runtime_supported to return false when CONTIG_ALLOC is 
>>> not enabled on all architectures and on POWER when it is enabled we 
>>> want it to be conditional as it is now.
>>>
>>> -aneesh
>>>
>>
>> CONFIG_ARCH_HAS_GIGANTIC_PAGE is set by default when an architecture 
>> supports gigantic
>> pages: on its own, it allows to allocate boottime gigantic pages AND 
>> to free them at runtime
>> (this is the goal of this series), but not to allocate runtime 
>> gigantic pages.
>> If CONTIG_ALLOC is set, it allows in addition to allocate runtime 
>> gigantic pages.
>>
>> I re-introduced the runtime checks because we can't know at compile 
>> time if powerpc can
>> or not support gigantic pages.
>>
>> So for all architectures, gigantic_page_runtime_supported only 
>> depends on
>> CONFIG_ARCH_HAS_GIGANTIC_PAGE enabled or not. The possibility to 
>> allocate runtime
>> gigantic pages is dealt with after those runtime checks.
>>
>
> you removed that #ifdef in the patch above. ie we had
> #ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
> static inline bool gigantic_page_supported(void)
> {
>     /*
>      * We used gigantic page reservation with hypervisor assist in 
> some case.
>      * We cannot use runtime allocation of gigantic pages in those 
> platforms
>      * This is hash translation mode LPARs.
>      */
>     if (firmware_has_feature(FW_FEATURE_LPAR) && !radix_enabled())
>         return false;
>
>     return true;
> }
> #endif

Yes, I removed the #ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE because it was 
defined only
if CONTIG_ALLOC was set. But now, CONFIG_ARCH_HAS_GIGANTIC_PAGE is 
inconditionally
set for powerpc so I think we don't need it anymore.
Actually I have doubts now, is this true for all configurations ? I see 
that it is only set for
PPC_RADIX_MMU. I think the problem is here: instead of returning true, 
it should do like
the generic version, ie return IS_ENABLED(CONFIG_ARCH_HAS_GIGANTIC_PAGE).
Do you agree ?

>
>
> This is now
> #define __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED
> static inline bool gigantic_page_runtime_supported(void)
> {
> if (firmware_has_feature(FW_FEATURE_LPAR) && !radix_enabled())
>         return false;
>
>     return true;
> }
>
>
> I am wondering whether it should be
>
> #define __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED
> static inline bool gigantic_page_runtime_supported(void)
> {
>
>    if (!IS_ENABLED(CONFIG_CONTIG_ALLOC))
>         return false;

I don't think this test should happen here, CONFIG_CONTIG_ALLOC only allows
to allocate gigantic pages, doing that check here would prevent powerpc
to free boottime gigantic pages when not a guest. Note that this check
is actually done in set_max_huge_pages.


>
> if (firmware_has_feature(FW_FEATURE_LPAR) && !radix_enabled())
>         return false;

Maybe I did not understand this check: I understood that, in the case 
the system
is virtualized, we do not want it to hand back gigantic pages. Does this 
check
test if the system is currently being virtualized ?
If yes, I think the patch is correct: it prevents freeing gigantic pages 
when the system
is virtualized but allows a 'normal' system to free gigantic pages.


>
>     return true;
> }
>
> or add that #ifdef back.
>
>> By the way, I forgot to ask you why you think that if an arch cannot 
>> allocate runtime gigantic
>> pages, it should not be able to free boottime gigantic pages ?
>>
>
> on virtualized platforms like powervm which use a paravirtualized page 
> table update mechanism (we dont' have two level table). The ability to 
> map a page huge depends on how hypervisor allocated the guest ram. 
> Hypervisor also allocates the guest specific page table of a specific 
> size depending on how many pages are going to be mapped by what page 
> size.
>
> on POWER we indicate possible guest real address that can be mapped 
> via hugepage (in this case 16G) using a device tree node 
> (ibm,expected#pages) . It is expected that we will map these pages 
> only as 16G pages. Hence we cannot free them back to the buddy where 
> it could get mapped via 64K page size.

Thanks for the explanations.

Alex
>
> -aneesh
>
>

