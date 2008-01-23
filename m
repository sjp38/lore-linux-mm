Message-ID: <4797836D.5060106@qumranet.com>
Date: Wed, 23 Jan 2008 20:11:57 +0200
From: Izik Eidus <izike@qumranet.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] [RFC][PATCH 0/5] Memory merging driver for Linux
References: <4794C2E1.8040607@qumranet.com> <20080123120510.4014e382@bree.surriel.com> <20080123175444.GH7141@v2.random>
In-Reply-To: <20080123175444.GH7141@v2.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Rik van Riel <riel@redhat.com>, kvm-devel <kvm-devel@lists.sourceforge.net>, avi@qumranet.com, dor.laor@qumranet.com, linux-mm@kvack.org, yaniv@qumranet.com
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Wed, Jan 23, 2008 at 12:05:10PM -0500, Rik van Riel wrote:
>   
>> On Mon, 21 Jan 2008 18:05:53 +0200
>> Izik Eidus <izike@qumranet.com> wrote:
>>
>>     
>>> i added 2 new functions to the kernel
>>> one:
>>> page_wrprotect() make the page as read only by setting the ptes point to
>>> it as read only.
>>> second:
>>> replace_page() - replace the pte mapping related to vm area between two 
>>> pages
>>>       
>> How will this work on CPUs with nested paging support, where the
>> CPU does the guest -> physical address translation?  (opposed to
>> having shadow page tables)
>>     

thanks for reviewing.

nested page tables are some what diffrent from shadow page tables
instead of keeping another page table like we are doing with the shadow code
we are keeping another layer that translate the physical memory of the 
guest into the
physical memory of the host,
to this new layer we are allowed to add access permission, so we can 
mark the pages that
are shared as readonly and to vmexit on that, so it should work with that.
>
> sptes resolve guest addresses to host physical addresses (what is
> different is only which kind of guest address is being translated).
>
> sptes are faster than nptes for non pte-mangling non-context-switching
> memory intensive number crunching workloads infact. (DBMS will
> appreciate ntpes instead ;)
>
>   
>> Is it sufficient to mark the page read-only in the guest->physical
>> translation page table?
>>     
>
> Yes, just like with sptes too. I guess ntpes will also be managed as a
> tlb even if they won't require many changes, but the mmu notifier
> already firing in those two calls is what will keep both sptes and
> nptes in sync with the main linux VM. The serialization against
> get_user_pages that refills the spte/npte layer with
> nonpresent-nofault case of course happens through the PT lock, just
> like for the regular linux page fault against the pte that is pte_none
> for a little while but with the lock held (and set to write protect or
> new value before releasing it). This infact shows how the mmu
> notifiers that connects the linux pte to the spte/npte works for more
> than swapping.
>   
yea, without mmu notifiers this driver cant work safely and effective 
for kvm
it can only work for normal applications such as qemu without the mmu 
notifers.

-- 
woof.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
