Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2CEFF28030E
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 14:24:15 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id z62so46799322ioi.8
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 11:24:15 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id z191si2664925ioe.46.2017.06.28.11.24.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 11:24:14 -0700 (PDT)
Subject: Re: [RFC PATCH] userfaultfd: Add feature to request for a signal
 delivery
References: <9363561f-a9cd-7ab6-9c11-ab9a99dc89f1@oracle.com>
 <20170627070643.GA28078@dhcp22.suse.cz> <20170627153557.GB10091@rapoport-lnx>
 <51508e99-d2dd-894f-8d8a-678e3747c1ee@oracle.com>
 <20170628131806.GD10091@rapoport-lnx>
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Message-ID: <3a8e0042-4c49-3ec8-c59f-9036f8e54621@oracle.com>
Date: Wed, 28 Jun 2017 11:23:32 -0700
MIME-Version: 1.0
In-Reply-To: <20170628131806.GD10091@rapoport-lnx>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>, linux-api@vger.kernel.org



On 6/28/17 6:18 AM, Mike Rapoport wrote:
> On Tue, Jun 27, 2017 at 09:01:20AM -0700, Prakash Sangappa wrote:
>> On 6/27/17 8:35 AM, Mike Rapoport wrote:
>>
>>> On Tue, Jun 27, 2017 at 09:06:43AM +0200, Michal Hocko wrote:
>>>> This is an user visible API so let's CC linux-api mailing list.
>>>>
>>>> On Mon 26-06-17 12:46:13, Prakash Sangappa wrote:
>>>>
>>>>> Any access to mapped address over holes in the file, which can occur due
>>>>> to bugs in the application, is considered invalid and expect the process
>>>>> to simply receive a SIGBUS.  However, currently when a hole in the file is
>>>>> accessed via the mapped address, kernel/mm attempts to automatically
>>>>> allocate a page at page fault time, resulting in implicitly filling the
>>>>> hole in the file. This may not be the desired behavior for applications
>>>>> like the database that want to explicitly manage page allocations of
>>>>> hugetlbfs files.
>>>> So you register UFFD_FEATURE_SIGBUS on each region tha you are unmapping
>>>> and than just let those offenders die?
>>> If I understand correctly, the database will create the mapping, then it'll
>>> open userfaultfd and register those mappings with the userfault.
>>> Afterwards, when the application accesses a hole userfault will cause
>>> SIGBUS and the application will process it in whatever way it likes, e.g.
>>> just die.
>> Yes.
>>
>>> What I don't understand is why won't you use userfault monitor process that
>>> will take care of the page fault events?
>>> It shouldn't be much overhead running it and it can keep track on all the
>>> userfault file descriptors for you and it will allow more versatile error
>>> handling that SIGBUS.
>>>
>> Co-ordination with the external monitor process by all the database
>> processes
>> to send  their userfaultfd is still an overhead.
> You are planning to register in userfaultfd only the holes you punch to
> deallocate pages, am I right?


No, the entire mmap'ed region. The DB processes would mmap(MAP_NORESERVE)
hugetlbfs files, register this mapped address with userfaultfd ones 
right after
the mmap() call.

>
> And the co-ordination of the userfault file descriptor with the monitor
> would have been added after calls to fallocate() and userfaultfd_register()?

Well, the database application does not need to deal with a monitor.

>
> I've just been thinking that maybe it would be possible to use
> UFFD_EVENT_REMOVE for this case. We anyway need to implement the generation
> of UFFD_EVENT_REMOVE for the case of hole punching in hugetlbfs for
> non-cooperative userfaultfd. It could be that it will solve your issue as
> well.
>

Will this result in a signal delivery?

In the use case described, the database application does not need any event
for  hole punching. Basically, just a signal for any invalid access to 
mapped
area over holes in the file.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
