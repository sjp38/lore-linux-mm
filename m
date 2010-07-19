Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C577A6006B4
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 17:36:14 -0400 (EDT)
Date: Mon, 19 Jul 2010 14:35:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/6] writeback: avoid unnecessary calculation of bdi
 dirty thresholds
Message-Id: <20100719143520.d9af9649.akpm@linux-foundation.org>
In-Reply-To: <20100711021748.879183413@intel.com>
References: <20100711020656.340075560@intel.com>
	<20100711021748.879183413@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 11 Jul 2010 10:06:59 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> Split get_dirty_limits() into global_dirty_limits()+bdi_dirty_limit(),
> so that the latter can be avoided when under global dirty background
> threshold (which is the normal state for most systems).
> 

mm/page-writeback.c: In function 'balance_dirty_pages_ratelimited_nr':
mm/page-writeback.c:466: warning: 'dirty_exceeded' may be used uninitialized in this function

This was a real bug.

--- a/mm/page-writeback.c~writeback-avoid-unnecessary-calculation-of-bdi-dirty-thresholds-fix
+++ a/mm/page-writeback.c
@@ -463,7 +463,7 @@ static void balance_dirty_pages(struct a
 	unsigned long bdi_thresh;
 	unsigned long pages_written = 0;
 	unsigned long pause = 1;
-	int dirty_exceeded;
+	bool dirty_exceeded = false;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
 
 	for (;;) {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
