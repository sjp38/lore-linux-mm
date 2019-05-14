Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6686BC04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 04:41:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2626D2086A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 04:41:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2626D2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8CDC6B0005; Tue, 14 May 2019 00:41:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3DAE6B0007; Tue, 14 May 2019 00:41:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92D986B0008; Tue, 14 May 2019 00:41:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5C9216B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 00:41:56 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e16so3939472pga.4
        for <linux-mm@kvack.org>; Mon, 13 May 2019 21:41:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=3fvbOxZoVHgGosSs/Fl7IyGOjkmdyUd0e962j0Lw9Dw=;
        b=dGfnlE/x8d12bbt8wWiIt1T/1Gw/wY5Gmqfjg48VXSBVHvRik6uC9CiR8l0r9pnxRC
         VD0rQiwLFoBGt8kDGcjFsAqbDrHxAPTvVn6Zy1ro0eK9wx+Vewq1vo7zzaiu5GL8cP6p
         2lprlHJdLyjdK2qb8sk3iFM5UnV6NRdkoIuPLRy9JY6SZEIFCsRJFLtqlawfw4Ndrz1M
         SKKHle1uG7/4DdjYpNjtP5gLyS/3Wcrr1bYIHQc+PSlV1pKFP23VzDeArkh7ZgocYM5i
         PDGwS5YFFpkZ4LlpPqs5w1auQMXOzJZfxCYQ0PeiasqHM+gTL0p6Ycb6nyIIjr6zOvoo
         EC1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUTHrsmQz+QU1FPBrcxHw0EINAtmGVvf/2TH8xI2caFYjI5V5yv
	gVPZye9co4q9y/cjlvFtJz1nYAbEnavo7yjwzXTC16xqWVE4L2G+kdoHqsJoiELND+5zwrThQ2n
	KuXARkLHwI4BZb4RVCQygCne09GEVPcqlhNrs/rWgUxKb2yFq+U+2lQOXXhCq707klA==
X-Received: by 2002:a17:902:6948:: with SMTP id k8mr35892850plt.81.1557808915971;
        Mon, 13 May 2019 21:41:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbsLfHrj+FBsym/CIbI87OaaSRr7OWCfPqL/wEYOm/PLIzXHPHW2s5vu/wNluXDkZq02s5
X-Received: by 2002:a17:902:6948:: with SMTP id k8mr35892824plt.81.1557808915270;
        Mon, 13 May 2019 21:41:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557808915; cv=none;
        d=google.com; s=arc-20160816;
        b=VuVLSQKt6gZl9IZ+qzoy7I2AzQw9ZeLy1saZtFXFTJ7E9pD04aK+1i/512LtGWchsr
         ZuZy7a7aUEuEiFXhu2YSEHYmePBd0tqWIQBlSZO6wm00pgWW+907n3RZVBGQpGKPXZvr
         PJSsoIrWyXOTmA0tzCTjZworDhChNvgP4fgG7UebQp7imUXOuJCEbn096EmV0Aw2TJb3
         V/XDOH/KbRAJG9qD3Gmr/suNCzfcDQrVI5QJbaLazX4P0J7iZI6Pq+6gm8VbplBXxJJP
         zkbblj/B1D6bTUC/nlZBG6wN0nbwNKcuRN7VdmtLKSC/Lb/bT8SPqjQirxEjxd7t2nGM
         UYUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=3fvbOxZoVHgGosSs/Fl7IyGOjkmdyUd0e962j0Lw9Dw=;
        b=S3KckHzgGHetYoEPGf6LB36vaVr7LoCSIgr7AeQRLYYBR4Z5eJYYeJSAbtm47NfXbG
         nFFqcrLj8gW+DaaEzj8T0a8POUihmBAaMwbTAMwSoVMiHes7S3n1FrcHbnIQRATjiOaH
         ylrXmWSX1acTkfQI79sBTw8IxiAbSMUQaIku9UeUN92IAyk1VLhndR4si4pkm3qODLLi
         L//kvb8iV97rPD4r9NgG4tyyZd0rNyDek0lGNkBIXRCNhWLNGSkhG6CfZzsOnl0FON7z
         tVC74pN9GHEm1bmEGKFYV8wYvxbIxtP1f9fzObSJvh+4eyYPdifsgkuuYX4V9dvXRlDy
         7+uw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p24si11341138pli.269.2019.05.13.21.41.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 21:41:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4E4c75r119448
	for <linux-mm@kvack.org>; Tue, 14 May 2019 00:41:54 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sfptjg236-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 May 2019 00:41:54 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 14 May 2019 05:41:53 +0100
