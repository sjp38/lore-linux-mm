Message-ID: <451884C1.8080209@yahoo.com.au>
Date: Tue, 26 Sep 2006 11:39:13 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] Make invalidate_inode_pages2() work again
References: <20060925231557.32226.66866.stgit@ingres.dsl.sfldmi.ameritech.net>	 <45186D4A.70009@yahoo.com.au> <1159233613.5442.61.camel@lade.trondhjem.org>
In-Reply-To: <1159233613.5442.61.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chucklever@gmail.com>, apkm@osdl.org, linux-mm@kvack.org, steved@redhat.com
List-ID: <linux-mm.kvack.org>

Trond Myklebust wrote:

>On Tue, 2006-09-26 at 09:59 +1000, Nick Piggin wrote:
>
>>Chuck Lever wrote:
>>
>>
>>>A recent change to fix a problem with invalidate_inode_pages() has weakened
>>>the behavior of invalidate_inode_pages2() inadvertently.  Add a flag to
>>>tell the helper routines when stronger invalidation semantics are desired.
>>>
>>>
>>Question: if invalidate_inode_pages2 cares about not invalidating dirty
>>pages, how can one avoid the page_count check and it still be correct
>>(ie. not randomly lose dirty bits in some situations)?
>>
>
>Tests of page_count _suck_ 'cos they are 100% non-specific. Is there no
>way to set a page flag or something to indicate that the page may have
>been remapped while we were sleeping?
>

We can exclude the page from being mapped again, if we put a lock_page in
the pagefault handler (which, we have decided, could be reasonable). But
that will only ensure it is not mapped.

If you want to ensure it never becomes *dirty*, then you need to test
page_count because it is the only way to know whether some page obtained
via get_user_pages will, without warning, get dirtied in some corner of
the kernel.

If it weren't for get_user_pages, once we are able to exclude all mappings,
it sounds sane for a filesystem to be able to then exclude anything else
that might dirty the page.

So I really dislike get_user_pages for reasons such as this. IMO it would
be cool if get_user_pages when the caller wants to write, would return with
the page dirty and a bit set to prevent writeout from cleaning it until it
has been finished with (via put_user_pages).

Actually, _ideally_, maybe keeping the mapping around (ie. holding at
least a read lock on mmap_sem) would do the trick. The presence of the
mapping will be seen by the invalidate routines[*], and in general things
might be simplified.

[*] although they'll still go ahead and invalidate the ptes because they
don't take mmap_sem. So something else might be needed. I haven't thought
this through.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
