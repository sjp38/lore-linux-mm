Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E18C96B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 10:04:03 -0400 (EDT)
Date: Thu, 30 Apr 2009 22:03:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] use GFP_NOFS in kernel_event()
Message-ID: <20090430140324.GA12033@localhost>
References: <20090430020004.GA1898@localhost> <20090429191044.b6fceae2.akpm@linux-foundation.org> <1241097573.6020.7.camel@localhost.localdomain> <20090430134821.GB8644@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090430134821.GB8644@localhost>
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Al Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 30, 2009 at 09:48:21PM +0800, Wu Fengguang wrote:
> On Thu, Apr 30, 2009 at 09:19:33PM +0800, Eric Paris wrote:
> > inotify: lockdep annotation when watch being removed
> > 
> > From: Eric Paris <eparis@redhat.com>
> > 
> > When a dentry is being evicted from memory pressure, if the inode associated
> > with that dentry has i_nlink == 0 we are going to drop all of the watches and
> > kick everything out.  Lockdep complains that previously holding inotify_mutex
> > we did a __GFP_FS allocation and now __GFP_FS reclaim is taking that lock.
> > There is no deadlock or danger, since we know on this code path we are
> > actually cleaning up and evicting everything.  So we move the lock into a new
> > class for clean up.
> 
> I can reproduce the bug and hence confirm that this patch works, so
> 
> Tested-by: Wu Fengguang <fengguang.wu@intel.com>

btw, I really see no point to have one GFP_KERNEL and one GFP_NOFS
sitting side by side inside kernel_event(). So this patch?

---
inotify: use consistent GFP_KERNEL in kernel_event()

kernel_event() has side by side kmem_cache_alloc(GFP_NOFS)
and kmalloc(GFP_KERNEL). Change to consistent GFP_KERNELs.

cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/notify/inotify/inotify_user.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- mm.orig/fs/notify/inotify/inotify_user.c
+++ mm/fs/notify/inotify/inotify_user.c
@@ -189,7 +189,7 @@ static struct inotify_kernel_event * ker
 {
 	struct inotify_kernel_event *kevent;
 
-	kevent = kmem_cache_alloc(event_cachep, GFP_NOFS);
+	kevent = kmem_cache_alloc(event_cachep, GFP_KERNEL);
 	if (unlikely(!kevent))
 		return NULL;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
