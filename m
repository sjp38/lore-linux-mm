Message-ID: <451862BF.5080102@yahoo.com.au>
Date: Tue, 26 Sep 2006 09:14:07 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Checking page_count(page) in invalidate_complete_page
References: <4518333E.2060101@oracle.com> <20060925141036.73f1e2b3.akpm@osdl.org> <4518589E.1070705@oracle.com> <45185EF6.9070908@RedHat.com>
In-Reply-To: <45185EF6.9070908@RedHat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: chuck.lever@oracle.com, Andrew Morton <akpm@osdl.org>, Trond Myklebust <Trond.Myklebust@netapp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Steve Dickson wrote:

> Chuck Lever wrote:
>
>>
>> It seems that the NFS client could now safely use a page cache 
>> invalidator that would wait for other page users to ensure that every 
>> page is invalidated properly, instead of skipping the pages that 
>> can't be immediately invalidated.
>>
>> In my opinion that would be the correct fix here for NFS.
>
> I would have to agree with this... in debugging this I
> changed the invalidate_inode_pages2 in nfs_revalidate_mapping
> to truncate_inode_pages() for non-file inode which also seem
> to work... So it does beg the question as to why aren't we
> waiting for page to be invalidated? Is there some type of
> VM deadlock we are trying to avoid?


Some kind of VM race.

http://marc.theaimsgroup.com/?l=linux-mm&m=115443228617576&w=2

It turns out that Andrew's patch that check page_count fixes the same
problem: It does so by ensuring nothing will touch this page before it
is invalidated; the patch at the above url[*] does so by ensuring just
page faults will not touch the page.

[*] has some implementation bugs so don't use it.

Andrew's patch solves a couple of silent data loss / corruption issues
so there is no option to circumvent it upstream.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
