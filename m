Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DC36C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:33:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A32521773
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:33:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A32521773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCBCA6B0007; Wed, 24 Apr 2019 06:33:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7B526B0008; Wed, 24 Apr 2019 06:33:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C42936B000A; Wed, 24 Apr 2019 06:33:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id A294A6B0007
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:33:45 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id j62so14521816ywe.3
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:33:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=nFs6IDDG/TshbkxB94tbMwb5jDUiYltDvO7hNh8yOqw=;
        b=mpcgD+WYPyqfzBMuUWbz4g7jzkSkaU2GgIwXggRzee2N9iibcsgI7VAOIb46bw2s0d
         8z6p72AOJjEWR9jk04j0lZy5Qoqp1LagJ0LL3Ll0P6k3ddW21WZ3N+6hFcvD/HPDJX9T
         J2hy63ViD98GOQONkFLl7f3UBhKyxajriGWB7ZRUtQI6QR82UG9+NsZU0wsUcyxcqvBs
         W1m9pGLaiCE14ub8H8KUps/JDjyfKHKJ6Sb+Aez38g8LdwQTEFuLG3WkXc08tx7do0y6
         0WyfzuSgX9WwmhvEYSM+mCQZgYYpmYPsuUlNdGWdtDEFS2GNg3yyRWI7+F3fL87zUpHD
         FVmw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXltMcOIX5Ybnfe1xapONalYUqCzV48ZplpTSd6izr1Fu1Gzcs9
	h2NeuHAtXAFIfUxmaaTrEI4KvuTkLwhTi4whruad3CVeFc5cng6xxPrdaPj+OuR5zPlm0VfgVkP
	w8wO/f4BnXQAecJVjp9fM2+pm5gPIgbjpMN488vdj9MXAIC0oEQREoQ0i6ctut7F7jw==
X-Received: by 2002:a0d:eacf:: with SMTP id t198mr3606615ywe.495.1556102025363;
        Wed, 24 Apr 2019 03:33:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzf+HbTQx3zNOUbY3ddO7lV/6jYlyb0LIRCgxNq3w0YaS56I87H6t9lumy6XxyHErPIhVM3
X-Received: by 2002:a0d:eacf:: with SMTP id t198mr3606541ywe.495.1556102024289;
        Wed, 24 Apr 2019 03:33:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556102024; cv=none;
        d=google.com; s=arc-20160816;
        b=lhJmimI3L9IzGpr1L49rE2zZO6TVmtJlCaP1o3HMRyXJ7YqXRoVxvdrMkFLy2h9MFW
         HRaBnfYKxFHvHph0mtLDhKiGj/xWVdO6or8S78AAVtnvVneJWoct4IBrjtYtBwIwa+v6
         942TZMXHvvq4IrgSRL5v5FitrlLsdkEWdOWWzCGt/pykMapfbftnR64totCTWLJowS79
         /U7/I/pXJW92HqIMYfhZVB268uOTBn2R4af9xPk9db3TPtwm2u9/blMoDDaOGlxUlOMr
         3EEH46vF7bBVhg+YHT6NTwjDLkVK72S8kTKd+02Vgxg3Tpv3srsPRS2No0+w7cFIqtja
         SwkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=nFs6IDDG/TshbkxB94tbMwb5jDUiYltDvO7hNh8yOqw=;
        b=BmkbqcVIGNE5S65NY+8MhY2OumROaDTDa4NODTyMaf/QR4l5pUMano99byfkhF6gu+
         ZO5JFAk44vlVQrMN6O3za5BxCOqN/CyMSBkTAinoPc9V0q1JdAKnslCJ3F2Pj6/ncYrI
         pPdhXNJpzH866F0EGtKp/RVCNnxnh3Ahxdf/5WCm3TBmK4OxnY3KoeKo+BBc4Zkeo23h
         V0uQFdj93+w0xsM7AT8ZCBa448YFtYHJYBFO3J15zs9HC9dSamzJl7VFv/8sgfqkRW8F
         WJq5PXdvynjfBYuCyQZlRY5TmGxUCj4G2P37CBJ0tjY3jGdn+YyqzVmtO9/8s1I2mXHx
         SY3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 196si12737634ywf.163.2019.04.24.03.33.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 03:33:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3OAXcFa114575
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:33:44 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2s2k57hy8y-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:33:39 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Wed, 24 Apr 2019 11:33:27 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 24 Apr 2019 11:33:16 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3OAXFXh57802952
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Apr 2019 10:33:15 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id EC166A4057;
	Wed, 24 Apr 2019 10:33:14 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 325F3A4040;
	Wed, 24 Apr 2019 10:33:12 +0000 (GMT)
