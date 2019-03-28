Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFEE6C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 03:18:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BDF5206C0
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 03:18:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BDF5206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABCDD6B0003; Wed, 27 Mar 2019 23:18:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A45BE6B0006; Wed, 27 Mar 2019 23:18:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BDB66B0007; Wed, 27 Mar 2019 23:18:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4ECCC6B0003
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 23:18:45 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i23so15551118pfa.0
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 20:18:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=IFDaOgeGE7XvfaKGh0CJsDo+W9/+pFoknBe8xYfXKsw=;
        b=sh2/pfH3j/soWTlYpWo2NKojGXCs/dZIqMJPdWVKlmN/H/TI4kJS3zwwAiIvIlHKYD
         fvKFspfefRsuHS+YwYwQCQkT58jGJtHCBuBzDKSP6CEkvciEVrfwTYTesOx8liJPyw7i
         XbEZy5URj8ZfMemOGLSCFFTLOQFAbQy1jSNA1S2K0hJOYTHipIyjtPqV/NfK0We24yrD
         8QkTtqX95W/AdyTXNPxi3juhkc+aX60BVwP1Eh6r/l0nL8LdQwDIgV49Ltm0znq4xBg+
         3meU56+plOjYycHepbfJ+VDAfnDtZy0Oh742piQAMnKntI7Pyk6rz9bCyEolxvGshgtr
         hCCA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAU3LQyVlL+SyTW0Gy2jRXfqqVnRIeHxo0Rz1vAa01Hxfcur35K/
	MB00QIqMBt7hdOIp/sAGAC4gG5aP8XLM9AqnPhGvXhaV/i5J9Gj9QtNC7RPfspNYDFS55qa1Mm5
	imZm7mDuNRjpUDh9XPGmgAZV9aIBpkbaSUI/dRG3jzi+Hmg3AuSXXApwBiM5lLEgNlg==
X-Received: by 2002:a65:64d5:: with SMTP id t21mr36960102pgv.266.1553743124933;
        Wed, 27 Mar 2019 20:18:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweUHnrO6qTLQHlTnneN9XxnmPyvPD+LPT35fVLDKCmDgKkxfhPNyMzThzMsf4JbxAR6Z+X
X-Received: by 2002:a65:64d5:: with SMTP id t21mr36960045pgv.266.1553743124065;
        Wed, 27 Mar 2019 20:18:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553743124; cv=none;
        d=google.com; s=arc-20160816;
        b=bbX5izMxi0hdOfk9ks6CPVghEaas8OxIcyGmQhlRCaRznHLbKyMxhS3Ei+4EMqou7L
         SVyBqvmstO5SsR0L6C7beb91cNZ7eBqKgJYNpntGtECr9Xgu3z0GCPRi1emJDi1CLr+y
         3ygxfUwpA5sFiHG9ZoxqJ7irmK/PLmhd7NQq5J97ilcRs3yGCa8tF3RA5DD9XmRQhPdu
         +1ZnEzWDLhrmx0FBbEz6x/JlndtCfW39IWasv0MpKkIkztSqfuuyF93m729hiocPccKH
         6rrJzVEmSSeoKeZu+IFwL3UIQZP76z/swyPBLRVd1C8N4bkN0ZKxsWUhmBwc2PLVt8ZP
         55rQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=IFDaOgeGE7XvfaKGh0CJsDo+W9/+pFoknBe8xYfXKsw=;
        b=OMhptD1xrb/GciWrCjApP9G0s81Sv7K4KKuJqPIoXqsfwsweApnqiyHK6u5n53QK3v
         lPCO4rnAgzdLDoh9ObBhYBP9tlAthxQ4QxNetSo3qoPubygDijBtbN1FLk5l1Jr4FpsQ
         56pZvzdcAJYBS7LkJZs7zC5OetA14iXDJrHiiz+twawk+TBedx1UOEzErkUGERRnLkxn
         EBjoQW5UOVOchiaPrW7aEAvGNYKv1qZ6vOJgXBA/lZ2ujSGy+cRyauhOttqh2MyVelLI
         IP74pBbV8epWw+5EYzat40dKSM8Uay1i1tPWa52uV3BJKltZBPbD6KfltCcLRL1DVcyP
         ND1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i13si12704458pgs.33.2019.03.27.20.18.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 20:18:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2S2xAqd077455
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 23:18:43 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rgkxymya1-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 23:18:42 -0400
Received: from localhost
	by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 28 Mar 2019 03:18:41 -0000
Received: from b01cxnp23033.gho.pok.ibm.com (9.57.198.28)
	by e16.ny.us.ibm.com (146.89.104.203) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 28 Mar 2019 03:18:38 -0000