Received: from b03cxnp07029.gho.boulder.ibm.com (9.17.130.16)
	by e35.co.us.ibm.com (192.168.1.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 14 May 2019 05:41:51 +0100
Received: from b03ledav002.gho.boulder.ibm.com (b03ledav002.gho.boulder.ibm.com [9.17.130.233])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4E4fooX2753004
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 04:41:50 GMT
Received: from b03ledav002.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2A8B7136060;
	Tue, 14 May 2019 04:41:50 +0000 (GMT)
Received: from b03ledav002.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AD0FE13604F;
	Tue, 14 May 2019 04:41:48 +0000 (GMT)
Received: from [9.80.230.27] (unknown [9.80.230.27])
	by b03ledav002.gho.boulder.ibm.com (Postfix) with ESMTP;
	Tue, 14 May 2019 04:41:48 +0000 (GMT)
Subject: Re: [PATCH] mm/nvdimm: Use correct alignment when looking at first
 pfn from a region
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
References: <20190514025512.9670-1-aneesh.kumar@linux.ibm.com>
 <CAPcyv4hgNUDxjgYNkxOXJ9hfLb6z2+E1yasNoZNDKFUxkCzWLA@mail.gmail.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Tue, 14 May 2019 10:11:47 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hgNUDxjgYNkxOXJ9hfLb6z2+E1yasNoZNDKFUxkCzWLA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19051404-0012-0000-0000-000017361693
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011095; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000285; SDB=6.01203028; UDB=6.00631439; IPR=6.00983950;
 MB=3.00026878; MTD=3.00000008; XFM=3.00000015; UTC=2019-05-14 04:41:52
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19051404-0013-0000-0000-00005741C30C
Message-Id: <925e41ad-cc57-bc03-a2b6-6913c9e98abf@linux.ibm.com>
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

On 5/14/19 9:59 AM, Dan Williams wrote:
> On Mon, May 13, 2019 at 7:55 PM Aneesh Kumar K.V
> <aneesh.kumar@linux.ibm.com> wrote:
>>
>> We already add the start_pad to the resource->start but fails to section
>> align the start. This make sure with altmap we compute the right first
>> pfn when start_pad is zero and we are doing an align down of start address.
>>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>> ---
>>   kernel/memremap.c | 4 ++--
>>   1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/kernel/memremap.c b/kernel/memremap.c
>> index a856cb5ff192..23d77b60e728 100644
>> --- a/kernel/memremap.c
>> +++ b/kernel/memremap.c
>> @@ -59,9 +59,9 @@ static unsigned long pfn_first(struct dev_pagemap *pgmap)
>>   {
>>          const struct resource *res = &pgmap->res;
>>          struct vmem_altmap *altmap = &pgmap->altmap;
>> -       unsigned long pfn;
>> +       unsigned long pfn = PHYS_PFN(res->start);
>>
>> -       pfn = res->start >> PAGE_SHIFT;
>> +       pfn = SECTION_ALIGN_DOWN(pfn);
> 
> This does not seem right to me it breaks the assumptions of where the
> first expected valid pfn occurs in the passed in range.
> 

How do we define the first valid pfn? Isn't that at pfn_sb->dataoff ?

-aneesh

