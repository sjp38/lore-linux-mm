Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA212C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 13:18:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B1A620449
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 13:18:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B1A620449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 128068E0004; Thu, 14 Mar 2019 09:18:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D60D8E0001; Thu, 14 Mar 2019 09:18:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E92008E0004; Thu, 14 Mar 2019 09:18:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A4E718E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 09:18:02 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id i13so6170265pgb.14
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 06:18:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=rLFy2JpAoIQ2tCLyuyz6bo8lWbfcu87SH1D7LIEsg/0=;
        b=bPEejh8icrxDeNLruVB0xfuXlJMRIC9virMxYmrlxQMrSBW8LnBDBtA7n5qqV3jE1h
         b8lCuP3dbLkX45lLXcM1cMSqu6O50kRvjTaDn5DeSf7BNCvpiFuTr24KvUgN8w2/5oAh
         BFw87dMc5D+Tdk9ez/B3+3uD7ZTgeFk3pVYanF0h1CYldJvpyCu7+L++b8B0+PRDVwZB
         QrE5yEthXoukIBtiL3kXSjnvYVHizKBuvc21SHe+KLyx+ac8N6eoFizbupYeSeYchUeT
         lQL++3uimoqz+g7GpIntRVd6r53Gav0uuEOpgk3Xml/cLeeoN/Y0OHJVAH/4iRjGaTrc
         2oJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUZzXiO/geNPBujBgafFj7tza8PGF3E9cW+cXsmqgsb83jFyqqY
	4Hpl/D/XCOOqVwiaasf335FLvupQJX06YjIBMblpQOD8KjaApALPGnPdyJi2mkD0S6mgmBoZgtA
	1f27sDySW+ZEBOqZ5412ghu5SzBRszehFmi5iKZ2e0mJvOQpOojOa02cljJqt2z1q0Q==
X-Received: by 2002:a17:902:8346:: with SMTP id z6mr52115403pln.74.1552569482128;
        Thu, 14 Mar 2019 06:18:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzU1zNHjgIs+/3pgpPGkUr/5ecABlki6IA4Q1Ya3SHnvSuCA/acUTSJHZm9kCsrw+Xc5z44
X-Received: by 2002:a17:902:8346:: with SMTP id z6mr52115311pln.74.1552569480901;
        Thu, 14 Mar 2019 06:18:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552569480; cv=none;
        d=google.com; s=arc-20160816;
        b=tC665llZJwolQ0p0CqxP+qlHSlDrHCEhJlmDGX4xbiCrMcgD9Ak1RT5PmdYOmTeO2v
         LGFoliUOfQ9/PmKgOcVeE+hd9VKqw0qftvP4XUHfIYnAJd5kwx1RGgY9HUMlcnkHyo2v
         m09ou564xUJTCjPKEON5flUTMO562G2G45fB3b+HgHLIyrYBN5MjMrLH+PztNX2/8Kcg
         GNJVGwruvtrPInBWuZAcvBSh5y3ZEn4HbvP9mqQlq5gEGEusWY9sKuz7ymClkQIh1j8k
         R0nrsQSRTK6weKULFtWMLCle+ew19sJHguRTk8D206HZryZ1jtMEziCmr+qRJ1iHWrNb
         amfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:to:subject;
        bh=rLFy2JpAoIQ2tCLyuyz6bo8lWbfcu87SH1D7LIEsg/0=;
        b=N/CMTQTTbWZeXeXIq8BT3rG6tjtsTF2psyvlhoaY5PNW7U8r48jPTSg7UfPPUkibqb
         +7PqsCnW03KKjd5+xuId3cqpYt3o5aQFFPL2wD407gFs57VbOvUxtvnZgnMIkFDwl2NL
         0PBk51jedVgv340eQrLEProEULpMdH81mV4m/moqJ/28gM7jF/4HlAC1gdSphMd0iAjc
         zbDItjdmgnbqurQa/ZTFBSN9vZWr6M154ZwTwzAR5dWfcAWWoZ3QizPmMZHlhvF9PHVZ
         zr2Hy9MA7zb5GbPCllpaf+gmjc1juQl8G7Q3fBmXEdiiih23OfqKfFvnK7hWofa0sBZt
         Zrig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r82si13010088pfa.140.2019.03.14.06.18.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 06:18:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2EDA5sm097292
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 09:18:00 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2r7qh3gr57-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 09:17:59 -0400
Received: from localhost
	by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 14 Mar 2019 13:17:56 -0000
Received: from b01cxnp23032.gho.pok.ibm.com (9.57.198.27)
	by e16.ny.us.ibm.com (146.89.104.203) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 14 Mar 2019 13:17:48 -0000
