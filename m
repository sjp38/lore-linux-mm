Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id A99906B0198
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 11:16:00 -0500 (EST)
Message-ID: <4EE6276C.6050304@mellanox.com>
Date: Mon, 12 Dec 2011 18:10:20 +0200
From: Sagi Grimberg <sagig@mellanox.com>
MIME-Version: 1.0
Subject: Re: mmu_notifier for IB
References: <62E8061CEEF5D44DB2306F06154B5704235A1495@MTLDAG01.mtl.com> <20111114152239.GB4414@redhat.com> <4ECDF451.9090705@mellanox.com> <20111211203433.GA4814@redhat.com>
In-Reply-To: <20111211203433.GA4814@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>, gleb@redhat.com, linux-mm@kvack.org

On 12/11/2011 10:34 PM, Andrea Arcangeli wrote:
> On Thu, Nov 24, 2011 at 09:37:53AM +0200, Sagi Grimberg wrote:
>> Hey again Andrea,
>>
>> On 11/14/2011 5:22 PM, Andrea Arcangeli wrote:
>>> Hi Sagi,
>>>
>>> On Mon, Nov 14, 2011 at 08:42:32AM +0000, Sagi Grimberg wrote:
>>>> Hello Andrea,
>>>>
>>>> I'm working on a prototype enabling pageable memory for an IB driver
>>>> using mmu_notifier.  Upon an invalidation callback (invalidate_page)
>>>> I need to update the HW about this change, This is a sleeping
>>>> procedure.  Due to the fact that the callback is non-sleepable, I
>>>> take the page's refcount and execute a worker context to do this
>>>> task (and release the page refcount afterwards).
>>> Good to hear.
>>>
>>>> Questions raising, What is the page's state when refusing the swap?
>>>> Is there any way to distinguish between a swapped out page and an
>>>> unmapped page?  The page is unmapped from the task's address space,
>>>> But it is still present in RAM space? This is an unfamiliar
>>>> situation.  Will It be swapped as soon as I release the page
>>>> refcount? (or will it go back to the end of the swap-out candidates
>>>> line?
>>> The page when pinned it won't be removed from swapcache so it will
>>> stay in ram and the page fault will fill it back from the same
>>> physical address like if it wasn't removed from the pte. You've to
>>> mark the page dirty after releasing it after if you write to it. See
>>> the vmscan.c:__remove_mapping.
>>>
>> What about notifications which are not due to swapping? i.e. if the user
>> has unmapped a page, and we increase the page refcount, this can lead to
>> serious
>> correctness issues.
> The page will remain in memory, it may be written to the disk but then
> it's up to you then to SetPageDirty if you write to it. No jurnaling
> is required, just remember to SetPageDirty before you do put_page if
> you modified the in-ram contents of the page.

Let me rephrase,
Say the user has mapped a memory region.
If the user will unmap that region and the driver will try to delay this 
invalidation (wants to batch some more), the user might mmap again, in 
this scenario the device is still referencing the old page while the 
user thinks he is referencing a new page. This can lead to bad results. 
This is why we need to distinguish the cases we can and can't delay 
invalidations.

Our HW sync operation is rather expensive - so its preferable that we 
will be able to batch invalidations since we can't afford to use HW sync 
for each of them.

>> How can we differentiate between this case and the swapping out case?
>> Can we know this from the invalidation callback? (similar scenarios can
>> occur for NUMA-migration, permissions-change, fork etc...)
> permission change is more tricky in fork, there's some race in fact
> there even with O_DIRECT but they can only lead to userland data
> corruption so it's up to userland apps not to write/read to<4k
> subpage (of the same 4k page) from different threads while using
> O_DIRECT or other get_user_pages users.

I'm not sure I understand, what race condition could emerge here? can 
you elaborate on that?

>> For example say the system wants to migrate a page, we attempt to pin
>> the page during the migration, but the NUMA migrator already started
>> migration, and
>> will not honor our pinning request, and we might end up writing on a
>> freed page.
>> Is there a way the mmu_notifier callbacks can give us a "hint" of the
>> invalidation source (swap, unmapping, etc...)?
> Migration will verify the page is not pinned by get_user_pages before
> starting moving it. And before checking it blocks the pte, so you
> can't grab the page pin with get_user_pages while it's being migrated.

So in this case we can't delay the invalidation (again, in order to 
batch more invalidations)? How can we know this within the invalidation 
callback?

>> Making the invalidation callbacks sleepable would be great - that can
>> solve a lot of problems raising from updating our SPTE asynchronously,
>> and also simplify the driver behavior significantly.
> Correct. We should go that way now that anon_vma lock and i_mmap_mutex
> are both sleepable mutex. It wasn't that way when I wrote mmu
> notifier, so it wasn't possible to schedule inside invalidate_page (in
> the invalidate_page case the invalidate must happen exactly after
> flushing the primary CPU tlb but _before_ freeing hte page and that
> happens within the context of the anon_vma lock/i_mmap_mutex).

I must emphasize that by sleeping I mean that we shall use a blocking 
operation which might last up to 10s of milliseconds under some 
conditions (usually few microseconds).
So can we move forward assuming that we are allowed to sleep in 
invalidate_page?

> Feel free to move the thread to linux-mm... no problem with me,
> hopefully people will be calm there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
