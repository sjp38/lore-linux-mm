Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D88CC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:43:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB4272133D
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:43:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB4272133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 571D88E0003; Thu, 28 Feb 2019 07:43:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 522428E0001; Thu, 28 Feb 2019 07:43:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E9F48E0003; Thu, 28 Feb 2019 07:43:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 128978E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 07:43:41 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id r24so18437587qtj.13
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:43:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=QZ7uSGpi3RM6X3DaBfMeIrExi20LicnVpcOF42eKq70=;
        b=JIii/a61Ju0x72/vV9g15LMPtWMc8BXDfIqqm2Jh7v3h/sStetcz3w49e3jKsgyKW9
         q9GDbZDJuAMDQMKn1BbJ7RSNZ/Uf7rA4DsVz415LrkoeoEh0QD76mbcxuRlE7MRr4VbV
         5IcJwIHVkAeM9kbogQWx4PsIi7+JOeGJM+OestsVus6pBzOn5Cjp/ufD9Fuuv/7HEm3D
         V2Iqm6wzB6cCi4y4T+zgDjKi2iOmGxE+e3ITznNGuRvsLdzbnWYxmFr+yY2GscNGEGCP
         j1VphNuzsN0Zz1V15HvE3dCpfwnCgzOCqQx4nZekTnhias+BMN/n6ZVkWJb8/wzBqpeA
         x5gA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAub9YBUzq3RUh8xVkYBvbY27Y+R9XPxHgWRE8W1X8sa9Vuc4dYam
	hsRFsFNsDtWPgnMR9NHpozmei6BKob6RGFtwEUIRnzIDXNbkhA5d04vgWD3OGTzCDmRO2BZrxRW
	zbjMWGXleQkon14Ea/+FINnYYn6rOCfmZ2TMJV3zWE+fUHreSgBJckXbqdhGVS6oing==
X-Received: by 2002:a37:47cb:: with SMTP id u194mr6138006qka.296.1551357820800;
        Thu, 28 Feb 2019 04:43:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IanVlvqz4S+SEtJq94nAKrYWA3E5zm2T8nPXxIYeMKqjyiTVANKcRx0s0ZtiuCVhI4rJf3C
X-Received: by 2002:a37:47cb:: with SMTP id u194mr6137953qka.296.1551357819953;
        Thu, 28 Feb 2019 04:43:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551357819; cv=none;
        d=google.com; s=arc-20160816;
        b=hsV/edAZ4ZdUVmHKhoVZrtfZOilmjn2ipRSDHv/2SNfQogZYvUPHnsKpbAYWaOX0TI
         4lnq8RO06v0dcK9gMEd8jvGbGPAGG6exzTvEaSDFSR4EDLVHXhz6326KXYaBlgneftgS
         BIGquhzHhpNEm73uDio6ePZDEyXujsi6HaVNrDTJMUP3Jz1aYh7RqN10TqhmYV6Wonva
         OJbU4FMO3VwBkkJQXG8BTbEx3N2fj0ArtJKSaF3wrodyxcoywv3imuofW+bGorkVCDdB
         7G+N3VCwE5joG+w5qKom/lcUtU9PG4OwLNtmp5GkXQUFeTzMCQCx4pLP39KsjMxNzWLI
         dFhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=QZ7uSGpi3RM6X3DaBfMeIrExi20LicnVpcOF42eKq70=;
        b=jjF4jZapeLpWAnflj5vJOGokQuCpuD+GoepN6Zjd4F7rfMCnpoJSjPsb91rCDPelRE
         1+OyBImNC8ha74nZQgS18eZSLpWVSRf43Uy9hKkJIGfSzGTweuCkCrVxtwozGSsTpk6e
         DffyQRNyMmcvSDcjRuIJ2cnFH1Kxi2fTKuuZUZYrUJpmalUKr+Dk0gIH5aR6byK/PSuB
         2sxyneNjRbA1hs484PA/U0QurbK19AQi1tKOZ5qdCGp75AjRWbnovR6kU7hasugCgXmE
         g7WYmaYvf4XRI9GkUKFcPZV8/jyICGmvV0rY8hvg36FtsIF7nzXt73hyRjn6dk7oHo9y
         xaKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l68si9076918qke.10.2019.02.28.04.43.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 04:43:39 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1SCedCo131264
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 07:43:39 -0500
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qxdxt5sey-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 07:43:38 -0500
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 28 Feb 2019 12:43:38 -0000
Received: from b01cxnp22034.gho.pok.ibm.com (9.57.198.24)
	by e15.ny.us.ibm.com (146.89.104.202) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 28 Feb 2019 12:43:34 -0000
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp22034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1SChX8u20381722
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Feb 2019 12:43:33 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4E510B2066;
	Thu, 28 Feb 2019 12:43:33 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0E7B5B205F;
	Thu, 28 Feb 2019 12:43:30 +0000 (GMT)
