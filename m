Date: Mon, 23 Apr 2007 19:23:45 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: [RFC 00/16] Variable Order Page Cache Patchset V2
Message-ID: <20070423092345.GH32602149@melbourne.sgi.com>
References: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>, Badari Pulavarty <pbadari@gmail.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Adam Litke <aglitke@gmail.com>, Dave Hansen <hansendc@us.ibm.com>, Mel Gorman <mel@skynet.ie>, Avi Kivity <avi@argo.co.il>
List-ID: <linux-mm.kvack.org>

On Sun, Apr 22, 2007 at 11:48:45PM -0700, Christoph Lameter wrote:
> Sorry for the earlier mail. quilt and exim not cooperating.
> 
> RFC V1->V2
> - Some ext2 support
> - Some block layer, fs layer support etc.
> - Better page cache macros
> - Use macros to clean up code.

I have this running on x86_64 UML with XFS. I've tested 16k and 64k
block size using fsx with mmap operations turned off. It survives
at least 100,000 operations without problems now.

You need to apply a fix to memclear_highpage_flush() otherwise
it bugs out on the first partial page truncate. I've attached
my hack below. Christoph, there's header file inclusion order
problems with using your new wrappers here, which is why I
open coded it. I'll leave it for you to solve ;)

I'll attach the XFS patch in another email.....

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group


---
 include/linux/highmem.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.21-rc7/include/linux/highmem.h
===================================================================
--- linux-2.6.21-rc7.orig/include/linux/highmem.h	2007-04-23 18:46:20.917655632 +1000
+++ linux-2.6.21-rc7/include/linux/highmem.h	2007-04-23 18:48:20.047323146 +1000
@@ -88,7 +88,7 @@ static inline void memclear_highpage_flu
 {
 	void *kaddr;
 
-	BUG_ON(offset + size > PAGE_SIZE);
+	BUG_ON(offset + size > (PAGE_SIZE << page->mapping->order));
 
 	kaddr = kmap_atomic(page, KM_USER0);
 	memset((char *)kaddr + offset, 0, size);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
