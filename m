Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BD18A6B02C4
	for <linux-mm@kvack.org>; Tue,  2 May 2017 12:07:04 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t130so60759603pgc.18
        for <linux-mm@kvack.org>; Tue, 02 May 2017 09:07:04 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id y20si18498513pfj.343.2017.05.02.09.07.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 09:07:03 -0700 (PDT)
Subject: Re: [PATCH RFC] hugetlbfs 'noautofill' mount option
References: <326e38dd-b4a8-e0ca-6ff7-af60e8045c74@oracle.com>
 <b0efc671-0d7a-0aef-5646-a635478c31b0@oracle.com>
 <06c4eb97-1545-7958-7694-3645d317666b@linux.vnet.ibm.com>
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Message-ID: <07f3fde3-b296-f205-377d-1b4c3bbedb70@oracle.com>
Date: Tue, 2 May 2017 09:07:00 -0700
MIME-Version: 1.0
In-Reply-To: <06c4eb97-1545-7958-7694-3645d317666b@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 5/2/17 3:53 AM, Anshuman Khandual wrote:
> On 05/01/2017 11:30 PM, Prakash Sangappa wrote:
>> Some applications like a database use hugetblfs for performance
>> reasons. Files on hugetlbfs filesystem are created and huge pages
>> allocated using fallocate() API. Pages are deallocated/freed using
>> fallocate() hole punching support that has been added to hugetlbfs.
>> These files are mmapped and accessed by many processes as shared memory.
>> Such applications keep track of which offsets in the hugetlbfs file have
>> pages allocated.
>>
>> Any access to mapped address over holes in the file, which can occur due
> s/mapped/unmapped/ ^ ?

It is 'mapped' address.

>
>> to bugs in the application, is considered invalid and expect the process
>> to simply receive a SIGBUS.  However, currently when a hole in the file is
>> accessed via the mapped address, kernel/mm attempts to automatically
>> allocate a page at page fault time, resulting in implicitly filling the
>> hole
> But this is expected when you try to control the file allocation from
> a mapped address. Any changes while walking past or writing the range
> in the memory mapped should reflect exactly in the file on the disk.
> Why its not a valid behavior ?
Sure, that is a valid behavior. However, hugetlbfs is a pesudo filesystem
and the purpose is for applications to use hugepage memory. The contents
of these filesystem are not backed by disk nor are they swapped out.

The proposed new behavior is only applicable for hugetlbfs filesystem 
mounted
with the new 'noautofill' mount option. The file's page allocation/free 
are managed
using the 'fallocate()' API.

For hugetlbfs filesystems mounted without this option, there is no 
change in behavior.

>> in the file. This may not be the desired behavior for applications like the
>> database that want to explicitly manage page allocations of hugetlbfs
>> files.
>>
>> This patch adds a new hugetlbfs mount option 'noautofill', to indicate that
>> pages should not be allocated at page fault time when accessed thru mmapped
>> address.
> When the page should be allocated for mapping ?
The application would allocate/free file pages using the fallocate() API.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
