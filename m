Date: Wed, 28 Nov 2007 20:15:26 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 14/19] Use page_cache_xxx in ext2
In-Reply-To: <20071129040659.GC119954183@sgi.com>
Message-ID: <Pine.LNX.4.64.0711282014590.20688@schroedinger.engr.sgi.com>
References: <20071129011052.866354847@sgi.com> <20071129011147.567317218@sgi.com>
 <20071129034521.GV119954183@sgi.com> <Pine.LNX.4.64.0711281955010.20688@schroedinger.engr.sgi.com>
 <20071129040659.GC119954183@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 Nov 2007, David Chinner wrote:

> I don't think that gives the same return value. The return value
> is supposed to be clamped at a maximum of page_cache_size(mapping).

Ok. So this?


ext2: Simplify some functions

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/ext2/dir.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

Index: mm/fs/ext2/dir.c
===================================================================
--- mm.orig/fs/ext2/dir.c	2007-11-28 20:13:07.387132777 -0800
+++ mm/fs/ext2/dir.c	2007-11-28 20:14:35.739632586 -0800
@@ -63,8 +63,7 @@ static inline void ext2_put_page(struct 
 
 static inline unsigned long dir_pages(struct inode *inode)
 {
-	return (inode->i_size+page_cache_size(inode->i_mapping)-1)>>
-			page_cache_shift(inode->i_mapping);
+	return page_cache_next(inode->i_mapping, inode->i_size);
 }
 
 /*
@@ -77,7 +76,7 @@ ext2_last_byte(struct inode *inode, unsi
 	unsigned last_byte = inode->i_size;
 	struct address_space *mapping = inode->i_mapping;
 
-	last_byte -= page_nr << page_cache_shift(mapping);
+	last_byte -= page_cache_pos(mapping, page_nr, 0);
 	if (last_byte > page_cache_size(mapping))
 		last_byte = page_cache_size(mapping);
 	return last_byte;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
