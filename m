Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD5A6C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 07:01:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7986E2077B
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 07:01:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7986E2077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 131186B0003; Mon, 18 Mar 2019 03:01:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BC376B0006; Mon, 18 Mar 2019 03:01:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC4D06B0007; Mon, 18 Mar 2019 03:01:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 90C856B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 03:01:00 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x21so6133319edr.17
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 00:01:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=9bE65Gw/wkI4iYUVfMmi7sThJo4Meh1Gf1hnq1+L99U=;
        b=R/M83eJRpFFiSri0O+lLPV1+gP22PMNFHgfuyVVucF3xgMWHYqi2Av5y7tFQYv0sNk
         WQ9GffCndrwPYgwQ+//kLcdSJ0wA0Dvdhmn8UzWV0m9sPvQpzyoby1ikjLKbSpaJy6xY
         5yYZWqGMQOOh6QiKTs+EsSk8/ZOaKQxEU8cXUYvLpGr73ixslrcnvFNua91IR54K0YqX
         kpY4RfajvJNDL4uwhMUpeam4WtnMGUciXAfVEftcNpL2T/zAsWwhUqegedhY7z8INK7N
         9wgwjLTmZgax+9bIsKaj7HdoBmPtS6LrX/y8eTe8XD1zPwxnKMyk1DaXvQ1lEKS91fEo
         gZBg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAW+aOXgrZ3JxMnUksRPt/ocnHvIL49Wl0riNpkBeH4nSrtfBb9U
	JinNgEWrlpnMWP+2jcGgSrV5s6MqNcBpS79MbIjW8W3jTalVYpHbFvrmvdVpunD6x8lbU9xOjwM
	zV9x+C5VcqTfc3d3+TRGYKVdKJdKQODCxstmsHOnL+eOh5U1PWYOVLm2D6ND9QjI=
X-Received: by 2002:a17:906:60d7:: with SMTP id f23mr9964466ejk.177.1552892460086;
        Mon, 18 Mar 2019 00:01:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4YsP8KzLTwf43aNR63BRHSr/g/aXGukT+lboOArWPdtSNxoDR/P7Pd6gVvfpYBd37LBXO
X-Received: by 2002:a17:906:60d7:: with SMTP id f23mr9964399ejk.177.1552892458639;
        Mon, 18 Mar 2019 00:00:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552892458; cv=none;
        d=google.com; s=arc-20160816;
        b=Ib9RifbEX4jOk2lSR8qBunhFJ0o5FDbLe+Fq2vjyr1o1XFDYdf15S3nBBEc0Sy1N7b
         Nlf6j2x6b4OG/t8CbLbH4qTL5EP7JXzgOhH9ORnpN0pChnqhYYTpGWqQnXPA9ExUj651
         Jg1iVEyOi5CAi+O3SC4RrNWZyphDfVtBf3D0XciIk4V7QjsR6eu29KS1owSwS9hWVeXx
         18wtIxJNyoQ8K3luJMAQ37GUsMrdpASMr5Ws7W9ZaMiKzyzkXvh08k6TJ1YEVCbGCrG2
         gS/B4ke+ZT91S5Ux/RZ/ppViEXbhMTC1yACFTEySZKOC8N9KsVK2iEa4zUnyQ9Q9wlRq
         ZFeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=9bE65Gw/wkI4iYUVfMmi7sThJo4Meh1Gf1hnq1+L99U=;
        b=Xk1DfygjK/pyKxRlCvRopV5Z2zVHMjjvboIr+e3I2UagIb6yGmkg1k3CYu22APRK+u
         NOHUDtWR0OOyuFaqyuJ3Tz4fooJV330hS3jUP6bDtxwYdKoGTskjXXfAWIbz9htkBCiF
         gFWsDbgQYos8rzo72tqiuDk1/yvLJnm+Js0f/Wo2maeXtRlwlIBDUFQTSa0ds9zLUrh8
         zYGukkwb3Bp3EjlHGNAG01AFSoZCyDvjb4H+DwPOqo5vxS1vMYtkWpJwHXIDbx01bI+O
         EYZyTTObpKTBC/W8BQWlTwpNrEFmnvelgG03iAbcL54f7EZ8AqU5ym7X0g/rq3i1KaOa
         xltg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id b37si863545ede.406.2019.03.18.00.00.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Mar 2019 00:00:58 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.11] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 59B641C0007;
	Mon, 18 Mar 2019 07:00:48 +0000 (UTC)
