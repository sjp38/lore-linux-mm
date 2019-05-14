Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17E06C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 04:46:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B78562086A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 04:46:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B78562086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FA366B0007; Tue, 14 May 2019 00:46:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3ABBE6B0008; Tue, 14 May 2019 00:46:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 273646B000A; Tue, 14 May 2019 00:46:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E301B6B0007
	for <linux-mm@kvack.org>; Tue, 14 May 2019 00:46:42 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id n4so10697441pgm.19
        for <linux-mm@kvack.org>; Mon, 13 May 2019 21:46:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=xGedRaNvYAGYgoTSa28eqi7Vhe4nBRPewT9ZWcWMNTw=;
        b=akbjofN6PaCBv6NvtjhoLH03T849KgaQH6xDuMgLtfmYvffHnYkOij1SfGmxCdm3ag
         oGrKie56h8Dl9vsUOtedMzyk998MwNOITUYF3cRPYyPMQGFcY+wWydJsxwqyOK99R1gc
         TT7HqU/Fgf2TmqWWXWaBseB2cNjkyoHEXnHi1+mZX0WJLOH+HV4qX2Wgr/LaqIFMAz1I
         nKwD91FL18bdU2IYlX8ImUEH/C266wHHDmpRkVzbWBrijwsRvePBH/VBY/1NxKm/bOTO
         6VkUaCgUI2t+N/ak5WQL2Sz9qIVBTkwOsouTMAGM+x+6SSCOAoRdT/TdnOGGASMEM3Sp
         waYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXP2A9xTpId4GhY3LOhA9GkWRToSISIa3tgsk3X58ln8d/6ZqTX
	HrZdVlWoVR+I7odwWmNFDnga4oydiLhRv7baiLXHl9aserDyr+9TpZesqMT4c97NskDpxyKxJpy
	liOeF/DaEFNJGSjlfmZICXFt81nqMN2cmdkECDxQwWLVfs+yaGnw1nUmDne1b90VI3A==
X-Received: by 2002:aa7:87c3:: with SMTP id i3mr37362872pfo.85.1557809202504;
        Mon, 13 May 2019 21:46:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2VtBmsmzGW2Q9j0B2uqnPudWX4dL1MZOkCQJ99MjyH+cNCFYA0cf8gvLO0FlZAcVZTLE0
X-Received: by 2002:aa7:87c3:: with SMTP id i3mr37362821pfo.85.1557809201743;
        Mon, 13 May 2019 21:46:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557809201; cv=none;
        d=google.com; s=arc-20160816;
        b=WrmFElLO7j8OPxRp52EbehoHxAt9IebV/qKrAm+dwVQij3uuLLRxFhxFyiP/h+Pj0g
         Ud/RamGRr2JsI09oXj5QFO22qSETdQDD74sUPX/nX8bDXzvraOw7FF41eLi4XeXeL+I0
         wxo5Rj4H3Wy6YDEl7x9a4Z+QAEA9nH9ZPpdDCe4r9BUYtdtnA3faRQui5LbC6JVLKuV+
         Xxa7Xcas9Kmn11t7LJquiyT/eM1L7h4LuxTzblIukDckm9EdNvlgByyko1C6RQ7X1yFE
         Df2bZDlwECSSZYny2XYewGDKvaofO5k2UPkcuIUb1i2/RYurPPika+4qjJA+FiRPq/sl
         BNfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=xGedRaNvYAGYgoTSa28eqi7Vhe4nBRPewT9ZWcWMNTw=;
        b=opyrju/e+8r+t21wXzE5CjZEWMjmeI3g42pgA29vqLxpEYG8o/2c8tOJUDK02GM3PH
         vofhO6qZu2+NYGHVqK3ToyK0caDLoxRXgEVAbzOtw0y7+P/8f+y5rDy0npFFTL/LGCS3
         1cW0JsuoJAOqEtGGpynjwZh3ozexKwljA4ptweYcd1CE2TVa3qbv7Kt7AkeKRESjMZcF
         Ona7lXjb6esPuxQdBlix0O/Ktb69szpOFHUC44VlmOwUz/XHbBzs1GxcKscvFlTnp3Mg
         8cI3q/IMbsb9eN7dLZGgCYBRABVBgzE3+g2luQI0SjTkIM2tg2Hpln48xcQ910HkpmbK
         biWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a6si17766733pls.407.2019.05.13.21.46.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 21:46:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4E4h4v3112692
	for <linux-mm@kvack.org>; Tue, 14 May 2019 00:46:41 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sfj48sa49-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 May 2019 00:46:40 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 14 May 2019 05:46:40 +0100
