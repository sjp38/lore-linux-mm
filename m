Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26B11C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 08:56:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6C372075E
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 08:56:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6C372075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D2636B0269; Wed, 27 Mar 2019 04:56:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 483936B026A; Wed, 27 Mar 2019 04:56:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34BC36B026B; Wed, 27 Mar 2019 04:56:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D39686B0269
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 04:56:01 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 33so13640688pgv.17
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 01:56:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=JDZinxg0OFUS7XIsBd8v6a/rMcz29fIEzBnJEif35Ig=;
        b=PDoFMn7uC40JjMBGjX6aFBzdkF/vqNKrmz3KAvtgJKf3EhT0UzeJd/fffPIUbkSpl7
         JLS6vntsPg7f4uSIl91Q+85AeAKYLwX2JXubGwjxGQ8e1/mTFKeFeOePhAovt0gxJV+Y
         mBtejJr0KBKXG3+dV78HO7tt18C62xNSANZcz5psI3vw/KntnpwWDxKRPanmtA8bPByH
         ci69v8aLLMeL2RtOWcp7l6qj/KVf53pqzbHkwoekz7Sk/BKrMqjQ3z+V1XypB5hAF6Eq
         sXaMvG6G+FeELYXKQ9tjJMcFHfS1nn1semRTeMisx9lmEjtd0OWH096RApdp7Ep23TWG
         0LpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXd5TBjiOotUaaShbFuW9/4kCBSj5rnL5cIGFimnYI/8kcA2Yym
	UcdU82/1FAqL8LcYTjs9N4rt81oEvN0mRKH0OEfHQg3cjjxmQeXr1s7o5LSatBBfCiLTKt1iTzE
	8mh+3VBWbc6uI8qAnRdx4cU9IuoxrQcji2ED4J96Arbr27XYHToxwfKgLcIPC0FLZ4g==
X-Received: by 2002:a17:902:8c81:: with SMTP id t1mr36298748plo.309.1553676961487;
        Wed, 27 Mar 2019 01:56:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmwdKy6Z8JyIDiRZURWuipPdUHxmPvhHhCKpW9VURPYBAftfby3j6EsbbxUl4VMKoUne1r
