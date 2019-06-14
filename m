Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1228C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 16:18:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0B172183E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 16:18:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0B172183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E8966B000A; Fri, 14 Jun 2019 12:18:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 599566B000D; Fri, 14 Jun 2019 12:18:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 438B16B000E; Fri, 14 Jun 2019 12:18:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0AACE6B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 12:18:34 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id b10so2191532pgb.22
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:18:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=sHrzYdo0GWEqratZ1k147/2lqx7Vx3ZbdqNDfqNQKlc=;
        b=gjtpLDdJ8bFNpTIakCtVB0f4qNjyukLTjjjDtmIsFqtAvsa6qegwpFD3g8fGqFte+Q
         Zd5n6czIBCzAP/W7u3aBEX9FJPDfxVEP1RuGs7DHGkJaqBVxLnlndEYHfYXAx/udOECY
         Emag88FiJznV+PRVMj75XVD80rsa656A6cHxm4u4XrO4uO2WfTFAr0M2w4//74vAHzII
         7p/eZMMQu8KBI2Pzz+tqP9Yl4l6HFQpOHCeG/PlMv/omeaGb5vfiKg+/64dfcCHFm6fj
         /Gy6QOez/C7YZtNtCLnUSFcRE8aBq/SbG6jHsqD5OjVMrbkeJIobsaYSHkf6cjsCMHqJ
         q6Bw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWLNJqg3pSRiF0SUpnSyqxnzfRRnfcvjqF0JQneC4g1U9uC4ARZ
	uRslmSkx3owTmpWspaWyvv28SynQQociJW09hrLKfoTWbRr8RShmlG9ZT91P9DOc6I/w4XPKmbJ
	nFoM4aui8CbKv1WMiv4I3YAaK1W5mEdb8WMcrUDZqd6wlSwkcYVK3En58JAjW39h50w==
X-Received: by 2002:a17:902:9682:: with SMTP id n2mr5910914plp.95.1560529113704;
        Fri, 14 Jun 2019 09:18:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwk8XexzAE6nsTw8jLsMCUE4WTBlu/cQQWpKML8zDK/v2ez2z9whvMG2pJZjs2sDJYLyyM0
