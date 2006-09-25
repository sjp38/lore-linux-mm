Message-ID: <45186481.1090306@yahoo.com.au>
Date: Tue, 26 Sep 2006 09:21:37 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Checking page_count(page) in invalidate_complete_page
References: <4518333E.2060101@oracle.com> <20060925141036.73f1e2b3.akpm@osdl.org> <45185D7E.6070104@yahoo.com.au> <451862C5.1010900@oracle.com>
In-Reply-To: <451862C5.1010900@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: chuck.lever@oracle.com
Cc: Andrew Morton <akpm@osdl.org>, Trond Myklebust <Trond.Myklebust@netapp.com>, Steve Dickson <steved@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chuck Lever wrote:

> Nick Piggin wrote:
>
>> Andrew Morton wrote:
>> Also, you can't guarantee anything much about its refcount even then
>> (because it could be on a private reclaim list or pagevec somewhere).
>>
>>> We could retry the invalidation a few times, but that stinks.
>>>
>>> I think invalidate_inode_pages2() is sufficiently different from (ie:
>>> stronger than) invalidate_inode_pages() to justify the addition of a 
>>> new
>>> invalidate_complete_page2(), which skips the page refcount check.
>>>
>>
>> Yes, I think that would be possible using the lock_page in do_no_page 
>> trick.
>> That would also enable you to invalidate pages that have direct IO going
>> into them, and other weird and wonderful get_user_pages happenings.
>>
>> I haven't thrown away those patches, and I am looking for a 
>> justification
>> for them because they make the code look nicer ;)
>>
>> For 2.6.18.stable, Andrew's idea of checking the return value and retry
>> might be the only option.
>
>
> I think allowing callers of invalidate_inode_pages2() to get the 
> previous behavior is reasonable here.  There are only 2 of them: v9fs 
> and the NFS client.



That still reintroduces the page fault race, but if the dumb 
check'n'retry is
no good then it may be OK for 2.6.18.stable, considering the page fault race
is much less common than the reclaim one. Not sure, not my call.

Upstream, it should be fixed properly without re-introducing bugs along the
way.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
