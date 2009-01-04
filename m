Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8DFE06B00BA
	for <linux-mm@kvack.org>; Sun,  4 Jan 2009 17:08:32 -0500 (EST)
Date: Sun, 4 Jan 2009 17:08:29 -0500
From: Theodore Tso <tytso@mit.edu>
Subject: [tytso@MIT.EDU: [PATCH, RFC] Use WRITE_SYNC in
	__block_write_full_page() if WBC_SYNC_ALL]
Message-ID: <20090104220829.GE22958@mit.edu>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="C7zPtVaVf+AK4Oqc"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Sorry, I screwed up the hostname for the linux-mm mailing list....

Comments, suggestions, et. al.  appreciated.  Many thanks,

       	 	    		     	 - Ted

--C7zPtVaVf+AK4Oqc
Content-Type: message/rfc822
Content-Disposition: inline

Return-Path: <linux-ext4-owner@vger.kernel.org>
Received: from po14.mit.edu ([unix socket])
	by po14.mit.edu (Cyrus v2.1.5) with LMTP; Sun, 04 Jan 2009 16:52:56 -0500
X-Sieve: CMU Sieve 2.2
Received: from pacific-carrier-annex.mit.edu by po14.mit.edu (8.13.6/4.7) id n04LquPd012114; Sun, 4 Jan 2009 16:52:56 -0500 (EST)
Received: from mit.edu (W92-130-BARRACUDA-1.MIT.EDU [18.7.21.220])
	by pacific-carrier-annex.mit.edu (8.13.6/8.9.2) with ESMTP id n04LqpH6024890
	for <tytso@mit.edu>; Sun, 4 Jan 2009 16:52:51 -0500 (EST)
X-ASG-Whitelist: Barracuda Reputation
Received: from vger.kernel.org (vger.kernel.org [209.132.176.167])
	by mit.edu (Spam Firewall) with ESMTP
	id 227F7D15DF1; Sun,  4 Jan 2009 16:52:51 -0500 (EST)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
	id S1750822AbZADVwu (ORCPT <rfc822;andersk@mit.edu> + 1 other);
	Sun, 4 Jan 2009 16:52:50 -0500
Received: (majordomo@vger.kernel.org) by vger.kernel.org id S1751121AbZADVwu
	(ORCPT <rfc822;linux-ext4-outgoing>); Sun, 4 Jan 2009 16:52:50 -0500
Received: from thunk.org ([69.25.196.29]:57185 "EHLO thunker.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750822AbZADVwu (ORCPT <rfc822;linux-ext4@vger.kernel.org>);
	Sun, 4 Jan 2009 16:52:50 -0500
Received: from root (helo=closure.thunk.org)
	by thunker.thunk.org with local-esmtp   (Exim 4.50 #1 (Debian))
	id 1LJatq-0006as-KP; Sun, 04 Jan 2009 16:52:46 -0500
Received: from tytso by closure.thunk.org with local (Exim 4.69)
	(envelope-from <tytso@mit.edu>)
	id 1LJatq-00061O-0e; Sun, 04 Jan 2009 16:52:46 -0500
To: Andrew Morton <akpm@osdl.org>, linux-mm@vger.kernel.org,
        linux-ext4@vger.kernel.org, Arjan van de Ven <arjan@infradead.org>
Cc: Jens Axboe <jens.axboe@oracle.com>
Subject: [PATCH, RFC] Use WRITE_SYNC in __block_write_full_page() if WBC_SYNC_ALL
From: "Theodore Ts'o" <tytso@MIT.EDU>
Phone: (781) 391-3464
Message-Id: <E1LJatq-00061O-0e@closure.thunk.org>
Date: Sun, 04 Jan 2009 16:52:46 -0500
X-SA-Exim-Connect-IP: <locally generated>
X-SA-Exim-Mail-From: tytso@mit.edu
X-SA-Exim-Scanned: No (on thunker.thunk.org); SAEximRunCond expanded to false
Sender: linux-ext4-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-ext4.vger.kernel.org>
X-Mailing-List: linux-ext4@vger.kernel.org
X-Spam-Score: -2.599
X-Spam-Flag: NO
X-Scanned-By: MIMEDefang 2.42


If wbc.sync_mode is WBC_SYNC_ALL, then in the page writeback paths we
will be waiting for the write to complete.  So the I/O should be
submitted via submit_bh() with WRITE_SYNC so the block layer should
properly prioritize the I/O.

Signed-off-by: "Theodore Ts'o" <tytso@mit.edu>
Cc: linux-mm@vger.kernel.org
---

Following up with an e-mail thread started by Arjan two months ago,
(subject: [PATCH] Give kjournald a IOPRIO_CLASS_RT io priority), I have
a patch, just sent to linux-ext4@vger.kernel.org, which fixes the jbd2
layer to submit journal writes via submit_bh() with WRITE_SYNC.
Hopefully this might be enough of a priority boost so we don't have to
force a higher I/O priority level via a buffer_head flag.  However,
while looking through the code paths, in ordered data mode, we end up
flushing data pages via the page writeback paths on a per-inode basis,
and I noticed that even though we are passing in
wbc.sync_mode=WBC_SYNC_ALL, __block_write_full_page() is using
submit_bh(WRITE, bh) instead of submit_bh(WRITE_SYNC).

I'm not completely confident in my understanding of the page writeback
code paths --- does this change make sense?

					- Ted

 fs/buffer.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 10179cf..392b1b3 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1741,7 +1741,8 @@ static int __block_write_full_page(struct inode *inode, struct page *page,
 	do {
 		struct buffer_head *next = bh->b_this_page;
 		if (buffer_async_write(bh)) {
-			submit_bh(WRITE, bh);
+			submit_bh((wbc->sync_mode == WB_SYNC_ALL) ?
+				  WRITE_SYNC : WRITE, bh);
 			nr_underway++;
 		}
 		bh = next;
@@ -1795,7 +1796,8 @@ recover:
 		struct buffer_head *next = bh->b_this_page;
 		if (buffer_async_write(bh)) {
 			clear_buffer_dirty(bh);
-			submit_bh(WRITE, bh);
+			submit_bh((wbc->sync_mode == WB_SYNC_ALL) ?
+				  WRITE_SYNC : WRITE, bh);
 			nr_underway++;
 		}
 		bh = next;
-- 
1.6.0.4.8.g36f27.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-ext4" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

--C7zPtVaVf+AK4Oqc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
