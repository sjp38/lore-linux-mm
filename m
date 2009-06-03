Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8C5FB6B004F
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:02:30 -0400 (EDT)
Date: Wed, 3 Jun 2009 11:35:46 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090603093546.GA16275@wotan.suse.de>
References: <20090528122357.GM6920@wotan.suse.de> <20090528135428.GB16528@localhost> <20090601115046.GE5018@wotan.suse.de> <20090601183225.GS1065@one.firstfloor.org> <20090602120042.GB1392@wotan.suse.de> <20090602124757.GG1065@one.firstfloor.org> <20090602125713.GG1392@wotan.suse.de> <20090602134659.GA21338@localhost> <20090602151729.GC17448@wotan.suse.de> <20090602172715.GT1065@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090602172715.GT1065@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02, 2009 at 07:27:15PM +0200, Andi Kleen wrote:
> > Hmm, if you're handling buffercache here then possibly yes.
> 
> Good question, will check.

BTW. now that I think about it, buffercache is probably not a good
idea to truncate (truncate, as-in: remove from pagecache). Because
filesystems can assume that with just a reference on the page, then
it will not be truncated.

This code will cause ext2 (as the first one I looked at), to go
oops.

And this is not predicated on PagePrivate or page_has_buffers,
because filesystems are free to directly operate on their own
metadata buffercache pages.

So I think it would be a good idea to exclude buffercache from
here completely until it can be shown to be safe. Actually you
*can* use the invalidate_mapping_pages path, which will check
refcounts etc (or a derivative thereof, similarly to my truncate
patch).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