X-Received: by 2002:a17:902:9682:: with SMTP id n2mr5910851plp.95.1560529112896;
        Fri, 14 Jun 2019 09:18:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560529112; cv=none;
        d=google.com; s=arc-20160816;
        b=iH4bkVncvpitQH78XwjHeqxRQAjmyaT7VzEdiuutUGMTrtsJJtP8Bks94PnR7movdp
         Gjtk6PBpNGEv570DMhbPrw/Cq5whPWqL7QcKrkukhPm/Lm+MZCTUCh3P8/0nTiwnGuSy
         8/lPiSvJ+KJw++VGqfI78+NpvepUCa1Ircbw3io9T0JIeCmmgCRxOpV1xyPvcJJVY7Ew
         jGcAljrjKhAkKMsbBsWzY2oiDHGdm/nbmz3JKMx8Mdy6B9SdpZgF85K7KI1iiDR9wNaa
         iPoGNYEaE+ftoLDVwbnah1lfT3UKUDRY5Pcxes13Dmgj0+ZMku8x+gVuqiYoJkgC6hks
         AzHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=sHrzYdo0GWEqratZ1k147/2lqx7Vx3ZbdqNDfqNQKlc=;
        b=kEmsGuM4sJTN5drUi5M8ZgpKcDuCqL9A7NwuiTZz1K6DGaGbS7E7S+56pknRdVxqyV
         5gQJzPsPFwOdB54uBDe8H0tVCmWOOHbUgH5h1bvfaMF6P6lzK78t90lyOrJXoNp4PJsc
         XGwIVzNZQRqaGlC+/ud9GtvDglKiPB+Dm0HHV0QRO4hi5Jktbski83jhD2fhz7lKRKHm
         aC796CGqupir08fjx74jyeTuJOx2xPdxttInxB6cY2IYQNRvi1wgjljBkVU28AMSTFcl
         cYVAC5m7w9MrieDiDHmq/eqfqqwGVb2N21qBBBFT9z+IITmt/yIOQggmm8FLjEmRLKJD
         6sXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 23si2696497pjx.87.2019.06.14.09.18.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 09:18:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5EGHJds032667
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 12:18:32 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t4e0ctk55-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 12:18:32 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Fri, 14 Jun 2019 17:18:31 +0100
Received: from b03cxnp08028.gho.boulder.ibm.com (9.17.130.20)
	by e31.co.us.ibm.com (192.168.1.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 14 Jun 2019 17:18:28 +0100
Received: from b03ledav001.gho.boulder.ibm.com (b03ledav001.gho.boulder.ibm.com [9.17.130.232])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5EGIRsn35258832
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 14 Jun 2019 16:18:27 GMT
Received: from b03ledav001.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D371D6E056;
	Fri, 14 Jun 2019 16:18:27 +0000 (GMT)
Received: from b03ledav001.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C28226E04C;
	Fri, 14 Jun 2019 16:18:25 +0000 (GMT)
Received: from [9.199.60.77] (unknown [9.199.60.77])
	by b03ledav001.gho.boulder.ibm.com (Postfix) with ESMTP;
	Fri, 14 Jun 2019 16:18:25 +0000 (GMT)
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from pfn_to_online_page()
To: Oscar Salvador <osalvador@suse.de>
Cc: Qian Cai <cai@lca.pw>, Dan Williams <dan.j.williams@intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux MM <linux-mm@kvack.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <1560366952-10660-1-git-send-email-cai@lca.pw>
 <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
 <CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com>
 <1560376072.5154.6.camel@lca.pw> <87lfy4ilvj.fsf@linux.ibm.com>
 <20190614153535.GA9900@linux>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Fri, 14 Jun 2019 21:48:13 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190614153535.GA9900@linux>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19061416-8235-0000-0000-00000EA7C32A
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011261; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01217912; UDB=6.00640490; IPR=6.00999034;
 MB=3.00027312; MTD=3.00000008; XFM=3.00000015; UTC=2019-06-14 16:18:30
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061416-8236-0000-0000-00004604C626
Message-Id: <c3f2c05d-e42f-c942-1385-664f646ddd33@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-14_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=27 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906140134
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/14/19 9:05 PM, Oscar Salvador wrote:
> On Fri, Jun 14, 2019 at 02:28:40PM +0530, Aneesh Kumar K.V wrote:
>> Can you check with this change on ppc64.  I haven't reviewed this series yet.
>> I did limited testing with change . Before merging this I need to go
>> through the full series again. The vmemmap poplulate on ppc64 needs to
>> handle two translation mode (hash and radix). With respect to vmemap
>> hash doesn't setup a translation in the linux page table. Hence we need
>> to make sure we don't try to setup a mapping for a range which is
>> arleady convered by an existing mapping.
>>
>> diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
>> index a4e17a979e45..15c342f0a543 100644
>> --- a/arch/powerpc/mm/init_64.c
>> +++ b/arch/powerpc/mm/init_64.c
>> @@ -88,16 +88,23 @@ static unsigned long __meminit vmemmap_section_start(unsigned long page)
>>    * which overlaps this vmemmap page is initialised then this page is
>>    * initialised already.
>>    */
>> -static int __meminit vmemmap_populated(unsigned long start, int page_size)
>> +static bool __meminit vmemmap_populated(unsigned long start, int page_size)
>>   {
>>   	unsigned long end = start + page_size;
>>   	start = (unsigned long)(pfn_to_page(vmemmap_section_start(start)));
>>   
>> -	for (; start < end; start += (PAGES_PER_SECTION * sizeof(struct page)))
>> -		if (pfn_valid(page_to_pfn((struct page *)start)))
>> -			return 1;
>> +	for (; start < end; start += (PAGES_PER_SECTION * sizeof(struct page))) {
>>   
>> -	return 0;
>> +		struct mem_section *ms;
>> +		unsigned long pfn = page_to_pfn((struct page *)start);
>> +
>> +		if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
>> +			return 0;
> 
> I might be missing something, but is this right?
> Having a section_nr above NR_MEM_SECTIONS is invalid, but if we return 0 here,
> vmemmap_populate will go on and populate it.

I should drop that completely. We should not hit that condition at all. 
I will send a final patch once I go through the full patch series making 
sure we are not breaking any ppc64 details.

Wondering why we did the below

#if defined(ARCH_SUBSECTION_SHIFT)
#define SUBSECTION_SHIFT (ARCH_SUBSECTION_SHIFT)
#elif defined(PMD_SHIFT)
#define SUBSECTION_SHIFT (PMD_SHIFT)
#else
/*
  * Memory hotplug enabled platforms avoid this default because they
  * either define ARCH_SUBSECTION_SHIFT, or PMD_SHIFT is a constant, but
  * this is kept as a backstop to allow compilation on
  * !ARCH_ENABLE_MEMORY_HOTPLUG archs.
  */
#define SUBSECTION_SHIFT 21
#endif

why not

#if defined(ARCH_SUBSECTION_SHIFT)
#define SUBSECTION_SHIFT (ARCH_SUBSECTION_SHIFT)
#else
#define SUBSECTION_SHIFT  SECTION_SHIFT
#endif

ie, if SUBSECTION is not supported by arch we have one sub-section per 
section?


-aneesh

