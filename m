Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id D48546B0038
	for <linux-mm@kvack.org>; Fri, 11 Sep 2015 12:08:42 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so63717507wic.0
        for <linux-mm@kvack.org>; Fri, 11 Sep 2015 09:08:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o12si1542978wik.94.2015.09.11.09.08.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Sep 2015 09:08:41 -0700 (PDT)
Subject: Re: Multiple potential races on vma->vm_flags
References: <CAAeHK+z8o96YeRF-fQXmoApOKXa0b9pWsQHDeP=5GC_hMTuoDg@mail.gmail.com>
 <55EC9221.4040603@oracle.com> <20150907114048.GA5016@node.dhcp.inet.fi>
 <55F0D5B2.2090205@oracle.com> <20150910083605.GB9526@node.dhcp.inet.fi>
 <CAAeHK+xSFfgohB70qQ3cRSahLOHtamCftkEChEgpFpqAjb7Sjg@mail.gmail.com>
 <20150911103959.GA7976@node.dhcp.inet.fi> <55F2F354.1030607@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55F2FC87.6060908@suse.cz>
Date: Fri, 11 Sep 2015 18:08:39 +0200
MIME-Version: 1.0
In-Reply-To: <55F2F354.1030607@suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrey Konovalov <andreyknvl@google.com>, Oleg Nesterov <oleg@redhat.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

On 09/11/2015 05:29 PM, Vlastimil Babka wrote:
> On 09/11/2015 12:39 PM, Kirill A. Shutemov wrote:
>> On Thu, Sep 10, 2015 at 03:27:59PM +0200, Andrey Konovalov wrote:
>>> Can a vma be shared among a few mm's?
>>
>> Define "shared".
>>
>> vma can belong only to one process (mm_struct), but it can be accessed
>> from other process like in rmap case below.
>>
>> rmap uses anon_vma_lock for anon vma and i_mmap_rwsem for file vma to make
>> sure that the vma will not disappear under it.
>>
>>> If yes, then taking current->mm->mmap_sem to protect vma is not enough.
>>
>> Depends on what protection you are talking about.
>>
>>> In the first report below both T378 and T398 take
>>> current->mm->mmap_sem at mm/mlock.c:650, but they turn out to be
>>> different locks (the addresses are different).
>>
>> See i_mmap_lock_read() in T398. It will guarantee that vma is there.
>>
>>> In the second report T309 doesn't take any locks at all, since it
>>> assumes that after checking atomic_dec_and_test(&mm->mm_users) the mm
>>> has no other users, but then it does a write to vma.
>>
>> This one is tricky. I *assume* the mm cannot be generally accessible after
>> mm_users drops to zero, but I'm not entirely sure about it.
>> procfs? ptrace?
>>
>> The VMA is still accessible via rmap at this point. And I think it can be
>> a problem:
>>
>> 		CPU0					CPU1
>> exit_mmap()
>>     // mmap_sem is *not* taken
>>     munlock_vma_pages_all()
>>       munlock_vma_pages_range()
>>       						try_to_unmap_one()
>> 						  down_read_trylock(&vma->vm_mm->mmap_sem))
>> 						  !!(vma->vm_flags & VM_LOCKED) == true
>>         vma->vm_flags &= ~VM_LOCKED;
>>         <munlock the page>
>>         						  mlock_vma_page(page);
>> 						  // mlocked pages is leaked.
>>
>> The obvious solution is to take mmap_sem in exit path, but it would cause
>> performance regression.
>>
>> Any comments?
>
> Just so others don't repeat the paths that I already looked at:
>
> - First I thought that try_to_unmap_one() has the page locked and
> munlock_vma_pages_range() will also lock it... but it doesn't.

More precisely, it does (in __munlock_pagevec()), but 
TestClearPageMlocked(page) doesn't happen under that lock.

> - Then I thought that exit_mmap() will revisit the page anyway doing
> actual unmap. It would, if it's the one who has the page mapped, it will
> clear the mlock (see page_remove_rmap()). If it's not the last one, page
> will be left locked. So it won't be completely leaked, but still, it
> will be mlocked when it shouldn't.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
