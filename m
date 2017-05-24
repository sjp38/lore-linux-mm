Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 615606B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 03:58:43 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a203so21488180wma.12
        for <linux-mm@kvack.org>; Wed, 24 May 2017 00:58:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b26si20340346edd.137.2017.05.24.00.58.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 00:58:42 -0700 (PDT)
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
References: <1495433562-26625-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170522114243.2wrdbncilozygbpl@node.shutemov.name>
 <20170522133559.GE27382@rapoport-lnx> <20170522135548.GA8514@dhcp22.suse.cz>
 <20170522142927.GG27382@rapoport-lnx>
 <a9e74c22-1a07-f49a-42b5-497fee85e9c9@suse.cz>
 <20170524075043.GB3063@rapoport-lnx>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c59a0893-d370-130b-5c33-d567a4621903@suse.cz>
Date: Wed, 24 May 2017 09:58:06 +0200
MIME-Version: 1.0
In-Reply-To: <20170524075043.GB3063@rapoport-lnx>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On 05/24/2017 09:50 AM, Mike Rapoport wrote:
> On Mon, May 22, 2017 at 05:52:47PM +0200, Vlastimil Babka wrote:
>> On 05/22/2017 04:29 PM, Mike Rapoport wrote:
>>> On Mon, May 22, 2017 at 03:55:48PM +0200, Michal Hocko wrote:
>>>> On Mon 22-05-17 16:36:00, Mike Rapoport wrote:
>>>>> On Mon, May 22, 2017 at 02:42:43PM +0300, Kirill A. Shutemov wrote:
>>>>>> On Mon, May 22, 2017 at 09:12:42AM +0300, Mike Rapoport wrote:
>>>>>>> Currently applications can explicitly enable or disable THP for a memory
>>>>>>> region using MADV_HUGEPAGE or MADV_NOHUGEPAGE. However, once either of
>>>>>>> these advises is used, the region will always have
>>>>>>> VM_HUGEPAGE/VM_NOHUGEPAGE flag set in vma->vm_flags.
>>>>>>> The MADV_CLR_HUGEPAGE resets both these flags and allows managing THP in
>>>>>>> the region according to system-wide settings.
>>>>>>
>>>>>> Seems reasonable. But could you describe an use-case when it's useful in
>>>>>> real world.
>>>>>
>>>>> My use-case was combination of pre- and post-copy migration of containers
>>>>> with CRIU.
>>>>> In this case we populate a part of a memory region with data that was saved
>>>>> during the pre-copy stage. Afterwards, the region is registered with
>>>>> userfaultfd and we expect to get page faults for the parts of the region
>>>>> that were not yet populated. However, khugepaged collapses the pages and
>>>>> the page faults we would expect do not occur.
>>>>
>>>> I am not sure I undestand the problem. Do I get it right that the
>>>> khugepaged will effectivelly corrupt the memory by collapsing a range
>>>> which is not yet fully populated? If yes shouldn't that be fixed in
>>>> khugepaged rather than adding yet another madvise command? Also how do
>>>> you prevent on races? (say you VM_NOHUGEPAGE, khugepaged would be in the
>>>> middle of the operation and sees a collapsable vma and you get the same
>>>> result)
>>>
>>> Probably I didn't explained it too well.
>>>
>>> The range is intentionally not populated. When we combine pre- and
>>> post-copy for process migration, we create memory pre-dump without stopping
>>> the process, then we freeze the process without dumping the pages it has
>>> dirtied between pre-dump and freeze, and then, during restore, we populate
>>> the dirtied pages using userfaultfd.
>>>
>>> When CRIU restores a process in such scenario, it does something like:
>>>
>>> * mmap() memory region
>>> * fill in the pages that were collected during the pre-dump
>>> * do some other stuff
>>> * register memory region with userfaultfd
>>> * populate the missing memory on demand
>>>
>>> khugepaged collapses the pages in the partially populated regions before we
>>> have a chance to register these regions with userfaultfd, which would
>>> prevent the collapse.
>>>
>>> We could have used MADV_NOHUGEPAGE right after the mmap() call, and then
>>> there would be no race because there would be nothing for khugepaged to
>>> collapse at that point. But the problem is that we have no way to reset
>>> *HUGEPAGE flags after the memory restore is complete.
>>
>> Hmm, I wouldn't be that sure if this is indeed race-free. Check that
>> this scenario is indeed impossible?
>>
>> - you do the mmap
>> - khugepaged will choose the process' mm to scan
>> - khugepaged will get to the vma in question, it doesn't have
>> MADV_NOHUGEPAGE yet
>> - you set MADV_NOHUGEPAGE on the vma
>> - you start populating the vma
>> - khugepaged sees the vma is non-empty, collapses
>>
>> unless I'm wrong, the racers will have mmap_sem for reading only when
>> setting/checking the MADV_NOHUGEPAGE? Might be actually considered a bug.
>>
>> However, can't you use prctl(PR_SET_THP_DISABLE) instead? "If arg2 has a
>> nonzero value, the flag is set, otherwise it is cleared." says the
>> manpage. Do it before the mmap and you avoid the race as well?
> 
> Unfortunately, prctl(PR_SET_THP_DISABLE) didn't help :(
> When I've tried to use it, I've ended up with VM_NOHUGEPAGE set on all VMAs
> created after prctl(). This returns me to the state when checkpoint-restore
> alters the application vma->vm_flags although it shouldn't and I do not see
> a way to fix it using existing interfaces.

[CC linux-api, should have been done in the initial posting already]

Hm so the prctl does:

                if (arg2)
                        me->mm->def_flags |= VM_NOHUGEPAGE;
                else
                        me->mm->def_flags &= ~VM_NOHUGEPAGE;

That's rather lazy implementation IMHO. Could we change it so the flag
is stored elsewhere in the mm, and the code that decides to (not) use
THP will check both the per-vma flag and the per-mm flag?

> --
> Sincerely yours,
> Mike. 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
