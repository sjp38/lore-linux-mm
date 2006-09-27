Message-ID: <451A9E9C.70503@oracle.com>
Date: Wed, 27 Sep 2006 11:54:04 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Reply-To: chuck.lever@oracle.com
MIME-Version: 1.0
Subject: Re: Checking page_count(page) in invalidate_complete_page
References: <4518333E.2060101@oracle.com> <20060925141036.73f1e2b3.akpm@osdl.org> <45185D7E.6070104@yahoo.com.au> <451862C5.1010900@oracle.com> <45186481.1090306@yahoo.com.au> <45186DC3.7000902@oracle.com> <451870C6.6050008@yahoo.com.au> <4518835D.3080702@oracle.com> <4518C7F1.3050809@yahoo.com.au> <4519273C.3000301@oracle.com> <451A025E.7020008@yahoo.com.au>
In-Reply-To: <451A025E.7020008@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Trond Myklebust <Trond.Myklebust@netapp.com>, Steve Dickson <steved@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Chuck Lever wrote:
>> Invalidate_inode_pages2() is used to remove page cache data that the 
>> client has determined is stale.  The client detects that the file has 
>> changed on the server, and it is not responsible for those changes, by 
>> examining the file's attributes and noticing mtime or size changes. 
>> When such a change is detected, all pages cached for a file are 
>> invalidated, and the page cache is gradually repopulated from the 
>> server as applications access parts of the file.
>>
> 
> If you can guarantee that a pagecache page can never get mapped to a 
> user mapping (eg. perhaps for
> directories and symlinks) and also ensure that you don't dirty it via 
> the filesystem, then you don't
> have to worry about it becoming dirty, so we can skip the checks Andrew 
> has added and maybe add a
> WARN_ON(PageDirty()).

As far as I can tell, for cached non-regular files, they can't be mapped 
or written to, and cannot be targets of direct I/O.

So, I think it's acceptable to add logic in nfs_revalidate_mapping() to 
use invalidate_inode_pages2() for non-regular files (and check the 
return code, of course), as long as we have addressed the page count 
issue somehow.

> Now that won't help you for regular file pages that can be mmapped. For 
> those, we need to ensure
> that the page isn't mapped, and the page will not be dirtied via a 
> get_user_pages user, and you need
> to ensure that it can't get dirtied via the filesystem. The former two 
> will require VM changes of
> the scale that aren't going to get into 2.6.19, but I'm working on them.
> 
> For now, can make do with flushing lru pagevecs, and also testing and 
> retrying in the caller?

I planned to play with this a bit yesterday, but got swept up in some 
higher priority issues.  Will try to get to testing this soonest.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