Subject: Re: [PATCH v7 4/4] hugetlb: allow to free gigantic pages regardless
 of the configuration
To: christophe leroy <christophe.leroy@c-s.fr>, aneesh.kumar@linux.ibm.com,
 mpe@ellerman.id.au, Andrew Morton <akpm@linux-foundation.org>,
 Vlastimil Babka <vbabka@suse.cz>, Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
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
References: <20190317162847.14107-1-alex@ghiti.fr>
 <20190317162847.14107-5-alex@ghiti.fr>
 <f434892d-80b2-f09d-31d6-754a1be0b97a@c-s.fr>
From: Alex Ghiti <alex@ghiti.fr>
Message-ID: <525d6c00-012f-c6dd-abf0-fa5e1ffc12be@ghiti.fr>
Date: Mon, 18 Mar 2019 03:00:47 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <f434892d-80b2-f09d-31d6-754a1be0b97a@c-s.fr>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: sv-FI
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/17/19 2:31 PM, christophe leroy wrote:
>
>
> Le 17/03/2019 à 17:28, Alexandre Ghiti a écrit :
>> On systems without CONTIG_ALLOC activated but that support gigantic 
>> pages,
>> boottime reserved gigantic pages can not be freed at all. This patch
>> simply enables the possibility to hand back those pages to memory
>> allocator.
>>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
>> Acked-by: David S. Miller <davem@davemloft.net> [sparc]
>> ---
>>   arch/arm64/Kconfig                           |  2 +-
>>   arch/arm64/include/asm/hugetlb.h             |  4 --
>>   arch/powerpc/include/asm/book3s/64/hugetlb.h |  7 ---
>>   arch/powerpc/platforms/Kconfig.cputype       |  2 +-
>>   arch/s390/Kconfig                            |  2 +-
>>   arch/s390/include/asm/hugetlb.h              |  3 --
>>   arch/sh/Kconfig                              |  2 +-
>>   arch/sparc/Kconfig                           |  2 +-
>>   arch/x86/Kconfig                             |  2 +-
>>   arch/x86/include/asm/hugetlb.h               |  4 --
>>   include/asm-generic/hugetlb.h                | 14 +++++
>>   include/linux/gfp.h                          |  2 +-
>>   mm/hugetlb.c                                 | 54 ++++++++++++++------
>>   mm/page_alloc.c                              |  4 +-
>>   14 files changed, 61 insertions(+), 43 deletions(-)
>>
>
> [...]
>
>> diff --git a/include/asm-generic/hugetlb.h 
>> b/include/asm-generic/hugetlb.h
>> index 71d7b77eea50..aaf14974ee5f 100644
>> --- a/include/asm-generic/hugetlb.h
>> +++ b/include/asm-generic/hugetlb.h
>> @@ -126,4 +126,18 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
>>   }
>>   #endif
>>   +#ifndef __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED
>> +#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
>> +static inline bool gigantic_page_runtime_supported(void)
>> +{
>> +    return true;
>> +}
>> +#else
>> +static inline bool gigantic_page_runtime_supported(void)
>> +{
>> +    return false;
>> +}
>> +#endif /* CONFIG_ARCH_HAS_GIGANTIC_PAGE */
>
> What about the following instead:
>
> static inline bool gigantic_page_runtime_supported(void)
> {
>     return IS_ENABLED(CONFIG_ARCH_HAS_GIGANTIC_PAGE);
> }
>