Received: from b03cxnp08025.gho.boulder.ibm.com (9.17.130.17)
	by e33.co.us.ibm.com (192.168.1.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 14 May 2019 05:46:38 +0100
Received: from b03ledav002.gho.boulder.ibm.com (b03ledav002.gho.boulder.ibm.com [9.17.130.233])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4E4kbOo10551696
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 04:46:38 GMT
Received: from b03ledav002.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D3310136055;
	Tue, 14 May 2019 04:46:37 +0000 (GMT)
Received: from b03ledav002.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6216913604F;
	Tue, 14 May 2019 04:46:36 +0000 (GMT)
Received: from [9.80.230.27] (unknown [9.80.230.27])
	by b03ledav002.gho.boulder.ibm.com (Postfix) with ESMTP;
	Tue, 14 May 2019 04:46:35 +0000 (GMT)
Subject: Re: [PATCH] mm/nvdimm: Use correct #defines instead of opencoding
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
References: <20190514025604.9997-1-aneesh.kumar@linux.ibm.com>
 <CAPcyv4iNgFbSq0Hqb+CStRhGWMHfXx7tL3vrDaQ95DcBBY8QCQ@mail.gmail.com>
 <f99c4f11-a43d-c2d3-ab4f-b7072d090351@linux.ibm.com>
 <CAPcyv4gOr8SFbdtBbWhMOU-wdYuMCQ4Jn2SznGRsv6Vku97Xnw@mail.gmail.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Tue, 14 May 2019 10:16:34 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4gOr8SFbdtBbWhMOU-wdYuMCQ4Jn2SznGRsv6Vku97Xnw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19051404-0036-0000-0000-00000AB9189C
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011095; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000285; SDB=6.01203030; UDB=6.00631440; IPR=6.00983952;
 MB=3.00026878; MTD=3.00000008; XFM=3.00000015; UTC=2019-05-14 04:46:39
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19051404-0037-0000-0000-00004BC780CB
Message-Id: <02d1d14d-650b-da38-0828-1af330f594d5@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-14_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905140032
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/14/19 9:42 AM, Dan Williams wrote:
> On Mon, May 13, 2019 at 9:05 PM Aneesh Kumar K.V
> <aneesh.kumar@linux.ibm.com> wrote:
>>
>> On 5/14/19 9:28 AM, Dan Williams wrote:
>>> On Mon, May 13, 2019 at 7:56 PM Aneesh Kumar K.V
>>> <aneesh.kumar@linux.ibm.com> wrote:
>>>>
>>>> The nfpn related change is needed to fix the kernel message
>>>>
>>>> "number of pfns truncated from 2617344 to 163584"
>>>>
>>>> The change makes sure the nfpns stored in the superblock is right value.
>>>>
>>>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>>>> ---
>>>>    drivers/nvdimm/pfn_devs.c    | 6 +++---
>>>>    drivers/nvdimm/region_devs.c | 8 ++++----
>>>>    2 files changed, 7 insertions(+), 7 deletions(-)
>>>>
>>>> diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
>>>> index 347cab166376..6751ff0296ef 100644
>>>> --- a/drivers/nvdimm/pfn_devs.c
>>>> +++ b/drivers/nvdimm/pfn_devs.c
>>>> @@ -777,8 +777,8 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
>>>>                    * when populating the vmemmap. This *should* be equal to
>>>>                    * PMD_SIZE for most architectures.
>>>>                    */
>>>> -               offset = ALIGN(start + reserve + 64 * npfns,
>>>> -                               max(nd_pfn->align, PMD_SIZE)) - start;
>>>> +               offset = ALIGN(start + reserve + sizeof(struct page) * npfns,
>>>> +                              max(nd_pfn->align, PMD_SIZE)) - start;
>>>
>>> No, I think we need to record the page-size into the superblock format
>>> otherwise this breaks in debug builds where the struct-page size is
>>> extended.
>>>
>>>>           } else if (nd_pfn->mode == PFN_MODE_RAM)
>>>>                   offset = ALIGN(start + reserve, nd_pfn->align) - start;
>>>>           else
>>>> @@ -790,7 +790,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
>>>>                   return -ENXIO;
>>>>           }
>>>>
>>>> -       npfns = (size - offset - start_pad - end_trunc) / SZ_4K;
>>>> +       npfns = (size - offset - start_pad - end_trunc) / PAGE_SIZE;
>>>
>>> Similar comment, if the page size is variable then the superblock
>>> needs to explicitly account for it.
>>>
>>
>> PAGE_SIZE is not really variable. What we can run into is the issue you
>> mentioned above. The size of struct page can change which means the
>> reserved space for keeping vmemmap in device may not be sufficient for
>> certain kernel builds.
>>
>> I was planning to add another patch that fails namespace init if we
>> don't have enough space to keep the struct page.
>>
>> Why do you suggest we need to have PAGE_SIZE as part of pfn superblock?
> 
> So that the kernel has a chance to identify cases where the superblock
> it is handling was created on a system with different PAGE_SIZE
> assumptions.
> 

The reason to do that is we don't have enough space to keep struct page 
backing the total number of pfns? If so, what i suggested above should 
handle that.

or are you finding any other reason why we should fail a namespace init 
with a different PAGE_SIZE value?

My another patch handle the details w.r.t devdax alignment for which 
devdax got created with PAGE_SIZE 4K but we are now trying to load that 
in a kernel with PAGE_SIZE 64k.

-aneesh

