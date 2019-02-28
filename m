Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96DBBC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:34:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D7562183F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:34:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D7562183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3BAB8E0005; Thu, 28 Feb 2019 07:34:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EECFF8E0001; Thu, 28 Feb 2019 07:34:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB5FA8E0005; Thu, 28 Feb 2019 07:34:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id ABE288E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 07:34:50 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id f70so15606633qke.8
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:34:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=65plmuKN0t96Ss4lhV8kQ0BWCdKPPdBAOQ9S+BoEA3M=;
        b=QZaYjVtwcpZ3sR0NXWQnFCoE1vjUNzOCIdiPkEbFIk2P2fwH9B3iJac2nl7tV5ocQV
         k++oMVDeW3NMoMYAED/oGQ47y9J+FRFUIlcY2zomfSMBG49LXqx5eXJ0LeZwVNkTMcuP
         DCq8JJ+EKNG4BTvgipYiA9MJmYlu4hBmaOqMu2DTbhhcKZY/l8PCmTOEcJZ5qINa5cMl
         fJAvx5YmJtbf0js3DxhnmqHGA6MD1Ruko1vQM3Rntgr2jWS1104/x5UKDwtGMnIwmdlU
         3Z9NFo6Hb6MgMZAbO4WFs3CU9PsPoSUrv4hP9DreXmNGHrWN6d96lRdQu/D+mg0xyTEQ
         mBvw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVLuJ8kZNy9aoC+1nic3uHsF5TvZ7diG3voeu6jQIQufWkyKT7V
	9T4ufGhw5TRR4VjOYtxKzHKFWUVA9B1Oe5ZR5JWLBCUCuHPRd+y7/0kA14yViv20bnFGNWEzKZK
	ftoeANeXL8v+b8pFV0ihpNj/fxbikf9hcG2RNDNDyB+DSvZ2yiljvpJAznr7W9Wbcug==
X-Received: by 2002:ac8:2d61:: with SMTP id o30mr6120142qta.13.1551357290444;
        Thu, 28 Feb 2019 04:34:50 -0800 (PST)
X-Google-Smtp-Source: APXvYqzPM86hn9gn7CtuQEHmaewLOuWMX0/lqE6Dl5Tjrqtt4/Ge6wLOkaVc3465rEHRrl6UrkSF
X-Received: by 2002:ac8:2d61:: with SMTP id o30mr6120096qta.13.1551357289801;
        Thu, 28 Feb 2019 04:34:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551357289; cv=none;
        d=google.com; s=arc-20160816;
        b=qLI4OZ9Z63YtQYW1PHR9TuioR+4qPcNPnc1jjCBo/VysJB5J4H/2ZVAIacnr00O6+3
         x0PdQTiVsXmS9RlQDVgJekrff5lBO6lDjxlp/bCuty5nbRx9NTduYK/slUSprEovddK2
         wZJeWoVeyHeeF2hhN/BVqiY2iEX8JFyFJe1rdvcsen6xlgPf+t/sGYIXW5ve7p36j+OF
         B0aE69M9IitIsnrqXrSWVxzNQ/JyVe7trpvdRDNMDwu5QR20jPk9+UAjFdxjQA34x6Ou
         IdmA11JR2hpaxmokzZjLoZ5dyplwiL7uBUQpEJAWPNfUvO7dW+GCG32tH9M2DMKYgAl3
         JuVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=65plmuKN0t96Ss4lhV8kQ0BWCdKPPdBAOQ9S+BoEA3M=;
        b=hQijsTu4jA9XbvmxMUPZo5LBGmKi/U6anInFmahm62m82hAGYtqLazaYNYQJxvM/xA
         cd5gnoVQw2ELnWxtklmQNI+HMK8ddkNMQB0sCatiD7NuCL1UEJr34Bc9Ue9+dxLGPLpl
         LzDtbglSQwI7VlEtzkLbMWm9jIi7vWlHXAEt0f2GnaAafx2otloJc5em1QwJWEOtoXTN
         KMgHY5gE1mR7S6MItQIaGT/edlAmKqxlkVDuWSzEEBUqeSbIn+6ke2uh5l35yJRZOWQx
         eiRDkAUT9tMq2wvTjLuJWOkXcNjbr5YUY1flui1G5amzBSf3L4zvhLjLL0QY95njW0b6
         YLjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l27si2480529qvl.89.2019.02.28.04.34.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 04:34:49 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1SCU7wv007308
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 07:34:49 -0500
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qxe7s4njd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 07:34:49 -0500
Received: from localhost
	by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 28 Feb 2019 12:34:48 -0000
