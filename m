Message-ID: <42BFABD7.5000006@yahoo.com.au>
Date: Mon, 27 Jun 2005 17:33:43 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: VFS scalability
References: <42BF9CD1.2030102@yahoo.com.au> <42BFA014.9090604@yahoo.com.au> <p733br4w9uw.fsf@verdi.suse.de>
In-Reply-To: <p733br4w9uw.fsf@verdi.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> writes:
> 
> 
>>This is with the filesystem mounted as noatime, so I can't work
>>out why update_atime is so high on the list. I suspect maybe a
>>false sharing issue with some other fields.
> 
> 
> Did all the 64CPUs write to the same file?
> 

Yes.

> Then update_atime was just the messenger - it is the first function
> to read the inode so it eats the cache miss overhead.
> 

I agree.

> Maybe adding a prefetch for it at the beginning of sys_read() 
> might help, but then with 64CPUs writing to parts of the inode
> it will always thrash no matter how many prefetches.
> 

True. I'm just not sure what is causing the bouncing - I guess
->f_count due to get_file()?

rw_verify_area is another that is taking a lot of hits - probably
due to the same cacheline(s) as update_atime.

Unless I'm mistaken, the big difference between the read fault and
the read(2) cases is that mmap holds a reference on the file, while
open(2) doesn't?

I guess if anyone really cares about that, they could hack up a flag
to tell the file to remain pinned.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
