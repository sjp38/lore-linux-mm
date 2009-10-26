Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EF71D6B005A
	for <linux-mm@kvack.org>; Mon, 26 Oct 2009 14:13:19 -0400 (EDT)
Date: Mon, 26 Oct 2009 19:13:14 +0100
From: Jan Kara <jack@suse.cz>
Subject: [RFC] [PATCH] Avoid livelock for fsync
Message-ID: <20091026181314.GE7233@duck.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="UlVJffcvxoiEqYs2"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: WU Fengguang <wfg@mail.ustc.edu.cn>
Cc: npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, hch@infradead.org, chris.mason@oracle.com
List-ID: <linux-mm.kvack.org>


--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

  Hi,

  on my way back from Kernel Summit, I've coded the attached patch which
implements livelock avoidance for write_cache_pages. We tag patches that
should be written in the beginning of write_cache_pages and then write
only tagged pages (see the patch for details). The patch is based on Nick's
idea.
  The next thing I've aimed at with this patch is a simplification of
current writeback code. Basically, with this patch I think we can just rip
out all the range_cyclic and nr_to_write (or other "fairness logic"). The
rationalle is following:
  What we want to achieve with fairness logic is that when a page is
dirtied, it gets written to disk within some reasonable time (like 30s or
so). We track dirty time on per-inode basis only because keeping it
per-page is simply too expensive. So in this setting fairness between
inodes really does not make any sence - why should be a page in a file
penalized and written later only because there are lots of other dirty
pages in the file? It is enough to make sure that we don't write one file
indefinitely when there are new dirty pages continuously created - and my
patch achieves that.
  So with my patch we can make write_cache_pages always write from
range_start (or 0) to range_end (or EOF) and write all tagged pages. Also
after changing balance_dirty_pages() so that a throttled process does not
directly submit the IO (Fengguang has the patches for this), we can
completely remove the nr_to_write logic because nothing really uses it
anymore. Thus also the requeue_io logic should go away etc...
  Fengguang, do you have the series somewhere publicly available? You had
there a plenty of changes and quite some of them are not needed when the
above is done. So could you maybe separate out the balance_dirty_pages
change and I'd base my patch and further simplifications on top of that?
Thanks.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--UlVJffcvxoiEqYs2
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-mm-Implement-writeback-livelock-avoidance-using-pag.patch"


--UlVJffcvxoiEqYs2--
