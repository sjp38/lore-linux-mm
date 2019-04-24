Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1A67C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:58:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C3E8218FE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:58:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C3E8218FE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2568F6B026B; Wed, 24 Apr 2019 10:58:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 205B46B026C; Wed, 24 Apr 2019 10:58:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D02B6B026F; Wed, 24 Apr 2019 10:58:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id E0E486B026B
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:58:09 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id q9so14849007ybg.21
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:58:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=07Cjx3cieQP3l+hjfEc02SojppRkBH+/LVgNb1xZDQ8=;
        b=BWmOhwY3ygzbM+o510NvA+TLhAS96Xvw+yMff4KvdpGKZ8z4UEoLN6iQrgxEqhgT0Q
         4mYMCKSEwPEOhS05Mqm0/cgXkZmLW8Y2/Cjlg2kqz1g6eAzQJGeTfwojrVCp7Ek+SIbw
         4omMlPewQjIFlJP4mNo7tV/2RpNpTXqUmrcGSI54ULr+OWl5C24/cs5Ob6NHfEAkIf8f
         ISXJLi/5nr2l26vTvOo1U1tMrXXHJjRx9m9ZIbzpp2pMuXQMHVadUoJTAFjOYcYteZIE
         huRZ9U7MJCUPc/bLicxS9YJbS+7vveAuImiQHcIlimMHlE+lel9w6d7JBlWhy50TMVMW
         YMTQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXzUw3nVKdzaOKSgFqoyLVPTPRYJzn4l7leBeGQqZ8Cg78ZaMYL
	1u5mdjnX5aqcos64n9IS1aYSih1txEI2VopSs5HUAq/3/9+NK8DHqtTJM0XlfZtGZz3oKr4A4PB
	DTqv/L8pjvWRLUtvSjKFAdw8/53X4By86V1+ERaSHbE7PHSfi0Otx3imYsv1VYuWaPQ==
X-Received: by 2002:a81:480d:: with SMTP id v13mr12299549ywa.489.1556117889656;
        Wed, 24 Apr 2019 07:58:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypHNnOJEw+s/ZjiBmsSePX4rq6xpHTWydr900lcnZ8HKXUHRRlxRbKKBLZHByIXtWsd7F8
X-Received: by 2002:a81:480d:: with SMTP id v13mr12299484ywa.489.1556117888837;
        Wed, 24 Apr 2019 07:58:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556117888; cv=none;
        d=google.com; s=arc-20160816;
        b=xnCbgTXNQwcR0wL9R4yq/7jtVxQbFoPPpXBUgbSucy4Fnk8T7ePfsnH/j2qpZu4tqc
         yCH3ezB+eu15K59SxEyVrXpdbtUrMR8QcXtpvRiB+bSOBdiUcavEscCAq+SQz6qqXD0i
         FmIobXVV1/DQqKL5PDoOpfNXsihaeNtxkC4j2THfyAYa1OgnbBNgr4qN5NrJvmqOJk6e
         LbeXiV18A5rAjZQDUtsUXCq1HaGa2jMG5QNWpWGw0Dn802Zrxcw089wqtcewflfczWHv
         nrPmo/zHc8egwNcVlVUCASsg5JhInI5L1KcHDU2uNZysTJJvzBj9g4Fa7bazIjDLQXrA
         2m+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=07Cjx3cieQP3l+hjfEc02SojppRkBH+/LVgNb1xZDQ8=;
        b=yDzFxTodsCfb//ylpVEoSLFkVl7ip1hy9o9Dv00pQBHT0P1JoDG33vBoyBkJHtsGp1
         +DBwYmrv30xu4K3o4NXlj9jPLSaqAEon0F+T0mjnGo0261ZdTLnMb22Dz1l0f6okt6C0
         Lfu5vKJwMr0rFiB+9u9M8BXcm/SzsmvOlc1LHMAoj8eo5Gwb0ynjPlhJH0OCMq6Gg/HX
         KzDrtCw4AcoGiLLlRKr+0Y6jtvSaEcdWWsea3RohklAoNv61/IKyu5V4ZbeQELbWSNC2
         4tpfohjXSSFPwaIQj568JUYz7DD5zPiTYFZWGPPR9CoCSLYLsUZ9PwoHe/p1LMrpn1tG
         eZzw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 83si3416766ybp.376.2019.04.24.07.58.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 07:58:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3OEsbdH029790
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:58:08 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s2rc7nxud-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:58:07 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Wed, 24 Apr 2019 15:58:04 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 24 Apr 2019 15:57:55 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3OEvrA663176882
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Apr 2019 14:57:53 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6642AAE04D;
	Wed, 24 Apr 2019 14:57:53 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 93EFBAE051;
	Wed, 24 Apr 2019 14:57:50 +0000 (GMT)
Received: from [9.145.176.48] (unknown [9.145.176.48])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 24 Apr 2019 14:57:50 +0000 (GMT)
Subject: Re: [PATCH v12 23/31] mm: don't do swap readahead during speculative
 page fault
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
        linuxppc-dev@lists.ozlabs.org, x86@kernel.org,
        Vinayak Menon <vinmenon@codeaurora.org>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-24-ldufour@linux.ibm.com>
 <20190422213611.GN14666@redhat.com>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Wed, 24 Apr 2019 16:57:50 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190422213611.GN14666@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19042414-0016-0000-0000-000002732720
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042414-0017-0000-0000-000032CF99CC
Message-Id: <42ba3103-cbac-199f-e6f1-0fbc12aaccc8@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-24_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904240116
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 22/04/2019 à 23:36, Jerome Glisse a écrit :
> On Tue, Apr 16, 2019 at 03:45:14PM +0200, Laurent Dufour wrote:
>> Vinayak Menon faced a panic because one thread was page faulting a page in
>> swap, while another one was mprotecting a part of the VMA leading to a VMA
>> split.
>> This raise a panic in swap_vma_readahead() because the VMA's boundaries
>> were not more matching the faulting address.
>>
>> To avoid this, if the page is not found in the swap, the speculative page
>> fault is aborted to retry a regular page fault.
>>
>> Reported-by: Vinayak Menon <vinmenon@codeaurora.org>
>> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> 
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> 
> Note that you should also skip non swap entry in do_swap_page() when doing
> speculative page fault at very least you need to is_device_private_entry()
> case.
> 
> But this should either be part of patch 22 or another patch to fix swap
> case.

Thanks Jérôme,

Yes I missed that, I guess the best option would be to abort on non swap 
entry. I'll add that in the patch 22.

>> ---
>>   mm/memory.c | 11 +++++++++++
>>   1 file changed, 11 insertions(+)
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 6e6bf61c0e5c..1991da97e2db 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2900,6 +2900,17 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
>>   				lru_cache_add_anon(page);
>>   				swap_readpage(page, true);
>>   			}
>> +		} else if (vmf->flags & FAULT_FLAG_SPECULATIVE) {
>> +			/*
>> +			 * Don't try readahead during a speculative page fault
>> +			 * as the VMA's boundaries may change in our back.
>> +			 * If the page is not in the swap cache and synchronous
>> +			 * read is disabled, fall back to the regular page
>> +			 * fault mechanism.
>> +			 */
>> +			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
>> +			ret = VM_FAULT_RETRY;
>> +			goto out;
>>   		} else {
>>   			page = swapin_readahead(entry, GFP_HIGHUSER_MOVABLE,
>>   						vmf);
>> -- 
>> 2.21.0
>>
> 

