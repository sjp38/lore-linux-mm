Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04051C04A6B
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 04:05:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C16DA2086A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 04:05:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C16DA2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5785A6B0005; Tue, 14 May 2019 00:05:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 529F06B0007; Tue, 14 May 2019 00:05:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F2796B0008; Tue, 14 May 2019 00:05:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 209E56B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 00:05:30 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id v191so23636325ywc.11
        for <linux-mm@kvack.org>; Mon, 13 May 2019 21:05:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=ukPV/+JTDZCXpcDbaMh08o5HG+V8ZwcMTXq3eIcJi/E=;
        b=gZuPGN7QLDPDO6qEBHYioOc17hWBve3IcKzXvSU8lUFjt7gUNHfuaNwlX+CP05Y8yM
         f8ASUvQnrW1EYIwHtq0sWUqzxSQKtbHSgvCD2It6gw66nQIYaQU5aVZtBm2cwR2stuc5
         iP//L1DoIuE6a6QbIdV/RTj5zvKtQM6fvAage153Sa8J40UI692UZ1wsHesfTuRpWik/
         mfRzxPATZWy6bmmrEshK/CwKmyMC9tYjVye12E8AseLlbYDb8M0BR8MXAeIOj9XpxFDb
         nmegsUkQtvRiVRbMVeQHqHdX5qnnULWsq8GieMJtLT0Z4JZXLEjqcogb1pxPO+bbTv3Z
         /GAg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVvDJqITGlOxBhgz3AoCjPxnsRNsfR2Iif7nGzOhK2n+Odd6lTN
	LcyLv59G7jibDThB5MzYFMBhlQn8RpeB1eiXypJ309QkBSeQoYg02/nxMXG92Mk0HRPz7MZYrnA
	QR5S+QVkHe0JlymQHMSOGqZW5ecmn9bcw94xRS426nCF3+Uf1MjnJipqZinjMWeCfqQ==
X-Received: by 2002:a25:d08e:: with SMTP id h136mr14541189ybg.316.1557806729869;
        Mon, 13 May 2019 21:05:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvccfUNtiGUbvTQRQ2XaXJmhpFpzjbDoCUD/AVRYcOjwoox7xA2Sy5qrEGt4rFhAEq/SaA
X-Received: by 2002:a25:d08e:: with SMTP id h136mr14541172ybg.316.1557806729156;
        Mon, 13 May 2019 21:05:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557806729; cv=none;
        d=google.com; s=arc-20160816;
        b=Vbe+kjK4UTLC3J/xn50jzeIPUMjZx4KRiiKJhCaFenrjGLHUPwAaenN6JxXjdXdYVq
         aIUFyC0zO/y4iRz/t0862E+tGNItQK1RfjJHh/YuIRTO7+a/E4lA5eZ72BedQ/tC7prw
         gED4SrH/UX/l0AABIXGXR4Z3ChbESmcvADkseCjge5dE3FS7EdCFZzrOCIZT4lpBIkOn
         CM12LfTOyk0GytMG44wd+DczkwVSgh0BsITsDAmhfAYmZNy3ikb2kcZ9UK4X9XbimF+R
         sMOGoPCJtDeax1dMsgHKCIoHuJKs0FR0wjt8uXfRj3iaEt1JvYB1HIX3dwLVUWWC6lty
         qvMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=ukPV/+JTDZCXpcDbaMh08o5HG+V8ZwcMTXq3eIcJi/E=;
        b=lzHHeAyUNboJx6Huab+zS2QJeVqxf59uWIZk408YUms6HRqtOUo9//g54LGTg8qVXb
         vbfDH1IhvEoPrlXdczTgc314QzoN7JKanwKNlI/ijwP14geTGd5ZuvYpJP5gKTBuIIhr
         Nre/3QbP+mKiq/JgY8pPZvxxH4fOxrI7MmpWlcm0s1CMrp0yR5QhUJq+2NbT3DIN2cju
         jccGvojNEBIb12QaUJYQb87NWjSZv+UwE2PhWvsE4qDma2XelSlJs+FoSJLlpBYnX8pi
         8KfZvVGsvMdulWdnPJdmagebdmN9OZ5g90UQ3j4js09xWCyxJhWuvy7oKtOqzW2iq3Hr
         jC4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d7si4463074ybb.464.2019.05.13.21.05.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 21:05:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4E42ar7058963
	for <linux-mm@kvack.org>; Tue, 14 May 2019 00:05:28 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2sfhn2ryqc-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 May 2019 00:05:28 -0400
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 14 May 2019 05:05:28 +0100
Received: from b01cxnp23034.gho.pok.ibm.com (9.57.198.29)
	by e11.ny.us.ibm.com (146.89.104.198) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 14 May 2019 05:05:25 +0100
