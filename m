Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id E57C46B0266
	for <linux-mm@kvack.org>; Fri,  4 May 2018 10:22:01 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id g12-v6so7628573qtj.22
        for <linux-mm@kvack.org>; Fri, 04 May 2018 07:22:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r13-v6si1796912qtr.81.2018.05.04.07.22.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 May 2018 07:22:00 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w44EIxLb119507
	for <linux-mm@kvack.org>; Fri, 4 May 2018 10:21:59 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hrpmu7d8t-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 04 May 2018 10:21:59 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.ibm.com>;
	Fri, 4 May 2018 15:21:51 +0100
From: Ravi Bangoria <ravi.bangoria@linux.ibm.com>
Subject: Re: [PATCH v3 6/9] trace_uprobe: Support SDT markers having reference
 count (semaphore)
References: <20180417043244.7501-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180417043244.7501-7-ravi.bangoria@linux.vnet.ibm.com>
 <20180504134816.8633a157dd036489d9b0f1db@kernel.org>
Date: Fri, 4 May 2018 19:51:32 +0530
MIME-Version: 1.0
In-Reply-To: <20180504134816.8633a157dd036489d9b0f1db@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Message-Id: <206e4a16-ae21-7da3-f752-853dc2f51947@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com

Hi Masami,

On 05/04/2018 10:18 AM, Masami Hiramatsu wrote:
>> +void uprobe_down_write_dup_mmap(void)
>> +{
>> +	percpu_down_write(&dup_mmap_sem);
>> +}
>> +
>> +void uprobe_up_write_dup_mmap(void)
>> +{
>> +	percpu_up_write(&dup_mmap_sem);
>> +}
>> +
> I'm not sure why these hunks are not done in previous patch.
> If you separate "uprobe_map_info" export patch, this also
> should be separated. (Or both merged into this patch)

Sure, I'll add separate patch for dup_mmap_sem.

>> +/*
>> + * Reference counter gate the invocation of probe. If present,
>> + * by default reference counter is 0. One needs to increment
>> + * it before tracing the probe and decrement it when done.
>> + */
>> +static int
>> +sdt_update_ref_ctr(struct mm_struct *mm, unsigned long vaddr, short d)
>> +{
>> +	void *kaddr;
>> +	struct page *page;
>> +	struct vm_area_struct *vma;
>> +	int ret = 0;
>> +	unsigned short *ptr;
>> +
>> +	if (vaddr == 0)
>> +		return -EINVAL;
>> +
>> +	ret = get_user_pages_remote(NULL, mm, vaddr, 1,
>> +		FOLL_FORCE | FOLL_WRITE, &page, &vma, NULL);
>> +	if (ret <= 0)
>> +		return ret;
> Hmm, get_user_pages_remote() said
>
> ===
> If nr_pages is 0 or negative, returns 0. If no pages were pinned, returns -errno.
> ===
>
> And you've passed 1 for nr_pages, so it must be 1 or -errno.
>
>> +
>> +	kaddr = kmap_atomic(page);
>> +	ptr = kaddr + (vaddr & ~PAGE_MASK);
>> +	*ptr += d;
>> +	kunmap_atomic(kaddr);
>> +
>> +	put_page(page);
>> +	return 0;
> And obviously 0 means "success" for sdt_update_ref_ctr().
> I think if get_user_pages_remote returns 0, this should
> return -EBUSY (*) or something else.
>
> * It seems that if faultin_page() in __get_user_pages()
> returns -EBUSY, get_user_pages_remote() can return 0.

Ah good catch :). Will change it.

>> +}
>> +
>> +static void sdt_increment_ref_ctr(struct trace_uprobe *tu)
>> +{
>> +	struct uprobe_map_info *info;
>> +
>> +	uprobe_down_write_dup_mmap();
>> +	info = uprobe_build_map_info(tu->inode->i_mapping,
>> +				tu->ref_ctr_offset, false);
>> +	if (IS_ERR(info))
>> +		goto out;
>> +
>> +	while (info) {
>> +		down_write(&info->mm->mmap_sem);
>> +
>> +		if (sdt_find_vma(tu, info->mm, info->vaddr))
>> +			sdt_update_ref_ctr(info->mm, info->vaddr, 1);
> Don't you have to handle the error to map pages here?

Correct.. I think, I've to feedback error code to probe_event_{enable|disable}
and handler failure there.

Thanks for the review,
Ravi
