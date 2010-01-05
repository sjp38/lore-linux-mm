Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id ECF346007BA
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 04:37:45 -0500 (EST)
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <alpine.LFD.2.00.1001041904250.3630@localhost.localdomain>
References: <20100104182429.833180340@chello.nl>
	 <20100104182813.753545361@chello.nl>
	 <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.LFD.2.00.1001041904250.3630@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 05 Jan 2010 10:37:09 +0100
Message-ID: <1262684229.2400.37.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-01-04 at 19:13 -0800, Linus Torvalds wrote:
> 
> Protecting the vma isn't enough. You need to protect the whole FS stack 
> with rcu. Probably by moving _all_ of "free_vma()" into the RCU path 
> (which means that the whole file/inode gets de-allocated at that later RCU 
> point, rather than synchronously). Not just the actual kfree. 

Right, looking at that I found another interesting challenge, fput() can
sleep and I suspect that even with call_srcu() its callbacks have to be
atomic.

While looking at that code, I found the placement of might_sleep() a tad
confusing, I'd expect that to be in fput() since that is the regular
entry point (all except AIO, which does crazy things).

---
 fs/file_table.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/file_table.c b/fs/file_table.c
index 69652c5..6070c32 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -196,6 +196,8 @@ EXPORT_SYMBOL(alloc_file);
 
 void fput(struct file *file)
 {
+	might_sleep();
+
 	if (atomic_long_dec_and_test(&file->f_count))
 		__fput(file);
 }
@@ -236,8 +238,6 @@ void __fput(struct file *file)
 	struct vfsmount *mnt = file->f_path.mnt;
 	struct inode *inode = dentry->d_inode;
 
-	might_sleep();
-
 	fsnotify_close(file);
 	/*
 	 * The function eventpoll_release() should be the first called


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
