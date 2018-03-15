Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id E80956B0006
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 07:21:38 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id v89so4184575qte.21
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 04:21:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v1si5014867qtg.188.2018.03.15.04.21.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 04:21:37 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2FBJXqx013263
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 07:21:36 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gqnjr7hac-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 07:21:36 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Thu, 15 Mar 2018 11:21:29 -0000
Subject: Re: [PATCH 5/8] trace_uprobe: Support SDT markers having reference
 count (semaphore)
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180313125603.19819-6-ravi.bangoria@linux.vnet.ibm.com>
 <20180314165943.GA5948@redhat.com>
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Date: Thu, 15 Mar 2018 16:53:40 +0530
MIME-Version: 1.0
In-Reply-To: <20180314165943.GA5948@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Message-Id: <e802ce35-7134-ea12-774b-512546953c47@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: mhiramat@kernel.org, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>



On 03/14/2018 10:29 PM, Oleg Nesterov wrote:
> On 03/13, Ravi Bangoria wrote:
>> +static bool sdt_valid_vma(struct trace_uprobe *tu, struct vm_area_struct *vma)
>> +{
>> +	unsigned long vaddr = vma_offset_to_vaddr(vma, tu->ref_ctr_offset);
>> +
>> +	return tu->ref_ctr_offset &&
>> +		vma->vm_file &&
>> +		file_inode(vma->vm_file) == tu->inode &&
>> +		vma->vm_flags & VM_WRITE &&
>> +		vma->vm_start <= vaddr &&
>> +		vma->vm_end > vaddr;
>> +}
> Perhaps in this case a simple
>
> 		ref_ctr_offset < vma->vm_end - vma->vm_start
>
> check without vma_offset_to_vaddr() makes more sense, but I won't insist.
>

Hmm... I'm not quite sure. Will rethink and get back to you.

>
>> +static void sdt_increment_ref_ctr(struct trace_uprobe *tu)
>> +{
>> +	struct uprobe_map_info *info;
>> +	struct vm_area_struct *vma;
>> +	unsigned long vaddr;
>> +
>> +	uprobe_start_dup_mmap();
>> +	info = uprobe_build_map_info(tu->inode->i_mapping,
>> +				tu->ref_ctr_offset, false);
> Hmm. This doesn't look right.
>
> If you need to find all mappings (and avoid the races with fork/dup_mmap) you
> need to take this semaphore for writing, uprobe_start_dup_mmap() can't help.

Oops. Yes. Will change it.

Thanks for the review :)
Ravi
