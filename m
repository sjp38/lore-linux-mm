Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id D67466B0009
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 05:26:50 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id h62so2483241qkc.20
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 02:26:50 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d18si6657914qtl.91.2018.03.16.02.26.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 02:26:50 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2G9PA9G140193
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 05:26:49 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gr8vdw7f7-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 05:26:48 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Fri, 16 Mar 2018 09:26:45 -0000
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Subject: Re: [PATCH 5/8] trace_uprobe: Support SDT markers having reference
 count (semaphore)
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180313125603.19819-6-ravi.bangoria@linux.vnet.ibm.com>
 <20180315142120.GA19218@redhat.com> <20180315143044.GA19643@redhat.com>
Date: Fri, 16 Mar 2018 14:58:55 +0530
MIME-Version: 1.0
In-Reply-To: <20180315143044.GA19643@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Message-Id: <3b303a2d-35dd-9178-fc03-de9f2d588797@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: mhiramat@kernel.org, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>



On 03/15/2018 08:00 PM, Oleg Nesterov wrote:
> On 03/15, Oleg Nesterov wrote:
>>> +static struct vm_area_struct *
>>> +sdt_find_vma(struct mm_struct *mm, struct trace_uprobe *tu)
>>> +{
>>> +	struct vm_area_struct *tmp;
>>> +
>>> +	for (tmp = mm->mmap; tmp != NULL; tmp = tmp->vm_next)
>>> +		if (sdt_valid_vma(tu, tmp))
>>> +			return tmp;
>>> +
>>> +	return NULL;
>> I can't understand the logic... Lets ignore sdt_valid_vma() for now.
>> The caller has uprobe_map_info, why it can't simply do
>> vma = find_vma(uprobe_map_info->vaddr)? and then check sdt_valid_vma().
> Note to mention that sdt_find_vma() can return NULL but the callers do
> vma_offset_to_vaddr(vma) without any check.

If the "mm" we are passing to sdt_find_vma() is returned by
uprobe_build_map_info(ref_ctr_offset), sdt_find_vma() must
_not_ return NULL.

Thanks for the review,
Ravi
