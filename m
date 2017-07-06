Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 25DF46B0401
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 20:39:29 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 123so5917500pgj.4
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 17:39:29 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d76si332877pfk.263.2017.07.05.17.39.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 17:39:28 -0700 (PDT)
Reply-To: prakash.sangappa@oracle.com
Subject: Re: [RFC PATCH v2] userfaultfd: Add feature to request for a signal
 delivery
References: <ff16daf5-7ba0-3dc2-7f73-eb7db8336df7@oracle.com>
 <20170704182806.GB4070@rapoport-lnx>
From: "prakash.sangappa" <prakash.sangappa@oracle.com>
Message-ID: <c1fa4d29-cbc9-6606-3e1f-9953078900a3@oracle.com>
Date: Wed, 5 Jul 2017 17:41:14 -0700
MIME-Version: 1.0
In-Reply-To: <20170704182806.GB4070@rapoport-lnx>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Michal Hocko <mhocko@kernel.org>



On 07/04/2017 11:28 AM, Mike Rapoport wrote:
> On Tue, Jun 27, 2017 at 09:08:40AM -0700, Prakash Sangappa wrote:
>> Applications like the database use hugetlbfs for performance reason.
>> Files on hugetlbfs filesystem are created and huge pages allocated
>> using fallocate() API. Pages are deallocated/freed using fallocate() hole
>> punching support. These files are mmap'ed and accessed by many
>> single threaded processes as shared memory.  The database keeps
>> track of which offsets in the hugetlbfs file have pages allocated.
>>
>> Any access to mapped address over holes in the file, which can occur due
>> to bugs in the application, is considered invalid and expect the process
>> to simply receive a SIGBUS.  However, currently when a hole in the file is
>> accessed via the mmap'ed address, kernel/mm attempts to automatically
>> allocate a page at page fault time, resulting in implicitly filling the
>> hole in the file. This may not be the desired behavior for applications
>> like the database that want to explicitly manage page allocations of
>> hugetlbfs files. The requirement here is for a way to prevent the kernel
>> from implicitly allocating a page  to fill holes in hugetbfs file.
>>
>> This can be achieved using userfaultfd mechanism to intercept page-fault
>> events when mmap'ed address over holes in the file are accessed, and
>> prevent kernel from implicitly filling the hole. However, currently using
>> userfaultfd would require each of the database processes to use a monitor
>> thread and the setup cost associated with it,  is considered an overhead.
>>
>> It would be better if userfaultd mechanism could have a way to request
>> simply sending a signal,for the robustness use case described above.
>> This would not require the use of a monitor thread.
>>
>> This patch adds the feature to userfaultfd mechanism to request for a
>> SIGBUS signal delivery to the faulting process, instead of the
>> page-fault event.
>>
>> See following for previous discussion about a different solution
>> to the above database requirement, leading to this proposal to enhance
>> userfaultfd, as suggested by Andrea.
>>
>> http://www.spinics.net/lists/linux-mm/msg129224.html
>>
>> Signed-off-by: Prakash <prakash.sangappa@oracle.com>
>> ---
>>   fs/userfaultfd.c                 |  5 +++++
>>   include/uapi/linux/userfaultfd.h | 10 +++++++++-
>>   2 files changed, 14 insertions(+), 1 deletion(-)
> Apparently your mail client clobbered the white space, can you please
> resend with proper formatting?
>   

Ok, Will resend the patch along with suggested changes.

>> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
>> index 1d622f2..5686d6d2 100644
>> --- a/fs/userfaultfd.c
>> +++ b/fs/userfaultfd.c
>> @@ -371,6 +371,11 @@ int handle_userfault(struct vm_fault *vmf, unsigned
>> long reason)
>>       VM_BUG_ON(reason & ~(VM_UFFD_MISSING|VM_UFFD_WP));
>>       VM_BUG_ON(!(reason & VM_UFFD_MISSING) ^ !!(reason & VM_UFFD_WP));
>>
>> +    if (ctx->features & UFFD_FEATURE_SIGBUS) {
>> +        goto out;
>> +    }
> Please remove the curly braces.

Ok,

>
>> +
>>       /*
>>        * If it's already released don't get it. This avoids to loop
>>        * in __get_user_pages if userfaultfd_release waits on the
>> diff --git a/include/uapi/linux/userfaultfd.h
>> b/include/uapi/linux/userfaultfd.h
>> index 3b05953..d39d5db 100644
>> --- a/include/uapi/linux/userfaultfd.h
>> +++ b/include/uapi/linux/userfaultfd.h
>> @@ -23,7 +23,8 @@
>>                  UFFD_FEATURE_EVENT_REMOVE |    \
>>                  UFFD_FEATURE_EVENT_UNMAP |        \
>>                  UFFD_FEATURE_MISSING_HUGETLBFS |    \
>> -               UFFD_FEATURE_MISSING_SHMEM)
>> +               UFFD_FEATURE_MISSING_SHMEM |        \
>> +               UFFD_FEATURE_SIGBUS)
>>   #define UFFD_API_IOCTLS                \
>>       ((__u64)1 << _UFFDIO_REGISTER |        \
>>        (__u64)1 << _UFFDIO_UNREGISTER |    \
>> @@ -153,6 +154,12 @@ struct uffdio_api {
>>        * UFFD_FEATURE_MISSING_SHMEM works the same as
>>        * UFFD_FEATURE_MISSING_HUGETLBFS, but it applies to shmem
>>        * (i.e. tmpfs and other shmem based APIs).
>> +     *
>> +     * UFFD_FEATURE_SIGBUS feature means no page-fault
>> +     * (UFFD_EVENT_PAGEFAULT) event will be delivered, instead
>> +     * a SIGBUS signal will be sent to the faulting process.
>> +     * The application process can enable this behavior by adding
>> +     * it to uffdio_api.features.
> I think that it maybe worth making UFFD_FEATURE_SIGBUS mutually exclusive
> with the non-cooperative events. There is no point of having monitor if the
> page fault handler will anyway just kill the faulting process.


Will this not be too restrictive?. The non-cooperative events could
still be useful if an application wants to track changes
to VA ranges that are registered even though it expects
a signal on page fault.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
