Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C75256B005D
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 11:17:45 -0400 (EDT)
Date: Mon, 28 Sep 2009 06:11:08 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC][PATCH] HWPOISON: remove the unsafe __set_page_locked()
Message-ID: <20090928041108.GD1656@one.firstfloor.org>
References: <20090926031537.GA10176@localhost> <Pine.LNX.4.64.0909261115530.12927@sister.anvils> <20090926190645.GB14368@wotan.suse.de> <20090926213204.GX30185@one.firstfloor.org> <Pine.LNX.4.64.0909271714370.9097@sister.anvils> <20090927192251.GB6327@wotan.suse.de> <Pine.LNX.4.64.0909272251180.4402@sister.anvils> <20090927230118.GH6327@wotan.suse.de> <20090928011943.GB1656@one.firstfloor.org> <20090928025741.GI6327@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090928025741.GI6327@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 28, 2009 at 04:57:41AM +0200, Nick Piggin wrote:
> On Mon, Sep 28, 2009 at 03:19:43AM +0200, Andi Kleen wrote:
> > > There is no real rush AFAIKS to fix this one single pagecache site
> > > while we have problems with slab allocators and all other unaudited
> > > places that nonatomically modify page flags with an elevated
> > 
> > hwpoison ignores slab pages.
> 
> "ignores" them *after* it has already written to page flags?
> By that time it's too late.

Yes, currently the page lock comes first. The only exception 
is for page count == 0 pages. I suppose we could move the slab check
up, but then it only helps when slab is set.

So if you make slab use refcount == 0 pages that would help.

> Well it's fundamentally badly buggy, rare or not. We could avoid

Let's put it like this -- any access to the poisoned cache lines
in that page will trigger a panic anyways.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
