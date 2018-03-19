Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D3A5E6B0003
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 00:26:18 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 31so1190537wrr.2
        for <linux-mm@kvack.org>; Sun, 18 Mar 2018 21:26:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y7si1078970edm.292.2018.03.18.21.26.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Mar 2018 21:26:17 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2J4O7PY054511
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 00:26:16 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gsxgg3q5w-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 00:26:15 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Mon, 19 Mar 2018 04:26:13 -0000
Subject: Re: [PATCH 5/8] trace_uprobe: Support SDT markers having reference
 count (semaphore)
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180313125603.19819-6-ravi.bangoria@linux.vnet.ibm.com>
 <20180314165943.GA5948@redhat.com>
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Date: Mon, 19 Mar 2018 09:58:28 +0530
MIME-Version: 1.0
In-Reply-To: <20180314165943.GA5948@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Message-Id: <9cb068f7-0996-6e24-a95b-771006559318@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: mhiramat@kernel.org, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>

Hi Oleg,

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

I still don't get this. This seems a comparison between file offset and size
of the vma. Shouldn't we need to consider pg_off here?

Thanks,
Ravi
