Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E025C82F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 17:15:48 -0400 (EDT)
Received: by padhy1 with SMTP id hy1so11692184pad.0
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 14:15:48 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id nc3si39796970pbc.24.2015.10.28.14.15.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 14:15:48 -0700 (PDT)
Subject: Re: [PATCH v2 0/4] hugetlbfs fallocate hole punch race with page
 faults
References: <1445385142-29936-1-git-send-email-mike.kravetz@oracle.com>
 <alpine.LSU.2.11.1510271919200.2872@eggly.anvils>
 <5630F274.5010908@oracle.com>
 <alpine.LSU.2.11.1510281332050.4687@eggly.anvils>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <56313A7D.4000102@oracle.com>
Date: Wed, 28 Oct 2015 14:13:33 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1510281332050.4687@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

On 10/28/2015 02:00 PM, Hugh Dickins wrote:
> On Wed, 28 Oct 2015, Mike Kravetz wrote:
>> On 10/27/2015 08:34 PM, Hugh Dickins wrote:
>>
>> Thanks for the detailed response Hugh.  I will try to address your questions
>> and provide more reasoning behind the use case and need for this code.
> 
> And thank you for your detailed response, Mike: that helped a lot.
> 
>> Ok, here is a bit more explanation of the proposed use case.  It all
>> revolves around a DB's use of hugetlbfs and the desire for more control
>> over the underlying memory.  This additional control is achieved by
>> adding existing fallocate and userfaultfd semantics to hugetlbfs.
>>
>> In this use case there is a single process that manages hugetlbfs files
>> and the underlying memory resources.  It pre-allocates/initializes these
>> files.
>>
>> In addition, there are many other processes which access (rw mode) these
>> files.  They will simply mmap the files.  It is expected that they will
>> not fault in any new pages.  Rather, all pages would have been pre-allocated
>> by the management process.
>>
>> At some time, the management process determines that specific ranges of
>> pages within the hugetlbfs files are no longer needed.  It will then punch
>> holes in the files.  These 'free' pages within the holes may then be used
>> for other purposes.  For applications like this (sophisticated DBs), huge
>> pages are reserved at system init time and closely managed by the
>> application.
>> Hence, the desire for this additional control.
>>
>> So, when a hole containing N huge pages is punched, the management process
>> wants to know that it really has N huge pages for other purposes.  Ideally,
>> none of the other processes mapping this file/area would access the hole.
>> This is an application error, and it can be 'caught' with  userfaultfd.
>>
>> Since these other (non-management) processes will never fault in pages,
>> they would simply set up userfaultfd to catch any page faults immediately
>> after mmaping the hugetlbfs file.
>>
>>>
>>> But it sounds to me more as if the holes you want punched are not
>>> quite like on other filesystems, and you want to be able to police
>>> them afterwards with userfaultfd, to prevent them from being refilled.
>>
>> I am not sure if they are any different.
>>
>> One could argue that a hole punch operation must always result in all
>> pages within the hole being deallocated.  As you point out, this could
>> race with a fault.  Previously, there would be no way to determine if
>> all pages had been deallocated because user space could not detect this
>> race.  Now, userfaultfd allows user space to catch page faults.  So,
>> it is now possible to catch/depend on hole punch deallocating all pages
>> within the hole.
>>
>>>
>>> Can't userfaultfd be used just slightly earlier, to prevent them from
>>> being filled while doing the holepunch?  Then no need for this patchset?
>>
>> I do not think so, at least with current userfaultfd semantics.  The hole
>> needs to be punched before being caught with UFFDIO_REGISTER_MODE_MISSING.
> 
> Great, that makes sense.
> 
> I was worried that you needed some kind of atomic treatment of the whole
> extent punched, but all you need is to close the hole/fault race one
> hugepage at a time.
> 
> Throw away all of 1/4, 2/4, 3/4: I think all you need is your 4/4
> (plus i_mmap_lock_write around the hugetlb_vmdelete_list of course).
> 
> There you already do the single hugepage hugetlb_vmdelete_list()
> under mutex_lock(&hugetlb_fault_mutex_table[hash]).
> 
> And it should come as no surprise that hugetlb_fault() does most
> of its work under that same mutex.
> 
> So once remove_inode_hugepages() unlocks the mutex, that page is gone
> from the file, and userfaultfd UFFDIO_REGISTER_MODE_MISSING will do
> what you want, won't it?
> 
> I don't think "my" code buys you anything at all: you're not in danger of
> shmem's starvation livelock issue, partly because remove_inode_hugepages()
> uses the simple loop from start to end, and partly because hugetlb_fault()
> already takes the serializing mutex (no equivalent in shmem_fault()).
> 
> Or am I dreaming?

I don't think you are dreaming.

I should have stepped back and thought about this more before before pulling
in the shmem code.  It really is only a 'page at a time' operation, and we
can use the fault mutex table for that.

I'll code it up with just the changes needed for 4/4 and put it through some
stress testing.

Thanks,
-- 
Mike Kravetz

> 
> Hugh
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
