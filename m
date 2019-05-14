Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2825C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 04:40:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7144E2086A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 04:40:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7144E2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAF676B0003; Tue, 14 May 2019 00:40:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5F7D6B0005; Tue, 14 May 2019 00:40:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D26486B0007; Tue, 14 May 2019 00:40:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id A67C66B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 00:40:21 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id j62so29002917ywe.3
        for <linux-mm@kvack.org>; Mon, 13 May 2019 21:40:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=Dbh30YPITRomoXBu9IvQDOczQn3nxRl1wVBFo0ynZqQ=;
        b=FbY917qya6W8EflTF13eUFHYyKWKp0rLwitjDk45XbKzWWK+ef8yWLhfIG3yfyNimD
         X1RCi228GeQoXqq6ZkilepoWZbjcM1o8NuXI1X9hXhfQKFmmTcP2muIMDDDociJmLLt2
         y7Ypp5eH7/i5IlWuqhVFwJawk7i+/cMHdKmCpb5FkuUQuYffaQsFJh/qtQn+BtSgwKdD
         +fLJShcnEbUxkmw1fCVOSC/ngwg6fxtHJlnDqDnqKE98bPqlrT7MKlOCHwzBWSPuktFf
         0wQMFtI1KF10m1ElFNabRbidGx5QfCyDQvlPhcnurXY8OxYTCGoxH6AfFvZB9+HNhXVK
         Qngw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVUF/iOpQfwbCXe4hBU9A/TnSs59S8BLGx1q4mtwstxviFNXPqm
	5wkuaKyOjS9cNDaqsqMpramWnDNEKj9nwSN4QouDYv5IB8IJFgTZkL0gJFp/zCYdg/q/8U/hxuw
	c6wanbQZPJK+XPG02weGcRvg26TlMaijy10zJKuy4cCWFnxc3HfdU8EBXLeTcycifFw==
X-Received: by 2002:a25:ba0c:: with SMTP id t12mr16218809ybg.70.1557808817455;
        Mon, 13 May 2019 21:40:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrdQ5KVES8mtdek1aTb+AUGr0kOsanwJF1thnSWPieQ6Wj97YkdlDwsOX7fvX0GUcqoBft
X-Received: by 2002:a25:ba0c:: with SMTP id t12mr16218791ybg.70.1557808816787;
        Mon, 13 May 2019 21:40:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557808816; cv=none;
        d=google.com; s=arc-20160816;
        b=O7Y6+H8zehi0ZUFuQCXm30s+2iibHH1404uyuWR+QygilemoHlrsXgsLdxu1UN9Mrz
         k5ZHka+zrBRB3BBUH9y/6qE/62QzxgB2LZBGjCpyAQYweb1CGrOBRQaYGu7s4Wt7fFa8
         23FCpxWAHiGzVkoUq7kGjAzpKKzIlBuWNw+XOnxR5puJFgS1v0qCdfOO+aYiDVFfcUYn
         zjVEaoma7VZSioyAsEk0ZT72Z900zNbGsFwA3Jwy7m/PJdjmhs4Rt3yYiPG/VDH6ubUf
         qupp2+4361JEz7PDGn8NIYdwdQIbZSyFtBEFFLPpTLW6zFuRW6ZdinELzsjNTybTEqWZ
         ocDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=Dbh30YPITRomoXBu9IvQDOczQn3nxRl1wVBFo0ynZqQ=;
        b=nar94Df0z7TnDscM+bmLs/FEZ6HSrlOot3hUx33qZsFczbrrixqZT82T9zJuz6JmSt
         Z6BPO9cNcpiro4LecWSI5IX3ZWvJhHN6pq0gwod8Z/ozq+8K6LIZxfGiNWy+KVSLNbRc
         w4kViXOmsjlp9eRsK1aAkFB1sxs/j9d9w1pCRfSp6LJ1xOxES9u/hoVZqt90dBcBlMvt
         KUHO15KPY1Hsl35PwVila78GC9kGrn/9/Qj7+WfsVkqJ7kZzXqZJSFXjYXnAsyZaOKgh
         D/whbUkVQcI8gMOEsnzKuA/w5VQAUUAat5PUqqyhp0AJ+pTyNhS718dWAj/nuT0GP6dq
         hT/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v2si4013996ybm.120.2019.05.13.21.40.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 21:40:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4E4Wh7H184059
	for <linux-mm@kvack.org>; Tue, 14 May 2019 00:40:16 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2sfj6d8xtv-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 May 2019 00:40:16 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 14 May 2019 05:40:15 +0100
