Date: Fri, 30 May 2003 09:43:44 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.70-mm1
Message-Id: <20030530094344.74a0e617.akpm@digeo.com>
In-Reply-To: <12430000.1054309916@[10.10.2.4]>
References: <20030527004255.5e32297b.akpm@digeo.com>
	<1980000.1054189401@[10.10.2.4]>
	<18080000.1054233607@[10.10.2.4]>
	<20030529115237.33c9c09a.akpm@digeo.com>
	<39810000.1054240214@[10.10.2.4]>
	<20030529141405.4578b72c.akpm@digeo.com>
	<12430000.1054309916@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> Well, that just seems to make the box hang in SDET (actually, moving it
>  outside lock_kernel makes it hang in a similar way). Not sure it's 
>  *caused* by this ... it might just change timing enough to trigger it.

Yes, sorry.  Looks like you hit the filemap.c screwup.  The below should
fix it.


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
