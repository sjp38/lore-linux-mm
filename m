Message-ID: <451886FB.50306@yahoo.com.au>
Date: Tue, 26 Sep 2006 11:48:43 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Checking page_count(page) in invalidate_complete_page
References: <4518333E.2060101@oracle.com> <20060925141036.73f1e2b3.akpm@osdl.org> <45185D7E.6070104@yahoo.com.au> <451862C5.1010900@oracle.com> <45186481.1090306@yahoo.com.au> <45186DC3.7000902@oracle.com> <451870C6.6050008@yahoo.com.au> <4518835D.3080702@oracle.com>
In-Reply-To: <4518835D.3080702@oracle.com>
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
>> I don't see where pagevec_strip calls get_page()?
>
>
> Ah, you're right, I was off by one symbol.  The get_page call is in 
> pagevec_lookup() (via find_get_pages).  That could mean there isn't a 
> reclaim race at all.


There will be transient (ie. race) conditions where the page count is 
elevated for whatever
reason. Reclaim is one of those, so this failure you're seeing will need 
to be fixed on the
NFS / invalidate side somehow.

>
> The page references I'm noting are:
>
> 1.  add_to_page_cache_lru  1 -> 2
>
> 2.  do_generic_mapping_read, released in nfs_do_filldir
>
> 3.  read_cache_page, released in nfs_readdir
>
> 4.  pagevec_lookup (from invalidate_inode_pages2_range)  2 -> 3
>
> The odd thing is some of the pages for the directory are released, so 
> they must have a ref count of 2 *after* the pagevec_lookup.  Looks 
> like more investigation is needed.


Well they could get flushed out of the lru add pagevecs which drops 
their count. Just to
test that theory you could run lru_add_drain_all() at the start of the 
invalidate function.
That's not going to actually fix the problem, but it might help 2.6.18 
limp along when
combined with some other work.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
