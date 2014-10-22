Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 797396B006E
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 10:01:01 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id r20so1460498wiv.13
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 07:01:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bf5si18496346wjc.82.2014.10.22.07.00.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Oct 2014 07:00:59 -0700 (PDT)
Message-ID: <5447B84C.4000909@redhat.com>
Date: Wed, 22 Oct 2014 15:59:40 +0200
From: Paolo Bonzini <pbonzini@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 0/4] mm: new function to forbid zeropage mappings for
 a process
References: <1413976170-42501-1-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1413976170-42501-1-git-send-email-dingel@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Dingel <dingel@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>



On 10/22/2014 01:09 PM, Dominik Dingel wrote:
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

... and zero the mm_use_skey flag correctly, too. :)

> v1 -> v2: 
>  - Following Dave and Paolo suggestion removing the vma flag

Thanks, the patches look good.  I expect that they will either go in
through the s390 tree, or come in via Christian.

If the latter, Martin, please reply with your Acked-by.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
