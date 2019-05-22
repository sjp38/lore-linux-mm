Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F19BC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 13:13:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49FD82089E
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 13:13:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49FD82089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CA2B6B0005; Wed, 22 May 2019 09:13:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97A6F6B0006; Wed, 22 May 2019 09:13:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8696F6B0007; Wed, 22 May 2019 09:13:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 509196B0005
	for <linux-mm@kvack.org>; Wed, 22 May 2019 09:13:25 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id l16so1696299pfb.23
        for <linux-mm@kvack.org>; Wed, 22 May 2019 06:13:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=kGK0iQlMWO4IbFk+7rjm6MV4NCzkZ7FumGYF9xcfo30=;
        b=TLUqUlLnIGMDMufIOLX5og7leCFjKvPRKotlVs42Gbq8vCQcAgLC/2+6rVUNT+Gq/Y
         +WHWsZN43Ngz/8yoD2xaJqGNyu7cWGc1afySLKjT1sZzn/VtB2bgCoViqagMyRL9kCrX
         cOxpm8ZrqbReLaIFIjOVmziDpyhbsZYzS80ugUx4XIdHD3Sil5F1JgHKM/UUoJhppfeB
         +/snAy0jBdg/gZjMQmmonK4tgT8qmhP1oFE0atvWvLSUiJvnqi4BQWMUFJcLDQe5USTK
         7uDQb1v4MOcum3Tuuw02AfvtijfgAqzo7iRg7Svc4imrwZjtj1PWGDmMfSaXCPiBfK4r
         5ghQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW+ruIgGGSdiTbNo+L5xu6l0gQ0bf0QCQJ10jhqVZC2+XlsIPQj
	sDDqacdkycvXBPULkwxsRTEccEm9P/8zmRw89aCQn8B1/L2x1O+7GVfdbCf0eAvyiqGprKInjPl
	sJm3wZh4igL3huawi/P7aQ7oPdBzpV18q2AzHLp8+WnfsNMFBF+X83XF1mMfhuxFASg==
X-Received: by 2002:a63:eb56:: with SMTP id b22mr5621776pgk.81.1558530804881;
        Wed, 22 May 2019 06:13:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1S9lJ9x3pSa2ueUoCwBXplBdik76k34yoyLHudRST2lBt+5EsDy4Sq7OM+j3qXCP8vnSJ
X-Received: by 2002:a63:eb56:: with SMTP id b22mr5621685pgk.81.1558530803805;
        Wed, 22 May 2019 06:13:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558530803; cv=none;
        d=google.com; s=arc-20160816;
        b=n7bCVhrahcHjaEnkAmOvQsUX+dmHJrw3NXjxP8fTmrpFIqKjtP5CTG8pP3QiY2runY
         vZj1c+9rmTYO9Yqsho1cWMpvxKOM2hO/gu4jRJbv10w/OjxkctB3Orfo1JxU44GMmaoC
         ixpv+A7WGOys7AbyN4/MS8PI915YPfkhqtiXfKfUDV3gdeZEqMGxL/I9cUuJ51YneYYV
         jsME81UaWJIP6DqNzE08U8Zs0XaGbuavXtTe7PsQ2uil2i2reyMQ9scaxZNNxDogsHVt
         TDuMmnApx5zYNUaCk4+He/DD66pyPCOeei6O1cSxzV77u6Wqw/FATsKJN8tAj4ifuyDI
         dDfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=kGK0iQlMWO4IbFk+7rjm6MV4NCzkZ7FumGYF9xcfo30=;
        b=xkD4ychijjjlRXWs11evxvqp3YwlObb+7wm3zYrw29T5Ie/opzvL793y6rG9QuDph4
         4KSptPvH39n4dhxlbGxYvFNs2lmbWfzHrhM4TOYSdDPaBEXXzjtUM4hIPPGkI3CPNBP6
         5Z5OHVw33vhN+fzacItpSZ8UXAndqT02tsPJHFo+jMtC4G0i0INM0CDedYg1AY6rV0UM
         8m3csN2ScyekFxy24+xYtLr30M9kqOB5S7YG4hMOsRmmYE8CveB9B0HigyKSApRZvaBn
         +yj9zMmVNcJqru7egOkrOf/yH6CpWYw63ri9Rv7b6nUBpyzKgCjSfo6luBaw32UpS4RO
         mAdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p16si8324142plo.310.2019.05.22.06.13.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 06:13:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4MDDKjO074000
	for <linux-mm@kvack.org>; Wed, 22 May 2019 09:13:21 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sn5qfuuba-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 May 2019 09:12:28 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 22 May 2019 14:12:26 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 22 May 2019 14:12:23 +0100
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4MDCMti56098848
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 22 May 2019 13:12:22 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 21C1A42041;
	Wed, 22 May 2019 13:12:22 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C9F3D42045;
	Wed, 22 May 2019 13:12:20 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.199.57.94])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 22 May 2019 13:12:20 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Dan Williams <dan.j.williams@intel.com>,
        Keith Busch <keith.busch@intel.com>