X-Received: by 2002:a17:902:8c81:: with SMTP id t1mr36298698plo.309.1553676960650;
        Wed, 27 Mar 2019 01:56:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553676960; cv=none;
        d=google.com; s=arc-20160816;
        b=LUe2Iyb35cJXr0dh+8T/mkuBrj/srUzm4xSd+jWQd/ooyWrHEWx2fFAIB3OO1BXxwY
         DPU6D47mYsHAIlEfFl80RoNcv+NVdN5DSsxrdLa73vdza2E1/dIc0pSOk/Y/q2pABD7T
         DaPzpJMJ7BaOop1rfVbkMLBlfBnY+9qhrf4C84uYOr/ASUd141UNOdPZHOAwofcx4+Nt
         YUdp1eIzhifSPrEQZsor3FQHBg/K3ceimpsb9jr39DiK38XAH8kNZFMfY4kAVqr7BuMh
         BtpUtapQzoUi3vn689PvVFfMYJgEhgcX88OHeLManHGYzKxPyjwGdXxMPLajKMv1bAHU
         lPPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:to:subject;
        bh=JDZinxg0OFUS7XIsBd8v6a/rMcz29fIEzBnJEif35Ig=;
        b=Y6bcLsSa+qYA2AXNb/2JikZVsyDo4A0swLaJaCfXEFQxvMUI+6XkdQUMtS+sq9KZ0C
         E+0OFV5+woNu/q8csAv1+Lq7q5VkCr3455nny61qnotm2BfEC194IKN0bLMZXqWCqW3r
         yYHwSO4Hza6QlMwH+pLwmezibIUEYURmhZZlRxAXhO/KIiY2tGffwK3NQFPXbdZBBrAs
         l29IEgxb6kzkt5j9XsFob7J461sILqSWutwEa4Pmlaev8XAXyXBur/54ttfGDhXDgeH8
         TWzTnZW6eDsXkhpODqxbGmuq8/b+MgO+jGsp8W48uIJSMQ+5Ohfddzaox6ZqueIXHjTg
         KnhA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y12si622048plp.47.2019.03.27.01.56.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 01:56:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2R8oBou131875
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 04:56:00 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rg3g06d4u-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 04:55:59 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 27 Mar 2019 08:55:59 -0000
Received: from b03cxnp08025.gho.boulder.ibm.com (9.17.130.17)
	by e31.co.us.ibm.com (192.168.1.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 27 Mar 2019 08:55:52 -0000
Received: from b03ledav006.gho.boulder.ibm.com (b03ledav006.gho.boulder.ibm.com [9.17.130.237])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2R8tnDw14680118
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Mar 2019 08:55:49 GMT
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 49C8FC6055;
	Wed, 27 Mar 2019 08:55:49 +0000 (GMT)
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 10CF9C6059;
	Wed, 27 Mar 2019 08:55:39 +0000 (GMT)
Received: from [9.102.0.57] (unknown [9.102.0.57])
	by b03ledav006.gho.boulder.ibm.com (Postfix) with ESMTP;
	Wed, 27 Mar 2019 08:55:39 +0000 (GMT)
Subject: Re: [PATCH v8 4/4] hugetlb: allow to free gigantic pages regardless
 of the configuration
To: Alexandre Ghiti <alex@ghiti.fr>, mpe@ellerman.id.au,
        Andrew Morton <akpm@linux-foundation.org>,
        Vlastimil Babka <vbabka@suse.cz>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon
 <will.deacon@arm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
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
References: <20190327063626.18421-1-alex@ghiti.fr>
 <20190327063626.18421-5-alex@ghiti.fr>
 <f6e74ad8-acca-3b1e-27eb-a2881ac8437d@linux.ibm.com>
 <fbae7220-2e6f-8516-cf93-fbe430452043@ghiti.fr>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Wed, 27 Mar 2019 14:25:38 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <fbae7220-2e6f-8516-cf93-fbe430452043@ghiti.fr>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19032708-8235-0000-0000-00000E73BD0A
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010822; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000282; SDB=6.01180325; UDB=6.00617688; IPR=6.00961042;
 MB=3.00026176; MTD=3.00000008; XFM=3.00000015; UTC=2019-03-27 08:55:58
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032708-8236-0000-0000-000044ECBA18
Message-Id: <aabfc780-1681-c69a-9927-4645d6499984@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-27_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903270065
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/27/19 2:14 PM, Alexandre Ghiti wrote:
> 
> 
> On 03/27/2019 08:01 AM, Aneesh Kumar K.V wrote:
>> On 3/27/19 12:06 PM, Alexandre Ghiti wrote:
>>> On systems without CONTIG_ALLOC activated but that support gigantic 
>>> pages,
>>> boottime reserved gigantic pages can not be freed at all. This patch
>>> simply enables the possibility to hand back those pages to memory
>>> allocator.
>>>
>>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
>>> Acked-by: David S. Miller <davem@davemloft.net> [sparc]
>>>
>>> diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h 
>>> b/arch/powerpc/include/asm/book3s/64/hugetlb.h
>>> index ec2a55a553c7..7013284f0f1b 100644
>>> --- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
>>> +++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
>>> @@ -36,8 +36,8 @@ static inline int hstate_get_psize(struct hstate 
>>> *hstate)
>>>       }
>>>   }
>>>   -#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
>>> -static inline bool gigantic_page_supported(void)
>>> +#define __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED
>>> +static inline bool gigantic_page_runtime_supported(void)
>>>   {
>>>       /*
>>>        * We used gigantic page reservation with hypervisor assist in 
>>> some case.
>>> @@ -49,7 +49,6 @@ static inline bool gigantic_page_supported(void)
>>>         return true;
>>>   }
>>> -#endif
>>>     /* hugepd entry valid bit */
>>>   #define HUGEPD_VAL_BITS        (0x8000000000000000UL)
>>
>> Is that correct when CONTIG_ALLOC is not enabled? I guess we want
>>
>> gigantic_page_runtime_supported to return false when CONTIG_ALLOC is 
>> not enabled on all architectures and on POWER when it is enabled we 
>> want it to be conditional as it is now.
>>
>> -aneesh
>>
> 
> CONFIG_ARCH_HAS_GIGANTIC_PAGE is set by default when an architecture 
> supports gigantic
> pages: on its own, it allows to allocate boottime gigantic pages AND to 
> free them at runtime
> (this is the goal of this series), but not to allocate runtime gigantic 
> pages.
> If CONTIG_ALLOC is set, it allows in addition to allocate runtime 
> gigantic pages.
> 
> I re-introduced the runtime checks because we can't know at compile time 
> if powerpc can
> or not support gigantic pages.
> 
> So for all architectures, gigantic_page_runtime_supported only depends on
> CONFIG_ARCH_HAS_GIGANTIC_PAGE enabled or not. The possibility to 
> allocate runtime
> gigantic pages is dealt with after those runtime checks.
> 

you removed that #ifdef in the patch above. ie we had
#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
static inline bool gigantic_page_supported(void)
{
	/*
	 * We used gigantic page reservation with hypervisor assist in some case.
	 * We cannot use runtime allocation of gigantic pages in those platforms
	 * This is hash translation mode LPARs.
	 */
	if (firmware_has_feature(FW_FEATURE_LPAR) && !radix_enabled())
		return false;

	return true;
}
#endif


This is now
#define __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED
static inline bool gigantic_page_runtime_supported(void)
{
if (firmware_has_feature(FW_FEATURE_LPAR) && !radix_enabled())
		return false;

	return true;
}


I am wondering whether it should be

#define __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED
static inline bool gigantic_page_runtime_supported(void)
{

    if (!IS_ENABLED(CONFIG_CONTIG_ALLOC))
		return false;

if (firmware_has_feature(FW_FEATURE_LPAR) && !radix_enabled())
		return false;

	return true;
}

or add that #ifdef back.

> By the way, I forgot to ask you why you think that if an arch cannot 
> allocate runtime gigantic
> pages, it should not be able to free boottime gigantic pages ?
> 

on virtualized platforms like powervm which use a paravirtualized page 
table update mechanism (we dont' have two level table). The ability to 
map a page huge depends on how hypervisor allocated the guest ram. 
Hypervisor also allocates the guest specific page table of a specific 
size depending on how many pages are going to be mapped by what page size.

on POWER we indicate possible guest real address that can be mapped via 
hugepage (in this case 16G) using a device tree node 
(ibm,expected#pages) . It is expected that we will map these pages only 
as 16G pages. Hence we cannot free them back to the buddy where it could 
get mapped via 64K page size.

-aneesh


