Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0DC526B007E
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 11:36:21 -0400 (EDT)
Date: Mon, 28 Sep 2009 06:29:58 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH] HWPOISON: remove the unsafe __set_page_locked()
Message-ID: <20090928042958.GJ6327@wotan.suse.de>
References: <Pine.LNX.4.64.0909261115530.12927@sister.anvils> <20090926190645.GB14368@wotan.suse.de> <20090926213204.GX30185@one.firstfloor.org> <Pine.LNX.4.64.0909271714370.9097@sister.anvils> <20090927192251.GB6327@wotan.suse.de> <Pine.LNX.4.64.0909272251180.4402@sister.anvils> <20090927230118.GH6327@wotan.suse.de> <20090928011943.GB1656@one.firstfloor.org> <20090928025741.GI6327@wotan.suse.de> <20090928041108.GD1656@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090928041108.GD1656@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 28, 2009 at 06:11:08AM +0200, Andi Kleen wrote:
> On Mon, Sep 28, 2009 at 04:57:41AM +0200, Nick Piggin wrote:
> > On Mon, Sep 28, 2009 at 03:19:43AM +0200, Andi Kleen wrote:
> > > > There is no real rush AFAIKS to fix this one single pagecache site
> > > > while we have problems with slab allocators and all other unaudited
> > > > places that nonatomically modify page flags with an elevated
> > > 
> > > hwpoison ignores slab pages.
> > 
> > "ignores" them *after* it has already written to page flags?
> > By that time it's too late.
> 
> Yes, currently the page lock comes first. The only exception 
> is for page count == 0 pages. I suppose we could move the slab check
> up, but then it only helps when slab is set.

Yes, so it misses other potential non-atomic page flags manipulations.

 
> So if you make slab use refcount == 0 pages that would help.

Yes it would help here and also help with the pagecache part too,
and most other cases I suspect. I have some patches to do this at
home so I'll post them when I get back.

 
> > Well it's fundamentally badly buggy, rare or not. We could avoid
> 
> Let's put it like this -- any access to the poisoned cache lines
> in that page will trigger a panic anyways.

Well yes, although maybe people who care about this feature will
care more about having a reliable panic than introducing a
random data corruption. I guess the chance of an ecc failure
combined with a chance the race window hits could be some orders
of magnitude less likely than other sources of bugs ;) but still
I don't like using that argument to allow known bugs -- it leads
to interesting things if we take it to a conclusion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
