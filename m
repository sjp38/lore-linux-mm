Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DC8DC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:34:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D6A8218B0
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:34:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D6A8218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B80CB6B0007; Wed, 24 Apr 2019 06:34:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B300F6B0008; Wed, 24 Apr 2019 06:34:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F8326B000A; Wed, 24 Apr 2019 06:34:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7E4E86B0007
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:34:53 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id c14so14300909ybf.23
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:34:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=gG2FIKQYX9k5IzTgrIwun0PAUiaZI8rLEdLHDdeKShg=;
        b=mk9jU81bn38N1STjMKFqCsDyoLwayHo0n+VUXXBAhwrPoMYoy9aICtJy4QxheoMqNC
         7ks9XA1sFcpbaPf2ow2eCPliyHdTK92PZM2/TFd5/Sf1MNbYcOaxBdSf753D97zzx47Y
         BpdlStfNos8YeeCrdhB/V8tiyRov8Kg8+zWJRdKN6BNN+9KF5D5Mn1IrhFnEt80o/mAP
         /JVNCMgkzb68tu5LcApwM376+jJg+NIzp7J+2udpPD8X24uelOQ7/sKvqu1yzig1eTjc
         ZC3+IJsvCoaMdESS+zEBjU/TeSBq+VOmH1mxq6YQv2rx3S/wx3aM9JU8QHUZANmRx+Yd
         yPNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW34LuRQZWt/h+fr2VKd4uEkYGHHM8ZcVQmhOf4uoVgR+ChhA4M
	RwRvw5KUoqNSTFc9WA7zuBthR2bVLJIYQQ7EfV85dPNpmntAB5T6Nsl/hq6FvEM6DxaNbcRnTZO
	WSo1s3WF9Kw28wodZXq6NqwpQTrCLTcPR8SL/8EsiX0N/Knrai/WApPccCgXyx1FbDQ==
X-Received: by 2002:a81:a0c2:: with SMTP id x185mr25803692ywg.155.1556102093144;
        Wed, 24 Apr 2019 03:34:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/Hwd28v/VfBWIcNPWfBDOcR41qBPJH20vGdGGw5anWB1Osf15OJ52yI2/I3xuG6G9hFVR
X-Received: by 2002:a81:a0c2:: with SMTP id x185mr25803624ywg.155.1556102092162;
        Wed, 24 Apr 2019 03:34:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556102092; cv=none;
        d=google.com; s=arc-20160816;
        b=0cdSUNo21Z0h0TUic0CTzPJA8k+3I/gH/tNEwEq+I+o3tAWge03/hGho2vgnHDjwkK
         I/aTmG26zzqKAqOR+9m3r5br8fVqcpMXwMflBE4JwHergUPsjHCF9Kse07Mmhim3vFgc
         V3bqKGFnK6xeFnXDti5sgr0UZ2ZlDs40T2AnKGM/7/8b7hqhCUmm/rjobowrOxyBSPns
         cQd/ascAXkFRlOdnYD7LCvVPfwNBySe9Ht3riptfzU/JvHsvD7Mwa0DsfvlqRdXnHj93
         /yV2TeSzInl7pe6f6irJM+R7Am6doy4/Qw1kac2ffBJWR0YJ8ZDn24w7esdMGYh9Ow4B
         haEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=gG2FIKQYX9k5IzTgrIwun0PAUiaZI8rLEdLHDdeKShg=;
        b=qukEGs3ZbOWW0kKtjGoOjSEdQocwKNUlHKf6TruSwdHhMiIGWFtqqML4mGisBJjj9r
         cYVg95reAnU5Q+rqt2CFQpjIbVCx08oRfcHRpumXkfDUwdqVlrPfcC29jJY5ZZHbiCjz
         osvzhj+3jSae9hYLjoExnru77u4GIVvPzSF7WDC9V2gl2EkVypzk43dY+DKBRicGZcNh
         8QWgZEzjd89cPHMzFj7qi161bh0vxj29hy0prQQrixGJ0cVgmr+QHbFo14gjp2WihoNz
         Bf3hyzeAxrAwTeRb4SVHtgYqm5AymibVuvaXxALWPsq4MsDoAuGJg2vf8Esj2j7htOYC
         cKfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i7si11870111ybp.56.2019.04.24.03.34.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 03:34:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3OAXdIt114630
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:34:52 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2s2k57j1f9-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:34:51 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Wed, 24 Apr 2019 11:34:48 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 24 Apr 2019 11:34:39 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3OAYbhp60227612
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Apr 2019 10:34:37 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8B5EFA405D;
	Wed, 24 Apr 2019 10:34:37 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D6834A404D;
	Wed, 24 Apr 2019 10:34:34 +0000 (GMT)