Received: from b01ledav006.gho.pok.ibm.com (b01ledav006.gho.pok.ibm.com [9.57.199.111])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2S3IbnJ24772810
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 03:18:37 GMT
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 41BC7AC064;
	Thu, 28 Mar 2019 03:18:37 +0000 (GMT)
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 84E86AC05F;
	Thu, 28 Mar 2019 03:18:35 +0000 (GMT)
Received: from [9.85.72.169] (unknown [9.85.72.169])
	by b01ledav006.gho.pok.ibm.com (Postfix) with ESMTP;
	Thu, 28 Mar 2019 03:18:35 +0000 (GMT)
Subject: Re: [PATCH] mm: Fix modifying of page protection by insert_pfn()
To: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>
Cc: Linux MM <linux-mm@kvack.org>, Chandan Rajendra <chandan@linux.ibm.com>,
        stable <stable@vger.kernel.org>,
        Dan Williams <dan.j.williams@intel.com>
References: <20190311084537.16029-1-jack@suse.cz>
 <CAPcyv4gBhTXs3Lf1ESgtaT4JUV8xiwNnM_OQU3-0ENB0hpAPng@mail.gmail.com>
 <20190327173332.GA15475@quack2.suse.cz>
 <20190327141414.ad663db479afa8694ed270c6@linux-foundation.org>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Thu, 28 Mar 2019 08:48:19 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190327141414.ad663db479afa8694ed270c6@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19032803-0072-0000-0000-000004116E16
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010827; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000282; SDB=6.01180691; UDB=6.00617909; IPR=6.00961410;
 MB=3.00026187; MTD=3.00000008; XFM=3.00000015; UTC=2019-03-28 03:18:40
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032803-0073-0000-0000-00004BA0AF87
Message-Id: <bd44db17-b28e-a0ce-03c6-14a90f3a8850@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-28_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903280021
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/28/19 2:44 AM, Andrew Morton wrote:
> On Wed, 27 Mar 2019 18:33:32 +0100 Jan Kara <jack@suse.cz> wrote:
> 
>> On Mon 11-03-19 10:22:44, Dan Williams wrote:
>>> On Mon, Mar 11, 2019 at 1:45 AM Jan Kara <jack@suse.cz> wrote:
>>>>
>>>> Aneesh has reported that PPC triggers the following warning when
>>>> excercising DAX code:
>>>>
>>>> [c00000000007610c] set_pte_at+0x3c/0x190
>>>> LR [c000000000378628] insert_pfn+0x208/0x280
>>>> Call Trace:
>>>> [c0000002125df980] [8000000000000104] 0x8000000000000104 (unreliable)
>>>> [c0000002125df9c0] [c000000000378488] insert_pfn+0x68/0x280
>>>> [c0000002125dfa30] [c0000000004a5494] dax_iomap_pte_fault.isra.7+0x734/0xa40
>>>> [c0000002125dfb50] [c000000000627250] __xfs_filemap_fault+0x280/0x2d0
>>>> [c0000002125dfbb0] [c000000000373abc] do_wp_page+0x48c/0xa40
>>>> [c0000002125dfc00] [c000000000379170] __handle_mm_fault+0x8d0/0x1fd0
>>>> [c0000002125dfd00] [c00000000037a9b0] handle_mm_fault+0x140/0x250
>>>> [c0000002125dfd40] [c000000000074bb0] __do_page_fault+0x300/0xd60
>>>> [c0000002125dfe20] [c00000000000acf4] handle_page_fault+0x18
>>>>
>>>> Now that is WARN_ON in set_pte_at which is
>>>>
>>>>          VM_WARN_ON(pte_hw_valid(*ptep) && !pte_protnone(*ptep));
>>>>
>>>> The problem is that on some architectures set_pte_at() cannot cope with
>>>> a situation where there is already some (different) valid entry present.
>>>>
>>>> Use ptep_set_access_flags() instead to modify the pfn which is built to
>>>> deal with modifying existing PTE.
>>>>
>>>> CC: stable@vger.kernel.org
>>>> Fixes: b2770da64254 "mm: add vm_insert_mixed_mkwrite()"
>>>> Reported-by: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
>>>> Signed-off-by: Jan Kara <jack@suse.cz>
>>>
>>> Acked-by: Dan Williams <dan.j.williams@intel.com>
>>>
>>> Andrew, can you pick this up?
>>
>> Andrew, ping?
> 
> I merged this a couple of weeks ago and it's in the queue for 5.1.
> 

I noticed that we need similar change for pmd and pud updates. I will 
send a patch for that.

-aneesh

