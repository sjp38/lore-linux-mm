Message-ID: <40B9A855.3030102@yahoo.com.au>
Date: Sun, 30 May 2004 19:24:37 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: mmap() > phys mem problem
References: <Pine.LNX.4.44.0405251523250.18898-100000@pygar.sc.orionmulti.com> <Pine.LNX.4.55L.0405282208210.32578@imladris.surriel.com> <Pine.LNX.4.60.0405292144350.1068@stimpy>
In-Reply-To: <Pine.LNX.4.60.0405292144350.1068@stimpy>
Content-Type: multipart/mixed;
 boundary="------------060101050106080002060601"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ron Maeder <rlm@orionmulti.com>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060101050106080002060601
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Ron Maeder wrote:
> On Fri, 28 May 2004, Rik van Riel wrote:
> 
>> On Tue, 25 May 2004, Ron Maeder wrote:
>>
>>> Is this an "undocumented feature" or is this a linux error?  I would
>>> expect pages of the mmap()'d file would get paged back to the original
>>> file. I know this won't be fast, but the performance is not an issue for
>>> this application.
>>
>>
>> It looks like a kernel bug.  Can you reproduce this problem
>> with the latest 2.6 kernel or is it still there ?
>>
>> Rik
> 
> 
> I was able to reproduce the problem with the code that I posted on a 2.6.6
> kernel.
> 

Can you give this NFS patch (from Trond) a try please?

(I don't think it is a very good idea for NFS to be using
WRITEPAGE_ACTIVATE here. If NFS needs to have good write
clustering off the end of the LRU, we need to go about it
some other way.)


--------------060101050106080002060601
Content-Type: text/x-patch;
 name="nfs-writepage.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-writepage.patch"

 linux-2.6-npiggin/fs/nfs/write.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff -puN fs/nfs/write.c~nfs-writepage fs/nfs/write.c
--- linux-2.6/fs/nfs/write.c~nfs-writepage	2004-05-30 18:46:48.000000000 +1000
+++ linux-2.6-npiggin/fs/nfs/write.c	2004-05-30 18:46:48.000000000 +1000
@@ -320,7 +320,7 @@ do_it:
 		if (err >= 0) {
 			err = 0;
 			if (wbc->for_reclaim)
-				err = WRITEPAGE_ACTIVATE;
+				nfs_flush_inode(inode, 0, 0, FLUSH_STABLE);
 		}
 	} else {
 		err = nfs_writepage_sync(NULL, inode, page, 0,
@@ -333,8 +333,7 @@ do_it:
 	}
 	unlock_kernel();
 out:
-	if (err != WRITEPAGE_ACTIVATE)
-		unlock_page(page);
+	unlock_page(page);
 	if (inode_referenced)
 		iput(inode);
 	return err; 

_

--------------060101050106080002060601--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
