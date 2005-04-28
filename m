Date: Wed, 27 Apr 2005 17:05:15 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Can this happen ?
Message-Id: <20050427170515.54a67065.akpm@osdl.org>
In-Reply-To: <1114645113.26913.662.camel@dyn318077bld.beaverton.ibm.com>
References: <1114645113.26913.662.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, skodati@in.ibm.com
List-ID: <linux-mm.kvack.org>

Badari Pulavarty <pbadari@us.ibm.com> wrote:
>
> We ran into a panic in drop_buffers()

erk.



In rare situations, drop_buffers() can be called for a page which has buffers,
but no ->mapping (it was truncated, but the buffers were left behind because
ext3 was still fiddling with them).

But if there was an I/O error in a buffer_head, drop_buffers() will try to get
at the address_space and will oops.

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 fs/buffer.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN fs/buffer.c~drop-buffers-oops-fix fs/buffer.c
--- 25/fs/buffer.c~drop-buffers-oops-fix	Wed Apr 27 17:02:02 2005
+++ 25-akpm/fs/buffer.c	Wed Apr 27 17:02:44 2005
@@ -2924,7 +2924,7 @@ drop_buffers(struct page *page, struct b
 
 	bh = head;
 	do {
-		if (buffer_write_io_error(bh))
+		if (buffer_write_io_error(bh) && page->mapping)
 			set_bit(AS_EIO, &page->mapping->flags);
 		if (buffer_busy(bh))
 			goto failed;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
