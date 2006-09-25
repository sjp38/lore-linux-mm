Message-ID: <45185AF3.7030606@oracle.com>
Date: Mon, 25 Sep 2006 18:40:51 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Reply-To: chuck.lever@oracle.com
MIME-Version: 1.0
Subject: Re: Checking page_count(page) in invalidate_complete_page
References: <4518333E.2060101@oracle.com> <20060925141036.73f1e2b3.akpm@osdl.org>
In-Reply-To: <20060925141036.73f1e2b3.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, Steve Dickson <steved@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Woops.

I got them backwards.

invalidate_inode_pages2 appears to wait for locked pages, while 
invalidate_inode_pages skips them.

Andrew Morton wrote:
> (Added linux-mm)
> 
> On Mon, 25 Sep 2006 15:51:26 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> Hi Andrew-
>>
>> Steve Dickson and I have independently discovered some cache 
>> invalidation problems in 2.6.18's NFS client.  Using git bisect, I was 
>> able to track it back to this commit:
>>
>>> commit 016eb4a0ed06a3677d67a584da901f0e9a63c666
>>> Author: Andrew Morton <akpm@osdl.org>
>>> Date:   Fri Sep 8 09:48:38 2006 -0700
>>>
>>>     [PATCH] invalidate_complete_page() race fix
>>>
>>>     If a CPU faults this page into pagetables after invalidate_mapping_pages()
>>>     checked page_mapped(), invalidate_complete_page() will still proceed to remove
>>>     the page from pagecache.  This leaves the page-faulting process with a
>>>     detached page.  If it was MAP_SHARED then file data loss will ensue.
>>>
>>>     Fix that up by checking the page's refcount after taking tree_lock.
>>>
>>>     Cc: Nick Piggin <nickpiggin@yahoo.com.au>
>>>     Cc: Hugh Dickins <hugh@veritas.com>
>>>     Cc: <stable@kernel.org>
>>>     Signed-off-by: Andrew Morton <akpm@osdl.org>
>>>     Signed-off-by: Linus Torvalds <torvalds@osdl.org>
>> Instrumenting get_page and put_page has shown that the page reclaim 
>> logic is temporarily bumping the page count on otherwise active but idle 
>> pages, racing with the new page_count check in invalidate_complete_page 
>> and preventing pages from being invalidated.
>>
>> One problem for the NFS client is that invalidate_inode_pages2 is being 
>> used to invalidate the pages associated with a cached directory.  If the 
>> directory pages can't be invalidated because of this race, the contents 
>> of the directory pages don't match the dentry cache, and all kinds of 
>> strange behavior results.
> 
> NFS is presently ignoring the return value from invalidate_inode_pages2(),
> in two places.  Could I suggest you fix that?  Then we'd at least not be
> seeing "strange behaviour" and things will be easier to diagnose next time.
> 
>> I haven't checked the data invalidation behavior for regular files, but 
>> the result will be file data corruption that comes and goes.
>>
>> Would it be acceptable to revert that page_count(page) != 2 check in 
>> invalidate_complete_page ?
> 
> Unfortunately not - that patch fixes cramfs failures and potential file
> corruption.
> 
> The way to keep memory reclaim away from that page is to take
> zone->lru_lock, but that's quite impractical for several reasons.
> 
> We could retry the invalidation a few times, but that stinks.
> 
> I think invalidate_inode_pages2() is sufficiently different from (ie:
> stronger than) invalidate_inode_pages() to justify the addition of a new
> invalidate_complete_page2(), which skips the page refcount check.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
