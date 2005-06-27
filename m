Message-ID: <42BFB287.5060104@yahoo.com.au>
Date: Mon, 27 Jun 2005 18:02:15 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc] lockless pagecache
References: <42BF9CD1.2030102@yahoo.com.au> <20050627004624.53f0415e.akpm@osdl.org>
In-Reply-To: <20050627004624.53f0415e.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>>First I'll put up some numbers to get you interested - of a 64-way Altix
>> with 64 processes each read-faulting in their own 512MB part of a 32GB
>> file that is preloaded in pagecache (with the proper NUMA memory
>> allocation).
> 
> 
> I bet you can get a 5x to 10x reduction in ->tree_lock traffic by doing
> 16-page faultahead.
> 
> 

Definitely, for the microbenchmark I was testing with.

However I think for Oracle and others that use shared memory like
this, they are probably not doing linear access, so that would be a
net loss. I'm not completely sure (I don't have access to real loads
at the moment), but I would have thought those guys would have looked
into fault ahead if it were a possibility.

Also, the memory usage regression cases that fault ahead brings makes it
a bit contentious.

I like that the lockless patch completely removes the problem at its
source and even makes the serial path lighter. The other things is, the
speculative get_page may be useful for more code than just pagecache
lookups. But it is fairly tricky I'll give you that.

Anyway it is obviously not something that can go in tomorrow. At the
very least the PageReserved patches need to go in first, and even they
will need a lot of testing out of tree.

Perhaps it can be discussed at KS and we can think about what to do with
it after that - that kind of time frame. No rush.

Oh yeah, and obviously it would be nice if it provided real improvements
on real workloads too ;)

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
