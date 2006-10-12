Message-ID: <452DFD5B.8080409@yahoo.com.au>
Date: Thu, 12 Oct 2006 18:31:23 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] EXT3: problem with page fault inside a transaction
References: <87mz82vzy1.fsf@sw.ru> <20061011234330.efae4265.akpm@osdl.org> <87lknmgeaz.fsf@sw.ru>
In-Reply-To: <87lknmgeaz.fsf@sw.ru>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dmitriy Monakhov <dmonakhov@sw.ru>
Cc: Andrew Morton <akpm@osdl.org>, Dmitriy Monakhov <dmonakhov@openvz.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, devel@openvz.org, ext2-devel@lists.sourceforge.net, Andrey Savochkin <saw@swsoft.com>
List-ID: <linux-mm.kvack.org>

Dmitriy Monakhov wrote:
> Andrew Morton <akpm@osdl.org> writes:

>>With the stuff Nick and I are looking at, we won't take pagefaults inside
>>prepare_write()/commit_write() any more.
> 
> I'sorry may be i've missed something, but how cant you prevent this?
> 
> Let's look at generic_file_buffered_write:
> #### force page fault
> fault_in_pages_readable();
> 
> ### find and lock page
>  __grab_cache_page()
> 
> #### allocate blocks.This may result in low memory condition
> #### try_to_free_pages->shrink_caches() and etc.  
> a_ops->prepare_write() 		
> 
> ### can anyone guarantee that page fault hasn't  happened by now ?

Yes. Do an atomic copy, which will early exit from the pagefault handler
and return a short copy. Then close up the write, drop the page lock,
and rerun the fault_in_pages_readable, which will do the full pagefaults
for us, then try again.

Regardless of what you do to ext3, the VM just can't handle a fault
here anyway.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
