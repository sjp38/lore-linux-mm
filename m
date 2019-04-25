Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BAD4C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 01:37:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7AE4214AE
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 01:37:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7AE4214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 756EF6B0007; Wed, 24 Apr 2019 21:37:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DC486B0008; Wed, 24 Apr 2019 21:37:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 558466B000A; Wed, 24 Apr 2019 21:37:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 194A16B0007
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 21:37:23 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m9so8807549pge.7
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 18:37:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=ThahsPJbwX9VKxo4yL0I2uQw4SlHGTygqhHiridxrTM=;
        b=kGeYK1agSm5iusBFPmJb3DZ9y4I39ZW30jzO0d+Lh7QDK+IjIRgwu7jwjzRLypGy/X
         2rOUlkwqosJUDwbnW5TyyP9vovr88aVX3SMAHn45HypT0yoybhxseaEPZrWcNOSXGk5I
         hN6VoEcpXm/rTBwkozY5CmlmdpKsKl6uuJHrPvbxFMiaMc13iAa+hPpIAphmkDCRk+TE
         TLVJu4d07Wn95geDEtQ6ypuPs5M2B0yJRgZEOU68Bq+mKhnIBi+aWY9PxZrXw+a249e6
         EsfSYjVOkrVRFPgUmEmjjGoRk1Mkd/ibERXVgTEpMnXFBadekLbrbJvrsvmvO7gAyWSJ
         8+vA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUkFU9Dz1y87dlM5rY6s7w0yWRBuhld5/2DNw/pgL0+Sq9geXky
	2ujFkm5vFaSCmrYvesgtl9grNzV72guxmDlljTp9PWORJLfI4fvfPDuJeCFX+h7EmjO12uINMlX
	K98e+dxkfal14vr8PtIXFMUzwVl4l5Kuoxnyg4d85zLo684ggIO9Zt8abYfoJm461RA==
X-Received: by 2002:a63:4a45:: with SMTP id j5mr34613907pgl.426.1556156242710;
        Wed, 24 Apr 2019 18:37:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkPJgtBdduzZnAQHEdYGPYtrpYJL0LP3P98DvOSjrZQZh8lws2k4N27YAHUXYH9i76SMED
X-Received: by 2002:a63:4a45:: with SMTP id j5mr34613854pgl.426.1556156241854;
        Wed, 24 Apr 2019 18:37:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556156241; cv=none;
        d=google.com; s=arc-20160816;
        b=D6rsySw0LeBPdjPVzZZBa8XX1mGuvU0usFLbm7IvF6YOkympqRuNNpaxky1Ev5fK6a
         1hPmLjjfaUUXJ+wFWU/hT5ZU7U7N3LXcVs08hMmPR6y1UAzbQS2TspIzRQrfqiCJ+csm
         epRUksNOnoxluGJ4Tre9pCjUQ74iJ64u6QqnUuLKVkHOfSRFwsGhRW0GvAo7h7hUrUir
         Q6r0tMo/br4D8m9mZlQYO0H9Yw9FNTyD/Lgj6si7VwCJGTVZvAeUF9fdy6Yy6l+gy5AO
         Zk2JSNReyW5JrXnl9fTNHCBLCy4XaPylOG+5Fug3EHBWWLJW1bhmfpELyWruyXF3MLJQ
         P8TA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=ThahsPJbwX9VKxo4yL0I2uQw4SlHGTygqhHiridxrTM=;
        b=X+VVtDhaoEX/0d3yxw7NSYtvRNnpbEZi5WAuQkEG2bL4/u//DRzQyKy4NLOSIxKgeP
         YEFKQwbmmSwJWgp45qfPRcOOWLar7DnGkpo/kZfflmOcPSDHDEgQBk/fpf7/QjvMc6Fv
         VwGt1P5JM/apFcgQnmXgNmkFrti+ar/720NG7JJNil64VkEYea3HJU/AhaPcDSnX9lxQ
         wBGvQh22MVi5vDTMWUwPGZWnEXece/KzX9gPL53MnnSNooYqlZ6xrTRRQd2E+/JCq3H9
         JThNuSt+zJ/myf+8gwxKf7ks+FO+yJc7OIBpEqUe0n0/VM6DRo7WvhEakbiqFwj6eXRq
         jfmw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w2si2049043plp.26.2019.04.24.18.37.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 18:37:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3P1UaHA039879
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 21:37:21 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s30jawk1x-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 21:37:20 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 25 Apr 2019 02:37:19 +0100
Received: from b01cxnp22033.gho.pok.ibm.com (9.57.198.23)
	by e17.ny.us.ibm.com (146.89.104.204) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 25 Apr 2019 02:37:17 +0100
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3P1bGRI20644004
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Apr 2019 01:37:16 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 44D9AB2064;
	Thu, 25 Apr 2019 01:37:16 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C969DB205F;
	Thu, 25 Apr 2019 01:37:13 +0000 (GMT)
