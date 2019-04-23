Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A3EBC10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 15:46:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34383218CD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 15:46:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34383218CD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B74A16B0008; Tue, 23 Apr 2019 11:46:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B24306B000A; Tue, 23 Apr 2019 11:46:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99ED26B000C; Tue, 23 Apr 2019 11:46:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 753CD6B0008
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:46:10 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id 134so12612376ywl.9
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 08:46:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=4lL7tc7+w06co3+Xg0kSD/WTetZ/hwaJXmCzOUKgtzA=;
        b=idti+W6OWnqVLvkEniuplIvD73VtikJJcTidnDWpme3GcH1YkIKHEyyRJKpSZa6X9w
         xFhK9G5EkOFdXWHoiQKU+AoepThjPvWEl/w4dxtKPoZ3vOyHK+YzVdX6KUqylO1ZYQm7
         h8wFQf47qHaM/fJ1GGYJzmS/S6VLkbQ+1Jg872B+y7F4gn8Pm1rWk9g35gzvUfvy139Y
         P+HK2Uc3lhp9ThBR57TVctAadHmt3hEiRMewwOdhpnGIrw2mif3FVnbhjeZXy5jxEi1N
         v+UQRtKSkQ4TLkxD7rvJd97OKRmF1v8ELa6wgKpFHb2S4wWOCb7K52bIsjgGeIW0MYAx
         oqAg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUwv8S6DGrWHyKWUj4yPYMauC20n4i75UP/XzzQwL5nfzJpsnks
	tTPnQ5lWCZIJVrDvCWiYicgVxAGSxjX61TeXeXyfwIi/Bn4macoVZ3knN/fPHEL+PQLPX+9wBLE
	4Vzo25jDgp4qw3bcOnFxvkExnEYkAH5EUI0CJLdBGIWMHjNKoeYPwxxBv8fSV3RN6hQ==
X-Received: by 2002:a81:7102:: with SMTP id m2mr22749812ywc.361.1556034370144;
        Tue, 23 Apr 2019 08:46:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhIVonhf5Jwk9NK4p4Ejjwty5l+Au1fco8FYSasjMu76EXaTSHkKOmZKtjroTFBEs/RATx
X-Received: by 2002:a81:7102:: with SMTP id m2mr22749748ywc.361.1556034369368;
        Tue, 23 Apr 2019 08:46:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556034369; cv=none;
        d=google.com; s=arc-20160816;
        b=0xSxeQOf+Flu6hlJipnNFkQkdGvUMJVLpSgBxTgIdpH03acUDqR4yDa7TuY7LmZQq5
         nJOt1QJDT32v1PatljmU9iaBuA5tqSPoIvzsSSN9QFbKYWXHTBY+PKneOZ7XUeQ8g04R
         eUCmEC2U/Mk7p3KynucqSAUcRONfaFw9RsWMn7CT+YwwhRacO5p3QYfjYgIE9jfqNMgG
         bpIu8CRTdj3hkRnVwydof61rRql3IpCM6eEP5qX1Ri5edcIXyyFcB8nohlVq0SE/vabH
         r92D1LovTmnkL1d1D7apQITDY9sSpL7D1XwPmNwrmMixw4GTejB1Fx3bTpPgmmdOTJ6U
         pUgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=4lL7tc7+w06co3+Xg0kSD/WTetZ/hwaJXmCzOUKgtzA=;
        b=DkhcZlECTU0pvRAHXNjUm3olTqoxhwkqQyzfhomCiU4HYM87o5VIXmfhqCmwhrdym9
         xiFPJvV8yWFq++rtrMkZDi5xzzbzn3R/Lco0SSE+vqG2juIROzTrSYzTIjKtvV/avYzv
         AAsgAb4tLHnOTmxl/1r8ZxvfeVMZL/yRDFSVf9ey8trHi2SwyiMeKPeThtBgx4sq+SZa
         bk9sS9YWfKvH9rilaubjugvoipC+5B8iyfjFo98FodAI5R0OpdEekf/43YFalKsypjt3
         G/N6mNA5xkV+5ltkCmD01rGWHAlLi+Q2eXR7OQxiK6Qg5B04TvmY1UJMLrXbqHJgG2rs
         kY4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 143si10769023ywk.57.2019.04.23.08.46.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 08:46:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3NFeZhi004291
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:46:08 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2s25da0qee-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:46:08 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 23 Apr 2019 16:46:06 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 23 Apr 2019 16:45:56 +0100
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3NFjsxQ46137354
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 23 Apr 2019 15:45:54 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 591F042041;
	Tue, 23 Apr 2019 15:45:54 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 033D842049;
	Tue, 23 Apr 2019 15:45:52 +0000 (GMT)
Received: from [9.145.7.116] (unknown [9.145.7.116])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 23 Apr 2019 15:45:51 +0000 (GMT)
Subject: Re: [PATCH v12 05/31] mm: prepare for FAULT_FLAG_SPECULATIVE
To: Jerome Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
        kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
        jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
        aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
        mpe@ellerman.id.au, paulus@samba.org,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        hpa@zytor.com, Will Deacon <will.deacon@arm.com>,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        sergey.senozhatsky.work@gmail.com,
        Andrea Arcangeli <aarcange@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
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
 <20190416134522.17540-6-ldufour@linux.ibm.com>
 <20190418220415.GE11645@redhat.com>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Tue, 23 Apr 2019 17:45:51 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190418220415.GE11645@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19042315-0020-0000-0000-00000332DF37
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042315-0021-0000-0000-0000218540CC
Message-Id: <8b102fee-e1bc-28e4-2187-994e39fb6734@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-23_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904230106
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 19/04/2019 à 00:04, Jerome Glisse a écrit :
> On Tue, Apr 16, 2019 at 03:44:56PM +0200, Laurent Dufour wrote:
>> From: Peter Zijlstra <peterz@infradead.org>
>>
>> When speculating faults (without holding mmap_sem) we need to validate
>> that the vma against which we loaded pages is still valid when we're
>> ready to install the new PTE.
>>
>> Therefore, replace the pte_offset_map_lock() calls that (re)take the
>> PTL with pte_map_lock() which can fail in case we find the VMA changed
>> since we started the fault.
>>
>> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
>>
>> [Port to 4.12 kernel]
>> [Remove the comment about the fault_env structure which has been
>>   implemented as the vm_fault structure in the kernel]
>> [move pte_map_lock()'s definition upper in the file]
>> [move the define of FAULT_FLAG_SPECULATIVE later in the series]
>> [review error path in do_swap_page(), do_anonymous_page() and
>>   wp_page_copy()]
>> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> 
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> 
>> ---
>>   mm/memory.c | 87 +++++++++++++++++++++++++++++++++++------------------
>>   1 file changed, 58 insertions(+), 29 deletions(-)
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index c6ddadd9d2b7..fc3698d13cb5 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2073,6 +2073,13 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
>>   }
>>   EXPORT_SYMBOL_GPL(apply_to_page_range);
>>   
>> +static inline bool pte_map_lock(struct vm_fault *vmf)
> 
> I am not fan of the name maybe pte_offset_map_lock_if_valid() ? But
> that just a taste thing. So feel free to ignore this comment.

I agree with you that adding _if_valid or something equivalent to 
highlight the conditional of this function would be a good idea.

I'll think further about that name but yours looks good ;)


>> +{
>> +	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
>> +				       vmf->address, &vmf->ptl);
>> +	return true;
>> +}
>> +
>>   /*
>>    * handle_pte_fault chooses page fault handler according to an entry which was
>>    * read non-atomically.  Before making any commitment, on those architectures
> 

