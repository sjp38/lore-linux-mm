Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 84FFE8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 21:58:30 -0400 (EDT)
Date: Tue, 29 Mar 2011 20:58:30 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH] tmpfs: implement xattr support for the entire security
 namespace
Message-ID: <20110330015830.GA2656@hallyn.com>
References: <20110329185648.3549.51631.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110329185648.3549.51631.stgit@paris.rdu.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Paris <eparis@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, hughd@google.com, akpm@linux-foundation.org, davej@redhat.com, hch@infradead.org, jmorris@namei.org

Quoting Eric Paris (eparis@redhat.com):
> This patch implements security namespace xattrs for tmpfs filesystems.  The
> feodra project, while trying to replace suid apps with file capabilities,
> realized that tmpfs, which is used on the build systems, does not support file
> capabilities and thus cannot be used to build packages which use file
> capabilities.
> 
> The xattr interface is a bit, odd.  If a filesystem does not implement any
> {get,set,list}xattr functions the VFS will call into some random LSM hooks and
> the running LSM can then implement some method for handling xattrs.  SELinux
> for example provides a method to support security.selinux but no other
> security.* xattrs.
> 
> As it stands today when one enables CONFIG_TMPFS_POSIX_ACL tmpfs will have
> xattr handler routines specifically to handle acls.  Because of this tmpfs
> would loose the VFS/LSM helpers to support the running LSM.  To make up for
> that tmpfs had stub functions that did nothing but call into the LSM hooks
> which implement the helpers.
> 
> This new patch does not use the LSM fallback functions and instead just
> implements a native get/set/list xattr feature for the full security.*
> namespace like a normal filesystem.  This means that tmpfs can now support
> both security.selinux and security.capability, which was not previously
> possible.
> 
> The basic implementation is that I attach a:
> 
> struct shmem_xattr {
> 	struct list_head list; /* anchored by shmem_inode_info->xattr_list */
> 	char *name;
> 	size_t size;
> 	char value[0];
> };
> 
> Into the struct shmem_inode_info for each xattr that is set.  This
> implementation could easily be turned into 2d array with one dimention being
> the xattr prefix and one the xattr suffix.  That could result in an easy
> implementation for user.* if we ever want it.  As it stands today though I
> assume the prefix is always security.
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>

Thanks, Eric.  I don't see any problems with this.  I do wonder whether
it could save quite a bit of space to use hlist_head instead of list_head
if selinux is not enabled?

Acked-by: Serge Hallyn <serge.hallyn@ubuntu.com>

