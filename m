Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E04986B0005
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 05:20:08 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id q185so4408069qke.0
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 02:20:08 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q130si867407qka.320.2018.03.16.02.20.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 02:20:07 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2G9K3tM125041
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 05:20:06 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gr8vdvy6p-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 05:20:05 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Fri, 16 Mar 2018 09:19:44 -0000
Subject: Re: [PATCH 5/8] trace_uprobe: Support SDT markers having reference
 count (semaphore)
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180313125603.19819-6-ravi.bangoria@linux.vnet.ibm.com>
 <20180315142120.GA19218@redhat.com>
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Date: Fri, 16 Mar 2018 14:51:52 +0530
MIME-Version: 1.0
In-Reply-To: <20180315142120.GA19218@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Message-Id: <56ae982d-2fbf-09c4-989b-57bce5a1cb04@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: mhiramat@kernel.org, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>



On 03/15/2018 07:51 PM, Oleg Nesterov wrote:
> On 03/13, Ravi Bangoria wrote:
>> @@ -1053,6 +1056,9 @@ int uprobe_mmap(struct vm_area_struct *vma)
>>  	struct uprobe *uprobe, *u;
>>  	struct inode *inode;
>>
>> +	if (uprobe_mmap_callback)
>> +		uprobe_mmap_callback(vma);
>> +
>>  	if (no_uprobe_events() || !valid_vma(vma, true))
>>  		return 0;
> probe_event_enable() does
>
> 	uprobe_register();
> 	/* WINDOW */
> 	sdt_increment_ref_ctr();
>
> what if uprobe_mmap() is called in between? The counter(s) in this vma
> will be incremented twice, no?

I guess, it's a valid issue with PATCH 5 but should be taken care by PATCH 6.

>
>> +static struct vm_area_struct *
>> +sdt_find_vma(struct mm_struct *mm, struct trace_uprobe *tu)
>> +{
>> +	struct vm_area_struct *tmp;
>> +
>> +	for (tmp = mm->mmap; tmp != NULL; tmp = tmp->vm_next)
>> +		if (sdt_valid_vma(tu, tmp))
>> +			return tmp;
>> +
>> +	return NULL;
> I can't understand the logic... Lets ignore sdt_valid_vma() for now.
> The caller has uprobe_map_info, why it can't simply do
> vma = find_vma(uprobe_map_info->vaddr)? and then check sdt_valid_vma().

Yes. that should work. Will change it.

Thanks for the review,
Ravi
