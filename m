Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D1E976B025E
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 03:05:01 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id bk3so80657473wjc.4
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 00:05:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b124si7329202wmg.77.2016.12.07.00.05.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Dec 2016 00:05:00 -0800 (PST)
Subject: Re: [PATCH] mm: make transparent hugepage size public
References: <alpine.LSU.2.11.1612052200290.13021@eggly.anvils>
 <20161207075003.GA17136@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <22c83914-a720-2650-54fa-9e63f61b94e0@suse.cz>
Date: Wed, 7 Dec 2016 09:04:44 +0100
MIME-Version: 1.0
In-Reply-To: <20161207075003.GA17136@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Linux API <linux-api@vger.kernel.org>

[+CC linux-api]

On 12/07/2016 08:50 AM, Michal Hocko wrote:
> On Mon 05-12-16 22:05:22, Hugh Dickins wrote:
>> Test programs want to know the size of a transparent hugepage.
>> While it is commonly the same as the size of a hugetlbfs page
>> (shown as Hugepagesize in /proc/meminfo), that is not always so:
>> powerpc implements transparent hugepages in a different way from
>> hugetlbfs pages, so it's coincidence when their sizes are the same;
>> and x86 and others can support more than one hugetlbfs page size.
>>
>> Add /sys/kernel/mm/transparent_hugepage/hpage_pmd_size to show the
>> THP size in bytes - it's the same for Anonymous and Shmem hugepages.
>> Call it hpage_pmd_size (after HPAGE_PMD_SIZE) rather than hpage_size,
>> in case some transparent support for pud and pgd pages is added later.

Let's hope no arch is crazy enough to add intermediate sizes for THP,
like they have for hugetlbfs? (See Dave's "proc: mm: export PTE sizes
directly in smaps" threads).

> 
> Definitely much better than cluttering /proc/meminfo even more.

Agreed.

>> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
>> ---
>>
>>  Documentation/vm/transhuge.txt |    5 +++++
>>  mm/huge_memory.c               |   10 ++++++++++
>>  2 files changed, 15 insertions(+)
>>
>> --- 4.9-rc8/Documentation/vm/transhuge.txt	2016-10-02 16:24:33.000000000 -0700
>> +++ linux/Documentation/vm/transhuge.txt	2016-12-05 20:55:12.142578631 -0800
>> @@ -136,6 +136,11 @@ or enable it back by writing 1:
>>  echo 0 >/sys/kernel/mm/transparent_hugepage/use_zero_page
>>  echo 1 >/sys/kernel/mm/transparent_hugepage/use_zero_page
>>  
>> +Some userspace (such as a test program, or an optimized memory allocation
>> +library) may want to know the size (in bytes) of a transparent hugepage:
>> +
>> +cat /sys/kernel/mm/transparent_hugepage/hpage_pmd_size
>> +
>>  khugepaged will be automatically started when
>>  transparent_hugepage/enabled is set to "always" or "madvise, and it'll
>>  be automatically shutdown if it's set to "never".
>> --- 4.9-rc8/mm/huge_memory.c	2016-12-04 16:42:39.881703357 -0800
>> +++ linux/mm/huge_memory.c	2016-12-05 20:58:19.953010005 -0800
>> @@ -285,6 +285,15 @@ static ssize_t use_zero_page_store(struc
>>  }
>>  static struct kobj_attribute use_zero_page_attr =
>>  	__ATTR(use_zero_page, 0644, use_zero_page_show, use_zero_page_store);
>> +
>> +static ssize_t hpage_pmd_size_show(struct kobject *kobj,
>> +		struct kobj_attribute *attr, char *buf)
>> +{
>> +	return sprintf(buf, "%lu\n", HPAGE_PMD_SIZE);
>> +}
>> +static struct kobj_attribute hpage_pmd_size_attr =
>> +	__ATTR_RO(hpage_pmd_size);
>> +
>>  #ifdef CONFIG_DEBUG_VM
>>  static ssize_t debug_cow_show(struct kobject *kobj,
>>  				struct kobj_attribute *attr, char *buf)
>> @@ -307,6 +316,7 @@ static struct attribute *hugepage_attr[]
>>  	&enabled_attr.attr,
>>  	&defrag_attr.attr,
>>  	&use_zero_page_attr.attr,
>> +	&hpage_pmd_size_attr.attr,
>>  #if defined(CONFIG_SHMEM) && defined(CONFIG_TRANSPARENT_HUGE_PAGECACHE)
>>  	&shmem_enabled_attr.attr,
>>  #endif
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
