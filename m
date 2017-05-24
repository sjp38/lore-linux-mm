Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DFDF16B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 10:25:15 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t126so113500069pgc.9
        for <linux-mm@kvack.org>; Wed, 24 May 2017 07:25:15 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0129.outbound.protection.outlook.com. [104.47.2.129])
        by mx.google.com with ESMTPS id l10si24518905pln.71.2017.05.24.07.25.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 24 May 2017 07:25:14 -0700 (PDT)
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
References: <1495433562-26625-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170522114243.2wrdbncilozygbpl@node.shutemov.name>
 <20170522133559.GE27382@rapoport-lnx> <20170522135548.GA8514@dhcp22.suse.cz>
 <20170522142927.GG27382@rapoport-lnx>
 <a9e74c22-1a07-f49a-42b5-497fee85e9c9@suse.cz>
 <20170524075043.GB3063@rapoport-lnx>
 <c59a0893-d370-130b-5c33-d567a4621903@suse.cz>
 <20170524103947.GC3063@rapoport-lnx> <20170524111800.GD14733@dhcp22.suse.cz>
From: Pavel Emelyanov <xemul@virtuozzo.com>
Message-ID: <45c88ac2-9fc3-2740-c54d-82b0be2d1c9f@virtuozzo.com>
Date: Wed, 24 May 2017 17:25:05 +0300
MIME-Version: 1.0
In-Reply-To: <20170524111800.GD14733@dhcp22.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On 05/24/2017 02:18 PM, Michal Hocko wrote:
> On Wed 24-05-17 13:39:48, Mike Rapoport wrote:
>> On Wed, May 24, 2017 at 09:58:06AM +0200, Vlastimil Babka wrote:
>>> On 05/24/2017 09:50 AM, Mike Rapoport wrote:
>>>> On Mon, May 22, 2017 at 05:52:47PM +0200, Vlastimil Babka wrote:
>>>>> On 05/22/2017 04:29 PM, Mike Rapoport wrote:
>>>>>>
>>>>>> Probably I didn't explained it too well.
>>>>>>
>>>>>> The range is intentionally not populated. When we combine pre- and
>>>>>> post-copy for process migration, we create memory pre-dump without stopping
>>>>>> the process, then we freeze the process without dumping the pages it has
>>>>>> dirtied between pre-dump and freeze, and then, during restore, we populate
>>>>>> the dirtied pages using userfaultfd.
>>>>>>
>>>>>> When CRIU restores a process in such scenario, it does something like:
>>>>>>
>>>>>> * mmap() memory region
>>>>>> * fill in the pages that were collected during the pre-dump
>>>>>> * do some other stuff
>>>>>> * register memory region with userfaultfd
>>>>>> * populate the missing memory on demand
>>>>>>
>>>>>> khugepaged collapses the pages in the partially populated regions before we
>>>>>> have a chance to register these regions with userfaultfd, which would
>>>>>> prevent the collapse.
>>>>>>
>>>>>> We could have used MADV_NOHUGEPAGE right after the mmap() call, and then
>>>>>> there would be no race because there would be nothing for khugepaged to
>>>>>> collapse at that point. But the problem is that we have no way to reset
>>>>>> *HUGEPAGE flags after the memory restore is complete.
>>>>>
>>>>> Hmm, I wouldn't be that sure if this is indeed race-free. Check that
>>>>> this scenario is indeed impossible?
>>>>>
>>>>> - you do the mmap
>>>>> - khugepaged will choose the process' mm to scan
>>>>> - khugepaged will get to the vma in question, it doesn't have
>>>>> MADV_NOHUGEPAGE yet
>>>>> - you set MADV_NOHUGEPAGE on the vma
>>>>> - you start populating the vma
>>>>> - khugepaged sees the vma is non-empty, collapses
>>>>>
>>>>> unless I'm wrong, the racers will have mmap_sem for reading only when
>>>>> setting/checking the MADV_NOHUGEPAGE? Might be actually considered a bug.
>>>>>
>>>>> However, can't you use prctl(PR_SET_THP_DISABLE) instead? "If arg2 has a
>>>>> nonzero value, the flag is set, otherwise it is cleared." says the
>>>>> manpage. Do it before the mmap and you avoid the race as well?
>>>>
>>>> Unfortunately, prctl(PR_SET_THP_DISABLE) didn't help :(
>>>> When I've tried to use it, I've ended up with VM_NOHUGEPAGE set on all VMAs
>>>> created after prctl(). This returns me to the state when checkpoint-restore
>>>> alters the application vma->vm_flags although it shouldn't and I do not see
>>>> a way to fix it using existing interfaces.
>>>
>>> [CC linux-api, should have been done in the initial posting already]
>>
>> Sorry, missed that.
>>  
>>> Hm so the prctl does:
>>>
>>>                 if (arg2)
>>>                         me->mm->def_flags |= VM_NOHUGEPAGE;
>>>                 else
>>>                         me->mm->def_flags &= ~VM_NOHUGEPAGE;
>>>
>>> That's rather lazy implementation IMHO. Could we change it so the flag
>>> is stored elsewhere in the mm, and the code that decides to (not) use
>>> THP will check both the per-vma flag and the per-mm flag?
>>
>> I afraid I don't understand how that can help.
>> What we need is an ability to temporarily disable collapse of the pages in
>> VMAs that do not have VM_*HUGEPAGE flags set and that after we re-enable
>> THP, the vma->vm_flags for those VMAs will remain intact.
> 
> Why cannot khugepaged simply skip over all VMAs which have userfault
> regions registered? This would sound like a less error prone approach to
> me.

It already does so. The problem is that there's a race window. We first populate VMA
with pages, then register it in UFFD. Between these two actions khugepaged comes
and generates a huge page out of populated pages and holes. And the holes in question
are not, well, holes -- they should be populated later via the UFFD, while the
generated huge page prevents this from happening.

-- Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
