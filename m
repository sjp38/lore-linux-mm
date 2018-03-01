Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id B78F46B0003
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 00:23:06 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id c76so3802185qke.19
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 21:23:06 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x6si2843130qke.188.2018.02.28.21.23.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Feb 2018 21:23:05 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w215JXq2089352
	for <linux-mm@kvack.org>; Thu, 1 Mar 2018 00:23:05 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2geaqv97qm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Mar 2018 00:23:04 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Thu, 1 Mar 2018 05:23:03 -0000
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Subject: Re: [RFC 2/4] Uprobe: Export few functions / data structures
References: <20180228075345.674-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180228075345.674-3-ravi.bangoria@linux.vnet.ibm.com>
 <20180228122440.GC63063@linux.vnet.ibm.com>
Date: Thu, 1 Mar 2018 10:55:07 +0530
MIME-Version: 1.0
In-Reply-To: <20180228122440.GC63063@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Message-Id: <dfd4c3ee-bd27-bc33-9b77-f10fac363a7e@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, linux-kernel@vger.kernel.org, rostedt@goodmis.org, mhiramat@kernel.org, ananth@linux.vnet.ibm.com, naveen.n.rao@linux.vnet.ibm.com, oleg@redhat.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>



On 02/28/2018 05:54 PM, Srikar Dronamraju wrote:
>> @@ -149,6 +155,11 @@ struct uprobes_state {
>>  extern bool arch_uprobe_ignore(struct arch_uprobe *aup, struct pt_regs *regs);
>>  extern void arch_uprobe_copy_ixol(struct page *page, unsigned long vaddr,
>>  					 void *src, unsigned long len);
>> +unsigned long offset_to_vaddr(struct vm_area_struct *vma, loff_t offset);
>> +void copy_from_page(struct page *page, unsigned long vaddr, void *dst, int len);
>> +void copy_to_page(struct page *page, unsigned long vaddr, const void *src, int len);
>> +struct uprobe_map_info *free_uprobe_map_info(struct uprobe_map_info *info);
>> +
>>  #else /* !CONFIG_UPROBES */
> If we have to export the above, we might have to work with mm maintainers and
> see if we can move them there.

Adding
A A A  linux-mm@kvack.org
A A A  Michal Hocko <mhocko@kernel.org>
A A A  Andrew Morton <akpm@linux-foundation.org>
in the cc.

>> -static inline struct uprobe_map_info *
>> -free_uprobe_map_info(struct uprobe_map_info *info)
>> +struct uprobe_map_info *free_uprobe_map_info(struct uprobe_map_info *info)
>>  {
>>  	struct uprobe_map_info *next = info->next;
>>  	kfree(info);
>>  	return next;
>>  }
>>
>> -static struct uprobe_map_info *
>> -build_uprobe_map_info(struct address_space *mapping, loff_t offset,
>> -		      bool is_register)
>> +struct uprobe_map_info *build_uprobe_map_info(struct address_space *mapping,
>> +					      loff_t offset, bool is_register)
>>  {
>>  	unsigned long pgoff = offset >> PAGE_SHIFT;
>>  	struct vm_area_struct *vma;
> Instead of exporting, did you look at extending the uprobe consumer with
> ops. i.e if the consumer detects that a probe is a semaphore and exports
> a set of callbacks which can them be called from uprobe
> insertion/deletion time. With such a thing, incrementing/decrementing
> the semaphore and the insertion/deletion of the breakpoint can be done
> at one shot. No?

Yes, we tried that approach as well. Basically, when install_breakpoint() get called,
notify consumer about that. We can either use consumer_filter function or add a
new callback into uprobe_consumer which will get called if install_breakpoint()
succeeds. something like:

A A A A  if (install_breakpoint()) {
A A A A  A A A  /* Notify consumers right after patching instruction. */
A A A A A A A A  consumer->post_prepare();
A A A A  }

There are different problem with that approach. install_breakpoint() gets called in
very early stage of binary loading and vma that holds the semaphore won't be
present in the mm yet. I also tried to solve this by creating a task_work in
consumer callback. task_work handler will get called when process virtual memory
map is fully prepared and we are going back to userspace. But it will make design
quite complicated. Also, there is no way to know if mm_struct we got in task_work
handler is _still_ valid.

With unregister also, we first remove the "caller" consumer and then re-patch
original instruction. i.e.

A A A A  __uprobe_unregister()
A A A A  {
A A A A A A A A  if (WARN_ON(!consumer_del(uprobe, uc)))
A A A A A A A A A A A A  return;
A A A A A A A A  err = register_for_each_vma(uprobe, NULL);

We don't callback "caller" consumer at unregistration.

Our idea is to make changes in core uprobe as less as possible. And IMHO,
exporting build_map_info() helps to simplifies the implementation.

Let me know if I'm missing something.

Thanks for the review,
Ravi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
