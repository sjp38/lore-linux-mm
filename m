Message-ID: <460A201C.3070405@yahoo.com.au>
Date: Wed, 28 Mar 2007 17:58:20 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch resend v4] update ctime and mtime for mmaped write
References: <20070328014816.4159.qmail@science.horizon.com>
In-Reply-To: <20070328014816.4159.qmail@science.horizon.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux@horizon.com
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

linux@horizon.com wrote:
>>Linux _will_ write all modified data to permanent storage locations.
>>Since 2.6.17 it will do this regardless of msync().  Before 2.6.17 you
>>do need msync() to enable data to be written back.
>>
>>But it will not start I/O immediately, which is not a requirement in
>>the standard, or at least it's pretty vague about that.
> 
> 
> As I've said before, I disagree, but I'm not going to start a major
> flame war about it.
> 
> The most relevant paragraph is:
> 
> # When MS_ASYNC is specified, msync() returns immediately once all the
> # write operations are initiated or queued for servicing; when MS_SYNC is
> # specified, msync() will not return until all write operations are
> # completed as defined for synchronised I/O data integrity completion.
> # Either MS_ASYNC or MS_SYNC is specified, but not both.
> 
> Note two things:
> 1) In the paragraphs before, what msync does is defined independently
>    of the MS_* flags.  Only the time of the return to user space varies.
>    Thus, whatever the delay between calling msync() and the data being
>    written, it should be the same whether MS_SYNC or MS_ASYNC is used.
> 
>    The implementation intended is:
>    - Start all I/O
>    - If MS_SYNC, wait for I/O to complete
>    - Return to user space

set_page_dirty queues pages for IO, and the writeout daemon will service
that queue when it sees fit. IMO it is sufficient that you cannot say the
implementation does not meet the standard.


> 2) "all the write operations are initiated or queued for servicing".
>    It is a common convention in English (and most languages, I expect)
>    that in the "or" is a preference for the first alternative.  The second
>    is a permitted alternative if the first is not possible.
> 
>    And "queued for servicing", especially "initiated or queued for
>    servicing", to me imples queuing waiting for some resource.  To have
>    the resource being waited for be a timer expiry seems like rather a
>    cheat to me.  It's perhaps doesn't break the letter of the standard,
>    but definitely bends it.  It feels like a fiddle.
> 
> Still, the basic hint function of msync(MS_ASYNC) *is* being accomplished:
> "I don't expect to write this page any more, so now would be a good time
> to clean it."
> It would just make my life easier if the kernel procrastinated less.

But if you didn't notice until now, then the current implementation
must be pretty reasonable for you use as well.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
