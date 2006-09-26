Message-ID: <4518835D.3080702@oracle.com>
Date: Mon, 25 Sep 2006 21:33:17 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Reply-To: chuck.lever@oracle.com
MIME-Version: 1.0
Subject: Re: Checking page_count(page) in invalidate_complete_page
References: <4518333E.2060101@oracle.com> <20060925141036.73f1e2b3.akpm@osdl.org> <45185D7E.6070104@yahoo.com.au> <451862C5.1010900@oracle.com> <45186481.1090306@yahoo.com.au> <45186DC3.7000902@oracle.com> <451870C6.6050008@yahoo.com.au>
In-Reply-To: <451870C6.6050008@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Trond Myklebust <Trond.Myklebust@netapp.com>, Steve Dickson <steved@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Chuck Lever wrote:
>> Nick Piggin wrote:
>>> That still reintroduces the page fault race, but if the dumb 
>>> check'n'retry is
>>> no good then it may be OK for 2.6.18.stable, considering the page 
>>> fault race
>>> is much less common than the reclaim one. Not sure, not my call.
>>
>>
>> The NFS client uses invalidate_inode_pages2 for files, symlinks, and 
>> directories.  The latter two won't have the do_no_page race since you 
>> can't map those types of file objects.
> 
> 
> But they're present on the LRU? That's unusual (I guess NFS doesn't have 
> a buffer cache for a backing
> block device).

That is correct -- NFS doesn't use the buffer cache.

>> Also, the last get_page() call is from pagevec_strip().  Why do we 
>> need to try to strip buffers off of a page that is guaranteed not to 
>> have any buffers?
> 
> 
> I don't see where pagevec_strip calls get_page()?

Ah, you're right, I was off by one symbol.  The get_page call is in 
pagevec_lookup() (via find_get_pages).  That could mean there isn't a 
reclaim race at all.

The page references I'm noting are:

1.  add_to_page_cache_lru  1 -> 2

2.  do_generic_mapping_read, released in nfs_do_filldir

3.  read_cache_page, released in nfs_readdir

4.  pagevec_lookup (from invalidate_inode_pages2_range)  2 -> 3

The odd thing is some of the pages for the directory are released, so 
they must have a ref count of 2 *after* the pagevec_lookup.  Looks like 
more investigation is needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
