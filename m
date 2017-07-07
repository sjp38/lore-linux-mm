Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id F1B106B02F3
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 13:04:16 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id 191so13584110vko.1
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 10:04:16 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id e38si2001469uah.20.2017.07.07.10.04.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 10:04:15 -0700 (PDT)
Subject: Re: [RFC PATCH 0/1] mm/mremap: add MREMAP_MIRROR flag
References: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
 <6f1460ef-a896-aef4-c0dc-66227232e025@linux.vnet.ibm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <e2650043-744b-3c24-01bc-18d3674ea491@oracle.com>
Date: Fri, 7 Jul 2017 10:04:04 -0700
MIME-Version: 1.0
In-Reply-To: <6f1460ef-a896-aef4-c0dc-66227232e025@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 07/07/2017 01:19 AM, Anshuman Khandual wrote:
> On 07/06/2017 09:47 PM, Mike Kravetz wrote:
>> The mremap system call has the ability to 'mirror' parts of an existing
>> mapping.  To do so, it creates a new mapping that maps the same pages as
>> the original mapping, just at a different virtual address.  This
>> functionality has existed since at least the 2.6 kernel [1].  A comment
>> was added to the code to help preserve this feature.
> 
> 
> Is this the comment ? If yes, then its not very clear.
> 
> 	/*
> 	 * We allow a zero old-len as a special case
> 	 * for DOS-emu "duplicate shm area" thing. But
> 	 * a zero new-len is nonsensical.
> 	 */
> 

Yes, I believe that is the comment.

>>
>> The Oracle JVM team has discovered this feature and used it while
>> prototyping a new garbage collection model.  This new model shows promise,
>> and they are considering its use in a future release.  However, since
>> the only mention of this functionality is a single comment in the kernel,
>> they are concerned about its future.
>>
>> I propose the addition of a new MREMAP_MIRROR flag to explicitly request
>> this functionality.  The flag simply provides the same functionality as
>> the existing undocumented 'old_size == 0' interface.  As an alternative,
>> we could simply document the 'old_size == 0' interface in the man page.
>> In either case, man page modifications would be needed.
> 
> Right. Adding MREMAP_MIRROR sounds cleaner from application programming
> point of view. But it extends the interface.

Yes.  That is the reason for the RFC.  We currently have functionality
that is not clearly part of a programming interface.  Application programmers
do not like to depend on something that is not part of an interface.

>>
>> Future Direction
>>
>> After more formally adding this to the API (either new flag or documenting
>> existing interface), the mremap code could be enhanced to optimize this
>> case.  Currently, 'mirroring' only sets up the new mapping.  It does not
>> create page table entries for new mapping.  This could be added as an
>> enhancement.
> 
> Then how it achieves mirroring, both the pointers should see the same
> data, that can happen with page table entries pointing to same pages,
> right ?

Correct.

In the code today, page tables for the new (mirrored) mapping are created
as needed via faults.  The enhancement would be to create page table entries
for the new mapping.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