Received: from b01cxnp22036.gho.pok.ibm.com (9.57.198.26)
	by e14.ny.us.ibm.com (146.89.104.201) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 28 Feb 2019 12:34:45 -0000
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1SCYi8j23068792
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Feb 2019 12:34:44 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3D531B2066;
	Thu, 28 Feb 2019 12:34:44 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 55412B2065;
	Thu, 28 Feb 2019 12:34:41 +0000 (GMT)
Received: from [9.199.36.171] (unknown [9.199.36.171])
	by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
	Thu, 28 Feb 2019 12:34:40 +0000 (GMT)
Subject: Re: [PATCH 1/2] fs/dax: deposit pagetable even when installing zero
 page
To: Jan Kara <jack@suse.cz>
Cc: akpm@linux-foundation.org,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        mpe@ellerman.id.au, Ross Zwisler <zwisler@kernel.org>,
        "Oliver O'Halloran" <oohall@gmail.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
 <20190228092101.GA22210@quack2.suse.cz>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Thu, 28 Feb 2019 18:04:24 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190228092101.GA22210@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19022812-0052-0000-0000-00000392380D
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00010679; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000281; SDB=6.01167573; UDB=6.00609978; IPR=6.00948186;
 MB=3.00025780; MTD=3.00000008; XFM=3.00000015; UTC=2019-02-28 12:34:47
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022812-0053-0000-0000-00005FFF6498
Message-Id: <5c788802-bbf4-2c12-b126-d9b83eea86d5@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-28_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902280087
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/28/19 2:51 PM, Jan Kara wrote:
> On Thu 28-02-19 14:05:21, Aneesh Kumar K.V wrote:
>> Architectures like ppc64 use the deposited page table to store hardware
>> page table slot information. Make sure we deposit a page table when
>> using zero page at the pmd level for hash.
>>
>> Without this we hit
>>
>> Unable to handle kernel paging request for data at address 0x00000000
>> Faulting instruction address: 0xc000000000082a74
>> Oops: Kernel access of bad area, sig: 11 [#1]
>> ....
>>
>> NIP [c000000000082a74] __hash_page_thp+0x224/0x5b0
>> LR [c0000000000829a4] __hash_page_thp+0x154/0x5b0
>> Call Trace:
>>   hash_page_mm+0x43c/0x740
>>   do_hash_page+0x2c/0x3c
>>   copy_from_iter_flushcache+0xa4/0x4a0
>>   pmem_copy_from_iter+0x2c/0x50 [nd_pmem]
>>   dax_copy_from_iter+0x40/0x70
>>   dax_iomap_actor+0x134/0x360
>>   iomap_apply+0xfc/0x1b0
>>   dax_iomap_rw+0xac/0x130
>>   ext4_file_write_iter+0x254/0x460 [ext4]
>>   __vfs_write+0x120/0x1e0
>>   vfs_write+0xd8/0x220
>>   SyS_write+0x6c/0x110
>>   system_call+0x3c/0x130
>>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> 
> Thanks for the patch. It looks good to me. You can add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> 
>> ---
>> TODO:
>> * Add fixes tag
> 
> Probably this is a problem since initial PPC PMEM support, isn't it?
> 

Considering ppc64 is the only broken architecture here, I guess I will 
use the commit that enabled PPC PMEM support here.

-aneesh

