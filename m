Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id E4B9D6B004F
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 15:55:58 -0500 (EST)
Date: Fri, 16 Dec 2011 12:55:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: add missing mutex lock arround notify_change
Message-Id: <20111216125556.db2bf308.akpm@linux-foundation.org>
In-Reply-To: <20111216112534.GA13147@dztty>
References: <20111216112534.GA13147@dztty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Djalal Harouni <tixxdz@opendz.org>
Cc: Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>, Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>

On Fri, 16 Dec 2011 12:25:34 +0100
Djalal Harouni <tixxdz@opendz.org> wrote:

> 
> Calls to notify_change() must hold i_mutex.
> 

It seems that this is true.  It's tersely documented in
Documentation/filesystems/porting.  It should be mentioned in the
non-existent notify_change() kerneldoc.

<does a quick audit>

fs/hpfs/namei.c and fs/nfsd/vfs.c:nfsd_setattr() aren't obviosuly
holding that lock when calling notify_change().  Everything else under
fs/ looks OK.

I'll add the below to my tree and shall slip it into linux-next, but not
mainline:

--- a/fs/attr.c~a
+++ a/fs/attr.c
@@ -171,6 +171,8 @@ int notify_change(struct dentry * dentry
 	struct timespec now;
 	unsigned int ia_valid = attr->ia_valid;
 
+	WARN_ON_ONCE(!mutex_is_locked(&inode->i_mutex));
+
 	if (ia_valid & (ATTR_MODE | ATTR_UID | ATTR_GID | ATTR_TIMES_SET)) {
 		if (IS_IMMUTABLE(inode) || IS_APPEND(inode))
 			return -EPERM;
@@ -245,5 +247,4 @@ int notify_change(struct dentry * dentry
 
 	return error;
 }
-
 EXPORT_SYMBOL(notify_change);


> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1994,10 +1994,16 @@ EXPORT_SYMBOL(should_remove_suid);
>  
>  static int __remove_suid(struct dentry *dentry, int kill)
>  {
> +	int ret;
>  	struct iattr newattrs;
>  
>  	newattrs.ia_valid = ATTR_FORCE | kill;
> -	return notify_change(dentry, &newattrs);
> +
> +	mutex_lock(&dentry->d_inode->i_mutex);
> +	ret = notify_change(dentry, &newattrs);
> +	mutex_unlock(&dentry->d_inode->i_mutex);
> +
> +	return ret;
>  }
>  
>  int file_remove_suid(struct file *file)

Looks good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
