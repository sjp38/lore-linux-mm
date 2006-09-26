Message-ID: <4519273C.3000301@oracle.com>
Date: Tue, 26 Sep 2006 09:12:28 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Reply-To: chuck.lever@oracle.com
MIME-Version: 1.0
Subject: Re: Checking page_count(page) in invalidate_complete_page
References: <4518333E.2060101@oracle.com> <20060925141036.73f1e2b3.akpm@osdl.org> <45185D7E.6070104@yahoo.com.au> <451862C5.1010900@oracle.com> <45186481.1090306@yahoo.com.au> <45186DC3.7000902@oracle.com> <451870C6.6050008@yahoo.com.au> <4518835D.3080702@oracle.com> <4518C7F1.3050809@yahoo.com.au>
In-Reply-To: <4518C7F1.3050809@yahoo.com.au>
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
>>> But they're present on the LRU? That's unusual (I guess NFS doesn't 
>>> have a buffer cache for a backing
>>> block device).
>>
>>
>> That is correct -- NFS doesn't use the buffer cache.
> 
> 
> So that raises another question: how do they get to invalidate_inode_pages2
> if they are not part of the buffer or pagecache?

It does use the page cache to cache data pages for files, directories, 
and symlinks.  It does not use buffers, however, since incoming file 
system data is read from a socket, not from a block device.  I believe 
the client provides a dummy backing device for the few things in the VFS 
that require it.

Invalidate_inode_pages2() is used to remove page cache data that the 
client has determined is stale.  The client detects that the file has 
changed on the server, and it is not responsible for those changes, by 
examining the file's attributes and noticing mtime or size changes. 
When such a change is detected, all pages cached for a file are 
invalidated, and the page cache is gradually repopulated from the server 
as applications access parts of the file.

I'd like to understand the difference between invalidate_inode_pages2() 
and truncate_inode_pages() in this scenario.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
