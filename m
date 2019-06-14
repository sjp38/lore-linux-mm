Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5C6CC31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 16:50:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55D49217F9
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 16:50:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55D49217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0D716B000E; Fri, 14 Jun 2019 12:50:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DBDE16B0266; Fri, 14 Jun 2019 12:50:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CAC7E6B0269; Fri, 14 Jun 2019 12:50:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 939BD6B000E
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 12:50:41 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id z10so2267176pgf.15
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:50:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=hNEn5F1t732oeIKKYapaFNIbtMIn+jH7RF6jl9wLZvk=;
        b=QuFLV68xmUqkI6vLWpyCI9AOXBYNiKeKrhx0On1RK+0gwjK0XKsCguuuuNMddPFndJ
         iIQOd1bq74VXfzQNqKZrV4YKuV+Kb6KmQQg12oVJ8iTart2ZTfUjLn1QG+Bo5JMzU1qk
         2oGOcubwac26BDZajh+NcWoMfWgmSWASOlM43tKkEFjXa1VeAT9/meicd2RT/WJ85R+l
         lLV3HIzdVVDyoaxq/tOO12sSkEPAb29jQ6DSa9okdqT8FQvy8OMNJ07MvYDCCMVdPV/U
         ceVjnpA7isWwegZsSwd4KXPTmD5al8wa689CABr8ggGtomuTwfaCU4ZyuDgFnHY/ONSG
         6Oug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVCxI+6elByM1CRY5eVU3j0vHw88tU3ueKgROGW+lXB3Mi5WKQy
	poIjqLsk3BUgNLEhkn9bnjSulEajuMO9lqrzSDM/eaMVJWC4Fc6f4YbTLJfJ7DTUOch0uY/JB9l
	Ixzq0H7MpPyzRteHt3/j4vEl3PjSaV2AWStWh4OQl1QhuO4p1DVrvIYQGXKnyQnq6vA==
X-Received: by 2002:a62:14c4:: with SMTP id 187mr26269216pfu.241.1560531041241;
        Fri, 14 Jun 2019 09:50:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOWNtGeT1ttJJ1e5Xt/K6dA7aMQ5ryHZh0EGse3Z/qQtO+5iaya779QP6cWbzS8Feo6G+e