Received: from b01ledav006.gho.pok.ibm.com (b01ledav006.gho.pok.ibm.com [9.57.199.111])
	by b01cxnp23032.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2EDHkFd7929956
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Mar 2019 13:17:46 GMT
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 977C3AC060;
	Thu, 14 Mar 2019 13:17:46 +0000 (GMT)
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2DAE9AC05E;
	Thu, 14 Mar 2019 13:17:37 +0000 (GMT)
Received: from [9.102.2.45] (unknown [9.102.2.45])
	by b01ledav006.gho.pok.ibm.com (Postfix) with ESMTP;
	Thu, 14 Mar 2019 13:17:36 +0000 (GMT)
Subject: Re: [PATCH v6 4/4] hugetlb: allow to free gigantic pages regardless
 of the configuration
To: Alexandre Ghiti <alex@ghiti.fr>,
        Andrew Morton
 <akpm@linux-foundation.org>,
        Vlastimil Babka <vbabka@suse.cz>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon
 <will.deacon@arm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Rich Felker <dalias@libc.org>,
        "David S . Miller" <davem@davemloft.net>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
        x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
        Andy Lutomirski <luto@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-mm@kvack.org
References: <20190307132015.26970-1-alex@ghiti.fr>
 <20190307132015.26970-5-alex@ghiti.fr> <87va0movdh.fsf@linux.ibm.com>
 <e39f5b5b-efa1-c7b1-c1d8-89155b926027@ghiti.fr>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Thu, 14 Mar 2019 18:47:35 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <e39f5b5b-efa1-c7b1-c1d8-89155b926027@ghiti.fr>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19031413-0072-0000-0000-0000040B046B
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010756; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000281; SDB=6.01174248; UDB=6.00614010; IPR=6.00954913;
 MB=3.00025978; MTD=3.00000008; XFM=3.00000015; UTC=2019-03-14 13:17:54
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19031413-0073-0000-0000-00004B7C921A
Message-Id: <972208b7-5c05-cc05-efbf-0d48bff4cf77@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-14_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903140092
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/14/19 5:13 PM, Alexandre Ghiti wrote:
> On 03/14/2019 06:52 AM, Aneesh Kumar K.V wrote:
>> Alexandre Ghiti <alex@ghiti.fr> writes:
>>
>>> On systems without CONTIG_ALLOC activated but that support gigantic 
>>> pages,
>>> boottime reserved gigantic pages can not be freed at all. This patch
>>> simply enables the possibility to hand back those pages to memory
>>> allocator.
>>>
>>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
>>> Acked-by: David S. Miller <davem@davemloft.net> [sparc]
>>> ---
>>>   arch/arm64/Kconfig                           |  2 +-
>>>   arch/arm64/include/asm/hugetlb.h             |  4 --
>>>   arch/powerpc/include/asm/book3s/64/hugetlb.h |  7 ---
>>>   arch/powerpc/platforms/Kconfig.cputype       |  2 +-
>>>   arch/s390/Kconfig                            |  2 +-
>>>   arch/s390/include/asm/hugetlb.h              |  3 --
>>>   arch/sh/Kconfig                              |  2 +-
>>>   arch/sparc/Kconfig                           |  2 +-
>>>   arch/x86/Kconfig                             |  2 +-
>>>   arch/x86/include/asm/hugetlb.h               |  4 --
>>>   include/linux/gfp.h                          |  2 +-
>>>   mm/hugetlb.c                                 | 57 ++++++++++++--------
>>>   mm/page_alloc.c                              |  4 +-
>>>   13 files changed, 44 insertions(+), 49 deletions(-)
>>>
>>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>>> index 091a513b93e9..af687eff884a 100644
>>> --- a/arch/arm64/Kconfig
>>> +++ b/arch/arm64/Kconfig
>>> @@ -18,7 +18,7 @@ config ARM64
>>>       select ARCH_HAS_FAST_MULTIPLIER
>>>       select ARCH_HAS_FORTIFY_SOURCE
>>>       select ARCH_HAS_GCOV_PROFILE_ALL
>>> -    select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
>>> +    select ARCH_HAS_GIGANTIC_PAGE
>>>       select ARCH_HAS_KCOV
>>>       select ARCH_HAS_MEMBARRIER_SYNC_CORE
>>>       select ARCH_HAS_PTE_SPECIAL
>>> diff --git a/arch/arm64/include/asm/hugetlb.h 
>>> b/arch/arm64/include/asm/hugetlb.h
>>> index fb6609875455..59893e766824 100644
>>> --- a/arch/arm64/include/asm/hugetlb.h
>>> +++ b/arch/arm64/include/asm/hugetlb.h
>>> @@ -65,8 +65,4 @@ extern void set_huge_swap_pte_at(struct mm_struct 
>>> *mm, unsigned long addr,
>>>   #include <asm-generic/hugetlb.h>
>>> -#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
>>> -static inline bool gigantic_page_supported(void) { return true; }
>>> -#endif
>>> -
>>>   #endif /* __ASM_HUGETLB_H */
>>> diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h 
>>> b/arch/powerpc/include/asm/book3s/64/hugetlb.h
>>> index 5b0177733994..d04a0bcc2f1c 100644
>>> --- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
>>> +++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
>>> @@ -32,13 +32,6 @@ static inline int hstate_get_psize(struct hstate 
>>> *hstate)
>>>       }
>>>   }
>>> -#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
>>> -static inline bool gigantic_page_supported(void)
>>> -{
>>> -    return true;
>>> -}
>>> -#endif
>>> -
>>>   /* hugepd entry valid bit */
>>>   #define HUGEPD_VAL_BITS        (0x8000000000000000UL)
>> As explained in https://patchwork.ozlabs.org/patch/1047003/
>> architectures like ppc64 have a hypervisor assisted mechanism to indicate
>> where to find gigantic huge pages(16G pages). At this point, we don't 
>> use this
>> reserved pages for anything other than hugetlb backing and hence there
>> is no runtime free of this pages needed ( Also we don't do
>> runtime allocation of them).
>>
>> I guess you can still achieve what you want to do in this patch by
>> keeping gigantic_page_supported()?
>>
>> NOTE: We should rename gigantic_page_supported to be more specific to
>> support for runtime_alloc/free of gigantic pages
>>
>> -aneesh
>>
> Thanks for noticing Aneesh.
> 
> I can't find a better solution than bringing back 
> gigantic_page_supported check,
> since it is must be done at runtime in your case.
> I'm not sure of one thing though: you say that freeing boottime gigantic 
> pages
> is not needed, but is it forbidden ? Just to know where the check and 
> what its
> new name should be.
> Is something like that (on top of this series) ok for you (and everyone 
> else) before
> I send a v7:
> 
> diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h 
> b/arch/powerpc/include/asm/book3s/64/hugetlb.h
> index d04a0bc..d121559 100644
> --- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
> +++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
> @@ -35,4 +35,20 @@ static inline int hstate_get_psize(struct hstate 
> *hstate)
>   /* hugepd entry valid bit */
>   #define HUGEPD_VAL_BITS                (0x8000000000000000UL)
> 
> +#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
> +#define __HAVE_ARCH_GIGANTIC_PAGE_SUPPORTED
> +static inline bool gigantic_page_supported(void)
> +{
> +       /*
> +        * We used gigantic page reservation with hypervisor assist in 
> some case.
> +        * We cannot use runtime allocation of gigantic pages in those 
> platforms
> +        * This is hash translation mode LPARs.
> +        */
> +       if (firmware_has_feature(FW_FEATURE_LPAR) && !radix_enabled())
> +               return false;
> +
> +       return true;
> +}
> +#endif
> +
>   #endif
> diff --git a/include/asm-generic/hugetlb.h b/include/asm-generic/hugetlb.h
> index 71d7b77..7d12e73 100644
> --- a/include/asm-generic/hugetlb.h
> +++ b/include/asm-generic/hugetlb.h
> @@ -126,4 +126,18 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
>   }
>   #endif
> 
> +#ifndef __HAVE_ARCH_GIGANTIC_PAGE_SUPPORTED
> +#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE


