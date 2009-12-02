Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6A391600762
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 08:38:06 -0500 (EST)
Date: Wed, 2 Dec 2009 21:37:53 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 24/24] HWPOISON: show corrupted file info
Message-ID: <20091202133753.GF13277@localhost>
References: <20091202031231.735876003@intel.com> <20091202043046.791112765@intel.com> <20091202132048.GI18989@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091202132048.GI18989@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 02, 2009 at 09:20:48PM +0800, Andi Kleen wrote:
> > +	dentry = d_find_alias(inode);
> > +
> > +	if (dentry) {
> > +		spin_lock(&dentry->d_lock);
> > +		name = dentry->d_name.name;
> > +	}
> 
> The standard way to do that is d_path()

Good idea.

> But the paths are somewhat meaningless without the root.

It would still be more helpful :)

> Better to not print path names for now.

OK.

> And pgoff should be just a byte offset with a range

Makes sense.


btw, I have a patch (maybe out of date) to allow calling d_path()
without a known root:


Subject: vfs: enable __d_path() to handle NULL vfsmnt

Enable __d_path() to handle vfsmnt==NULL case.

This can happen when the caller only have a struct inode/dentry instead of a
struct file, and still want to print the (partial) path within the filesystem.

Signed-off-by: Wu Fengguang <wfg@mail.ustc.edu.cn>
---

---
 fs/dcache.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

--- linux-2.6.orig/fs/dcache.c
+++ linux-2.6/fs/dcache.c
@@ -1943,7 +1943,10 @@ char *__d_path(const struct path *path, 
 
 		if (dentry == root->dentry && vfsmnt == root->mnt)
 			break;
-		if (dentry == vfsmnt->mnt_root || IS_ROOT(dentry)) {
+		if (unlikely(!vfsmnt)) {
+			if (IS_ROOT(dentry))
+				break;
+		} else if (dentry == vfsmnt->mnt_root || IS_ROOT(dentry)) {
 			/* Global root? */
 			if (vfsmnt->mnt_parent == vfsmnt) {
 				goto global_root;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