X-Received: by 2002:a62:14c4:: with SMTP id 187mr26269156pfu.241.1560531040376;
        Fri, 14 Jun 2019 09:50:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560531040; cv=none;
        d=google.com; s=arc-20160816;
        b=a+fQXo9PBWBEoYE6lMERCJLt5tZgpT5e2OOf6V/E4lObfWnsEr5kDTpS4KFzChLjiJ
         ssixWhQfDYntFi9CoXVil8ilSKhGFHz+XetZSRIarKvV1QESQQcNcb+5SKe6jNvkF2ob
         eCrhrt42K5X6FzFebUXeD12UvI1Lc9zQSFO67wJoFLBH582JTY6YqSyUTI2kci3MANU8
         DuRFoJqiO9ZR5zE4aLGZiWEc57VFA911xJcMo8vWuHz0Erh2HwgdtzfbGoEKfpDa3bKF
         al439GHUUouZ5J4bpfdzw37iZS6qLuPIs5mAc5l5xqiajNYQBKipoV80/QdsJTUYnGOY
         p4RQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=hNEn5F1t732oeIKKYapaFNIbtMIn+jH7RF6jl9wLZvk=;
        b=zA3PWs+DPAJmHmdMyQU3BYAfBu6MPLSSlq0jmn+0Kqw9fpUalk2mBM+rQeAhsHJgQU
         0JvhpXf9PrdXnw7mReyGztXgIQdqjES+XIzov44WGeYVBPOdG1+MA7gntkAafV1cudXN
         cVJ8c7n28+hJby+CDEivE6kxEzGZkXUvZc1DDbNdblohDFxRj7Tqx2jHGsS1gf3ilVWq
         d7kpmrNVcmggVPcRTcKb2i1Wc68bIwh8dMbwj5txSw+maZbjsptTQDOPzpsMS5Mwqctf
         nH/MLr5e68L2k/x9X8bR9gI6xVSb8Kay0uzIZ+3OHD8SXQGwTcJcTS71a49QG4+/TurN
         NeMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d7si2864166pfr.145.2019.06.14.09.50.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 09:50:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5EGli5d061824
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 12:50:39 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t4dr0mx33-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 12:50:39 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Fri, 14 Jun 2019 17:50:38 +0100
Received: from b03cxnp08028.gho.boulder.ibm.com (9.17.130.20)
	by e35.co.us.ibm.com (192.168.1.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 14 Jun 2019 17:50:34 +0100
Received: from b03ledav001.gho.boulder.ibm.com (b03ledav001.gho.boulder.ibm.com [9.17.130.232])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5EGoX7q29753776
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 14 Jun 2019 16:50:33 GMT
Received: from b03ledav001.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8ABC36E050;
	Fri, 14 Jun 2019 16:50:33 +0000 (GMT)
Received: from b03ledav001.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1493E6E04C;
	Fri, 14 Jun 2019 16:50:30 +0000 (GMT)
Received: from [9.199.60.77] (unknown [9.199.60.77])
	by b03ledav001.gho.boulder.ibm.com (Postfix) with ESMTP;
	Fri, 14 Jun 2019 16:50:30 +0000 (GMT)
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from pfn_to_online_page()
To: Dan Williams <dan.j.williams@intel.com>
Cc: Oscar Salvador <osalvador@suse.de>, Qian Cai <cai@lca.pw>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux MM <linux-mm@kvack.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        jmoyer <jmoyer@redhat.com>, linux-nvdimm <linux-nvdimm@lists.01.org>
References: <1560366952-10660-1-git-send-email-cai@lca.pw>
 <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
 <CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com>
 <1560376072.5154.6.camel@lca.pw> <87lfy4ilvj.fsf@linux.ibm.com>
 <20190614153535.GA9900@linux>
 <c3f2c05d-e42f-c942-1385-664f646ddd33@linux.ibm.com>
 <CAPcyv4j_QQB8SrhTqL2mnEEHGYCg4H7kYanChiww35k0fwNv8Q@mail.gmail.com>
 <24fcb721-5d50-2c34-f44b-69281c8dd760@linux.ibm.com>
 <CAPcyv4ixq6aRQLdiMAUzQ-eDoA-hGbJQ6+_-K-nZzhXX70m1+g@mail.gmail.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Fri, 14 Jun 2019 22:20:14 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4ixq6aRQLdiMAUzQ-eDoA-hGbJQ6+_-K-nZzhXX70m1+g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19061416-0012-0000-0000-000017444A92
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011261; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01217923; UDB=6.00640496; IPR=6.00999044;
 MB=3.00027312; MTD=3.00000008; XFM=3.00000015; UTC=2019-06-14 16:50:36
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061416-0013-0000-0000-000057B1CDDD
Message-Id: <6cbef0c5-1ce8-91ac-3396-902a9bf95716@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-14_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=27 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906140136
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/14/19 10:06 PM, Dan Williams wrote:
> On Fri, Jun 14, 2019 at 9:26 AM Aneesh Kumar K.V
> <aneesh.kumar@linux.ibm.com> wrote:
>>
>> On 6/14/19 9:52 PM, Dan Williams wrote:
>>> On Fri, Jun 14, 2019 at 9:18 AM Aneesh Kumar K.V
>>> <aneesh.kumar@linux.ibm.com> wrote:
>>>>
>>>> On 6/14/19 9:05 PM, Oscar Salvador wrote:
>>>>> On Fri, Jun 14, 2019 at 02:28:40PM +0530, Aneesh Kumar K.V wrote:
>>>>>> Can you check with this change on ppc64.  I haven't reviewed this series yet.
>>>>>> I did limited testing with change . Before merging this I need to go
>>>>>> through the full series again. The vmemmap poplulate on ppc64 needs to
>>>>>> handle two translation mode (hash and radix). With respect to vmemap
>>>>>> hash doesn't setup a translation in the linux page table. Hence we need
>>>>>> to make sure we don't try to setup a mapping for a range which is
>>>>>> arleady convered by an existing mapping.
>>>>>>
>>>>>> diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
>>>>>> index a4e17a979e45..15c342f0a543 100644
>>>>>> --- a/arch/powerpc/mm/init_64.c
>>>>>> +++ b/arch/powerpc/mm/init_64.c
>>>>>> @@ -88,16 +88,23 @@ static unsigned long __meminit vmemmap_section_start(unsigned long page)
>>>>>>      * which overlaps this vmemmap page is initialised then this page is
>>>>>>      * initialised already.
>>>>>>      */
>>>>>> -static int __meminit vmemmap_populated(unsigned long start, int page_size)
>>>>>> +static bool __meminit vmemmap_populated(unsigned long start, int page_size)
>>>>>>     {
>>>>>>        unsigned long end = start + page_size;
>>>>>>        start = (unsigned long)(pfn_to_page(vmemmap_section_start(start)));
>>>>>>
>>>>>> -    for (; start < end; start += (PAGES_PER_SECTION * sizeof(struct page)))
>>>>>> -            if (pfn_valid(page_to_pfn((struct page *)start)))
>>>>>> -                    return 1;
>>>>>> +    for (; start < end; start += (PAGES_PER_SECTION * sizeof(struct page))) {
>>>>>>
>>>>>> -    return 0;
>>>>>> +            struct mem_section *ms;
>>>>>> +            unsigned long pfn = page_to_pfn((struct page *)start);
>>>>>> +
>>>>>> +            if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
>>>>>> +                    return 0;
>>>>>
>>>>> I might be missing something, but is this right?
>>>>> Having a section_nr above NR_MEM_SECTIONS is invalid, but if we return 0 here,
>>>>> vmemmap_populate will go on and populate it.
>>>>
>>>> I should drop that completely. We should not hit that condition at all.
>>>> I will send a final patch once I go through the full patch series making
>>>> sure we are not breaking any ppc64 details.
>>>>
>>>> Wondering why we did the below
>>>>
>>>> #if defined(ARCH_SUBSECTION_SHIFT)
>>>> #define SUBSECTION_SHIFT (ARCH_SUBSECTION_SHIFT)
>>>> #elif defined(PMD_SHIFT)
>>>> #define SUBSECTION_SHIFT (PMD_SHIFT)
>>>> #else
>>>> /*
>>>>     * Memory hotplug enabled platforms avoid this default because they
>>>>     * either define ARCH_SUBSECTION_SHIFT, or PMD_SHIFT is a constant, but
>>>>     * this is kept as a backstop to allow compilation on
>>>>     * !ARCH_ENABLE_MEMORY_HOTPLUG archs.
>>>>     */
>>>> #define SUBSECTION_SHIFT 21
>>>> #endif
>>>>
>>>> why not
>>>>
>>>> #if defined(ARCH_SUBSECTION_SHIFT)
>>>> #define SUBSECTION_SHIFT (ARCH_SUBSECTION_SHIFT)
>>>> #else
>>>> #define SUBSECTION_SHIFT  SECTION_SHIFT
>>
>> That should be SECTION_SIZE_SHIFT
>>
>>>> #endif
>>>>
>>>> ie, if SUBSECTION is not supported by arch we have one sub-section per
>>>> section?
>>>
>>> A couple comments:
>>>
>>> The only reason ARCH_SUBSECTION_SHIFT exists is because PMD_SHIFT on
>>> PowerPC was a non-constant value. However, I'm planning to remove the
>>> distinction in the next rev of the patches. Jeff rightly points out
>>> that having a variable subsection size per arch will lead to
>>> situations where persistent memory namespaces are not portable across
>>> archs. So I plan to just make SUBSECTION_SHIFT 21 everywhere.
>>>
>>
>>
>> persistent memory namespaces are not portable across archs because they
>> have PAGE_SIZE dependency.
> 
> We can fix that by reserving mem_map capacity assuming the smallest
> PAGE_SIZE across archs.
> 
>> Then we have dependencies like the page size
>> with which we map the vmemmap area.
> 
> How does that lead to cross-arch incompatibility? Even on a single
> arch the vmemmap area will be mapped with 2MB pages for 128MB aligned
> spans of pmem address space and 4K pages for subsections.

I am not sure I understood that details. On ppc64 vmemmap can be mapped 
by either 16M, 2M, 64K depending on the translation mode (hash or 
radix). Doesn't that imply our reserve area size will vary between these 
configs? I was thinking we should let the arch pick the largest value as 
alignment and align things based on that. Otherwise if you align the 
vmemmap/altmap area to 2M and we move to a platform that map the vmemmap 
area using 16MB pagesize we fail right? In other words if you want to 
build a portable pmem region, we have to configure these alignment 
correctly.

Also the label area storage is completely hidden in firmware right? So 
the portability will be limited to platforms that support same firmware?


> 
>> Why not let the arch
>> arch decide the SUBSECTION_SHIFT and default to one subsection per
>> section if arch is not enabled to work with subsection.
> 
> Because that keeps the implementation from ever reaching a point where
> a namespace might be able to be moved from one arch to another. If we
> can squash these arch differences then we can have a common tool to
> initialize namespaces outside of the kernel. The one wrinkle is
> device-dax that wants to enforce the mapping size, but I think we can
> have a module-option compatibility override for that case for the
> admin to say "yes, I know this namespace is defined for 2MB x86 pages,
> but I want to force enable it with 64K pages on PowerPC"

But then you can't say I want to enable this with 16M pages on PowerPC.
But I understood what you are suggesting here.

-aneesh