Received: from [9.85.69.165] (unknown [9.85.69.165])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Thu, 25 Apr 2019 01:37:13 +0000 (GMT)
Subject: Re: [PATCH v2] mm: Fix modifying of page protection by
 insert_pfn_pmd()
To: Dan Williams <dan.j.williams@intel.com>,
        Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>,
        linux-nvdimm <linux-nvdimm@lists.01.org>,
        Linux MM <linux-mm@kvack.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
        stable
 <stable@vger.kernel.org>,
        Chandan Rajendra <chandan@linux.ibm.com>
References: <20190402115125.18803-1-aneesh.kumar@linux.ibm.com>
 <CAPcyv4hzRj5yxVJ5-7AZgzzBxEL02xf2xwhDv-U9_osWFm9kiA@mail.gmail.com>
 <20190424173833.GE19031@bombadil.infradead.org>
 <CAPcyv4gLGUa69svQnwjvruALZ0ChqUJZHQJ1Mt_Cjr1Jh_6vbQ@mail.gmail.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Thu, 25 Apr 2019 07:07:12 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4gLGUa69svQnwjvruALZ0ChqUJZHQJ1Mt_Cjr1Jh_6vbQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19042501-0040-0000-0000-000004E5C17C
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010990; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000285; SDB=6.01193953; UDB=6.00625937; IPR=6.00974777;
 MB=3.00026582; MTD=3.00000008; XFM=3.00000015; UTC=2019-04-25 01:37:19
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042501-0041-0000-0000-000008F0D197
Message-Id: <444ca26b-ec38-ae4b-512b-7e915c575098@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-25_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904250008
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/24/19 11:43 PM, Dan Williams wrote:
> On Wed, Apr 24, 2019 at 10:38 AM Matthew Wilcox <willy@infradead.org> wrote:
>>
>> On Wed, Apr 24, 2019 at 10:13:15AM -0700, Dan Williams wrote:
>>> I think unaligned addresses have always been passed to
>>> vmf_insert_pfn_pmd(), but nothing cared until this patch. I *think*
>>> the only change needed is the following, thoughts?
>>>
>>> diff --git a/fs/dax.c b/fs/dax.c
>>> index ca0671d55aa6..82aee9a87efa 100644
>>> --- a/fs/dax.c
>>> +++ b/fs/dax.c
>>> @@ -1560,7 +1560,7 @@ static vm_fault_t dax_iomap_pmd_fault(struct
>>> vm_fault *vmf, pfn_t *pfnp,
>>>                  }
>>>
>>>                  trace_dax_pmd_insert_mapping(inode, vmf, PMD_SIZE, pfn, entry);
>>> -               result = vmf_insert_pfn_pmd(vma, vmf->address, vmf->pmd, pfn,
>>> +               result = vmf_insert_pfn_pmd(vma, pmd_addr, vmf->pmd, pfn,
>>>                                              write);
>>
>> We also call vmf_insert_pfn_pmd() in dax_insert_pfn_mkwrite() -- does
>> that need to change too?
> 
> It wasn't clear to me that it was a problem. I think that one already
> happens to be pmd-aligned.
> 

How about vmf_insert_pfn_pud()?

-aneesh

