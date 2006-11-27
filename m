Message-ID: <456A964D.2050004@yahoo.com.au>
Date: Mon, 27 Nov 2006 18:39:57 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: The VFS cache is not freed when there is not enough free memory
 to allocate
References: <6d6a94c50611212351if1701ecx7b89b3fe79371554@mail.gmail.com>	 <1164185036.5968.179.camel@twins> <6d6a94c50611220202t1d076b4cye70dcdcc19f56e55@mail.gmail.com>
In-Reply-To: <6d6a94c50611220202t1d076b4cye70dcdcc19f56e55@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aubrey <aubreylee@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Aubrey wrote:
> On 11/22/06, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

>> The lack of a MMU on your system makes it very hard not to rely on
>> higher order allocations, because even user-space allocs need to be
>> physically contiguous. But please take that into consideration when
>> writing software.
> 
> 
> Well, the test application just use an exaggerated way to replicate the 
> issue.
> 
> Actually, In the real work, the application such as mplayer, asterisk,
> etc will run into
> the above problem when run them at the second time. I think I have no
> reason to modify those kind of applications.

No that's wrong. And your patch is just a hack that happens to mask the
issue in the case you tested, and it will probably blow up in production
at some stage (consider the case where the VFS cache page is not freeable
or that page is being used for something else).

With the nommu kernel, you actually *do* have a huge reason to write
special code: large anonymous memory allocations have to use higher order
allocations!

I haven't actually written any nommu userspace code, but it is obvious
that you must try to keep malloc to <= PAGE_SIZE (although order 2 and
even 3 allocations seem to be reasonable, from process context)... Then
you would use something a bit more advanced than a linear array to store
data (a pagetable-like radix tree would be a nice, easy idea).

You are of course free to put that patch into your product's kernel
(although I would advise against it, because it has a lot of deadlock
issues)... but the reality is that if you want a robust system, you
cannot just take a unix program and run it unmodified on a nommu kernel
AFAIKS.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
