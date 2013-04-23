Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id DAF666B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 05:31:09 -0400 (EDT)
Date: Tue, 23 Apr 2013 11:31:07 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130423093107.GF4596@quack.suse.cz>
References: <20130410105608.GC1910@suse.de>
 <20130410131245.GC4862@thunk.org>
 <20130411170402.GB11656@suse.de>
 <20130411183512.GA12298@thunk.org>
 <20130411213335.GE9379@quack.suse.cz>
 <20130412025708.GB7445@thunk.org>
 <20130412045042.GA30622@dastard>
 <20130412151952.GA4944@thunk.org>
 <20130422143846.GA2675@suse.de>
 <x49a9oqmblc.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49a9oqmblc.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On Mon 22-04-13 18:42:23, Jeff Moyer wrote:
> Jan, if I were to come up with a way of promoting a particular async
> queue to the front of the line, where would I put such a call in the
> ext4/jbd2 code to be effective?
  As Ted wrote the simplies might be to put his directly in
__lock_buffer(). Something like:

diff --git a/fs/buffer.c b/fs/buffer.c
index b4dcb34..e026a3e 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -69,6 +69,12 @@ static int sleep_on_buffer(void *word)
 
 void __lock_buffer(struct buffer_head *bh)
 {
+       /*
+        * Likely under async writeback? Tell io scheduler we are
+        * now waiting for the IO...
+        */
+       if (PageWriteback(bh->b_page))
+               io_now_sync(bh->b_bdev, bh->b_blocknr);
        wait_on_bit_lock(&bh->b_state, BH_Lock, sleep_on_buffer,
                                                        TASK_UNINTERRUPTIBLE);
}

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
