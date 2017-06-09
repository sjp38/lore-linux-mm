Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1E26B0279
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 04:21:03 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p190so2877799wme.3
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 01:21:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q1si478652wrc.106.2017.06.09.01.21.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Jun 2017 01:21:01 -0700 (PDT)
Subject: Re: [PATCH 2/4] thp: fix MADV_DONTNEED vs. numa balancing race
From: Vlastimil Babka <vbabka@suse.cz>
References: <20170302151034.27829-1-kirill.shutemov@linux.intel.com>
 <20170302151034.27829-3-kirill.shutemov@linux.intel.com>
 <f105f6a5-bb5e-9480-6b2e-d2d15f631af9@suse.cz>
 <20170516202919.GA2843@redhat.com>
 <744fe557-3aaf-0010-4b94-5f53c9f28f89@suse.cz>
Message-ID: <3b6e3eab-3d61-e7f8-0ebd-886b7c9c23e9@suse.cz>
Date: Fri, 9 Jun 2017 10:21:00 +0200
MIME-Version: 1.0
In-Reply-To: <744fe557-3aaf-0010-4b94-5f53c9f28f89@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 05/23/2017 02:42 PM, Vlastimil Babka wrote:
> On 05/16/2017 10:29 PM, Andrea Arcangeli wrote:
>> On Wed, Apr 12, 2017 at 03:33:35PM +0200, Vlastimil Babka wrote:
>>>
>>> pmdp_invalidate() does:
>>>
>>>         pmd_t entry = *pmdp;
>>>         set_pmd_at(vma->vm_mm, address, pmdp, pmd_mknotpresent(entry));
>>>
>>> so it's not atomic and if CPU sets dirty or accessed in the middle of
>>> this, they will be lost?
>>
>> I agree it looks like the dirty bit can be lost. Furthermore this also
>> loses a MMU notifier invalidate that will lead to corruption at the
>> secondary MMU level (which will keep using the old protection
>> permission, potentially keeping writing to a wrprotected page).
> 
> Oh, I didn't paste the whole function, just the pmd manipulation.
> There's also a third line:
> 
> flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
> 
> so there's no missing invalidate, AFAICS? Sorry for the confusion.

Oh, tlb flush is not MMU notified invalidate...

>>>
>>> But I don't see how the other invalidate caller
>>> __split_huge_pmd_locked() deals with this either. Andrea, any idea?
>>
>> The original code I wrote did this in __split_huge_page_map to create
>> the "entry" to establish in the pte pagetables:
>>
>>     	       entry = mk_pte(page + i, vma->vm_page_prot);
>> 	       entry = maybe_mkwrite(pte_mkdirty(entry),
>> 	       	       		   vma);
>>
>> For anonymous memory the dirty bit is only meaningful for swapping,
>> and THP couldn't be swapped so setting it unconditional avoided any
>> issue with the pmdp_invalidate; pmdp_establish.
> 
> Yeah, but now we are going to swap THP's, and we have shmem THP's...
> 
>> pmdp_invalidate is needed primarily to avoid aliasing of two different
>> TLB translation pointing from the same virtual address to the the same
>> physical address that triggered machine checks (while needing to keep
>> the pmd huge at all times, back then it was also splitting huge,
>> splitting is a software bit so userland could still access the data,
>> splitting bit only blocked kernel code to manipulate on it similar to
>> what migration entry does right now upstream, except those prevent
>> userland to access the page during split which is less efficient than
>> the splitting bit, but at least it's only used for the physical split,
>> back then there was no difference between virtual and physical split
>> and physical split is less frequent than the virtual one right now).
> 
> This took me a while to grasp, but I think I understand now :)
> 
>> It looks like this needs a pmdp_populate that atomically grabs the
>> value of the pmd and returns it like pmdp_huge_get_and_clear_notify
>> does
> 
> pmdp_huge_get_and_clear_notify() is now gone...
> 
>> and a _notify variant to use "freeze" is false (if freeze is true
>> the MMU notifier invalidate must have happened when the pmd was set to
>> a migration entry). If pmdp_populate_notify (freeze==true)
>> /pmd_populate (freeze==false) would return the old pmd value
>> atomically with xchg() (just instead of setting it to 0 we should set
>> it to the mknotpresent one), then we can set the dirty bit on the ptes
>> (__split_huge_pmd_locked) or in the pmd itself in the change_huge_pmd
>> accordingly.

I was trying to look into this yesterday, but e.g. I know next to
nothing about MMU notifiers (see above :) so I would probably get it
wrong. But it should get fixed, so... Kirill?

> I think the confusion was partially caused by the comment at the
> original caller of pmdp_invalidate():
> 
> we first mark the
> * current pmd notpresent (atomically because here the pmd_trans_huge
> * and pmd_trans_splitting must remain set at all times on the pmd
> * until the split is complete for this pmd),
> 
> It says "atomically" but in fact that only means that the pmd_trans_huge
> and pmd_trans_splitting flags are not temporarily cleared at any point
> of time, right? It's not a true atomic swap.
> 
>> If the "dirty" flag information is obtained by the pmd read before
>> calling pmdp_invalidate is not ok (losing _notify also not ok).
> 
> Right.
> 
>> Thanks!
>> Andrea
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
