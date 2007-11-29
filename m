Message-ID: <396296481.07368@ustc.edu.cn>
Date: Thu, 29 Nov 2007 08:34:33 +0800
From: Fengguang Wu <wfg@mail.ustc.edu.cn>
Subject: Re: [patch 1/1] Writeback fix for concurrent large and small file
	writes
References: <20071128192957.511EAB8310@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071128192957.511EAB8310@localhost>
Message-Id: <E1IxXMP-0002i8-4S@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Rubin <mrubin@google.com>
Cc: a.p.zijlstra@chello.nl, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 28, 2007 at 11:29:57AM -0800, Michael Rubin wrote:
> >From mrubin@matchstick.corp.google.com Wed Nov 28 11:10:06 2007
> Message-Id: <20071128190121.716364000@matchstick.corp.google.com>
> Date: Wed, 28 Nov 2007 11:01:21 -0800
> From: mrubin@google.com
> To: mrubin@google.com
> Subject: [patch 1/1] Writeback fix for concurrent large and small file writes.
> 
> From: Michael Rubin <mrubin@google.com>
> 
> Fixing a bug where writing to large files while concurrently writing to
> smaller ones creates a situation where writeback cannot keep up with the

Could you demonstrate the situation? Or if I guess it right, could it
be fixed by the following patch? (not a nack: If so, your patch could
also be considered as a general purpose improvement, instead of a bug
fix.)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 0fca820..62e62e2 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -301,7 +301,7 @@ __sync_single_inode(struct inode *inode, struct writeback_control *wbc)
 			 * Someone redirtied the inode while were writing back
 			 * the pages.
 			 */
-			redirty_tail(inode);
+			requeue_io(inode);
 		} else if (atomic_read(&inode->i_count)) {
 			/*
 			 * The inode is clean, inuse

Thank you,
Fengguang

> traffic and memory baloons until the we hit the threshold watermark. This
> can result in surprising latency spikes when syncing. This latency
> can take minutes on large memory systems. Upon request I can provide
> a test to reproduce this situation. The flush tree fixes this issue and
> fixes several other minor issues with fairness also.
> 
> 1) Adding a data structure to guarantee fairness when writing inodes
> to disk.  The flush_tree is based on an rbtree. The only difference is
> how duplicate keys are chained off the same rb_node.
> 
> 2) Added a FS flag to mark file systems that are not disk backed so we
> don't have to flush them. Not sure I marked all of them. But just marking
> these improves writeback performance.
> 
> 3) Added an inode flag to allow inodes to be marked so that they are
> never written back to disk. See get_pipe_inode.
> 
> Under autotest this patch has passed: fsx, bonnie, and iozone. I am
> currently writing more writeback focused tests (which so far have been
> passed) to add into autotest.
> 
> Signed-off-by: Michael Rubin <mrubin@google.com>
> ---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
