Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B469C282E1
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 15:22:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47769206BA
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 15:22:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47769206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C231A6B0003; Tue, 23 Apr 2019 11:22:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD32C6B0005; Tue, 23 Apr 2019 11:22:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A99BB6B0007; Tue, 23 Apr 2019 11:22:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 57CEE6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:22:06 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id q17so8151617eda.13
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 08:22:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=1Hq9GDwpavLHPlAi4sgV7BnTVf/FARNXWXz3UrUgYK4=;
        b=GAXSgSjngOQ6fUocXaXRN5zGTf2GtTy7wQrrdU2xR9d/ngGa+M6ohsjZTbwaGMwB1P
         09Fihx7pvklK9ai3Cdln9tmBM8QpIYItIeZ4LfAIlHoYPmEs/cz2BC6OOpQUFp12u/Dc
         2y//WlkuGMRzMd2bN21Ri8xLygB3qGvSJ13Uyxfo1F3pr69KuSyb0POxwiT5YlyT2B/x
         1gveqUwnU71Dw1a0YqSm0VxlmvyDH0wNew1LrM7OjzhokorkJZ5fvCL7m3o2bkGG2te7
         SyQB4REb/Gg9sYJYQBzhcUREcbUKjxwkwFC9jcnfLtxk+s1nMfG8zhSGxKM+NwZRG8T0
         ybiA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVVjRHyE0WPuFniWSFr+j7n4b872SqSHBznOCi9Wpq6jv2S/6h0
	SAzl1f2LWneiDp6S1K5c3AOZgWrCSOTjOqDJtl0dwyStif2YST2ArpqLMhzV5XzGoPEfkz4Vjs2
	nAZOlAk8ZS112Rm86bDEZ7ggYoH4dPp5334DWHApiAAS4zuW+veDG65ECYfRD7hUPxQ==
X-Received: by 2002:a50:8719:: with SMTP id i25mr5158811edb.172.1556032925885;
        Tue, 23 Apr 2019 08:22:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwmtQB3DyhKvpoIYylWNs3Lk7xBUVug/CzcqUz7cLxsNqg+Sh98gaD5TV134NOltV6p9dT
X-Received: by 2002:a50:8719:: with SMTP id i25mr5158741edb.172.1556032924722;
        Tue, 23 Apr 2019 08:22:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556032924; cv=none;
        d=google.com; s=arc-20160816;
        b=Vs/DoZOz3vOO4sr6AnbnmvINSqAqEb0QhPqmGut1ufHKCoTzDcNU1CYoYBxfZZFWTv
         bfJN+9rhq5dmtnOBVsUlhY9cgCKRVGh0T8h1pe0b6TWsCJ7v9zLw0Jd8Whs90fz3FQkh
         GIwSlEtfs5y5uyqnixB1UXZLjvQ562TLcUV3v6ldB27L14+XDfU59zYb01GGxBDEpNm1
         wkD+EJpY0wHdtVgyhj71q/ocsNXG6Slg4AKtwxFJGtJ7V8k+wJWdzKbUT1KccfRVxgUn
         qvrFviFylbtooeLLGfjdvhLdnT1Tal5+EP43kzsiHl1AchuzQXm2+RAHZAgBYUrYer2n
         TcEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=1Hq9GDwpavLHPlAi4sgV7BnTVf/FARNXWXz3UrUgYK4=;
        b=E3wfVwdvznIZKKY1LVOjMkOXbe23ay4O9dDYGrgWTGFdpJOI2TlOriRtxt8HEzYFqK
         pLV2IvAiRu7XDZCKwPHhJ1AS15b/Ny330W5VeKiCYONiv0HsUI9xkIlCSn8w9wUUje6P
         tOK5A3TLcZh7UA9QwidRpMTUwrdeepHHXZ+hJwT/c4FSg2a4AN48zSJn7dOf2xJlGppo
         bvlZM9lVr+TczLEZQmrqTLdeG115HOQD3sVo3nBc4QyKTeD9quRrohQi4dvhHkSR1rrS
         FVpvmH86bKokk1qLTHCgLNLTQPcrDVtxYsmYyf8Z98Rb+xJJl0bZLrOOtZYprTO0x0/j
         rBCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z64si1862650ede.365.2019.04.23.08.22.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 08:22:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3NFIuhR063362
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:22:02 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s23rm4x93-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:22:02 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 23 Apr 2019 16:21:52 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 23 Apr 2019 16:21:42 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3NFLfkJ26017998
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 23 Apr 2019 15:21:41 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DC7BC42045;
	Tue, 23 Apr 2019 15:21:40 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 678A04204D;
	Tue, 23 Apr 2019 15:21:38 +0000 (GMT)
