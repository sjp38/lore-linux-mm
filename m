Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id DD4296810BE
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 17:57:46 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id f1so4023713ioj.11
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 14:57:46 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id r65si490337itc.28.2017.07.11.14.57.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 14:57:46 -0700 (PDT)
Subject: Re: [RFC PATCH 1/1] mm/mremap: add MREMAP_MIRROR flag for existing
 mirroring functionality
References: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
 <1499357846-7481-2-git-send-email-mike.kravetz@oracle.com>
 <20170711123642.GC11936@dhcp22.suse.cz>
 <7f14334f-81d1-7698-d694-37278f05a78e@oracle.com>
 <20170711210256.GF22628@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <fcfa8403-3151-41eb-4ac4-bbac55705626@oracle.com>
Date: Tue, 11 Jul 2017 14:57:38 -0700
MIME-Version: 1.0
In-Reply-To: <20170711210256.GF22628@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On 07/11/2017 02:02 PM, Andrea Arcangeli wrote:
> On Tue, Jul 11, 2017 at 11:23:19AM -0700, Mike Kravetz wrote:
>> I was surprised as well when a JVM developer pointed this out.
>>
>> From the old e-mail thread, here is original use case:
>> shmget(IPC_PRIVATE, 31498240, 0x1c0|0600) = 11337732
>> shmat(11337732, 0, 0)                   = 0x40299000
>> shmctl(11337732, IPC_RMID, 0)           = 0
>> mremap(0x402a9000, 0, 65536, MREMAP_MAYMOVE|MREMAP_FIXED, 0) = 0
>> mremap(0x402a9000, 0, 65536, MREMAP_MAYMOVE|MREMAP_FIXED, 0x100000) = 0x100000
>>
>> The JVM team wants to do something similar.  They are using
>> mmap(MAP_ANONYMOUS|MAP_SHARED) to create the initial mapping instead
>> of shmget/shmat.  As Vlastimil mentioned previously, one would not
>> expect a shared mapping for parts of the JVM heap.  I am working
>> to get clarification from the JVM team.
> 
> Why don't they use memfd_create instead? That's made so that the fd is
> born anon unlinked so when the last reference is dropped all memory
> associated with it is automatically freed. No need of IC_RMID and then
> they can use mmap instead of mremap(len=0) to get a double map of it.

Wow!  I did not even know about memfd_create until you mentioned it.
That would certainly work for 'normal' pages.

> If they use mmap(MAP_ANONYMOUS|MAP_SHARED) it's not hugetlbfs, that
> would have been the only issue.
> 
> Using hugetlbfs for JVM wouldn't be really flexible, better they try
> to leverage THP on SHM or the hugetlbfs reservation gets in the way of
> efficient use of the unused memory for memory allocations that don't
> have a definitive size (i.e. JVM forks or more JVM are run in
> parallel).

Well, the JVM has had a config option for the use of hugetlbfs for quite
some time.  I assume they have already had to deal with these issues.

What prompted this discussion is that they want the mremap mirroring/
duplication functionality extended to support hugetlbfs.  This is pretty
straight forward.  But, I wanted to have a discussion about whether the
mremap(old_size == 0) functionality should be formally documented first.

Do note that if you actually create/mount a hugetlbfs filesystem and
use a fd in that filesystem you can get the desired functionality.  However,
they want to avoid this extra step if possible and use mmap(anon, hugetlb).

I'm guessing that if memfd_create supported hugetlbfs, that would also
meet their needs.  Any thoughts about extending memfd_create support to
hugetlbfs?  I can't think of any big issues.  In fact, 'under the covers'
there actually is a hugetlbfs file created for anon mappings.  However,
that is not exposed to the user.

>> Yes.  I think this should be a separate patch.  As mentioned earlier,
>> mremap today creates a new/additional private mapping if called in this
>> way with old_size == 0.  To me, this is a bug.
> 
> Kernel by sheer luck should stay stable, but the result is weird and
> it's unlikely intentional.

Yes, that is why I think it is a bug.  Not that kernel is unstable, but
rather the unintentional/unexpected result.

> memfd_create doesn't have such issue, the new mmap MAP_PRIVATE will
> get the file pages correctly after a new mmap (even if there were cows
> in the old MAP_PRIVATE mmap).
> 
>> One reason for the RFC was to determine if people thought we should:
>> 1) Just document the existing old_size == 0 functionality
>> 2) Create a more explicit interface such as a new mremap flag for this
>>    functionality
>>
>> I am waiting to see what direction people prefer before making any
>> man page updates.
> 
> I guess old_size == 0 would better be dropped if possible, if
> memfd_create fits perfectly your needs as I supposed above. If it's
> not dropped then it's not very far from allowing mmap of /proc/self/mm
> again (removed around so far as 2.3.x?).

Yes, in my google'ing it appears the first users of mremap(old_size == 0)
previously used mmap of /proc/self/mm.

If memfd_create can be extended to support hugetlbfs, then I might suggest
dropping the memfd_create(old_size == 0) support.  Just a thought.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
