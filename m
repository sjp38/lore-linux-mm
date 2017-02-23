Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9350E6B0389
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 02:51:29 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f21so38205676pgi.4
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 23:51:29 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f68si3618338pfd.98.2017.02.22.23.51.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 23:51:28 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1N7nnh0108891
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 02:51:28 -0500
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28shbjdc5r-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 02:51:28 -0500
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 23 Feb 2017 17:51:25 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id A3FB93578065
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 18:51:20 +1100 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1N7pCRf49479926
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 18:51:20 +1100
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1N7oln7025864
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 18:50:48 +1100
Subject: Re: [RFC PATCH 03/14] mm/migrate: Add copy_pages_mthread function
References: <20170217150551.117028-1-zi.yan@sent.com>
 <20170217150551.117028-4-zi.yan@sent.com>
 <20170223060649.GA7336@hori1.linux.bs1.fc.nec.co.jp>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 23 Feb 2017 13:20:16 +0530
MIME-Version: 1.0
In-Reply-To: <20170223060649.GA7336@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Message-Id: <ff44b5a5-d022-5c68-b067-634614f0a28c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@sent.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "dnellans@nvidia.com" <dnellans@nvidia.com>, "apopple@au1.ibm.com" <apopple@au1.ibm.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "zi.yan@cs.rutgers.edu" <zi.yan@cs.rutgers.edu>

On 02/23/2017 11:36 AM, Naoya Horiguchi wrote:
> On Fri, Feb 17, 2017 at 10:05:40AM -0500, Zi Yan wrote:
>> From: Zi Yan <ziy@nvidia.com>
>>
>> This change adds a new function copy_pages_mthread to enable multi threaded
>> page copy which can be utilized during migration. This function splits the
>> page copy request into multiple threads which will handle individual chunk
>> and send them as jobs to system_highpri_wq work queue.
>>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
>> ---
>>  include/linux/highmem.h |  2 ++
>>  mm/Makefile             |  2 ++
>>  mm/copy_pages.c         | 86 +++++++++++++++++++++++++++++++++++++++++++++++++
>>  3 files changed, 90 insertions(+)
>>  create mode 100644 mm/copy_pages.c
>>
>> diff --git a/include/linux/highmem.h b/include/linux/highmem.h
>> index bb3f3297062a..e1f4f1b82812 100644
>> --- a/include/linux/highmem.h
>> +++ b/include/linux/highmem.h
>> @@ -236,6 +236,8 @@ static inline void copy_user_highpage(struct page *to, struct page *from,
>>  
>>  #endif
>>  
>> +int copy_pages_mthread(struct page *to, struct page *from, int nr_pages);
>> +
>>  static inline void copy_highpage(struct page *to, struct page *from)
>>  {
>>  	char *vfrom, *vto;
>> diff --git a/mm/Makefile b/mm/Makefile
>> index aa0aa17cb413..cdd4bab9cc66 100644
>> --- a/mm/Makefile
>> +++ b/mm/Makefile
>> @@ -43,6 +43,8 @@ obj-y			:= filemap.o mempool.o oom_kill.o \
>>  
>>  obj-y += init-mm.o
>>  
>> +obj-y += copy_pages.o
>> +
>>  ifdef CONFIG_NO_BOOTMEM
>>  	obj-y		+= nobootmem.o
>>  else
>> diff --git a/mm/copy_pages.c b/mm/copy_pages.c
>> new file mode 100644
>> index 000000000000..c357e7b01042
>> --- /dev/null
>> +++ b/mm/copy_pages.c
>> @@ -0,0 +1,86 @@
>> +/*
>> + * This implements parallel page copy function through multi threaded
>> + * work queues.
>> + *
>> + * Zi Yan <ziy@nvidia.com>
>> + *
>> + * This work is licensed under the terms of the GNU GPL, version 2.
>> + */
>> +#include <linux/highmem.h>
>> +#include <linux/workqueue.h>
>> +#include <linux/slab.h>
>> +#include <linux/freezer.h>
>> +
>> +/*
>> + * nr_copythreads can be the highest number of threads for given node
>> + * on any architecture. The actual number of copy threads will be
>> + * limited by the cpumask weight of the target node.
>> + */
>> +unsigned int nr_copythreads = 8;
> 
> If you give this as a constant, how about defining as macro?

Sure, will change it up next time around.

> 
>> +
>> +struct copy_info {
>> +	struct work_struct copy_work;
>> +	char *to;
>> +	char *from;
>> +	unsigned long chunk_size;
>> +};
>> +
>> +static void copy_pages(char *vto, char *vfrom, unsigned long size)
>> +{
>> +	memcpy(vto, vfrom, size);
>> +}
>> +
>> +static void copythread(struct work_struct *work)
>> +{
>> +	struct copy_info *info = (struct copy_info *) work;
>> +
>> +	copy_pages(info->to, info->from, info->chunk_size);
>> +}
>> +
>> +int copy_pages_mthread(struct page *to, struct page *from, int nr_pages)
>> +{
>> +	unsigned int node = page_to_nid(to);
>> +	const struct cpumask *cpumask = cpumask_of_node(node);
>> +	struct copy_info *work_items;
>> +	char *vto, *vfrom;
>> +	unsigned long i, cthreads, cpu, chunk_size;
>> +	int cpu_id_list[32] = {0};
> 
> Why 32? Maybe you can set the array size with nr_copythreads (macro version.)

Sure, will do.

> 
>> +
>> +	cthreads = nr_copythreads;
>> +	cthreads = min_t(unsigned int, cthreads, cpumask_weight(cpumask));
> 
> nitpick, but looks a little wordy, can it be simply like below?
> 
>   cthreads = min_t(unsigned int, nr_copythreads, cpumask_weight(cpumask));
> 
>> +	cthreads = (cthreads / 2) * 2;
> 
> I'm not sure the intention here. # of threads should be even number?

Yes.

> If cpumask_weight() is 1, cthreads is 0, that could cause zero division.
> So you had better making sure to prevent it.

If cpumask_weight() is 1, then min_t(unsigned int, 8, 1) should be
greater that equal to 1. Then cthreads can end up in 0. That is
possible. But how there is a chance of zero division ? May be its
possible if we are trying move into a CPU less memory only node
where cpumask_weight() is 0 ?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
