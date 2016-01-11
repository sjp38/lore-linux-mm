Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0CBCE828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 11:37:40 -0500 (EST)
Received: by mail-yk0-f176.google.com with SMTP id x67so437687333ykd.2
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 08:37:40 -0800 (PST)
Received: from mail-yk0-x22d.google.com (mail-yk0-x22d.google.com. [2607:f8b0:4002:c07::22d])
        by mx.google.com with ESMTPS id b189si15530900ywf.172.2016.01.11.08.37.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 08:37:39 -0800 (PST)
Received: by mail-yk0-x22d.google.com with SMTP id v14so343395353ykd.3
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 08:37:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56937446.1050308@plexistor.com>
References: <569263BA.5060503@plexistor.com>
	<CAPcyv4hb6T9cR2Z=G9U_U2q-i_wEmRwNCrkc8kK9YpH9RkS9cA@mail.gmail.com>
	<56937446.1050308@plexistor.com>
Date: Mon, 11 Jan 2016 08:37:38 -0800
Message-ID: <CAPcyv4g6SeAqA9Vt_B0U411xNJXZ-c5JE2+tYEq-8CXQtHO+tw@mail.gmail.com>
Subject: Re: [PATCHSET 0/2] Allow single pagefault in write access of a
 VM_MIXEDMAP mapping
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, Jan 11, 2016 at 1:22 AM, Boaz Harrosh <boaz@plexistor.com> wrote:
> On 01/11/2016 03:19 AM, Dan Williams wrote:
>> On Sun, Jan 10, 2016 at 5:59 AM, Boaz Harrosh <boaz@plexistor.com> wrote:
>>> Hi
>>>
>>> Today any VM_MIXEDMAP or VM_PFN mapping when enabling a write access
>>> to their mapping, will have a double pagefault for every write access.
>>>
>>> This is because vma->vm_page_prot defines how a page/pfn is inserted into
>>> the page table (see vma_wants_writenotify in mm/mmap.c).
>>>
>>> Which means that it is always inserted with read-only under the
>>> assumption that we want to be notified when write access occurs.
>>>
>>> But this is not always true and adds an unnecessary page-fault on
>>> every new mmap-write access
>>>
>>> This patchset is trying to give the fault handler more choice by passing
>>> an pgprot_t to vm_insert_mixed() via a new vm_insert_mixed_prot() API.
>>>
>>> If the mm guys feel that the pgprot_t and its helpers and flags are private
>>> to mm/memory.c I can easily do a new: vm_insert_mixed_rw() instead. of the
>>> above vm_insert_mixed_prot() which enables any control not only write.
>>>
>>> Following is a patch to DAX to optimize out the extra page-fault.
>>>
>>> TODO: I only did 4k mapping perhaps 2M mapping can enjoy the same single
>>> fault on write access. If interesting to anyone I can attempt a fix.
>>>
>>> Dan Andrew who needs to pick this up please?
>>
>> This collides with the patches currently pending in -mm for 4.5, lets
>> take a look at this for 4.6.
>>
>
> OK thanks, I will try to work this over current linux-next and sure we
> will wait for 4.5-rc1 to look at this again.
>
> Do you have any comments in general about this?

Looks worthwhile at first glance, the only concern that comes to mind
is integration with Ross' fsync/msync enabling.  How much does this
change matter in practice?  If the mapping is long standing then I
expect this cost gets hidden?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
