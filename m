Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 17B806B04CA
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 17:03:00 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g53so1854722qtc.6
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 14:03:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k1si393084qkd.166.2017.07.11.14.02.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 14:02:59 -0700 (PDT)
Date: Tue, 11 Jul 2017 23:02:56 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH 1/1] mm/mremap: add MREMAP_MIRROR flag for existing
 mirroring functionality
Message-ID: <20170711210256.GF22628@redhat.com>
References: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
 <1499357846-7481-2-git-send-email-mike.kravetz@oracle.com>
 <20170711123642.GC11936@dhcp22.suse.cz>
 <7f14334f-81d1-7698-d694-37278f05a78e@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7f14334f-81d1-7698-d694-37278f05a78e@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Tue, Jul 11, 2017 at 11:23:19AM -0700, Mike Kravetz wrote:
> I was surprised as well when a JVM developer pointed this out.
> 
> From the old e-mail thread, here is original use case:
> shmget(IPC_PRIVATE, 31498240, 0x1c0|0600) = 11337732
> shmat(11337732, 0, 0)                   = 0x40299000
> shmctl(11337732, IPC_RMID, 0)           = 0
> mremap(0x402a9000, 0, 65536, MREMAP_MAYMOVE|MREMAP_FIXED, 0) = 0
> mremap(0x402a9000, 0, 65536, MREMAP_MAYMOVE|MREMAP_FIXED, 0x100000) = 0x100000
> 
> The JVM team wants to do something similar.  They are using
> mmap(MAP_ANONYMOUS|MAP_SHARED) to create the initial mapping instead
> of shmget/shmat.  As Vlastimil mentioned previously, one would not
> expect a shared mapping for parts of the JVM heap.  I am working
> to get clarification from the JVM team.

Why don't they use memfd_create instead? That's made so that the fd is
born anon unlinked so when the last reference is dropped all memory
associated with it is automatically freed. No need of IC_RMID and then
they can use mmap instead of mremap(len=0) to get a double map of it.

If they use mmap(MAP_ANONYMOUS|MAP_SHARED) it's not hugetlbfs, that
would have been the only issue.

Using hugetlbfs for JVM wouldn't be really flexible, better they try
to leverage THP on SHM or the hugetlbfs reservation gets in the way of
efficient use of the unused memory for memory allocations that don't
have a definitive size (i.e. JVM forks or more JVM are run in
parallel).

> Yes.  I think this should be a separate patch.  As mentioned earlier,
> mremap today creates a new/additional private mapping if called in this
> way with old_size == 0.  To me, this is a bug.

Kernel by sheer luck should stay stable, but the result is weird and
it's unlikely intentional.

memfd_create doesn't have such issue, the new mmap MAP_PRIVATE will
get the file pages correctly after a new mmap (even if there were cows
in the old MAP_PRIVATE mmap).

> One reason for the RFC was to determine if people thought we should:
> 1) Just document the existing old_size == 0 functionality
> 2) Create a more explicit interface such as a new mremap flag for this
>    functionality
> 
> I am waiting to see what direction people prefer before making any
> man page updates.

I guess old_size == 0 would better be dropped if possible, if
memfd_create fits perfectly your needs as I supposed above. If it's
not dropped then it's not very far from allowing mmap of /proc/self/mm
again (removed around so far as 2.3.x?).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