Received: from b03cxnp08028.gho.boulder.ibm.com (9.17.130.20)
	by e34.co.us.ibm.com (192.168.1.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 14 May 2019 05:40:12 +0100
Received: from b03ledav002.gho.boulder.ibm.com (b03ledav002.gho.boulder.ibm.com [9.17.130.233])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4E4eBNH22282622
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 04:40:11 GMT
Received: from b03ledav002.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 83E6D136060;
	Tue, 14 May 2019 04:40:11 +0000 (GMT)
Received: from b03ledav002.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7F1C7136059;
	Tue, 14 May 2019 04:40:09 +0000 (GMT)
Received: from [9.80.230.27] (unknown [9.80.230.27])
	by b03ledav002.gho.boulder.ibm.com (Postfix) with ESMTP;
	Tue, 14 May 2019 04:40:09 +0000 (GMT)
Subject: Re: [RFC PATCH] mm/nvdimm: Fix kernel crash on
 devm_mremap_pages_release
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
        Keith Busch <keith.busch@intel.com>
References: <20190514025354.9108-1-aneesh.kumar@linux.ibm.com>
 <CAPcyv4hsTvyRnLGr3y4JB6zPzdxb7WGQgaWs=5vRqf=L1DYynQ@mail.gmail.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Tue, 14 May 2019 10:10:07 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hsTvyRnLGr3y4JB6zPzdxb7WGQgaWs=5vRqf=L1DYynQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19051404-0016-0000-0000-000009B209BE
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011095; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000285; SDB=6.01203028; UDB=6.00631438; IPR=6.00983950;
 MB=3.00026878; MTD=3.00000008; XFM=3.00000015; UTC=2019-05-14 04:40:14
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19051404-0017-0000-0000-00004335AEC6
Message-Id: <b775d65b-30e3-aceb-f2f8-f2413b129f52@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-14_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905140031
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/14/19 9:45 AM, Dan Williams wrote:
> [ add Keith who was looking at something similar ]
> 
> On Mon, May 13, 2019 at 7:54 PM Aneesh Kumar K.V
> <aneesh.kumar@linux.ibm.com> wrote:
>>
>> When we initialize the namespace, if we support altmap, we don't initialize all the
>> backing struct page where as while releasing the namespace we look at some of
>> these uninitilized struct page. This results in a kernel crash as below.
>>
>> kernel BUG at include/linux/mm.h:1034!
>> cpu 0x2: Vector: 700 (Program Check) at [c00000024146b870]
>>      pc: c0000000003788f8: devm_memremap_pages_release+0x258/0x3a0
>>      lr: c0000000003788f4: devm_memremap_pages_release+0x254/0x3a0
>>      sp: c00000024146bb00
>>     msr: 800000000282b033
>>    current = 0xc000000241382f00
>>    paca    = 0xc00000003fffd680   irqmask: 0x03   irq_happened: 0x01
>>      pid   = 4114, comm = ndctl
>>   c0000000009bf8c0 devm_action_release+0x30/0x50
>>   c0000000009c0938 release_nodes+0x268/0x2d0
>>   c0000000009b95b4 device_release_driver_internal+0x164/0x230
>>   c0000000009b638c unbind_store+0x13c/0x190
>>   c0000000009b4f44 drv_attr_store+0x44/0x60
>>   c00000000058ccc0 sysfs_kf_write+0x70/0xa0
>>   c00000000058b52c kernfs_fop_write+0x1ac/0x290
>>   c0000000004a415c __vfs_write+0x3c/0x70
>>   c0000000004a85ac vfs_write+0xec/0x200
>>   c0000000004a8920 ksys_write+0x80/0x130
>>   c00000000000bee4 system_call+0x5c/0x70
>>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>> ---
>>   mm/page_alloc.c | 5 +----
>>   1 file changed, 1 insertion(+), 4 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 59661106da16..892eabe1ec13 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5740,8 +5740,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>>
>>   #ifdef CONFIG_ZONE_DEVICE
>>          /*
>> -        * Honor reservation requested by the driver for this ZONE_DEVICE
>> -        * memory. We limit the total number of pages to initialize to just
>> +        * We limit the total number of pages to initialize to just
>>           * those that might contain the memory mapping. We will defer the
>>           * ZONE_DEVICE page initialization until after we have released
>>           * the hotplug lock.
>> @@ -5750,8 +5749,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>>                  if (!altmap)
>>                          return;
>>
>> -               if (start_pfn == altmap->base_pfn)
>> -                       start_pfn += altmap->reserve;
> 
> If it's reserved then we should not be accessing, even if the above
> works in practice. Isn't the fix something more like this to fix up
> the assumptions at release time?
> 
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index a856cb5ff192..9074ba14572c 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -90,6 +90,7 @@ static void devm_memremap_pages_release(void *data)
>    struct device *dev = pgmap->dev;
>    struct resource *res = &pgmap->res;
>    resource_size_t align_start, align_size;
> + struct vmem_altmap *altmap = pgmap->altmap_valid ? &pgmap->altmap : NULL;
>    unsigned long pfn;
>    int nid;
> 
> @@ -102,7 +103,10 @@ static void devm_memremap_pages_release(void *data)
>    align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
>    - align_start;
> 
> - nid = page_to_nid(pfn_to_page(align_start >> PAGE_SHIFT));
> + pfn = align_start >> PAGE_SHIFT;
> + if (altmap)
> + pfn += vmem_altmap_offset(altmap);
> + nid = page_to_nid(pfn_to_page(pfn));
> 
>    mem_hotplug_begin();
>    if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
> @@ -110,8 +114,7 @@ static void devm_memremap_pages_release(void *data)
>    __remove_pages(page_zone(pfn_to_page(pfn)), pfn,
>    align_size >> PAGE_SHIFT, NULL);
>    } else {
> - arch_remove_memory(nid, align_start, align_size,
> - pgmap->altmap_valid ? &pgmap->altmap : NULL);
> + arch_remove_memory(nid, align_start, align_size, altmap);
>    kasan_remove_zero_shadow(__va(align_start), align_size);
>    }
>    mem_hotplug_done();
> 
I did try that first. I was not sure about that. From the memory add vs 
remove perspective.

devm_memremap_pages:

align_start = res->start & ~(SECTION_SIZE - 1);
align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
		- align_start;
align_end = align_start + align_size - 1;

error = arch_add_memory(nid, align_start, align_size, altmap,
				false);


devm_memremap_pages_release:

/* pages are dead and unused, undo the arch mapping */
align_start = res->start & ~(SECTION_SIZE - 1);
align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
		- align_start;

arch_remove_memory(nid, align_start, align_size,
		pgmap->altmap_valid ? &pgmap->altmap : NULL);


Now if we are fixing the memremap_pages_release, shouldn't we adjust 
alig_start w.r.t memremap_pages too? and I was not sure what that means 
w.r.t add/remove alignment requirements.

What is the intended usage of reserve area? I guess we want that part to 
be added? if so shouldn't we remove them?


-aneesh

