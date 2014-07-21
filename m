Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1186B0036
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 03:18:18 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id bs8so3514679wib.8
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 00:18:17 -0700 (PDT)
Message-ID: <53CCBEB4.1050401@suse.cz>
Date: Mon, 21 Jul 2014 09:18:12 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: vmscan: unlock_page page when forcing reclaim
References: <1405698484-25803-1-git-send-email-ryao@gentoo.org> <20140718163843.GK29639@cmpxchg.org> <53C96CBF.4040705@gentoo.org>
In-Reply-To: <53C96CBF.4040705@gentoo.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Yao <ryao@gentoo.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, mthode@mthode.org, kernel@gentoo.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@openvz.org>, Rik van Riel <riel@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Dave Chinner <dchinner@redhat.com>, open@kvack.org, "list@kvack.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On 07/18/2014 08:51 PM, Richard Yao wrote:
> On 07/18/2014 12:38 PM, Johannes Weiner wrote:
>> I don't really understand how the scenario you describe can happen.
>>
>> Successfully reclaiming a page means that __remove_mapping() was able
>> to freeze a page count of 2 (page cache and LRU isolation), but
>> filemap_fault() increases the refcount on the page before trying to
>> lock the page.  If __remove_mapping() wins, find_get_page() does not
>> work and the fault does not lock the page.  If find_get_page() wins,
>> __remove_mapping() does not work and the reclaimer aborts and does a
>> regular unlock_page().
>>
>> page_check_references() is purely about reclaim strategy, it should
>> not be essential for correctness.
>>
>
> You are right that something else is happened here. I had not spotted
> the cmpxchg being done in __remove_mapping(). If I spot something that
> looks like it could be what went wrong doing this, I will propose a new
> fix to the list for review. Thanks for your time.
>
> P.S. The system had ECC RAM, so this was not a bit flip. My current
> method for debugging this involves using cscope to construct possible
> call paths under a couple of assumptions:
>
> 1. Something set PG_locked without calling unlock_page().
> 2. The only ways of doing #1 that I see in the code are calling
> __clear_page_locked() or failing to clear the bit. I do not believe that
> a patch was accepted that did the latter, so I assume the former.

Could it be that the process holding the lock was also stuck doing 
something, and it was not a missed unlock?

> I have root access to the system, so each time I do a lookup using
> cscope, I go through the list to logically eliminate possibilities by
> inspecting the system where the problem occurred. When I cannot
> eliminate a possibility, I recurse. This is prone to fail positives
> should I miss a subtle piece of code that prevents a problem and it is
> very tedious, but I do not see a better way of debugging based on what I
> have at my disposal. If anyone has any suggestions, I would appreciate them.

You could try enabling VM_DEBUG, possibly LOCKDEP, try a git bisect if 
there's a previous known working kernel version...

> P.P.S. I *really* wish that I had used kdump when this issue happened,
> but sadly, the system is not setup for kdump.

So it happened only once so far? How about enabling kdump and waiting if 
it happens again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