Received: from [9.145.184.124] (unknown [9.145.184.124])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 24 Apr 2019 10:34:34 +0000 (GMT)
Subject: Re: [PATCH v12 04/31] arm64/mm: define
 ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
To: Mark Rutland <mark.rutland@arm.com>
Cc: Jerome Glisse <jglisse@redhat.com>, akpm@linux-foundation.org,
        mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name,
        ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz,
        Matthew Wilcox <willy@infradead.org>, aneesh.kumar@linux.ibm.com,
        benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        hpa@zytor.com, Will Deacon <will.deacon@arm.com>,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        sergey.senozhatsky.work@gmail.com,
        Andrea Arcangeli <aarcange@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com,
        Daniel Jordan <daniel.m.jordan@oracle.com>,
        David Rientjes <rientjes@google.com>,
        Ganesh Mahendran <opensource.ganesh@gmail.com>,
        Minchan Kim <minchan@kernel.org>,
        Punit Agrawal <punitagrawal@gmail.com>,
        vinayak menon <vinayakm.list@gmail.com>,
        Yang Shi <yang.shi@linux.alibaba.com>,
        zhong jiang <zhongjiang@huawei.com>,
        Haiyan Song <haiyanx.song@intel.com>,
        Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
        Michel Lespinasse <walken@google.com>,
        Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
        paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
        linuxppc-dev@lists.ozlabs.org, x86@kernel.org
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-5-ldufour@linux.ibm.com>
 <20190416142710.GA54515@lakrids.cambridge.arm.com>
 <4ef9ff4b-2230-0644-2254-c1de22d41e6c@linux.ibm.com>
 <20190416144156.GB54708@lakrids.cambridge.arm.com>
 <20190418215113.GD11645@redhat.com>
 <73a3650d-7e9f-bc9e-6ea1-2cef36411b0c@linux.ibm.com>
 <20190423161931.GE56999@lakrids.cambridge.arm.com>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Wed, 24 Apr 2019 12:34:34 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190423161931.GE56999@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19042410-0016-0000-0000-00000272F61E
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042410-0017-0000-0000-000032CF66F9
Message-Id: <e270e50f-8afe-9007-1759-f576aa4c08c9@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-24_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904240088
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 23/04/2019 à 18:19, Mark Rutland a écrit :
> On Tue, Apr 23, 2019 at 05:36:31PM +0200, Laurent Dufour wrote:
>> Le 18/04/2019 à 23:51, Jerome Glisse a écrit :
>>> On Tue, Apr 16, 2019 at 03:41:56PM +0100, Mark Rutland wrote:
>>>> On Tue, Apr 16, 2019 at 04:31:27PM +0200, Laurent Dufour wrote:
>>>>> Le 16/04/2019 à 16:27, Mark Rutland a écrit :
>>>>>> On Tue, Apr 16, 2019 at 03:44:55PM +0200, Laurent Dufour wrote:
>>>>>>> From: Mahendran Ganesh <opensource.ganesh@gmail.com>
>>>>>>>
>>>>>>> Set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT for arm64. This
>>>>>>> enables Speculative Page Fault handler.
>>>>>>>
>>>>>>> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
>>>>>>
>>>>>> This is missing your S-o-B.
>>>>>
>>>>> You're right, I missed that...
>>>>>
>>>>>> The first patch noted that the ARCH_SUPPORTS_* option was there because
>>>>>> the arch code had to make an explicit call to try to handle the fault
>>>>>> speculatively, but that isn't addeed until patch 30.
>>>>>>
>>>>>> Why is this separate from that code?
>>>>>
>>>>> Andrew was recommended this a long time ago for bisection purpose. This
>>>>> allows to build the code with CONFIG_SPECULATIVE_PAGE_FAULT before the code
>>>>> that trigger the spf handler is added to the per architecture's code.
>>>>
>>>> Ok. I think it would be worth noting that in the commit message, to
>>>> avoid anyone else asking the same question. :)
>>>
>>> Should have read this thread before looking at x86 and ppc :)
>>>
>>> In any case the patch is:
>>>
>>> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
>>
>> Thanks Mark and Jérôme for reviewing this.
>>
>> Regarding the change in the commit message, I'm wondering if this would be
>> better to place it in the Series's letter head.
>>
>> But I'm fine to put it in each architecture's commit.
> 
> I think noting it in both the cover letter and specific patches is best.
> 
> Having something in the commit message means that the intent will be
> clear when the patch is viewed in isolation (e.g. as they will be once
> merged).
> 
> All that's necessary is something like:
> 
>    Note that this patch only enables building the common speculative page
>    fault code such that this can be bisected, and has no functional
>    impact. The architecture-specific code to make use of this and enable
>    the feature will be addded in a subsequent patch.

Thanks Mark, will do it this way.


> Thanks,
> Mark.

