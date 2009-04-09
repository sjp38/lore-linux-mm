Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 35E9F5F0001
	for <linux-mm@kvack.org>; Thu,  9 Apr 2009 03:27:04 -0400 (EDT)
Date: Thu, 9 Apr 2009 09:29:49 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [13/16] POISON: The high level memory error handler in the VM
Message-ID: <20090409072949.GF14687@one.firstfloor.org>
References: <20090407509.382219156@firstfloor.org> <20090407151010.E72A91D0471@basil.firstfloor.org> <1239210239.28688.15.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1239210239.28688.15.camel@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Andi Kleen <andi@firstfloor.org>, hugh@veritas.com, npiggin@suse.de, riel@redhat.com, lee.schermerhorn@hp.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 08, 2009 at 01:03:59PM -0400, Chris Mason wrote:

Hi Chris,

Thanks for the review.

> So, try_to_release_page returns 1 when it works.  I know this only
> because I have to read it every time to remember ;)

Argh. I think I read that, but then somehow the code still came out
wrong and the tester didn't catch the failure.

> 
> try_to_release_page is also very likely to fail if the page is dirty or
> under writeback.  At the end of the day, we'll probably need a call into

Would you recommend a retry step?  If it fails cancel_dirty_page() and then
retry?

Ideally I would like to stop the write back before it starts (it will
result in a hardware bus abort or even a machine check if the CPU
touches the data), but I realize it's difficult for anything with
private page state. I just cancel dirty for !Private at least.

> the FS to tell it a given page isn't coming back, and to clean it at all
> cost.
> 
> invalidatepage is close, but ext3/reiserfs will keep the buffer heads
> and let the page->mapping go to null in an ugly data=ordered corner
> case.  The buffer heads pin the page and it won't be freed until the IO
> is done.

invalidate_mapping_pages() ? 

I had this in an earlier version, but took it out because it seemed
problematic to rely on a specific inode. Should i reconsider it?


-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
