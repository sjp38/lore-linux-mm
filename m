Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id DB5666B0035
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 20:07:29 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id fa1so1132302pad.17
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 17:07:29 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id m8si52468615pbq.239.2014.01.07.17.07.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 17:07:28 -0800 (PST)
Message-ID: <52CCA4A6.7030106@oracle.com>
Date: Wed, 08 Jan 2014 09:06:46 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mlock: fix BUG_ON unlocked page for nolinear VMAs
References: <1387267550-8689-1-git-send-email-liwanp@linux.vnet.ibm.com>	<52b1138b.0201430a.19a8.605dSMTPIN_ADDED_BROKEN@mx.google.com>	<52B11765.8030005@oracle.com>	<52b120a5.a3b2440a.3acf.ffffd7c3SMTPIN_ADDED_BROKEN@mx.google.com>	<52B166CF.6080300@suse.cz>	<52b1699f.87293c0a.75d1.34d3SMTPIN_ADDED_BROKEN@mx.google.com>	<20131218134316.977d5049209d9278e1dad225@linux-foundation.org>	<52C71ACC.20603@oracle.com>	<CA+55aFzDcFyyXwUUu5bLP3fsiuzxU7VPivpTPHgp8smvdTeESg@mail.gmail.com>	<52C74972.6050909@suse.cz> <CA+55aFzq1iQqddGo-m=vutwMYn5CPf65Ergov5svKR4AWC3rUQ@mail.gmail.com> <6B2BA408B38BA1478B473C31C3D2074E2BF812BC82@SV-EXCHANGE1.Corp.FC.LOCAL> <52CC16DC.9070308@suse.cz>
In-Reply-To: <52CC16DC.9070308@suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Michel Lespinasse <walken@google.com>, Nick Piggin <npiggin@suse.de>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>


On 01/07/2014 11:01 PM, Vlastimil Babka wrote:
> On 01/06/2014 05:47 PM, Motohiro Kosaki wrote:
>>
>>
>>> -----Original Message-----
>>> From: linus971@gmail.com [mailto:linus971@gmail.com] On Behalf Of Linus
>>> Torvalds
>>> Sent: Friday, January 03, 2014 7:18 PM
>>> To: Vlastimil Babka
>>> Cc: Sasha Levin; Andrew Morton; Wanpeng Li; Michel Lespinasse; Bob Liu;
>>> Nick Piggin; Motohiro Kosaki JP; Rik van Riel; David Rientjes; Mel Gorman;
>>> Minchan Kim; Hugh Dickins; Johannes Weiner; linux-mm; Linux Kernel Mailing
>>> List
>>> Subject: Re: [PATCH] mm/mlock: fix BUG_ON unlocked page for nolinear
>>> VMAs
>>>
>>> On Fri, Jan 3, 2014 at 3:36 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>>>
>>>> I'm for going with the removal of BUG_ON. The TestSetPageMlocked
>>>> should provide enough race protection.
>>>
>>> Maybe. But dammit, that's subtle, and I don't think you're even right.
>>>
>>> It basically depends on mlock_vma_page() and munlock_vma_page() being
>>> able to run CONCURRENTLY on the same page. In particular, you could have a
>>> mlock_vma_page() set the bit on one CPU, and munlock_vma_page()
>>> immediately clearing it on another, and then the rest of those functions
>>> could run with a totally arbitrary interleaving when working with the exact
>>> same page.
>>>
>>> They both do basically
>>>
>>>      if (!isolate_lru_page(page))
>>>          putback_lru_page(page);
>>>
>>> but one or the other would randomly win the race (it's internally protected
>>> by the lru lock), and *if* the munlock_vma_page() wins it, it would also do
>>>
>>>      try_to_munlock(page);
>>>
>>> but if mlock_vma_page() wins it, that wouldn't happen. That looks entirely
>>> broken - you end up with the PageMlocked bit clear, but
>>> try_to_munlock() was never called on that page, because
>>> mlock_vma_page() got to the page isolation before the "subsequent"
>>> munlock_vma_page().
>>>
>>> And this is very much what the page lock serialization would prevent.
>>> So no, the PageMlocked in *no* way gives serialization. It's an atomic bit op,
>>> yes, but that only "serializes" in one direction, not when you can have a mix
>>> of bit setting and clearing.
>>>
>>> So quite frankly, I think you're wrong. The BUG_ON() is correct, or at least
>>> enforces some kind of ordering. And try_to_unmap_cluster() is just broken
>>> in calling that without the page being locked. That's my opinion. There may
>>> be some *other* reason why it all happens to work, but no,
>>> "TestSetPageMlocked should provide enough race protection" is simply not
>>> true, and even if it were, it's way too subtle and odd to be a good rule.
>>>
>>> So I really object to just removing the BUG_ON(). Not with a *lot* more
>>> explanation as to why these kinds of issues wouldn't matter.
>>
>> I don't have a perfect answer. But I can explain a bit history. Let's me try.
>>
>> First off, 5 years ago, Lee's original putback_lru_page() implementation required
>> page-lock, but I removed the restriction months later. That's why we can see
>> strange BUG_ON here.
>>
>> 5 years ago, both mlock(2) and munlock(2) called do_mlock() and it was protected  by
>> mmap_sem (write mdoe). Then, mlock and munlock had no race.
>> Now, __mm_populate() (called by mlock(2)) is only protected by mmap_sem read-mode. However it is enough to
>> protect against munlock.
>>
>> Next, In case of mlock vs reclaim, the key is that mlock(2) has two step operation. 1) turn on VM_LOCKED under
>> mmap_sem write-mode, 2) turn on Page_Mlocked under mmap_sem read-mode. If reclaim race against step (1),
>> reclaim must lose because it uses trylock. On the other hand, if reclaim race against step (2), reclaim must detect
>> VM_LOCKED because both VM_LOCKED modifier and observer take mmap-sem.
>>
>> By the way, page isolation is still necessary because we need to protect another page modification like page migration.
> 
> I guess you meant page locking, not (lru) isolation. Indeed, the documentation
> at Documentation/vm/unevictable-lru.txt also discusses races with page migration.
> 
> I've checked and it seems really the case that mlock_migrate_page()
> could race with mlock_vma_page() so that PG_mlocked is set on the
> old page again after deciding that the new page will be without the flag.
> (or after the flag was transferred to the new page)
> That would not be fatal, but distort accounting anyway.
> 
> So here's a patch that if accepted should replace the removal of BUG_ON patch in
> -mm tree: http://ozlabs.org/~akpm/mmots/broken-out/mm-remove-bug_on-from-mlock_vma_page.patch
> 

