Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 81B596B007D
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 01:44:16 -0400 (EDT)
Message-ID: <4C88742A.6000406@tuxonice.net>
Date: Thu, 09 Sep 2010 15:44:10 +1000
From: Nigel Cunningham <nigel@tuxonice.net>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] swap: prevent reuse during hibernation
References: <alpine.LSU.2.00.1009060104410.13600@sister.anvils> <alpine.LSU.2.00.1009060111220.13600@sister.anvils> <20100907132036.03428c47.akpm@linux-foundation.org> <alpine.LSU.2.00.1009071336240.1839@sister.anvils>
In-Reply-To: <alpine.LSU.2.00.1009071336240.1839@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Ondrej Zary <linux@rainbow-software.org>, Andrea Gelmini <andrea.gelmini@gmail.com>, Balbir Singh <balbir@in.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Hi.

On 08/09/10 07:38, Hugh Dickins wrote:
> On Tue, 7 Sep 2010, Andrew Morton wrote:
>> On Mon, 6 Sep 2010 01:12:38 -0700 (PDT)
>> Hugh Dickins<hughd@google.com>  wrote:
>>
>>> Move the hibernation check from scan_swap_map() into try_to_free_swap():
>>
>> Well, it doesn't really "move" anything.  It removes one test (usage ==
>> SWAP_HAS_CACHE) and adds a quite different one (gfp_allowed_mask&
>> __GFP_IO).
>
> Okay, replaces a peculiar check for hibernation in scan_swap_map()
> by a more general check for hibernation inside try_to_free_swap().
>
>>
>>> to catch not only the common case when hibernation's allocation itself
>>> triggers swap reuse, but also the less likely case when concurrent page
>>> reclaim (shrink_page_list) might happen to try_to_free_swap from a page.
>>>
>>> Hibernation already clears __GFP_IO from the gfp_allowed_mask, to stop
>>> reclaim from going to swap: check that to prevent swap reuse too.
>>>
>>> Signed-off-by: Hugh Dickins<hughd@google.com>
>>> Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>>> Cc: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
>>> Cc: "Rafael J. Wysocki"<rjw@sisk.pl>
>>> Cc: Ondrej Zary<linux@rainbow-software.org>
>>> Cc: Andrea Gelmini<andrea.gelmini@gmail.com>
>>> Cc: Balbir Singh<balbir@in.ibm.com>
>>> Cc: Andrea Arcangeli<aarcange@redhat.com>
>>> Cc: Nigel Cunningham<nigel@tuxonice.net>
>>> Cc: stable@kernel.org
>
> I put Cc: stable@kernel.org in the list here, so that they'd be notified
> when the patch reaches Linus's tree: I thought it would just be noise to
> Cc them on earlier mails - but I've not removed the Cc you've now added!
>
>>> ---
>>>
>>>   mm/swapfile.c |   24 ++++++++++++++++++++----
>>>   1 file changed, 20 insertions(+), 4 deletions(-)
>>>
>>> --- swap1/mm/swapfile.c	2010-09-05 22:37:07.000000000 -0700
>>> +++ swap2/mm/swapfile.c	2010-09-05 22:45:54.000000000 -0700
>>> @@ -318,10 +318,8 @@ checks:
>>>   	if (offset>  si->highest_bit)
>>>   		scan_base = offset = si->lowest_bit;
>>>
>>> -	/* reuse swap entry of cache-only swap if not hibernation. */
>>> -	if (vm_swap_full()
>>> -		&&  usage == SWAP_HAS_CACHE
>>> -		&&  si->swap_map[offset] == SWAP_HAS_CACHE) {
>>> +	/* reuse swap entry of cache-only swap if not busy. */
>>> +	if (vm_swap_full()&&  si->swap_map[offset] == SWAP_HAS_CACHE) {
>>>   		int swap_was_freed;
>>>   		spin_unlock(&swap_lock);
>>>   		swap_was_freed = __try_to_reclaim_swap(si, offset);
>>
>> This hunk is already present in 2.6.35.
>
> That hunk is already present in 2.6.35, but it's been replaced by the
> usage == SWAP_HAS_CACHE hunk in 2.6.35.4 (or earlier), so this part of
> the patch reverts 2.6.35.4 back to how 2.6.35 was.  (An extra test here
> does no harm, and is even a more efficient way of preventing the
> issue where it's most likely to occur; but I thought it better to
> handle the issue just in one place, with a longish comment.)
>
>>
>>> @@ -688,6 +686,24 @@ int try_to_free_swap(struct page *page)
>>>   	if (page_swapcount(page))
>>>   		return 0;
>>>
>>> +	/*
>>> +	 * Once hibernation has begun to create its image of memory,
>>> +	 * there's a danger that one of the calls to try_to_free_swap()
>>> +	 * - most probably a call from __try_to_reclaim_swap() while
>>> +	 * hibernation is allocating its own swap pages for the image,
>>> +	 * but conceivably even a call from memory reclaim - will free
>>> +	 * the swap from a page which has already been recorded in the
>>> +	 * image as a clean swapcache page, and then reuse its swap for
>>> +	 * another page of the image.  On waking from hibernation, the
>>> +	 * original page might be freed under memory pressure, then
>>> +	 * later read back in from swap, now with the wrong data.
>>> +	 *
>>> +	 * Hibernation clears bits from gfp_allowed_mask to prevent
>>> +	 * memory reclaim from writing to disk, so check that here.
>>> +	 */
>>> +	if (!(gfp_allowed_mask&  __GFP_IO))
>>> +		return 0;
>>> +
>>>   	delete_from_swap_cache(page);
>>>   	SetPageDirty(page);
>>>   	return 1;
>>
>> This is the good bit.  I guess the (unCc:ed!) -stable guys would like a
>> standalone patch.
>
> They do need both hunks (well, nobody *needs* the first part, but it's
> tidier to restore the original code and keep tracking mainline).
>
>>
>> Also, are patches [3/4] and [4/4] really -stable material??
>
> I'm sure that 3/4, the one that removes the BLKDEV_IFL_BARRIER from the
> BLKDEV_IFL_WAITing swap discards, is -stable material; and it's not at
> all dependent on Christoph's and Tejun's ongoing barrier changes.
>
> (An alternative for -stable might have been to remove the BLKDEV_IFL_WAITs
> instead, going back more to 2.6.34: except I cannot vouch for the stability
> of that change - what of intervening mods at the block layer? - and it
> would go against the remove-barriers direction we're moving for 2.6.37.)
>
> Nigel saw a terrible pause in hibernation (originally with TuxOnIce, but
> he then checked swsusp too): he reported "The patch reduces the pause
> from minutes to a matter of seconds (with 4GB of swap), but it is still
> there (there was previously no discernable delay)".
>
> I've not noticed such an outstanding effect in ordinary swapping, where
> other things are going on; but the patch can easily halve the length of
> a run when swapping to some SSDs.
>
> But is 4/4 (SWAP_FLAG_DISCARD) really -stable material?  I think so
> (Nigel still sees a pause of seconds without it, and I see some swapping
> tests - on some SSDs - take three times as long without it), but it's more
> questionable: I was rather hoping to provoke a reaction with it.  And it
> will need swapon(2 and 8) manual page updates and util-linux-ng swapon
> support (latter ready but waiting to see when the kernel end goes in),
> if it's to amount to anything more than removing discard from swapping.
> Perhaps wait for more comment on it before pushing it to stable?

Just to back up what Hugh's saying, here's part of the original report:

Adding a printk in discard swap cluster gives the following:

[   46.758330] Discarding 256 pages from bdev 800003 beginning at page 
640377.
[   47.003363] Discarding 256 pages from bdev 800003 beginning at page 
640633.
[   47.246514] Discarding 256 pages from bdev 800003 beginning at page 
640889.

...

[  221.877465] Discarding 256 pages from bdev 800003 beginning at page 
826745.
[  222.121284] Discarding 256 pages from bdev 800003 beginning at page 
827001.
[  222.365908] Discarding 256 pages from bdev 800003 beginning at page 
827257.
[  222.610311] Discarding 256 pages from bdev 800003 beginning at page 
827513.

So allocating 4GB of swap on my SSD now takes 176 seconds instead of 
virtually no time at all.

Regards,

Nigel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