Received: from [9.145.184.124] (unknown [9.145.184.124])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 24 Apr 2019 10:33:12 +0000 (GMT)
Subject: Re: [PATCH v12 18/31] mm: protect against PTE changes done by
 dup_mmap()
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
 <20190416134522.17540-19-ldufour@linux.ibm.com>
 <20190422203217.GI14666@redhat.com>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Wed, 24 Apr 2019 12:33:11 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190422203217.GI14666@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19042410-0020-0000-0000-00000333F137
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042410-0021-0000-0000-0000218655DC
Message-Id: <e61f71d0-1427-4a30-6dc3-b94a8fd609e8@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-24_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904240088
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 22/04/2019 à 22:32, Jerome Glisse a écrit :
> On Tue, Apr 16, 2019 at 03:45:09PM +0200, Laurent Dufour wrote:
>> Vinayak Menon and Ganesh Mahendran reported that the following scenario may
>> lead to thread being blocked due to data corruption:
>>
>>      CPU 1                   CPU 2                    CPU 3
>>      Process 1,              Process 1,               Process 1,
>>      Thread A                Thread B                 Thread C
>>
>>      while (1) {             while (1) {              while(1) {
>>      pthread_mutex_lock(l)   pthread_mutex_lock(l)    fork
>>      pthread_mutex_unlock(l) pthread_mutex_unlock(l)  }
>>      }                       }
>>
>> In the details this happens because :
>>
>>      CPU 1                CPU 2                       CPU 3
>>      fork()
>>      copy_pte_range()
>>        set PTE rdonly
>>      got to next VMA...
>>       .                   PTE is seen rdonly          PTE still writable
>>       .                   thread is writing to page
>>       .                   -> page fault
>>       .                     copy the page             Thread writes to page
>>       .                      .                        -> no page fault
>>       .                     update the PTE
>>       .                     flush TLB for that PTE
>>     flush TLB                                        PTE are now rdonly
> 
> Should the fork be on CPU3 to be consistant with the top thing (just to
> make it easier to read and go from one to the other as thread can move
> from one CPU to another).

Sure, this is quite confusing this way ;)

>>
>> So the write done by the CPU 3 is interfering with the page copy operation
>> done by CPU 2, leading to the data corruption.
>>
>> To avoid this we mark all the VMA involved in the COW mechanism as changing
>> by calling vm_write_begin(). This ensures that the speculative page fault
>> handler will not try to handle a fault on these pages.
>> The marker is set until the TLB is flushed, ensuring that all the CPUs will
>> now see the PTE as not writable.
>> Once the TLB is flush, the marker is removed by calling vm_write_end().
>>
>> The variable last is used to keep tracked of the latest VMA marked to
>> handle the error path where part of the VMA may have been marked.
>>
>> Since multiple VMA from the same mm may have the sequence count increased
>> during this process, the use of the vm_raw_write_begin/end() is required to
>> avoid lockdep false warning messages.
>>
>> Reported-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
>> Reported-by: Vinayak Menon <vinmenon@codeaurora.org>
>> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> 
> A minor comment (see below)
> 
> Reviewed-by: Jérome Glisse <jglisse@redhat.com>

Thanks for the review Jérôme.

>> ---
>>   kernel/fork.c | 30 ++++++++++++++++++++++++++++--
>>   1 file changed, 28 insertions(+), 2 deletions(-)
>>
>> diff --git a/kernel/fork.c b/kernel/fork.c
>> index f8dae021c2e5..2992d2c95256 100644
>> --- a/kernel/fork.c
>> +++ b/kernel/fork.c
>> @@ -462,7 +462,7 @@ EXPORT_SYMBOL(free_task);
>>   static __latent_entropy int dup_mmap(struct mm_struct *mm,
>>   					struct mm_struct *oldmm)
>>   {
>> -	struct vm_area_struct *mpnt, *tmp, *prev, **pprev;
>> +	struct vm_area_struct *mpnt, *tmp, *prev, **pprev, *last = NULL;
>>   	struct rb_node **rb_link, *rb_parent;
>>   	int retval;
>>   	unsigned long charge;
>> @@ -581,8 +581,18 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
>>   		rb_parent = &tmp->vm_rb;
>>   
>>   		mm->map_count++;
>> -		if (!(tmp->vm_flags & VM_WIPEONFORK))
>> +		if (!(tmp->vm_flags & VM_WIPEONFORK)) {
>> +			if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT)) {
>> +				/*
>> +				 * Mark this VMA as changing to prevent the
>> +				 * speculative page fault hanlder to process
>> +				 * it until the TLB are flushed below.
>> +				 */
>> +				last = mpnt;
>> +				vm_raw_write_begin(mpnt);
>> +			}
>>   			retval = copy_page_range(mm, oldmm, mpnt);
>> +		}
>>   
>>   		if (tmp->vm_ops && tmp->vm_ops->open)
>>   			tmp->vm_ops->open(tmp);
>> @@ -595,6 +605,22 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
>>   out:
>>   	up_write(&mm->mmap_sem);
>>   	flush_tlb_mm(oldmm);
>> +
>> +	if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT)) {
> 
> You do not need to check for CONFIG_SPECULATIVE_PAGE_FAULT as last
> will always be NULL if it is not enabled but maybe the compiler will
> miss the optimization opportunity if you only have the for() loop
> below.

I didn't check for the generated code, perhaps the compiler will be 
optimize that correctly.
This being said, I think the if block is better for the code 
readability, highlighting that this block is only needed in the case of SPF.

>> +		/*
>> +		 * Since the TLB has been flush, we can safely unmark the
>> +		 * copied VMAs and allows the speculative page fault handler to
>> +		 * process them again.
>> +		 * Walk back the VMA list from the last marked VMA.
>> +		 */
>> +		for (; last; last = last->vm_prev) {
>> +			if (last->vm_flags & VM_DONTCOPY)
>> +				continue;
>> +			if (!(last->vm_flags & VM_WIPEONFORK))
>> +				vm_raw_write_end(last);
>> +		}
>> +	}
>> +
>>   	up_write(&oldmm->mmap_sem);
>>   	dup_userfaultfd_complete(&uf);
>>   fail_uprobe_end:
>> -- 
>> 2.21.0
>>
> 

