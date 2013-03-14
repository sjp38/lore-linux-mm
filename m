Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 5BF816B0027
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 19:01:12 -0400 (EDT)
Date: Thu, 14 Mar 2013 16:01:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] bounce:fix bug, avoid to flush dcache on slab page from
 jbd2.
Message-Id: <20130314160110.a0fe092cb103bfe6720d3009@linux-foundation.org>
In-Reply-To: <20130314224243.GI5313@blackbox.djwong.org>
References: <5139DB90.5090302@gmail.com>
	<20130312153221.0d26fe5599d4885e51bb0c7c@linux-foundation.org>
	<20130313011020.GA5313@blackbox.djwong.org>
	<20130313085021.GA29730@quack.suse.cz>
	<20130313194429.GE5313@blackbox.djwong.org>
	<20130313210216.GA7754@quack.suse.cz>
	<20130314224243.GI5313@blackbox.djwong.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Jan Kara <jack@suse.cz>, Shuge <shugelinux@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Kevin <kevin@allwinneretch.com>, Theodore Ts'o <tytso@mit.edu>, Jens Axboe <axboe@kernel.dk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org

On Thu, 14 Mar 2013 15:42:43 -0700 "Darrick J. Wong" <darrick.wong@oracle.com> wrote:

> Subject: [PATCH] mm: Make snapshotting pages for stable writes a per-bio operation
> 
> Walking a bio's page mappings has proved problematic, so create a new bio flag
> to indicate that a bio's data needs to be snapshotted in order to guarantee
> stable pages during writeback.  Next, for the one user (ext3/jbd) of
> snapshotting, hook all the places where writes can be initiated without
> PG_writeback set, and set BIO_SNAP_STABLE there.  Finally, the MS_SNAP_STABLE
> mount flag (only used by ext3) is now superfluous, so get rid of it.

whoa, that looks way better.

Must do this though:

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-make-snapshotting-pages-for-stable-writes-a-per-bio-operation-fix

rename _submit_bh()'s `flags' to `bio_flags', delobotomize the _submit_bh declaration

Cc: Adrian Hunter <adrian.hunter@intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Artem Bityutskiy <dedekind1@gmail.com>
Cc: Darrick J. Wong <darrick.wong@oracle.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Jens Axboe <axboe@kernel.dk>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/buffer.c                 |    4 ++--
 include/linux/buffer_head.h |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff -puN fs/buffer.c~mm-make-snapshotting-pages-for-stable-writes-a-per-bio-operation-fix fs/buffer.c
--- a/fs/buffer.c~mm-make-snapshotting-pages-for-stable-writes-a-per-bio-operation-fix
+++ a/fs/buffer.c
@@ -2949,7 +2949,7 @@ static void guard_bh_eod(int rw, struct
 	}
 }
 
-int _submit_bh(int rw, struct buffer_head * bh, unsigned long flags)
+int _submit_bh(int rw, struct buffer_head * bh, unsigned long bio_flags)
 {
 	struct bio *bio;
 	int ret = 0;
@@ -2984,7 +2984,7 @@ int _submit_bh(int rw, struct buffer_hea
 
 	bio->bi_end_io = end_bio_bh_io_sync;
 	bio->bi_private = bh;
-	bio->bi_flags |= flags;
+	bio->bi_flags |= bio_flags;
 
 	/* Take care of bh's that straddle the end of the device */
 	guard_bh_eod(rw, bio, bh);
diff -puN include/linux/buffer_head.h~mm-make-snapshotting-pages-for-stable-writes-a-per-bio-operation-fix include/linux/buffer_head.h
--- a/include/linux/buffer_head.h~mm-make-snapshotting-pages-for-stable-writes-a-per-bio-operation-fix
+++ a/include/linux/buffer_head.h
@@ -181,7 +181,7 @@ void ll_rw_block(int, int, struct buffer
 int sync_dirty_buffer(struct buffer_head *bh);
 int __sync_dirty_buffer(struct buffer_head *bh, int rw);
 void write_dirty_buffer(struct buffer_head *bh, int rw);
-int _submit_bh(int, struct buffer_head *, unsigned long);
+int _submit_bh(int rw, struct buffer_head *bh, unsigned long bio_flags);
 int submit_bh(int, struct buffer_head *);
 void write_boundary_block(struct block_device *bdev,
 			sector_t bblock, unsigned blocksize);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
