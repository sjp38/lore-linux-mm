Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA16071
	for <linux-mm@kvack.org>; Wed, 26 May 1999 12:14:58 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14156.7671.583211.355576@dukat.scot.redhat.com>
Date: Wed, 26 May 1999 17:14:47 +0100 (BST)
Subject: Re: [VFS] move active filesystem
In-Reply-To: <Pine.LNX.4.05.9905191820290.3829-100000@laser.random>
References: <19990518183725.B30692@caffeine.ix.net.nz>
	<Pine.LNX.4.05.9905191820290.3829-100000@laser.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@suse.de>
Cc: Chris Wedgwood <cw@ix.net.nz>, Gabor Lenart <lgb@oxygene.terra.vein.hu>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 19 May 1999 18:28:04 +0200 (CEST), Andrea Arcangeli
<andrea@suse.de> said:

> BTW, allowing dirty pages in the page cache may avoid I/O to disk but
> won't avoid memcpy data to the page cache even if the page cache was just
> uptdate. So I am convinced right now update_shared_mappings() is the right
> thing to do and it's not an dirty hack. It's only a not very efficient
> implementation that has to play with pgd/pmd/pte because we don't have
> enough information (yet) from the pagemap.

To do it correctly, you need to do much more than just play with the
page tables in the way your current update_shared_mappings() does,
because the page can be at different addresses in different VAs.  For
MAP_SHARED pages we have a list of all the VAs, but for MAP_PRIVATE
pages we do not, and mremap() can still cause a shared private page
(eg. data pages after fork()) to appear at different locations in
different mms. 

Dealing with that is a little tricky, but you can do it by keeping lists
of "related" vmas, based on overlaps between the original addresses of
the vmas, not their current addresses.  Private page sharing can only
occur when the original address of the vmas overlapped, and that gives
us an invariant to check for over mremap().

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
