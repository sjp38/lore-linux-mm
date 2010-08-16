Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 80C0C6B01F0
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 16:21:07 -0400 (EDT)
Message-ID: <4C699DB1.3010905@gmx.de>
Date: Mon, 16 Aug 2010 22:21:05 +0200
From: Helge Deller <deller@gmx.de>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] Fix up rss/swap usage of shm segments in /proc/pid/smaps
References: <20100811201345.GA11304@p100.box> <20100812131005.e466a9fd.akpm@linux-foundation.org> <4C6468A9.7090503@gmx.de> <alpine.DEB.1.00.1008121522150.9966@tigran.mtv.corp.google.com> <20100813195252.GA2450@p100.box> <alpine.DEB.1.00.1008131455070.12356@tigran.mtv.corp.google.com>
In-Reply-To: <alpine.DEB.1.00.1008131455070.12356@tigran.mtv.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On 08/14/2010 12:45 AM, Hugh Dickins wrote:
> On Fri, 13 Aug 2010, Helge Deller wrote:
>>
>> I tried quite hard to implement rss/swap accounting for shm segments inside
>> smaps_pte_range() which is a callback function of walk_page_range() in
>> show_smap().
>
> Sorry, I think the short answer will be that you should give up on this:
> reasons below.
>
>>
>> Given the fact that I'm no linux-mm expert, I might have overseen other
>> possibilities, but my experiments inside smaps_pte_range() were not
>> very successful:
>>  From my tests, a swapped-out shm segment
>> 	- fails on the "is_swap_pte()" test, and
>> 	- succeeds on the "!pte_present()" test (since it's swapped
>> 	  out).
>
> Yes.
>
>> So, here would it be possible to add such accounting for swap, but how
>> can I then see that this pte is
>> 	a) belonging to a shm segment?, and
>> 	b) see if this page/pte was really swapped out and not just not
>> yet written to at all?
>
> You would have to add a function in mm/shmem.c to do this: it would
> need to check vma->vm_file to work out if this vma belongs to it,
> and use shmem_swp_alloc() to check if the page there is on swap.  OTOH
> I'm not sure if you could call it while holding page table lock or not.
>
>> As answers I found:
>> 	a) (vma->vm_flags&  VM_MAYSHARE) is true for shm segments (is
>> 		this check sufficient?)
>
> No, VM_MAYSHARE is set on many other kinds of mapping too; and is not
> set on all mappings of shmem objects - there is no good reason to
> include SysV shm segments here, yet omit other kinds of shmem object
> (/dev/shm POSIX shared memory, shared-anonymous mappings, mappings of
> tmpfs files).
>
>> 	b) no idea.
>>
>> But if I add this page to the mss.swap entry, all pages including such
>> which haven't been touched yet at all are suddenly counted as
>> swapped-out...?
>>
>> Any hints here would be great...
>>
>>
>> As an alternative solution, I created the following patch.
>> This one works nicely, but it's just a fix-up of the mss.resident and
>> mss.swap values after walk_page_range() was called.
>> It's mostly a copy of the shm_add_rss_swap() function from
>> my previous patch (http://marc.info/?l=linux-mm&m=128171161101817&w=2).
>> Do you think such a fix-up-afterwards-approach is acceptable at all?
>> If yes, a new patch on top of my ipc/shm.c patch would be easy (and
>> small).
>
> Not acceptable, I'm afraid.  Nothing wrong with a fix-up-afterwards
> approach as such, but it's assuming that the vma covers the full extent
> of the shmem object.  That is very often the case, but by no means
> necessarily so (whereas it is always the case that one vma cannot cover
> more than one object).  So you do have to count pageslot by pageslot.
>
> There are two reasons why I think you have to abandon this.  One is
> that /proc/<pid>/smaps is reporting on the userspace mappings, saying
> where swap is instanced in them.  Some of those mappings may be of
> shmem objects, and some of those shmem objects may use swap backing
> themselves, but that's different from the mapping using swap directly.
>
> One can argue about that distinction, but it is how all this is
> designed, and blurring that distinction tends to get into trouble.
> (It's reasonable to think of anonymous mappings as mappings of anon
> objects, which just happen to find room for the swp_entry in the page
> table: but then it's a happy accident that smaps can see them.)
>
> The second reason is that since 2.6.34, /proc/<pid>/status shows
> VmSwap: we would not want a huge discrepancy between what it shows
> in swap and what /proc/<pid>/smaps shows in swap, but nor would we
> want to make /proc/<pid>/status scan through page tables enquiring
> of shmem.
>
> All this stands in contrast to your /proc/sysvipc/shm patch, which
> is rightly dealing with one class of shmem object, not via mappings
> of those objects.
>
> There is a case for a "where has my swap gone" tool, which examines
> the different kinds of object involved (anonymous mappings as well
> as shmem objects), and shows them all somehow.  But that's a lot
> more work than just extending an existing stats display.

Hugh, thanks for the good and comprehensive summary!
Seems that I have to live with the /proc/sysvipc/shm overview then :-(

Thanks,
Helge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
