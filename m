Date: Sat, 19 Jul 2003 23:12:30 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test1-mm2
Message-Id: <20030719231230.4de39ffe.akpm@osdl.org>
In-Reply-To: <200307200647.43410.Starborn@anime-city.co.uk>
References: <20030719174350.7dd8ad59.akpm@osdl.org>
	<20030720024102.GA18576@triplehelix.org>
	<20030720042918.GA19219@triplehelix.org>
	<200307200647.43410.Starborn@anime-city.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Morris <Starborn@anime-city.co.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joshua Kwan <joshk@triplehelix.org>
List-ID: <linux-mm.kvack.org>

Michael Morris <Starborn@anime-city.co.uk> wrote:
>
> Here's my oops:
> 
> Unable to handle kernel NULL pointer dereference at virtual address 00000014
> EIP is at journal_dirty_metadata+0x38/0x210

OK, bad bug.  This should fix it.

 fs/ext3/inode.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff -puN fs/ext3/inode.c~ext3_getblk-race-fix-fix fs/ext3/inode.c
--- 25/fs/ext3/inode.c~ext3_getblk-race-fix-fix	2003-07-19 22:59:50.000000000 -0700
+++ 25-akpm/fs/ext3/inode.c	2003-07-19 23:07:42.000000000 -0700
@@ -936,19 +936,17 @@ struct buffer_head *ext3_getblk(handle_t
 			   ext3_get_block instead, so it's not a
 			   problem. */
 			lock_buffer(bh);
-			if (!buffer_uptodate(bh)) {
-				BUFFER_TRACE(bh, "call get_create_access");
-				fatal = ext3_journal_get_create_access(handle, bh);
-				if (!fatal) {
-					memset(bh->b_data, 0,
-							inode->i_sb->s_blocksize);
-					set_buffer_uptodate(bh);
-				}
+			BUFFER_TRACE(bh, "call get_create_access");
+			fatal = ext3_journal_get_create_access(handle, bh);
+			if (!fatal && !buffer_uptodate(bh)) {
+				memset(bh->b_data, 0, inode->i_sb->s_blocksize);
+				set_buffer_uptodate(bh);
 			}
 			unlock_buffer(bh);
 			BUFFER_TRACE(bh, "call ext3_journal_dirty_metadata");
 			err = ext3_journal_dirty_metadata(handle, bh);
-			if (!fatal) fatal = err;
+			if (!fatal)
+				fatal = err;
 		} else {
 			BUFFER_TRACE(bh, "not a new buffer");
 		}

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
