Date: Fri, 30 May 2003 04:17:04 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.70-mm2
Message-Id: <20030530041704.5d740ee2.akpm@digeo.com>
In-Reply-To: <200305291452.09041.pbadari@us.ibm.com>
References: <20030529012914.2c315dad.akpm@digeo.com>
	<200305291452.09041.pbadari@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, nsharoff@us.ibm.com, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Badari Pulavarty <pbadari@us.ibm.com> wrote:
>
> 2.5.70-mm2 seems to hang while running LTP.

It is actually a VFS bug.  A brand new one.  Here's a fix, but we should
check that it still gets all the LTP writev cases right.

A couple of ext3 bugs in -mm2 have been fixed so please don't spend time
stresstesting it until mm3.

Thanks.



The recent writev() fix broke the invariant that ->commit_write _must_ be
called after a successful ->prepare_write().  It leaves ext3 with a
transaction stuck open and the filesystem locks up.




 mm/filemap.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff -puN mm/filemap.c~generic_file_write-commit_write-fix mm/filemap.c
--- 25/mm/filemap.c~generic_file_write-commit_write-fix	2003-05-30 04:01:19.000000000 -0700
+++ 25-akpm/mm/filemap.c	2003-05-30 04:04:11.000000000 -0700
@@ -1718,10 +1718,9 @@ generic_file_aio_write_nolock(struct kio
 			copied = filemap_copy_from_user_iovec(page, offset,
 						cur_iov, iov_base, bytes);
 		flush_dcache_page(page);
+		status = a_ops->commit_write(file, page, offset,
+						offset + copied);
 		if (likely(copied > 0)) {
-			status = a_ops->commit_write(file, page, offset,
-						     offset + copied);
-
 			if (!status)
 				status = copied;
 

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
