Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E20A06B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 16:05:24 -0400 (EDT)
Message-ID: <4A2D7036.1010800@redhat.com>
Date: Mon, 08 Jun 2009 23:10:30 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] RFC - ksm api change into madvise
References: <1242261048-4487-1-git-send-email-ieidus@redhat.com> <Pine.LNX.4.64.0906081555360.22943@sister.anvils> <4A2D47C1.5020302@redhat.com> <Pine.LNX.4.64.0906081902520.9518@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0906081902520.9518@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, chrisw@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Mon, 8 Jun 2009, Izik Eidus wrote:
>   
>> Hugh Dickins wrote:
>>     
>>> You seem to have no callback in fork: doesn't that mean that KSM
>>> pages get into mms of which mm/ksm.c has no knowledge?  
>>>       
>> What you mean by this?, should the vma flags be copyed into the child and
>> therefore ksm will scan the vma?
>>     
>
> That part should be happening automatically now
> (you'd have to add code to avoid copying VM_ flags).
>   

Yea, should -> shouldn't

>   
>> (only thing i have to check is: maybe the process itself wont go into the
>> mmlist, and therefore ksm wont know about it)
>>     
>
> But that part needs something to make it happen.  In the case of
> swap, it's done over in copy_one_pte; the important thing is to
> do it where the locking is such that it cannot get missed,
> I can't say where is the right place yet.
>
>   
>>> You had
>>> no callback in mremap move: doesn't that mean that KSM pages could
>>> be moved into areas which mm/ksm.c never tracked?  Though that's
>>> probably no issue now we move over to vmas: they should now travel
>>> with their VM flag.  You have no callback in unmap: doesn't that
>>> mean that KSM never knows when its pages have gone away?
>>>   
>>>       
>> Yes, Adding all this callbacks would make ksm much more happy, Again, i didnt
>> want to scare anyone...
>>     
>
> Izik, you're too kindly ;)
>
>   
>>> (Closing the /dev/ksm fd used to clean up some of this, in the
>>> end; but the lifetime of the fd can be so different from that of
>>> the mapped area, I've felt very unsafe with that technique - a good
>>> technique when you're trying to sneak in special handling for your
>>> special driver, but not a good technique once you go to mainline.)
>>>
>>> I haven't worked out the full consequences of these lost pages:
>>> perhaps it's no worse than that you could never properly enforce
>>> your ksm_thread_max_kernel_pages quota.
>>>   
>>>       
>> You mean the shared pages outside the stable tree comment?
>>     
>
> I don't understand or even parse that question: which probably
> means, no.  I mean that if the merged pages end up in areas
> outside of where your trees expect them, then you've got pages
> counted which cannot be found to have gone.  Whether you can get
> too many resident pages that way, or just more counted than are
> really there, I don't know: I've not worked through the accounting
> yet, and would really really prefer it to be exact, instead of
> pages getting lost outside the trees and raising these questions.
>   

Agree, but to have the exact number you should have notification from 
do_wp_page when it break the write protected ksm pages, no?

(Right now ksm count this pages somewhat in "out of sync" mode from the 
linux VM, it doesnt mean that more unswappable pages can be allocated
 by ksm then allowed by ksm_thread_max_kernel_pages, but it mean that 
for some preiod of time less kernel pages might be allocated than allowed
 beacuse ksm will find too late, that some of the kernel pages that it 
already allocated were break and became swappable)

> But you may tell me that I simply haven't understood it yet.
>
>   
>>> And a question on your page_wrprotect() addition to mm/rmap.c: though
>>> it may contain some important checks (I'm thinking of the get_user_pages
>>> protection), isn't it essentially redundant, and should be removed from
>>> the patchset?  If we have a private page which is mapped into more than
>>> the one address space by which we arrive at it, then, quite independent
>>> of KSM, it needs to be write-protected already to prevent mods in one
>>> address space leaking into another - doesn't it?  So I see no need for
>>> the rmap'ped write-protection there, just make the checks and write
>>> protect the pte you have in ksm.c.  Or am I missing something?
>>>   
>>>       
>> Ok, so we have here 2 cases for ksm:
>> 1:
>>    When the page is anonymous and is mapped readonly beteween serveal
>> processes:
>>         for this you say we shouldnt walk over the rmap and try to
>> writeprotect what is already writeprtected...
>>     
>
> Yes.
>
>   
>> 2:
>>   When the page is anonymous and is mapped write by just one process:
>>       for this you say it is better to handle it directly from inside ksm
>> beacuse we already know
>>       the virtual address mapping of this page?
>>     
>
> Yes.
>
>   
>>       so about this: you are right about the fact that we might dont have to
>> walk over the rmap of the page for pages with mapcount 1
>>       but isnt it cleaner to deal it inside rmap.c?
>>     
>
> If you needed to writeprotect pages with mapcount 2, 3, ... then
> indeed you'd want to do it in rmap.c, and you wouldn't want to
> specialcase mapcount 1.  But I'm saying you don't need to do the
> writeprotection with mapcount 2, 3, ...; therefore better just
> to do it (again, no need to special case mapcount 1) in ksm.c.
>
> Cutting out a body of code: that's as clean as clean can be.
>
>
>   
Make sense, i will send patch today that merge that code into ksm.c 
(without all the rmap walking)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
