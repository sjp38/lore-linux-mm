Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0700A82F8A
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 17:26:01 -0400 (EDT)
Received: by wicfx6 with SMTP id fx6so18272352wic.1
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 14:26:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kk4si40603255wjb.48.2015.10.19.14.25.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 19 Oct 2015 14:25:59 -0700 (PDT)
Subject: Re: [PATCH 2/12] mm: rmap use pte lock not mmap_sem to set
 PageMlocked
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
 <alpine.LSU.2.11.1510182148040.2481@eggly.anvils> <56248C5B.3040505@suse.cz>
 <alpine.LSU.2.11.1510190341490.3809@eggly.anvils>
 <20151019131308.GB15819@node.shutemov.name>
 <alpine.LSU.2.11.1510191218070.4652@eggly.anvils>
 <20151019201003.GA18106@node.shutemov.name>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56255FE4.5070609@suse.cz>
Date: Mon, 19 Oct 2015 23:25:56 +0200
MIME-Version: 1.0
In-Reply-To: <20151019201003.GA18106@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrey Konovalov <andreyknvl@google.com>, Dmitry Vyukov <dvyukov@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On 10/19/2015 10:10 PM, Kirill A. Shutemov wrote:
> On Mon, Oct 19, 2015 at 12:53:17PM -0700, Hugh Dickins wrote:
>> On Mon, 19 Oct 2015, Kirill A. Shutemov wrote:
>>> On Mon, Oct 19, 2015 at 04:20:05AM -0700, Hugh Dickins wrote:
>>>>> Note how munlock_vma_pages_range() via __munlock_pagevec() does
>>>>> TestClearPageMlocked() without (or "between") pte or page lock. But the pte
>>>>> lock is being taken after clearing VM_LOCKED, so perhaps it's safe against
>>>>> try_to_unmap_one...
>>>>
>>>> A mind-trick I found helpful for understanding the barriers here, is
>>>> to imagine that the munlocker repeats its "vma->vm_flags &= ~VM_LOCKED"
>>>> every time it takes the pte lock: it does not actually do that, it
>>>> doesn't need to of course; but that does help show that ~VM_LOCKED
>>>> must be visible to anyone getting that pte lock afterwards.
>>>
>>> How can you make sure that any other codepath that changes vm_flags would
>>> not make (vm_flags & VM_LOCKED) temporary true while dealing with other
>>> flags?
>>>
>>> Compiler can convert things like "vma->vm_flags &= ~VM_FOO;" to whatever
>>> it wants as long as end result is the same. It's very unlikely that it
>>> will generate code to set all bits to one and then clear all which should
>>> be cleared, but it's theoretically possible.

I think Linus would be very vocal about such compiler implementation. 
And I can imagine a lot of things in the kernel would break by those 
spuriously set bits. There must be a lot of stuff that's "theoretically 
possible within the standard" but no sane compiler does. I believe even 
compiler guys are not that insane. IIRC we've seen bugs like this and 
they were always treated as bugs and fixed.
The example I've heard often used for theoretically possible but insane 
stuff is that the compiler could make code randomly write over anything 
that's not volatile, as long as it restored the original values upon 
e.g. returning from the function. That just can't happen.

>> I think that's in the realm of the fanciful.  But yes, it quite often
>> turns out that what I think is fanciful, is something that Paul has
>> heard compiler writers say they want to do, even if he has managed
>> to discourage them from doing it so far.
>
> Paul always has links to pdfs with this kind of horror. ;)
>
>> But more to the point, when you write of "end result", the compiler
>> would have no idea that releasing mmap_sem is the point at which
>> end result must be established:

Isn't releasing a lock one of those "release" barriers where previously
issued writes must become visible before the unlock takes place?

>> wouldn't it have to establish end
>> result before the next unlock operation, and before the end of the
>> compilation unit?

Now I'm lost in what you mean.

>> pte unlock being the relevant unlock operation
>> in this case, at least with my patch if not without.

Hm so IIUC Kirill's point is that try_to_unmap_one() is checking 
VM_LOCKED under pte lock, but somebody else might be modifying vm_flags 
under mmap_sem, and thus we have no protection.

>>>
>>> I think we need to have at lease WRITE_ONCE() everywhere we update
>>> vm_flags and READ_ONCE() where we read it without mmap_sem taken.

It wouldn't hurt to check if seeing a stale value or using non-atomic 
RMW can be a problem somewhere. In this case it's testing, not changing, 
so RMW is not an issue. But the check shouldn't consider arbitrary 
changes made by a potentially crazy compiler.

>> Not a series I'll embark upon myself,
>> and the patch at hand doesn't make things worse.
>
> I think it does.

So what's the alternative? Hm could we keep the trylock on mmap_sem 
under pte lock? The ordering is wrong, but it's a trylock, so no danger 
of deadlock?

> The patch changes locking rules for ->vm_flags without proper preparation
> and documentation. It will strike back one day.
> I know we have few other cases when we access ->vm_flags without mmap_sem,
> but this doesn't justify introducing one more potentially weak codepath.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
