Message-ID: <45185D7E.6070104@yahoo.com.au>
Date: Tue, 26 Sep 2006 08:51:42 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Checking page_count(page) in invalidate_complete_page
References: <4518333E.2060101@oracle.com> <20060925141036.73f1e2b3.akpm@osdl.org>
In-Reply-To: <20060925141036.73f1e2b3.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: chuck.lever@oracle.com, Trond Myklebust <Trond.Myklebust@netapp.com>, Steve Dickson <steved@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>>I haven't checked the data invalidation behavior for regular files, but 
>>the result will be file data corruption that comes and goes.
>>
>>Would it be acceptable to revert that page_count(page) != 2 check in 
>>invalidate_complete_page ?
>>
>
>Unfortunately not - that patch fixes cramfs failures and potential file
>corruption.
>
>The way to keep memory reclaim away from that page is to take
>zone->lru_lock, but that's quite impractical for several reasons.
>

Also, you can't guarantee anything much about its refcount even then
(because it could be on a private reclaim list or pagevec somewhere).

>We could retry the invalidation a few times, but that stinks.
>
>I think invalidate_inode_pages2() is sufficiently different from (ie:
>stronger than) invalidate_inode_pages() to justify the addition of a new
>invalidate_complete_page2(), which skips the page refcount check.
>

Yes, I think that would be possible using the lock_page in do_no_page trick.
That would also enable you to invalidate pages that have direct IO going
into them, and other weird and wonderful get_user_pages happenings.

I haven't thrown away those patches, and I am looking for a justification
for them because they make the code look nicer ;)

For 2.6.18.stable, Andrew's idea of checking the return value and retry
might be the only option.

Nick
--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
