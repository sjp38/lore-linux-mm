Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 996716B0279
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 19:36:23 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s65so142983341pfi.14
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 16:36:23 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id s22si13241959plk.185.2017.06.20.16.36.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 16:36:22 -0700 (PDT)
Subject: Re: [PATCH RFC] hugetlbfs 'noautofill' mount option
References: <326e38dd-b4a8-e0ca-6ff7-af60e8045c74@oracle.com>
 <b0efc671-0d7a-0aef-5646-a635478c31b0@oracle.com>
 <7ff6fb32-7d16-af4f-d9d5-698ab7e9e14b@intel.com>
 <03127895-3c5a-5182-82de-3baa3116749e@oracle.com>
 <22557bf3-14bb-de02-7b1b-a79873c583f1@intel.com>
 <7677d20e-5d53-1fb7-5dac-425edda70b7b@oracle.com>
 <48a544c4-61b3-acaf-0386-649f073602b6@intel.com>
 <476ea1b6-36d1-bc86-fa99-b727e3c2650d@oracle.com>
 <20170509085825.GB32555@infradead.org>
 <1031e0d4-cdbb-db8b-dae7-7c733921e20e@oracle.com>
 <20170616131554.GD11676@redhat.com>
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Message-ID: <47ea78b4-3b14-264e-2c92-e5e507fd3cba@oracle.com>
Date: Tue, 20 Jun 2017 16:35:37 -0700
MIME-Version: 1.0
In-Reply-To: <20170616131554.GD11676@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>



On 6/16/17 6:15 AM, Andrea Arcangeli wrote:
> Hello Prakash,


Thanks for you response. Comments inline.

>
> On Tue, May 09, 2017 at 01:59:34PM -0700, Prakash Sangappa wrote:
>>
>> On 5/9/17 1:58 AM, Christoph Hellwig wrote:
>>> On Mon, May 08, 2017 at 03:12:42PM -0700, prakash.sangappa wrote:
>>>> Regarding #3 as a general feature, do we want to
>>>> consider this and the complexity associated with the
>>>> implementation?
>>> We have to.  Given that no one has exclusive access to hugetlbfs
>>> a mount option is fundamentally the wrong interface.
>>
>> A hugetlbfs filesystem may need to be mounted for exclusive use by
>> an application. Note, recently the 'min_size' mount option was added
>> to hugetlbfs, which would reserve minimum number of huge pages
>> for that filesystem for use by an application. If the filesystem with
>> min size specified, is not setup for exclusive use by an application,
>> then the purpose of reserving huge pages is defeated.  The
>> min_size option was for use by applications like the database.
>>
>> Also, I am investigating enabling hugetlbfs mounts within user
>> namespace's mount namespace. That would allow an application
>> to mount a hugetlbfs filesystem inside a namespace exclusively for
>> its use, running as a non root user. For this it seems like the 'min_size'
>> should be subject to some user limits. Anyways, mounting inside
>> user namespaces is  a different discussion.
>>
>> So, if a filesystem has to be setup for exclusive use by an application,
>> then different mount options can be used for that filesystem.
> Before userfaultfd I used a madvise that triggered SIGBUS. Aside from
> performance that is much lower than userfaultfd because of the return
> to userland, SIGBUS handling and new enter kernel to communicate
> through a pipe with a memory manager, it couldn't work reliably
> because you're not going to get exact information on the virtual
> address that triggered the fault if the SIGBUS triggers in some random
> in a copy-user of some random syscall, depending on the syscall some
> random error will be returned. So it couldn't work transparently to
> the app as far as syscalls and get_user_pages drivers were concerned.


Sure, seems like that would be the case if an application wants to take 
some action as a result of the fault.

>
> With your solution if you pass a corrupted pointer to a random read()
> syscall you're going to get a error, but supposedly you already handle
> any syscall error and stop the app.


Yes, the expectation is  that the application will handle the error and 
stop. This would be similar to an application passing an invalid  
address to a system call.

So, in the use case for this feature,  accessing the mapped address over 
a hole in hugetlbfs file is invalid. The application will keep track of 
the valid regions.


>
> This is a special case because you don't care about performance and
> you don't care about not returning random EFAULT errors from syscalls
> like read().


Exactly.

>
> This mount option seems non intrusive enough and hugetlbfs is quite
> special already, so I'm not particularly concerned by the fact it's
> one more special tweak.
>
> If it would be enough to convert the SIGBUS into a (killable) process
> hang, you could still use uffd and there would be no need to send the
> uffd to a manager. You'd find the corrupting buggy process stuck in
> handle_userfault().


This could be a useful feature in debug mode.  However, In the normal 
mode the application should exit/die.

>
> As an alternative to the mount option we could consider adding
> UFFD_FEATURE_SIGBUS that tells the handle_userfault() to simply return
> VM_FAULT_SIGBUS in presence of a pagefault event. You'd still get
> weird EFAULT or erratic retvals from syscalls so it would only be
> usable in for your robustness feature. Then you could use UFFDIO_COPY
> too to fill the memory atomically which runs faster than a page fault
> (fallocate punch hole still required to zap it).
>
> Adding a single if (ctx->feature & UFFD_FEATURE_SIGBUS) goto out,
> branch for this corner case to handle_userfault() isn't great and the
> hugetlbfs mount option is absolutely zero cost to the handle_userfault
> which is primarily why I'm not against it.. although it's not going to
> be measurable so it would be ok also to add such feature.


Sure, UFFD_FEATURE_SIGBUS would address the use case for the database 
using hugetlbfs. This could be a generic API and so could be useful in 
other cases as well maybe?

However for this, the userfaultfd(2)  has to be opened to register. This 
fd has to remain opened. Is this ok? Also, even though  a monitor thread 
will not be required for this particular feature, hopefully it will not 
hinder future  enhancements to userfaultfd.

Expectation is that the overhead of registering UFFD_FEATURE_SIGBUS is 
minimal, and the registration will be done by the application ones after 
every mmap() call as required, hopefully this is not required to be done 
frequently. In the database use case, the registration  will mainly be 
done once in the beginning when mapping hugetlbfs files, so should be ok.

The mount option proposed, would give one consistent behavior for the 
filesystem and will not require the application to take any additional 
steps.

If implementing UFFD_FEATURE_SIGBUS is preferred instead of the mount 
option, I could look into that.


Thanks,
-Prakash.

>
> Thanks,
> Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