Received: from b01ledav004.gho.pok.ibm.com (b01ledav004.gho.pok.ibm.com [9.57.199.109])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4E45OZ633161672
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 04:05:24 GMT
Received: from b01ledav004.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3797211206B;
	Tue, 14 May 2019 04:05:24 +0000 (GMT)
Received: from b01ledav004.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 22F6811206E;
	Tue, 14 May 2019 04:05:23 +0000 (GMT)
Received: from [9.80.221.111] (unknown [9.80.221.111])
	by b01ledav004.gho.pok.ibm.com (Postfix) with ESMTP;
	Tue, 14 May 2019 04:05:22 +0000 (GMT)
Subject: Re: [PATCH] mm/nvdimm: Use correct #defines instead of opencoding
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
References: <20190514025604.9997-1-aneesh.kumar@linux.ibm.com>
 <CAPcyv4iNgFbSq0Hqb+CStRhGWMHfXx7tL3vrDaQ95DcBBY8QCQ@mail.gmail.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Tue, 14 May 2019 09:35:21 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4iNgFbSq0Hqb+CStRhGWMHfXx7tL3vrDaQ95DcBBY8QCQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19051404-2213-0000-0000-0000038D6545
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011095; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000285; SDB=6.01203018; UDB=6.00631432; IPR=6.00983938;
 MB=3.00026877; MTD=3.00000008; XFM=3.00000015; UTC=2019-05-14 04:05:27
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19051404-2214-0000-0000-00005E6D0FF7
Message-Id: <f99c4f11-a43d-c2d3-ab4f-b7072d090351@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-14_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905140027
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/14/19 9:28 AM, Dan Williams wrote:
> On Mon, May 13, 2019 at 7:56 PM Aneesh Kumar K.V
> <aneesh.kumar@linux.ibm.com> wrote:
>>
>> The nfpn related change is needed to fix the kernel message
>>
>> "number of pfns truncated from 2617344 to 163584"
>>
>> The change makes sure the nfpns stored in the superblock is right value.
>>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>> ---
>>   drivers/nvdimm/pfn_devs.c    | 6 +++---
>>   drivers/nvdimm/region_devs.c | 8 ++++----
>>   2 files changed, 7 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
>> index 347cab166376..6751ff0296ef 100644
>> --- a/drivers/nvdimm/pfn_devs.c
>> +++ b/drivers/nvdimm/pfn_devs.c
>> @@ -777,8 +777,8 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
>>                   * when populating the vmemmap. This *should* be equal to
>>                   * PMD_SIZE for most architectures.
>>                   */
>> -               offset = ALIGN(start + reserve + 64 * npfns,
>> -                               max(nd_pfn->align, PMD_SIZE)) - start;
>> +               offset = ALIGN(start + reserve + sizeof(struct page) * npfns,
>> +                              max(nd_pfn->align, PMD_SIZE)) - start;
> 
> No, I think we need to record the page-size into the superblock format
> otherwise this breaks in debug builds where the struct-page size is
> extended.
> 
>>          } else if (nd_pfn->mode == PFN_MODE_RAM)
>>                  offset = ALIGN(start + reserve, nd_pfn->align) - start;
>>          else
>> @@ -790,7 +790,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
>>                  return -ENXIO;
>>          }
>>
>> -       npfns = (size - offset - start_pad - end_trunc) / SZ_4K;
>> +       npfns = (size - offset - start_pad - end_trunc) / PAGE_SIZE;
> 
> Similar comment, if the page size is variable then the superblock
> needs to explicitly account for it.
> 

PAGE_SIZE is not really variable. What we can run into is the issue you 
mentioned above. The size of struct page can change which means the 
reserved space for keeping vmemmap in device may not be sufficient for 
certain kernel builds.

I was planning to add another patch that fails namespace init if we 
don't have enough space to keep the struct page.

Why do you suggest we need to have PAGE_SIZE as part of pfn superblock?

-aneesh