Make sense to me.

> The idea is that try_to_unmap_cluster() will try locking the page
> for mlock, and just leave it alone if lock cannot be obtained. Again
> that's not fatal, as eventually something will encounter and mlock the page.
> 
> -----8<-----
> 
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Tue, 7 Jan 2014 14:59:58 +0100
> Subject: [PATCH] mm: try_to_unmap_cluster() should lock_page() before mlocking
> 
> A BUG_ON(!PageLocked) was triggered in mlock_vma_page() by Sasha Levin fuzzing
> with trinity. The call site try_to_unmap_cluster() does not lock the pages
> other than its check_page parameter (which is already locked).
> 
> The BUG_ON in mlock_vma_page() is not documented and its purpose is somewhat
> unclear, but apparently it serializes against page migration, which could
> otherwise fail to transfer the PG_mlocked flag. This would not be fatal, as the
> page would be eventually encountered again, but NR_MLOCK accounting would
> become distorted nevertheless. This patch adds a comment to the BUG_ON in
> mlock_vma_page() and munlock_vma_page() to that effect.
> 
> The call site try_to_unmap_cluster() is fixed so that for page != check_page,
> trylock_page() is attempted (to avoid possible deadlocks as we already have
> check_page locked) and mlock_vma_page() is performed only upon success. If the
> page lock cannot be obtained, the page is left without PG_mlocked, which is
> again not a problem in the whole unevictable memory design.
> 
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Bob Liu <bob.liu@oracle.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Reviewed-by: Bob Liu <bob.liu@oracle.com>

> ---
>  mm/mlock.c |  2 ++
>  mm/rmap.c  | 14 ++++++++++++--
>  2 files changed, 14 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/mlock.c b/mm/mlock.c
> index 192e6ee..1b12dfa 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -79,6 +79,7 @@ void clear_page_mlock(struct page *page)
>   */
>  void mlock_vma_page(struct page *page)
>  {
> +	/* Serialize with page migration */
>  	BUG_ON(!PageLocked(page));
>  
>  	if (!TestSetPageMlocked(page)) {
> @@ -153,6 +154,7 @@ unsigned int munlock_vma_page(struct page *page)
>  {
>  	unsigned int nr_pages;
>  
> +	/* For try_to_munlock() and to serialize with page migration */
>  	BUG_ON(!PageLocked(page));
>  
>  	if (TestClearPageMlocked(page)) {
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 068522d..b99c742 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1389,9 +1389,19 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
>  		BUG_ON(!page || PageAnon(page));
>  
>  		if (locked_vma) {
> -			mlock_vma_page(page);   /* no-op if already mlocked */
> -			if (page == check_page)
> +			if (page == check_page) {
> +				/* we know we have check_page locked */
> +				mlock_vma_page(page);
>  				ret = SWAP_MLOCK;
> +			} else if (trylock_page(page)) {
> +				/*
> +				 * If we can lock the page, perform mlock.
> +				 * Otherwise leave the page alone, it will be
> +				 * eventually encountered again later.
> +				 */
> +				mlock_vma_page(page);
> +				unlock_page(page);
> +			}
>  			continue;	/* don't unmap */
>  		}
>  
> 

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
