Message-ID: <451C6AAC.1080203@yahoo.com.au>
Date: Fri, 29 Sep 2006 10:37:00 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Checking page_count(page) in invalidate_complete_page
References: <4518333E.2060101@oracle.com>	<20060925141036.73f1e2b3.akpm@osdl.org>	<45185D7E.6070104@yahoo.com.au>	<451862C5.1010900@oracle.com>	<45186481.1090306@yahoo.com.au>	<45186DC3.7000902@oracle.com>	<451870C6.6050008@yahoo.com.au>	<4518835D.3080702@oracle.com>	<451886FB.50306@yahoo.com.au>	<451BF7BC.1040807@oracle.com>	<20060928093640.14ecb1b1.akpm@osdl.org>	<20060928094023.e888d533.akpm@osdl.org>	<451BFB84.5070903@oracle.com> <20060928100306.0b58f3c7.akpm@osdl.org> <451C01C8.7020104@oracle.com>
In-Reply-To: <451C01C8.7020104@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: chuck.lever@oracle.com
Cc: Andrew Morton <akpm@osdl.org>, Trond Myklebust <Trond.Myklebust@netapp.com>, Steve Dickson <steved@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chuck Lever wrote:

> Andrew Morton wrote:
>
>> lru_add_drain_all() is a nasty, hacky, not-exported-to-modules 
>> thing.  It
>> equates to lru_add_drain() if !CONFIG_NUMA.
>

It should drain on all CPUs though, I can't remember why it doesn't.
Not that I disagree that throwing IPIs around is a hack ;)

>>
>> Sigh, we're not getting there, are we?
>>
>> I'm still thinking we add invalidate_complete_page2() to get us out of
>> trouble and park the problem :(.  That'd be a good approach for 
>> 2.6.18.x,
>> which I assume is fairly urgent.
>
>
> Choosing which fix to include is above my pay grade.  Both of these 
> proposals address the NFS readdir cache invalidation problem.
>
> But it seems like there is a real problem here -- the pages that are 
> waiting to be added the LRU will always have a page count that is too 
> high for invalidate_inode_pages to work on them.


If you do the lru_add_drain_all, then the vmscan problem should be probably
mostly fixable by detecting failure, waiting, and retrying a few times.

After that, making an invalidate_complete_page2 ignore the page count or
dirty status would only save you from a very small number of cases, and they
would be likely to be a data loss / corruption case.

OTOH, we haven't had many complains before, so for 2.6.18, an
invalidate_complete_page2 may indeed be the best option?

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