Cc: Linux MM <linux-mm@kvack.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
        linux-nvdimm <linux-nvdimm@lists.01.org>
Subject: Re: [RFC PATCH] mm/nvdimm: Fix kernel crash on devm_mremap_pages_release
In-Reply-To: <b775d65b-30e3-aceb-f2f8-f2413b129f52@linux.ibm.com>
References: <20190514025354.9108-1-aneesh.kumar@linux.ibm.com> <CAPcyv4hsTvyRnLGr3y4JB6zPzdxb7WGQgaWs=5vRqf=L1DYynQ@mail.gmail.com> <b775d65b-30e3-aceb-f2f8-f2413b129f52@linux.ibm.com>
Date: Wed, 22 May 2019 18:42:19 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19052213-4275-0000-0000-000003376C43
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052213-4276-0000-0000-00003847052A
Message-Id: <875zq2k4zw.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-22_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905220095
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:

> On 5/14/19 9:45 AM, Dan Williams wrote:
>> [ add Keith who was looking at something similar ]
>> 

...

>>
>> If it's reserved then we should not be accessing, even if the above
>> works in practice. Isn't the fix something more like this to fix up
>> the assumptions at release time?
>> 
>> diff --git a/kernel/memremap.c b/kernel/memremap.c
>> index a856cb5ff192..9074ba14572c 100644
>> --- a/kernel/memremap.c
>> +++ b/kernel/memremap.c
>> @@ -90,6 +90,7 @@ static void devm_memremap_pages_release(void *data)
>>    struct device *dev = pgmap->dev;
>>    struct resource *res = &pgmap->res;
>>    resource_size_t align_start, align_size;
>> + struct vmem_altmap *altmap = pgmap->altmap_valid ? &pgmap->altmap : NULL;
>>    unsigned long pfn;
>>    int nid;
>> 
>> @@ -102,7 +103,10 @@ static void devm_memremap_pages_release(void *data)
>>    align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
>>    - align_start;
>> 
>> - nid = page_to_nid(pfn_to_page(align_start >> PAGE_SHIFT));
>> + pfn = align_start >> PAGE_SHIFT;
>> + if (altmap)
>> + pfn += vmem_altmap_offset(altmap);
>> + nid = page_to_nid(pfn_to_page(pfn));
>> 
>>    mem_hotplug_begin();
>>    if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
>> @@ -110,8 +114,7 @@ static void devm_memremap_pages_release(void *data)
>>    __remove_pages(page_zone(pfn_to_page(pfn)), pfn,
>>    align_size >> PAGE_SHIFT, NULL);
>>    } else {
>> - arch_remove_memory(nid, align_start, align_size,
>> - pgmap->altmap_valid ? &pgmap->altmap : NULL);
>> + arch_remove_memory(nid, align_start, align_size, altmap);
>>    kasan_remove_zero_shadow(__va(align_start), align_size);
>>    }
>>    mem_hotplug_done();
>> 
> I did try that first. I was not sure about that. From the memory add vs 
> remove perspective.
>
> devm_memremap_pages:
>
> align_start = res->start & ~(SECTION_SIZE - 1);
> align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
> 		- align_start;
> align_end = align_start + align_size - 1;
>
> error = arch_add_memory(nid, align_start, align_size, altmap,
> 				false);
>
>
> devm_memremap_pages_release:
>
> /* pages are dead and unused, undo the arch mapping */
> align_start = res->start & ~(SECTION_SIZE - 1);
> align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
> 		- align_start;
>
> arch_remove_memory(nid, align_start, align_size,
> 		pgmap->altmap_valid ? &pgmap->altmap : NULL);
>
>
> Now if we are fixing the memremap_pages_release, shouldn't we adjust 
> alig_start w.r.t memremap_pages too? and I was not sure what that means 
> w.r.t add/remove alignment requirements.
>
> What is the intended usage of reserve area? I guess we want that part to 
> be added? if so shouldn't we remove them?

We need to intialize the struct page backing the reserve area too right?
Where should we do that?

-aneesh

