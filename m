Message-ID: <451870C6.6050008@yahoo.com.au>
Date: Tue, 26 Sep 2006 10:13:58 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Checking page_count(page) in invalidate_complete_page
References: <4518333E.2060101@oracle.com> <20060925141036.73f1e2b3.akpm@osdl.org> <45185D7E.6070104@yahoo.com.au> <451862C5.1010900@oracle.com> <45186481.1090306@yahoo.com.au> <45186DC3.7000902@oracle.com>
In-Reply-To: <45186DC3.7000902@oracle.com>
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
>> That still reintroduces the page fault race, but if the dumb 
>> check'n'retry is
>> no good then it may be OK for 2.6.18.stable, considering the page 
>> fault race
>> is much less common than the reclaim one. Not sure, not my call.
>
>
> The NFS client uses invalidate_inode_pages2 for files, symlinks, and 
> directories.  The latter two won't have the do_no_page race since you 
> can't map those types of file objects.


But they're present on the LRU? That's unusual (I guess NFS doesn't have 
a buffer cache for a backing
block device).

> For NFS files, the do_no_page race does exist (at least theoretically 
> -- I've never seen a report of such a problem).  Most people are not 
> brave enough to use shared mapped files on NFS... so that race may be 
> very rare indeed.


I think the race is rare, but we have had at least one customer see it. 
The problem with mainline kernel
is that there will be no indication from the kernel, and it will be hard 
enough to reproduce that it will
probably be considered as a hardware bug or a userspace bug if someone 
hits it.

>> Upstream, it should be fixed properly without re-introducing bugs 
>> along the
>> way.
>
>
> Of course... thanks for sending the history.
>
> I'm wondering aloud here, because I'm a VM neophyte.  I'm not sure how 
> common the reclaim race is in real environments.  For instance, the 
> test I'm running is pretty simple, and I run it just after the client 
> has rebooted.  Why is try_to_free_pages being called here?  If I knew 
> that I could probably make a better guess about how common this race is.


It will be called because you're low on memory somewhere. Reclaim is 
common (usually to free up old pagecache).

>
> Also, the last get_page() call is from pagevec_strip().  Why do we 
> need to try to strip buffers off of a page that is guaranteed not to 
> have any buffers?


I don't see where pagevec_strip calls get_page()?

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
