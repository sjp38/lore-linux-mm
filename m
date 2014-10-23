Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id D9F516B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 06:19:56 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id a1so771253wgh.9
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 03:19:56 -0700 (PDT)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id jb20si4515823wic.97.2014.10.23.03.19.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Oct 2014 03:19:55 -0700 (PDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 23 Oct 2014 11:19:54 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 5FC191B0804B
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 11:19:52 +0100 (BST)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9NAJp1G4653294
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 10:19:51 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9NAJoEe024553
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 04:19:51 -0600
Date: Thu, 23 Oct 2014 12:19:48 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH v3 0/4] mm: new function to forbid zeropage mappings for
 a process
Message-ID: <20141023121948.51e4a6cb@mschwide>
In-Reply-To: <1413976170-42501-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1413976170-42501-1-git-send-email-dingel@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Paolo Bonzini <pbonzini@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>

On Wed, 22 Oct 2014 13:09:26 +0200
Dominik Dingel <dingel@linux.vnet.ibm.com> wrote:

> s390 has the special notion of storage keys which are some sort of page flags
> associated with physical pages and live outside of direct addressable memory.
> These storage keys can be queried and changed with a special set of instructions.
> The mentioned instructions behave quite nicely under virtualization, if there is: 
> - an invalid pte, then the instructions will work on memory in the host page table
> - a valid pte, then the instructions will work with the real storage key
> 
> Thanks to Martin with his software reference and dirty bit tracking,
> the kernel does not issue any storage key instructions as now a 
> software based approach will be taken, on the other hand distributions 
> in the wild are currently using them.
> 
> However, for virtualized guests we still have a problem with guest pages 
> mapped to zero pages and the kernel same page merging.  
> With each one multiple guest pages will point to the same physical page
> and share the same storage key.
> 
> Let's fix this by introducing a new function which s390 will define to
> forbid new zero page mappings.  If the guest issues a storage key related 
> instruction we flag the mm_struct, drop existing zero page mappings
> and unmerge the guest memory.
> 
> v2 -> v3:
>  - Clearing up patch description Patch 3/4
>  - removing unnecessary flag in mmu_context (Paolo)
> 
> v1 -> v2: 
>  - Following Dave and Paolo suggestion removing the vma flag
> 
> Dominik Dingel (4):
>   s390/mm: recfactor global pgste updates
>   mm: introduce mm_forbids_zeropage function
>   s390/mm: prevent and break zero page mappings in case of storage keys
>   s390/mm: disable KSM for storage key enabled pages
> 
>  arch/s390/include/asm/pgalloc.h |   2 -
>  arch/s390/include/asm/pgtable.h |   8 +-
>  arch/s390/kvm/kvm-s390.c        |   2 +-
>  arch/s390/kvm/priv.c            |  17 ++--
>  arch/s390/mm/pgtable.c          | 180 ++++++++++++++++++----------------------
>  include/linux/mm.h              |   4 +
>  mm/huge_memory.c                |   2 +-
>  mm/memory.c                     |   2 +-
>  8 files changed, 106 insertions(+), 111 deletions(-)
 
Patches look good to me and as nobody seems to disagree with the proposed
solution I will add the code to the features branch of the s390 tree.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