Received: from [9.145.7.116] (unknown [9.145.7.116])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 23 Apr 2019 15:21:38 +0000 (GMT)
Subject: Re: [PATCH v12 01/31] mm: introduce CONFIG_SPECULATIVE_PAGE_FAULT
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
        linuxppc-dev@lists.ozlabs.org, x86@kernel.org
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-2-ldufour@linux.ibm.com>
 <20190418214721.GA11645@redhat.com>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Tue, 23 Apr 2019 17:21:37 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190418214721.GA11645@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19042315-0012-0000-0000-00000311DE1E
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042315-0013-0000-0000-0000214A2FD2
Message-Id: <bcb29b68-0dd4-92a7-4f7e-1cb009233ed7@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-23_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904230103
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 18/04/2019 à 23:47, Jerome Glisse a écrit :
> On Tue, Apr 16, 2019 at 03:44:52PM +0200, Laurent Dufour wrote:
>> This configuration variable will be used to build the code needed to
>> handle speculative page fault.
>>
>> By default it is turned off, and activated depending on architecture
>> support, ARCH_HAS_PTE_SPECIAL, SMP and MMU.
>>
>> The architecture support is needed since the speculative page fault handler
>> is called from the architecture's page faulting code, and some code has to
>> be added there to handle the speculative handler.
>>
>> The dependency on ARCH_HAS_PTE_SPECIAL is required because vm_normal_page()
>> does processing that is not compatible with the speculative handling in the
>> case ARCH_HAS_PTE_SPECIAL is not set.
>>
>> Suggested-by: Thomas Gleixner <tglx@linutronix.de>
>> Suggested-by: David Rientjes <rientjes@google.com>
>> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> 
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

Thanks Jérôme.

> Small question below
> 
>> ---
>>   mm/Kconfig | 22 ++++++++++++++++++++++
>>   1 file changed, 22 insertions(+)
>>
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 0eada3f818fa..ff278ac9978a 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -761,4 +761,26 @@ config GUP_BENCHMARK
>>   config ARCH_HAS_PTE_SPECIAL
>>   	bool
>>   
>> +config ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
>> +       def_bool n
>> +
>> +config SPECULATIVE_PAGE_FAULT
>> +	bool "Speculative page faults"
>> +	default y
>> +	depends on ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
>> +	depends on ARCH_HAS_PTE_SPECIAL && MMU && SMP
>> +	help
>> +	  Try to handle user space page faults without holding the mmap_sem.
>> +
>> +	  This should allow better concurrency for massively threaded processes
> 
> Is there any case where it does not provide better concurrency ? The
> should make me wonder :)

Depending on the VMA's type, it may not provide better concurrency. 
Indeed only anonymous mapping are managed currently. Perhaps this should 
be mentioned here, is it ?

>> +	  since the page fault handler will not wait for other thread's memory
>> +	  layout change to be done, assuming that this change is done in
>> +	  another part of the process's memory space. This type of page fault
>> +	  is named speculative page fault.
>> +
>> +	  If the speculative page fault fails because a concurrent modification
>> +	  is detected or because underlying PMD or PTE tables are not yet
>> +	  allocated, the speculative page fault fails and a classic page fault
>> +	  is then tried.
>> +
>>   endmenu
>> -- 
>> 2.21.0
>>
> 

