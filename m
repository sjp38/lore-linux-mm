Message-ID: <447DB4AB.9090008@yahoo.com.au>
Date: Thu, 01 Jun 2006 01:22:19 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc][patch] remove racy sync_page?
References: <447AC011.8050708@yahoo.com.au> <20060529121556.349863b8.akpm@osdl.org> <447B8CE6.5000208@yahoo.com.au> <20060529183201.0e8173bc.akpm@osdl.org> <447BB3FD.1070707@yahoo.com.au> <20060529201444.cd89e0d8.akpm@osdl.org> <20060530090549.GF4199@suse.de> <447D9D9C.1030602@yahoo.com.au> <Pine.LNX.4.64.0605311602020.26969@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0605311602020.26969@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Jens Axboe <axboe@suse.de>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mason@suse.com, andrea@suse.de, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Wed, 31 May 2006, Nick Piggin wrote:
> 
>>Jens Axboe wrote:
>>
>>>Maybe I'm being dense, but I don't see a problem there. You _should_
>>>call the new mapping sync page if it has been migrated.
>>
>>But can some other thread calling lock_page first find the old mapping,
>>and then run its ->sync_page which finds the new mapping? While it may
>>not matter for anyone in-tree, it does break the API so it would be
>>better to either fix it or rip it out than be silently buggy.
> 
> 
> Splicing a page from one mapping to another is rather worrying/exciting,
> but it does look safely done to me.  remove_mapping checks page_count
> while page lock and old mapping->tree_lock are held, and gives up if
> anyone else has an interest in the page.  And we already know it's
> unsafe to lock_page without holding a reference to the page, don't we?

Oh, that's true. I had thought that splice allows stealing pages with
an elevated refcount, which Jens was thinking about at one stage. But
I see that code isn't in mainline. AFAIKS it would allow other
->pin()ers to attempt to lock the page while it was being stolen.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