Totally, it already was like that in v2 or v3...


>
>> +#endif /* __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED */
>> +
>>   #endif /* _ASM_GENERIC_HUGETLB_H */
>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>> index 1f1ad9aeebb9..58ea44bf75de 100644
>> --- a/include/linux/gfp.h
>> +++ b/include/linux/gfp.h
>> @@ -589,8 +589,8 @@ static inline bool pm_suspended_storage(void)
>>   /* The below functions must be run on a range from a single zone. */
>>   extern int alloc_contig_range(unsigned long start, unsigned long end,
>>                     unsigned migratetype, gfp_t gfp_mask);
>> -extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
>>   #endif
>> +extern void free_contig_range(unsigned long pfn, unsigned int 
>> nr_pages);
>
> 'extern' is unneeded and should be avoided (iaw checkpatch)
>

Ok, I did fix a checkpatch warning here, but did not notice the 'extern' 
one.


Thanks for your time,


Alex


> Christophe
>
>>     #ifdef CONFIG_CMA
>>   /* CMA stuff */
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index afef61656c1e..4e55aa38704f 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -1058,6 +1058,7 @@ static void free_gigantic_page(struct page 
>> *page, unsigned int order)
>>       free_contig_range(page_to_pfn(page), 1 << order);
>>   }
>>   +#ifdef CONFIG_CONTIG_ALLOC
>>   static int __alloc_gigantic_page(unsigned long start_pfn,
>>                   unsigned long nr_pages, gfp_t gfp_mask)
>>   {
>> @@ -1142,11 +1143,20 @@ static struct page 
>> *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
>>     static void prep_new_huge_page(struct hstate *h, struct page 
>> *page, int nid);
>>   static void prep_compound_gigantic_page(struct page *page, unsigned 
>> int order);
>> +#else /* !CONFIG_CONTIG_ALLOC */
>> +static struct page *alloc_gigantic_page(struct hstate *h, gfp_t 
>> gfp_mask,
>> +                    int nid, nodemask_t *nodemask)
>> +{
>> +    return NULL;
>> +}
>> +#endif /* CONFIG_CONTIG_ALLOC */
>>     #else /* !CONFIG_ARCH_HAS_GIGANTIC_PAGE */
>> -static inline bool gigantic_page_supported(void) { return false; }
>>   static struct page *alloc_gigantic_page(struct hstate *h, gfp_t 
>> gfp_mask,
>> -        int nid, nodemask_t *nodemask) { return NULL; }
>> +                    int nid, nodemask_t *nodemask)
>> +{
>> +    return NULL;
>> +}
>>   static inline void free_gigantic_page(struct page *page, unsigned 
>> int order) { }
>>   static inline void destroy_compound_gigantic_page(struct page *page,
>>                           unsigned int order) { }
>> @@ -1156,7 +1166,7 @@ static void update_and_free_page(struct hstate 
>> *h, struct page *page)
>>   {
>>       int i;
>>   -    if (hstate_is_gigantic(h) && !gigantic_page_supported())
>> +    if (hstate_is_gigantic(h) && !gigantic_page_runtime_supported())
>>           return;
>>         h->nr_huge_pages--;
>> @@ -2276,13 +2286,27 @@ static int adjust_pool_surplus(struct hstate 
>> *h, nodemask_t *nodes_allowed,
>>   }
>>     #define persistent_huge_pages(h) (h->nr_huge_pages - 
>> h->surplus_huge_pages)
>> -static unsigned long set_max_huge_pages(struct hstate *h, unsigned 
>> long count,
>> -                        nodemask_t *nodes_allowed)
>> +static int set_max_huge_pages(struct hstate *h, unsigned long count,
>> +                  nodemask_t *nodes_allowed)
>>   {
>>       unsigned long min_count, ret;
>>   -    if (hstate_is_gigantic(h) && !gigantic_page_supported())
>> -        return h->max_huge_pages;
>> +    spin_lock(&hugetlb_lock);
>> +
>> +    /*
>> +     * Gigantic pages runtime allocation depend on the capability 
>> for large
>> +     * page range allocation.
>> +     * If the system does not provide this feature, return an error 
>> when
>> +     * the user tries to allocate gigantic pages but let the user 
>> free the
>> +     * boottime allocated gigantic pages.
>> +     */
>> +    if (hstate_is_gigantic(h) && !IS_ENABLED(CONFIG_CONTIG_ALLOC)) {
>> +        if (count > persistent_huge_pages(h)) {
>> +            spin_unlock(&hugetlb_lock);
>> +            return -EINVAL;
>> +        }
>> +        /* Fall through to decrease pool */
>> +    }
>>         /*
>>        * Increase the pool size
>> @@ -2295,7 +2319,6 @@ static unsigned long set_max_huge_pages(struct 
>> hstate *h, unsigned long count,
>>        * pool might be one hugepage larger than it needs to be, but
>>        * within all the constraints specified by the sysctls.
>>        */
>> -    spin_lock(&hugetlb_lock);
>>       while (h->surplus_huge_pages && count > 
>> persistent_huge_pages(h)) {
>>           if (!adjust_pool_surplus(h, nodes_allowed, -1))
>>               break;
>> @@ -2350,9 +2373,10 @@ static unsigned long set_max_huge_pages(struct 
>> hstate *h, unsigned long count,
>>               break;
>>       }
>>   out:
>> -    ret = persistent_huge_pages(h);
>> +    h->max_huge_pages = persistent_huge_pages(h);
>>       spin_unlock(&hugetlb_lock);
>> -    return ret;
>> +
>> +    return 0;
>>   }
>>     #define HSTATE_ATTR_RO(_name) \
>> @@ -2404,7 +2428,7 @@ static ssize_t __nr_hugepages_store_common(bool 
>> obey_mempolicy,
>>       int err;
>>       NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | 
>> __GFP_NORETRY);
>>   -    if (hstate_is_gigantic(h) && !gigantic_page_supported()) {
>> +    if (hstate_is_gigantic(h) && !gigantic_page_runtime_supported()) {
>>           err = -EINVAL;
>>           goto out;
>>       }
>> @@ -2428,15 +2452,13 @@ static ssize_t 
>> __nr_hugepages_store_common(bool obey_mempolicy,
>>       } else
>>           nodes_allowed = &node_states[N_MEMORY];
>>   -    h->max_huge_pages = set_max_huge_pages(h, count, nodes_allowed);
>> +    err = set_max_huge_pages(h, count, nodes_allowed);
>>   +out:
>>       if (nodes_allowed != &node_states[N_MEMORY])
>>           NODEMASK_FREE(nodes_allowed);
>>   -    return len;
>> -out:
>> -    NODEMASK_FREE(nodes_allowed);
>> -    return err;
>> +    return err ? err : len;
>>   }
>>     static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index ac9c45ffb344..a4547d90fa7a 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -8234,8 +8234,9 @@ int alloc_contig_range(unsigned long start, 
>> unsigned long end,
>>                   pfn_max_align_up(end), migratetype);
>>       return ret;
>>   }
>> +#endif /* CONFIG_CONTIG_ALLOC */
>>   -void free_contig_range(unsigned long pfn, unsigned nr_pages)
>> +void free_contig_range(unsigned long pfn, unsigned int nr_pages)
>>   {
>>       unsigned int count = 0;
>>   @@ -8247,7 +8248,6 @@ void free_contig_range(unsigned long pfn, 
>> unsigned nr_pages)
>>       }
>>       WARN(count != 0, "%d pages are still in use!\n", count);
>>   }
>> -#endif
>>     #ifdef CONFIG_MEMORY_HOTPLUG
>>   /*
>>
>
> ---
> L'absence de virus dans ce courrier électronique a été vérifiée par le 
> logiciel antivirus Avast.
> https://www.avast.com/antivirus
>

