Received: from alogconduit1ah.ccr.net (ccr@alogconduit1ao.ccr.net [208.130.159.15])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA02378
	for <linux-mm@kvack.org>; Mon, 26 Apr 1999 10:42:49 -0400
Subject: Re: 2.2.6_andrea2.bz2
References: <Pine.LNX.4.05.9904252047530.7477-100000@laser.random> <m1yajfg61n.fsf@flinx.ccr.net> <19990426154524.A749@kali.munich.netsurf.de>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 26 Apr 1999 09:20:33 -0500
In-Reply-To: Andi Kleen's message of "Mon, 26 Apr 1999 15:45:24 +0200"
Message-ID: <m1u2u3fopa.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <ak@muc.de>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "AK" == Andi Kleen <ak@muc.de> writes:

AK> On Mon, Apr 26, 1999 at 10:05:56AM +0200, Eric W. Biederman wrote:
>> >>>>> "AA" == Andrea Arcangeli <andrea@e-mind.com> writes:
>> 
>> >>> o	update_shared_mappings (will greatly improve performances while
>> >>> writing from many task to the same shared memory).
>> >> 
>> >> do you have performance numbers on this?
>> 
AA> The performance optimization can be huge.
>> 
AA> The reason this my code is not in the kernel is not because it's buggy but
AA> simple because there are plans for 2.3.x (no-way for 2.2.x) to allow the
AA> file cache to be dirty (to cache also writes and not only read in the page
AA> cache).
>> 
>> Andrea.  The plan (at least my plan) is not to have 2 layers of buffers.
>> Instead it is to do all of the caching (except for perhaps superblocks, and their
>> kin in the page cache).  brw_page will be used for both reads and writes, with
>> anonymouse buffer heads (at least for a start).

AK> Stupid question: do you plan to cache fs metadata in the page cache too? 
AK> If yes, it is rather wasteful to use a 4K page for the usually block sized
AK> directories and other fs data like indirect blocks. How do you plan to 
AK> address this problem?

I certainly plan on investigating it.  I currently have the buffer
pointer in struct page, set up as a generic pointer.  So you can either
use it's bits directly to keep track of what is dirty on a page.  Or
you can allocate a structure to have such things as a per page list
of dirty places (like nfs does now).

For the start however the buffer cache will remain for the fs metadata.

But the fs metadata should be small enough that even if
cached a little inefficiently we shouldn't have space problems.
At least that's my hunch.

Eric


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
