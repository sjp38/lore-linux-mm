Message-ID: <45186DC3.7000902@oracle.com>
Date: Mon, 25 Sep 2006 20:01:07 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Reply-To: chuck.lever@oracle.com
MIME-Version: 1.0
Subject: Re: Checking page_count(page) in invalidate_complete_page
References: <4518333E.2060101@oracle.com> <20060925141036.73f1e2b3.akpm@osdl.org> <45185D7E.6070104@yahoo.com.au> <451862C5.1010900@oracle.com> <45186481.1090306@yahoo.com.au>
In-Reply-To: <45186481.1090306@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Trond Myklebust <Trond.Myklebust@netapp.com>, Steve Dickson <steved@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Chuck Lever wrote:
> 
>> Nick Piggin wrote:
>>
>>> Andrew Morton wrote:
>>> Also, you can't guarantee anything much about its refcount even then
>>> (because it could be on a private reclaim list or pagevec somewhere).
>>>
>>>> We could retry the invalidation a few times, but that stinks.
>>>>
>>>> I think invalidate_inode_pages2() is sufficiently different from (ie:
>>>> stronger than) invalidate_inode_pages() to justify the addition of a 
>>>> new
>>>> invalidate_complete_page2(), which skips the page refcount check.
>>>>
>>>
>>> Yes, I think that would be possible using the lock_page in do_no_page 
>>> trick.
>>> That would also enable you to invalidate pages that have direct IO going
>>> into them, and other weird and wonderful get_user_pages happenings.
>>>
>>> I haven't thrown away those patches, and I am looking for a 
>>> justification
>>> for them because they make the code look nicer ;)
>>>
>>> For 2.6.18.stable, Andrew's idea of checking the return value and retry
>>> might be the only option.
>>
>>
>> I think allowing callers of invalidate_inode_pages2() to get the 
>> previous behavior is reasonable here.  There are only 2 of them: v9fs 
>> and the NFS client.
> 
> 
> 
> That still reintroduces the page fault race, but if the dumb 
> check'n'retry is
> no good then it may be OK for 2.6.18.stable, considering the page fault 
> race
> is much less common than the reclaim one. Not sure, not my call.

The NFS client uses invalidate_inode_pages2 for files, symlinks, and 
directories.  The latter two won't have the do_no_page race since you 
can't map those types of file objects.

For NFS files, the do_no_page race does exist (at least theoretically -- 
I've never seen a report of such a problem).  Most people are not brave 
enough to use shared mapped files on NFS... so that race may be very 
rare indeed.

> Upstream, it should be fixed properly without re-introducing bugs along the
> way.

Of course... thanks for sending the history.

I'm wondering aloud here, because I'm a VM neophyte.  I'm not sure how 
common the reclaim race is in real environments.  For instance, the test 
I'm running is pretty simple, and I run it just after the client has 
rebooted.  Why is try_to_free_pages being called here?  If I knew that I 
could probably make a better guess about how common this race is.

Also, the last get_page() call is from pagevec_strip().  Why do we need 
to try to strip buffers off of a page that is guaranteed not to have any 
buffers?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
