Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F06308D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 04:54:04 -0400 (EDT)
Received: by iwl42 with SMTP id 42so13073194iwl.14
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 01:54:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110323143632.GL5698@random.random>
References: <201103222153.p2MLrD0x029642@imap1.linux-foundation.org>
	<AANLkTi=1krqzHY1mg2T-k52C-VNruWsnXO33qS7BzeL+@mail.gmail.com>
	<20110323002536.GG5698@random.random>
	<AANLkTikdhswcngKzksQcxeY5U4Kku6N8Kf5HXqpy0LNK@mail.gmail.com>
	<20110323143632.GL5698@random.random>
Date: Thu, 24 Mar 2011 17:54:00 +0900
Message-ID: <AANLkTim0Xa+ydGhNqt3hYxaX81Jo9KyvvwdvtDamy1Np@mail.gmail.com>
Subject: Re: + mm-compaction-use-async-migration-for-__gfp_no_kswapd-and-enforce-no-writeback.patch
 added to -mm tree
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, arthur.marsh@internode.on.net, cladisch@googlemail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>

On Wed, Mar 23, 2011 at 11:36 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> On Wed, Mar 23, 2011 at 03:01:33PM +0900, Minchan Kim wrote:
>> Okay. I will look at result.
>> If the problem happens again with reverted patch of page_alloc.c,
>> Don't we have to investigate further the problem happens with SLUB or
>> some driver's big memory allocation which is lower than 2M? We didn't
>> see the problem allocation under 2M but async migration's history was
>> short so we can't make sure it.
>
> Yes, probably. This is also why I hope the page_alloc.c part didn't
> make a difference. We kept it to be sure to make any sign of sync
> migration to go away from the stack traces, but I hope it's not so
> important anymore now. Reclaim eventually also becomes synchronous.
>
>> Don't you want to add async migration for low order allocation like SLUB?
>> If you don't want to do async migration low order allocation, we can
>> add the check if (gfp_flags & __GFP_RETRY) && (order >= 9 or some
>> threshold) for async migration?
>>
>> My point is to avoid implicit hidden meaning of __GFP_NO_KSWAPD
>> although __GFP_REPEAT already does it.
>
> I see your point, so let's think about it after testing of the
> reversal of the page_alloc.c change. If that's not necessary we just
> reverse it and it already solves these concerns.

Absolutely.

>
>> If async migration is going on and meet the dirty page, the patch can
>> return the -EBUSY so the page could put back to head of LRU but the
>> old migration can be going on although the page is dirty.
>
> Ok, but in term of LRU it's not like we're going to help much in
> skipping the page in compaction, it'd leave the sync pages there, and
> only list_del the async pages. I think it's mostly a cpu saving
> optimization, I doubt the lru ordering will be much more accurate by
> not doing list_del on the sync pages considering we would list_del
> the rest but not the sync part.

Yes. In terms of all LRU pages, I doubt it but isn't it better than
current meaningless rotation if we can do it easily?

Anyway, It's not a urgent issue so I don't mind it. :)
Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
