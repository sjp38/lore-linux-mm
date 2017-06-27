Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB966B0350
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:48:10 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m19so20957777ioe.12
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 08:48:10 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id o195si3108781ioe.98.2017.06.27.08.48.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 08:48:09 -0700 (PDT)
Subject: Re: [RFC PATCH] userfaultfd: Add feature to request for a signal
 delivery
References: <9363561f-a9cd-7ab6-9c11-ab9a99dc89f1@oracle.com>
 <20170627070643.GA28078@dhcp22.suse.cz>
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Message-ID: <46792166-898b-47b7-ccd1-e128511b21ee@oracle.com>
Date: Tue, 27 Jun 2017 08:47:38 -0700
MIME-Version: 1.0
In-Reply-To: <20170627070643.GA28078@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>

On 6/27/17 12:06 AM, Michal Hocko wrote:

> This is an user visible API so let's CC linux-api mailing list.
>
> On Mon 26-06-17 12:46:13, Prakash Sangappa wrote:
>> In some cases, userfaultfd mechanism should just deliver a SIGBUS signal
>> to the faulting process, instead of the page-fault event. Dealing with
>> page-fault event using a monitor thread can be an overhead in these
>> cases. For example applications like the database could use the signaling
>> mechanism for robustness purpose.
> this is rather confusing. What is the reason that the monitor would be
> slower than signal delivery and handling?

There are a large number of single threaded database processes involved,
each of these processes will require a monitor thread which is considered
an overhead.

>
>> Database uses hugetlbfs for performance reason. Files on hugetlbfs
>> filesystem are created and huge pages allocated using fallocate() API.
>> Pages are deallocated/freed using fallocate() hole punching support.
>> These files are mmapped and accessed by many processes as shared memory.
>> The database keeps track of which offsets in the hugetlbfs file have
>> pages allocated.
>>
>> Any access to mapped address over holes in the file, which can occur due
>> to bugs in the application, is considered invalid and expect the process
>> to simply receive a SIGBUS.  However, currently when a hole in the file is
>> accessed via the mapped address, kernel/mm attempts to automatically
>> allocate a page at page fault time, resulting in implicitly filling the
>> hole in the file. This may not be the desired behavior for applications
>> like the database that want to explicitly manage page allocations of
>> hugetlbfs files.
> So you register UFFD_FEATURE_SIGBUS on each region tha you are unmapping
> and than just let those offenders die?

The database application will create the mapping and register with 
userfault.
Subsequently when the processes the mapping over a hole will result in 
SIGBUS
and die.

>
>> Using userfaultfd mechanism, with this support to get a signal, database
>> application can prevent pages from being allocated implicitly when
>> processes access mapped address over holes in the file.
>>
>> This patch adds the feature to request for a SIGBUS signal to userfaultfd
>> mechanism.
>>
>> See following for previous discussion about the database requirement
>> leading to this proposal as suggested by Andrea.
>>
>> http://www.spinics.net/lists/linux-mm/msg129224.html
> Please make those requirements part of the changelog.

The requirement is described above, which is the need for the database
application to not fill hole implicitly. Sorry, if this was not clear. I
will update the change log and send a v2 patch again.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
