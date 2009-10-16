Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7CDBD6B004D
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 20:21:20 -0400 (EDT)
Date: Fri, 16 Oct 2009 01:21:14 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 7/9] swap_info: swap count continuations
In-Reply-To: <alpine.DEB.1.00.0910151414570.25796@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0910160106580.14004@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
 <Pine.LNX.4.64.0910150153560.3291@sister.anvils>
 <20091015123024.21ca3ef7.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.1.00.0910151414570.25796@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, hongshin@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Oct 2009, David Rientjes wrote:
> On Thu, 15 Oct 2009, KAMEZAWA Hiroyuki wrote:
> > Hmm...maybe I don't understand the benefit of this style of data structure.
> > 
> > Do we need fine grain chain ? 
> > Is  array of "unsigned long" counter is bad ?  (too big?)
> 
> I'm wondering if flex_array can be used for this purpose, which can store 
> up to 261632 elements of size unsigned long with 4K pages, or whether 
> finding the first available bit or weight would be too expensive.

When flex_arrays were first mooted, I did briefly wonder if we could
use them instead of vmalloc for the swap_map; but no, their interface
would slow down scan_swap_map() unacceptably.

Extensions of the swap_map are a different matter, they are seldom
referenced, and referenced just an item at a time: much better suited
to a flex_array.  And looking at Jon's Doc, I see they're good for
sparse arrays, that would suit swap_map extensions very well.

However... that limit of 261632 elements rules them out here (or can
we have a flex_array of flex_arrays?), and the lack of support for
__GFP_HIGHMEM is disappointing - the current implementation of swap
count continuations does use highmem (though perhaps these pages
are so rarely needed that it actually doesn't matter).

It seems that the flex_array is a solution in search of a problem,
and that the swap_map extension is not the right problem for it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