Received: from [9.199.36.171] (unknown [9.199.36.171])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Thu, 28 Feb 2019 12:43:29 +0000 (GMT)
Subject: Re: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
To: Oliver <oohall@gmail.com>, Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Jan Kara <jack@suse.cz>, Michael Ellerman <mpe@ellerman.id.au>,
        Ross Zwisler <zwisler@kernel.org>, Linux MM <linux-mm@kvack.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
 <20190228083522.8189-2-aneesh.kumar@linux.ibm.com>
 <CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Thu, 28 Feb 2019 18:13:28 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19022812-0068-0000-0000-0000039BAD11
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010679; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000281; SDB=6.01167576; UDB=6.00609980; IPR=6.00948189;
 MB=3.00025780; MTD=3.00000008; XFM=3.00000015; UTC=2019-02-28 12:43:37
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022812-0069-0000-0000-000047A84445
Message-Id: <65e1671d-6896-e2e9-e000-90c5b0484ad2@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-28_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902280088
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/28/19 3:10 PM, Oliver wrote:
> On Thu, Feb 28, 2019 at 7:35 PM Aneesh Kumar K.V
> <aneesh.kumar@linux.ibm.com> wrote:
>>
>> Add a flag to indicate the ability to do huge page dax mapping. On architecture
>> like ppc64, the hypervisor can disable huge page support in the guest. In
>> such a case, we should not enable huge page dax mapping. This patch adds
>> a flag which the architecture code will update to indicate huge page
>> dax mapping support.
> 
> *groan*
> 
>> Architectures mostly do transparent_hugepage_flag = 0; if they can't
>> do hugepages. That also takes care of disabling dax hugepage mapping
>> with this change.
>>
>> Without this patch we get the below error with kvm on ppc64.
>>
>> [  118.849975] lpar: Failed hash pte insert with error -4
>>
>> NOTE: The patch also use
>>
>> echo never > /sys/kernel/mm/transparent_hugepage/enabled
>> to disable dax huge page mapping.
>>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>> ---
>> TODO:
>> * Add Fixes: tag
>>
>>   include/linux/huge_mm.h | 4 +++-
>>   mm/huge_memory.c        | 4 ++++
>>   2 files changed, 7 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
>> index 381e872bfde0..01ad5258545e 100644
>> --- a/include/linux/huge_mm.h
>> +++ b/include/linux/huge_mm.h
>> @@ -53,6 +53,7 @@ vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
>>                          pud_t *pud, pfn_t pfn, bool write);
>>   enum transparent_hugepage_flag {
>>          TRANSPARENT_HUGEPAGE_FLAG,
>> +       TRANSPARENT_HUGEPAGE_DAX_FLAG,
>>          TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
>>          TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
>>          TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
>> @@ -111,7 +112,8 @@ static inline bool __transparent_hugepage_enabled(struct vm_area_struct *vma)
>>          if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
>>                  return true;
>>
>> -       if (vma_is_dax(vma))
>> +       if (vma_is_dax(vma) &&
>> +           (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_DAX_FLAG)))
>>                  return true;
> 
> Forcing PTE sized faults should be fine for fsdax, but it'll break
> devdax. The devdax driver requires the fault size be >= the namespace
> alignment since devdax tries to guarantee hugepage mappings will be
> used and PMD alignment is the default. We can probably have devdax
> fall back to the largest size the hypervisor has made available, but
> it does run contrary to the design. Ah well, I suppose it's better off
> being degraded rather than unusable.
> 

Will fix that. I will make PFN_DEFAULT_ALIGNMENT arch specific.


>>          if (transparent_hugepage_flags &
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index faf357eaf0ce..43d742fe0341 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -53,6 +53,7 @@ unsigned long transparent_hugepage_flags __read_mostly =
>>   #ifdef CONFIG_TRANSPARENT_HUGEPAGE_MADVISE
>>          (1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG)|
>>   #endif
>> +       (1 << TRANSPARENT_HUGEPAGE_DAX_FLAG) |
>>          (1<<TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG)|
>>          (1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG)|
>>          (1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
>> @@ -475,6 +476,8 @@ static int __init setup_transparent_hugepage(char *str)
>>                            &transparent_hugepage_flags);
>>                  clear_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
>>                            &transparent_hugepage_flags);
>> +               clear_bit(TRANSPARENT_HUGEPAGE_DAX_FLAG,
>> +                         &transparent_hugepage_flags);
>>                  ret = 1;
>>          }
>>   out:
> 
>> @@ -753,6 +756,7 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
>>          spinlock_t *ptl;
>>
>>          ptl = pmd_lock(mm, pmd);
>> +       /* should we check for none here again? */
> 
> VM_WARN_ON() maybe? If THP is disabled and we're here then something
> has gone wrong.

I was wondering whether we can end up calling insert_pfn_pmd in parallel 
and hence end up having a pmd entry here already. Usually we check for 
if (!pmd_none(pmd)) after holding pmd_lock. Was not sure whether there 
is anything preventing a parallel fault in case of dax.


> 
>>          entry = pmd_mkhuge(pfn_t_pmd(pfn, prot));
>>          if (pfn_t_devmap(pfn))
>>                  entry = pmd_mkdevmap(entry);
>> --
>> 2.20.1
>>
> 