> ---
> 
>  fs/Kconfig               |    4 ++
>  include/linux/shmem_fs.h |    1 
>  mm/shmem.c               |  116 ++++++++++++++++++++++++++++++++++++++++++----
>  3 files changed, 111 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index f3aa9b0..5e2bfc4 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -132,6 +132,10 @@ config TMPFS_POSIX_ACL
>  	  To learn more about Access Control Lists, visit the POSIX ACLs for
>  	  Linux website <http://acl.bestbits.at/>.
>  
> +	  Enablings this option will also enable support for the entire
> +	  security.* xattr namespace.  This is to make up for support lost
> +	  from the VFS/LSM when a filesystem has any xattr handler.
> +
>  	  If you don't know what Access Control Lists are, say N.
>  
>  config HUGETLBFS
> diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
> index 399be5a..20912d1 100644
> --- a/include/linux/shmem_fs.h
> +++ b/include/linux/shmem_fs.h
> @@ -19,6 +19,7 @@ struct shmem_inode_info {
>  	struct page		*i_indirect;	/* top indirect blocks page */
>  	swp_entry_t		i_direct[SHMEM_NR_DIRECT]; /* first blocks */
>  	struct list_head	swaplist;	/* chain of maybes on swap */
> +	struct list_head	xattr_list;	/* list of shmem_xattr */
>  	struct inode		vfs_inode;
>  };
>  
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 58da7c1..c77634f 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -99,6 +99,13 @@ static struct vfsmount *shm_mnt;
>  /* Pretend that each entry is of this size in directory's i_size */
>  #define BOGO_DIRENT_SIZE 20
>  
> +struct shmem_xattr {
> +	struct list_head list;	/* anchored by shmem_inode_info->xattr_list */
> +	char *name;		/* xattr suffix */
> +	size_t size;
> +	char value[0];
> +};
> +
>  /* Flag allocation requirements to shmem_getpage and shmem_swp_alloc */
>  enum sgp_type {
>  	SGP_READ,	/* don't exceed i_size, don't allocate page */
> @@ -821,6 +828,7 @@ static int shmem_notify_change(struct dentry *dentry, struct iattr *attr)
>  static void shmem_evict_inode(struct inode *inode)
>  {
>  	struct shmem_inode_info *info = SHMEM_I(inode);
> +	struct shmem_xattr *xattr, *nxattr;
>  
>  	if (inode->i_mapping->a_ops == &shmem_aops) {
>  		truncate_inode_pages(inode->i_mapping, 0);
> @@ -833,6 +841,11 @@ static void shmem_evict_inode(struct inode *inode)
>  			mutex_unlock(&shmem_swaplist_mutex);
>  		}
>  	}
> +
> +	list_for_each_entry_safe(xattr, nxattr, &info->xattr_list, list) {
> +		kfree(xattr->name);
> +		kfree(xattr);
> +	}
>  	BUG_ON(inode->i_blocks);
>  	shmem_free_inode(inode->i_sb);
>  	end_writeback(inode);
> @@ -1595,6 +1608,7 @@ static struct inode *shmem_get_inode(struct super_block *sb, const struct inode
>  		spin_lock_init(&info->lock);
>  		info->flags = flags & VM_NORESERVE;
>  		INIT_LIST_HEAD(&info->swaplist);
> +		INIT_LIST_HEAD(&info->xattr_list);
>  		cache_no_acl(inode);
>  
>  		switch (mode & S_IFMT) {
> @@ -2059,8 +2073,8 @@ static const struct inode_operations shmem_symlink_inode_operations = {
>  
>  #ifdef CONFIG_TMPFS_POSIX_ACL
>  /*
> - * Superblocks without xattr inode operations will get security.* xattr
> - * support from the VFS "for free". As soon as we have any other xattrs
> + * Superblocks without xattr inode operations may get some security.* xattr
> + * support from the LSM "for free". As soon as we have any other xattrs
>   * like ACLs, we also need to implement the security.* handlers at
>   * filesystem level, though.
>   */
> @@ -2069,24 +2083,106 @@ static size_t shmem_xattr_security_list(struct dentry *dentry, char *list,
>  					size_t list_len, const char *name,
>  					size_t name_len, int handler_flags)
>  {
> -	return security_inode_listsecurity(dentry->d_inode, list, list_len);
> +	struct shmem_xattr *xattr;
> +	struct shmem_inode_info *info;
> +	size_t used = 0;
> +
> +	info = SHMEM_I(dentry->d_inode);
> +
> +	spin_lock(&dentry->d_inode->i_lock);
> +	list_for_each_entry(xattr, &info->xattr_list, list) {
> +		used += XATTR_SECURITY_PREFIX_LEN;
> +		used += strlen(xattr->name) + 1;
> +
> +		if (list) {
> +			if (list_len < used) {
> +				used = -ERANGE;
> +				break;
> +			}
> +			strncpy(list, XATTR_SECURITY_PREFIX, XATTR_SECURITY_PREFIX_LEN);
> +			list += XATTR_SECURITY_PREFIX_LEN;
> +			strncpy(list, xattr->name, strlen(xattr->name) + 1);
> +			list += strlen(xattr->name) + 1;
> +		}
> +	}
> +	spin_unlock(&dentry->d_inode->i_lock);
> +
> +	return used;
>  }
>  
>  static int shmem_xattr_security_get(struct dentry *dentry, const char *name,
>  		void *buffer, size_t size, int handler_flags)
>  {
> -	if (strcmp(name, "") == 0)
> -		return -EINVAL;
> -	return xattr_getsecurity(dentry->d_inode, name, buffer, size);
> +	struct shmem_inode_info *info;
> +	struct shmem_xattr *xattr;
> +	int ret = -ENODATA;
> +
> +	info = SHMEM_I(dentry->d_inode);
> +
> +	spin_lock(&dentry->d_inode->i_lock);
> +	list_for_each_entry(xattr, &info->xattr_list, list) {
> +		if (strcmp(name, xattr->name))
> +			continue;
> +
> +		ret = xattr->size;
> +		if (buffer) {
> +			if (size < xattr->size)
> +				ret = -ERANGE;
> +			else
> +				memcpy(buffer, xattr->value, xattr->size);
> +		}
> +		break;
> +	}
> +	spin_unlock(&dentry->d_inode->i_lock);
> +	return ret;
>  }
>  
> +/*
> + * We only handle security.* but we could potentially store the prefix
> + * as well as the suffix in struct shmem_xattr and support *.*
> + */
>  static int shmem_xattr_security_set(struct dentry *dentry, const char *name,
>  		const void *value, size_t size, int flags, int handler_flags)
>  {
> -	if (strcmp(name, "") == 0)
> -		return -EINVAL;
> -	return security_inode_setsecurity(dentry->d_inode, name, value,
> -					  size, flags);
> +	struct inode *inode = dentry->d_inode;
> +	struct shmem_inode_info *info = SHMEM_I(inode);
> +	struct shmem_xattr *xattr;
> +	struct shmem_xattr *new_xattr;
> +	size_t len;
> +
> +	/* wrap around? */
> +	len = sizeof(*new_xattr) + size;
> +	if (len <= sizeof(*new_xattr))
> +		return -ENOMEM;
> +
> +	new_xattr = kmalloc(len, GFP_NOFS);
> +	if (!new_xattr)
> +		return -ENOMEM;
> +
> +	new_xattr->name = kstrdup(name, GFP_NOFS);
> +	if (!new_xattr->name) {
> +		kfree(new_xattr);
> +		return -ENOMEM;
> +	}
> +
> +	new_xattr->size = size;
> +	memcpy(new_xattr->value, value, size);
> +
> +	spin_lock(&inode->i_lock);
> +	list_for_each_entry(xattr, &info->xattr_list, list) {
> +		if (!strcmp(name, xattr->name)) {
> +			list_replace(&xattr->list, &new_xattr->list);
> +			goto out;
> +		}
> +	}
> +	list_add(&new_xattr->list, &info->xattr_list);
> +	xattr = NULL;
> +out:
> +	spin_unlock(&inode->i_lock);
> +	if (xattr)
> +		kfree(xattr->name);
> +	kfree(xattr);
> +	return 0;
>  }
>  
>  static const struct xattr_handler shmem_xattr_security_handler = {
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
