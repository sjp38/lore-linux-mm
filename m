Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A18EA6B005C
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 11:18:55 -0400 (EDT)
Date: Mon, 28 Sep 2009 09:52:10 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] HWPOISON: remove the unsafe __set_page_locked()
Message-ID: <20090928015210.GA8379@localhost>
References: <20090926031537.GA10176@localhost> <Pine.LNX.4.64.0909261115530.12927@sister.anvils> <20090926190645.GB14368@wotan.suse.de> <20090926213204.GX30185@one.firstfloor.org> <Pine.LNX.4.64.0909271714370.9097@sister.anvils> <20090927192251.GB6327@wotan.suse.de> <Pine.LNX.4.64.0909272251180.4402@sister.anvils> <20090927230118.GH6327@wotan.suse.de> <20090928011943.GB1656@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090928011943.GB1656@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 28, 2009 at 09:19:43AM +0800, Andi Kleen wrote:
> > There is no real rush AFAIKS to fix this one single pagecache site
> > while we have problems with slab allocators and all other unaudited
> > places that nonatomically modify page flags with an elevated
> 
> hwpoison ignores slab pages.
> 
> > page reference ... just mark HWPOISON as broken for the moment, or
> > cut it down to do something much simpler I guess?
> 
> Erm no. These cases are *EXTREMLY* unlikely to hit.
> 
> I'll look into exploiting the ordering of the mapping assignment.

Andi, given that overheads of this patch is considered unacceptable,
I think we can just ignore it.

The proposed schemes are already tricky enough (and may not achieve
100% correctness). We have not even considered the interaction with
free buddy pages, unpoison, and hwpoison filtering.

It may well result in something unmanageable.

On the other hand, we may just ignore the __set_page_locked race, 

- it could trigger BUG() on unlock_page(), however that's _no worse_
  than plain kernel without hwpoison. Plain kernel will also die when
  trying to fill data into the newly allocated pages.
- it is _not yet_ a LRU page. So it does not hurt the general idea of
  "hwpoison can handle LRU pages reliably".
- in hwpoison stress testing, we can avoid such pages by checking the
  PG_lru bit. Thus we can make the tests immune to this race.

Or,
- the page being __set_page_locked() is _not_ the fine LRU page
- we can prevent the kernel panic in the tests
- for a production workload, this presents merely another (rare) type
  of kernel page we cannot rescue.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
