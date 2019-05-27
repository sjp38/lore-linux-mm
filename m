Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C83DC07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 09:35:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7BC92173B
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 09:35:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7BC92173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 189D16B000C; Mon, 27 May 2019 05:35:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13B0C6B0266; Mon, 27 May 2019 05:35:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02A0D6B026B; Mon, 27 May 2019 05:35:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BFDD26B000C
	for <linux-mm@kvack.org>; Mon, 27 May 2019 05:35:49 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 205so6464115pfx.2
        for <linux-mm@kvack.org>; Mon, 27 May 2019 02:35:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=+nFKZw1/3mrTKvNVIsRm9EX9HzlZYfPy7QXIUGdT7eA=;
        b=ktmF/d31zNHI8GB5cgL7ofBqePOpfdBNrYgLbSJPP2ip2dfnPxjZ2likVsAiDQ6wmF
         em/P1a04WViC/RK+zQUKA0mD63wepzg6z4GUVri6CUsoDD82VVhoku6j9jvxL1bTQsw4
         amUolbcShLFQJ80y6+tbGJ+BpFIbUYo1uD5scRBOXnOD1xq88yMFrP2oJ+m4AE/QIS68
         DZcfJp21k/RSs6YXoi77V3mv9/pL61My+1T6XG6T8SQz4YhB6mzvMJVLu4EctvZOsWRc
         V3EPgFhxYmg1EbeKHGu53COOnBQorQ8Sj4h9rEDkTH8WdsSjxD9qOqqZNXbMyIeRmb1g
         5uxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWo+rsPBtus+TsjcOCwtdTu/L22gMA2e4telwjQHW7yfOgTyUzC
	S78e8viGyMEsxpIn06qQychY4rbjRvpbtMvSTV3UZBekDj+s7Fe639cRx43Exp3AcWpRdukqZYC
	hcaEomvUTjpKduwL8vnPVjQBftvotVNfgxyXHSynOSDoZv0Pngekpl7ZusjdcsHYMfw==
X-Received: by 2002:a17:90a:3442:: with SMTP id o60mr30360098pjb.5.1558949749347;
        Mon, 27 May 2019 02:35:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwB9bjr9tpxgcSicrTgwt88OJ9XOniUWICaGdVjKXqWMDdWnrk1fDL8miTtwfAx3TKB1cqY
X-Received: by 2002:a17:90a:3442:: with SMTP id o60mr30359990pjb.5.1558949748425;
        Mon, 27 May 2019 02:35:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558949748; cv=none;
        d=google.com; s=arc-20160816;
        b=PkdEGtd4jsucMfEgGxEk+JdcZjpAXuf88jqaagpN9TuXMMAbnEuphFfDJtuBr74RmJ
         ENleQyCyfo1c0o0X1O17ewSiboI3roxvjbms6UoxILFNYis3XmIFb59rCkwVyZfyj5nX
         zdkMs6JRy9EGtrTSYUuQMLiUBRM1roW7LNo1WrJyTINVOnsYATxqnANMPN7xTnzSNbNb
         ph8dWmfgJ0GaHQqiEnKu4X5SfYAGmlim4QJ4MC28pacYrldBXgAdNc2Xvy6ivqo2Azbb
         0AEeW9LCRnG3zwrh02fYcJeqHM8trdpGPHHi93Yo4HB6kLURH1V/QpSuD9YGbmueQPe7
         nF1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=+nFKZw1/3mrTKvNVIsRm9EX9HzlZYfPy7QXIUGdT7eA=;
        b=pJCbgM8BcVyseIUsQ1vRK5LbgS2tK+jTGCT1Mxq5dRMYU5i0kuLX88SZBFFu9nkogl
         CcYhDbeZe+aUhyLhRrUBWMHk59WtNuMfOWdZhr49tQKUjdRLBAUMEixhhSEt2l6bsZIc
         eG/ve8srCHo77Zw+fuDWbzKOMNTuX5pVFnnrpIhrIJlh4d/i79bfd62nqCu3yQ6atq9C
         hoTKSzdDm9Rg0QBAYCHcpXiD+ZEGdU3Y5y5OitpOxBZkHLSZ3BFwdjlOTAVpGkNaQbbS
         7zEjF66j6iWB3UM3XeftLTBHZPyR/fe2pbNC1HJ72TWkD8Q1YPp/fM3wTpSoaviksIwt
         zlgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q43si16200342pjb.30.2019.05.27.02.35.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 02:35:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4R9SG2f123078
	for <linux-mm@kvack.org>; Mon, 27 May 2019 05:35:47 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2srcyq9kk7-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 27 May 2019 05:35:47 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Mon, 27 May 2019 10:35:45 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 27 May 2019 10:35:43 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4R9ZgFG51707976
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 27 May 2019 09:35:42 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AE9E4AE058;
	Mon, 27 May 2019 09:35:42 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C802BAE053;
	Mon, 27 May 2019 09:35:41 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.124.31.115])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Mon, 27 May 2019 09:35:41 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Subject: Re: [PATCH] mm/nvdimm: Use correct alignment when looking at first pfn from a region
In-Reply-To: <925e41ad-cc57-bc03-a2b6-6913c9e98abf@linux.ibm.com>
References: <20190514025512.9670-1-aneesh.kumar@linux.ibm.com> <CAPcyv4hgNUDxjgYNkxOXJ9hfLb6z2+E1yasNoZNDKFUxkCzWLA@mail.gmail.com> <925e41ad-cc57-bc03-a2b6-6913c9e98abf@linux.ibm.com>
Date: Mon, 27 May 2019 15:05:40 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19052709-0020-0000-0000-00000340DB7A
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052709-0021-0000-0000-00002193D197
Message-Id: <87k1ecutn7.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-27_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=888 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905270067
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:

> On 5/14/19 9:59 AM, Dan Williams wrote:
>> On Mon, May 13, 2019 at 7:55 PM Aneesh Kumar K.V
>> <aneesh.kumar@linux.ibm.com> wrote:
>>>
>>> We already add the start_pad to the resource->start but fails to section
>>> align the start. This make sure with altmap we compute the right first
>>> pfn when start_pad is zero and we are doing an align down of start address.
>>>
>>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>>> ---
>>>   kernel/memremap.c | 4 ++--
>>>   1 file changed, 2 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/kernel/memremap.c b/kernel/memremap.c
>>> index a856cb5ff192..23d77b60e728 100644
>>> --- a/kernel/memremap.c
>>> +++ b/kernel/memremap.c
>>> @@ -59,9 +59,9 @@ static unsigned long pfn_first(struct dev_pagemap *pgmap)
>>>   {
>>>          const struct resource *res = &pgmap->res;
>>>          struct vmem_altmap *altmap = &pgmap->altmap;
>>> -       unsigned long pfn;
>>> +       unsigned long pfn = PHYS_PFN(res->start);
>>>
>>> -       pfn = res->start >> PAGE_SHIFT;
>>> +       pfn = SECTION_ALIGN_DOWN(pfn);
>> 
>> This does not seem right to me it breaks the assumptions of where the
>> first expected valid pfn occurs in the passed in range.
>> 
>
> How do we define the first valid pfn? Isn't that at pfn_sb->dataoff ?

for altmap the pfn_first should be

pfn_first = altmap->base_pfn + vmem_altmap_offset(altmap);

?

-aneesh