The pattern i like is

#ifndef gigantic_page_supported
#define gigantic_page_supported gigantic_page_supported

static inline bool gigantic_page_supported(void)
{
         return true;
}

#endif

instead of _HAVE_ARCH_GIGANTIC_PAGE_SUPPORTED.


> +static inline bool gigantic_page_supported(void)
> +{
> +        return true;
> +}
> +#else
> +static inline bool gigantic_page_supported(void)
> +{
> +        return false;
> +}
> +#endif /* CONFIG_ARCH_HAS_GIGANTIC_PAGE */
> +#endif /* __HAVE_ARCH_GIGANTIC_PAGE_SUPPORTED */
> +
>   #endif /* _ASM_GENERIC_HUGETLB_H */
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 9fc96ef..cfbbafe 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2425,6 +2425,11 @@ static ssize_t __nr_hugepages_store_common(bool 
> obey_mempolicy,
>          int err;
>          NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | 
> __GFP_NORETRY);
> 
> +       if (hstate_is_gigantic(h) && !gigantic_page_supported()) {
> +               err = -EINVAL;
> +               goto out;
> +       }


you should restore other users of gigantic_page_supported() not just 
this. That will just make your earlier patch as removing 
gigantic_page_supported from every architecture other than ppc64 and 
have a generic version as above.


> +
>          if (nid == NUMA_NO_NODE) {
>                  /*
>                   * global hstate attribute
> @@ -2446,6 +2451,7 @@ static ssize_t __nr_hugepages_store_common(bool 
> obey_mempolicy,
> 
>          err = set_max_huge_pages(h, count, nodes_allowed);
> 
> +out:
>          if (nodes_allowed != &node_states[N_MEMORY])
>                  NODEMASK_FREE(nodes_allowed);
> 
> 
> 
> 

-aneesh.

