Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id E03D26B0253
	for <linux-mm@kvack.org>; Sun,  8 Nov 2015 18:37:12 -0500 (EST)
Received: by ykba4 with SMTP id a4so239436097ykb.3
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 15:37:12 -0800 (PST)
Received: from mail-yk0-x229.google.com (mail-yk0-x229.google.com. [2607:f8b0:4002:c07::229])
        by mx.google.com with ESMTPS id y206si3234699ywc.240.2015.11.08.15.37.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Nov 2015 15:37:11 -0800 (PST)
Received: by ykfs79 with SMTP id s79so10719438ykf.1
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 15:37:11 -0800 (PST)
Date: Sun, 8 Nov 2015 15:37:02 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] tmpfs: listxattr should include POSIX ACL xattrs
In-Reply-To: <1446559981-26025-1-git-send-email-agruenba@redhat.com>
Message-ID: <alpine.LSU.2.11.1511081504460.14116@eggly.anvils>
References: <1446559981-26025-1-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>, Aristeu Rozanski <arozansk@redhat.com>, Eric Paris <eparis@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Tue, 3 Nov 2015, Andreas Gruenbacher wrote:

> When a file on tmpfs has an ACL or a Default ACL, listxattr should include the
> corresponding xattr names.
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> ---
>  fs/kernfs/inode.c     |  2 +-
>  fs/xattr.c            | 53 +++++++++++++++++++++++++++++++++++----------------
>  include/linux/xattr.h |  2 +-
>  mm/shmem.c            |  2 +-
>  4 files changed, 40 insertions(+), 19 deletions(-)

Hmm, can you make a stronger argument for this patch than above?

My ignorance of ACLs and XATTRs is boundless, I'll have to defer to
you and others.  But when I read the listxattr(2) manpage saying
"Filesystems like ext2, ext3 and XFS which implement POSIX ACLs
using extended attributes, might return a list like ...",
I don't see that as mandating that any filesystem which happens
for its own internal convenience to implement ACLs via XATTRs,
has to list the ACLs with the XATTRs - I read it rather as an
apology that some of them (for their own simplicity) do so.

If this patch simplified the code, I'd be all for it;
but it's the reverse, and we seem to have survived for several
years without it: I don't see yet why it's needed.  I've no
fundamental objection, but I'd like to understand why it's
a step forwards rather than a step backwards.

Thanks,
Hugh

> 
> diff --git a/fs/kernfs/inode.c b/fs/kernfs/inode.c
> index 756dd56..3c415bf 100644
> --- a/fs/kernfs/inode.c
> +++ b/fs/kernfs/inode.c
> @@ -230,7 +230,7 @@ ssize_t kernfs_iop_listxattr(struct dentry *dentry, char *buf, size_t size)
>  	if (!attrs)
>  		return -ENOMEM;
>  
> -	return simple_xattr_list(&attrs->xattrs, buf, size);
> +	return simple_xattr_list(d_inode(dentry), &attrs->xattrs, buf, size);
>  }
>  
>  static inline void set_default_inode_attr(struct inode *inode, umode_t mode)
> diff --git a/fs/xattr.c b/fs/xattr.c
> index 072fee1..7035d7d 100644
> --- a/fs/xattr.c
> +++ b/fs/xattr.c
> @@ -926,38 +926,59 @@ static bool xattr_is_trusted(const char *name)
>  	return !strncmp(name, XATTR_TRUSTED_PREFIX, XATTR_TRUSTED_PREFIX_LEN);
>  }
>  
> +static int xattr_list_one(char **buffer, ssize_t *remaining_size,
> +			  const char *name)
> +{
> +	size_t len = strlen(name) + 1;
> +	if (*buffer) {
> +		if (*remaining_size < len)
> +			return -ERANGE;
> +		memcpy(*buffer, name, len);
> +		*buffer += len;
> +	}
> +	*remaining_size -= len;
> +	return 0;
> +}
> +
>  /*
>   * xattr LIST operation for in-memory/pseudo filesystems
>   */
> -ssize_t simple_xattr_list(struct simple_xattrs *xattrs, char *buffer,
> -			  size_t size)
> +ssize_t simple_xattr_list(struct inode *inode, struct simple_xattrs *xattrs,
> +			  char *buffer, size_t size)
>  {
>  	bool trusted = capable(CAP_SYS_ADMIN);
>  	struct simple_xattr *xattr;
> -	size_t used = 0;
> +	ssize_t remaining_size = size;
> +	int err;
> +
> +#ifdef CONFIG_FS_POSIX_ACL
> +	if (inode->i_acl) {
> +		err = xattr_list_one(&buffer, &remaining_size,
> +				     XATTR_NAME_POSIX_ACL_ACCESS);
> +		if (err)
> +			return err;
> +	}
> +	if (inode->i_default_acl) {
> +		err = xattr_list_one(&buffer, &remaining_size,
> +				     XATTR_NAME_POSIX_ACL_DEFAULT);
> +		if (err)
> +			return err;
> +	}
> +#endif
>  
>  	spin_lock(&xattrs->lock);
>  	list_for_each_entry(xattr, &xattrs->head, list) {
> -		size_t len;
> -
>  		/* skip "trusted." attributes for unprivileged callers */
>  		if (!trusted && xattr_is_trusted(xattr->name))
>  			continue;
>  
> -		len = strlen(xattr->name) + 1;
> -		used += len;
> -		if (buffer) {
> -			if (size < used) {
> -				used = -ERANGE;
> -				break;
> -			}
> -			memcpy(buffer, xattr->name, len);
> -			buffer += len;
> -		}
> +		err = xattr_list_one(&buffer, &remaining_size, xattr->name);
> +		if (err)
> +			return err;
>  	}
>  	spin_unlock(&xattrs->lock);
>  
> -	return used;
> +	return size - remaining_size;
>  }
>  
>  /*
> diff --git a/include/linux/xattr.h b/include/linux/xattr.h
> index 91b0a68..b57aed5 100644
> --- a/include/linux/xattr.h
> +++ b/include/linux/xattr.h
> @@ -92,7 +92,7 @@ int simple_xattr_get(struct simple_xattrs *xattrs, const char *name,
>  int simple_xattr_set(struct simple_xattrs *xattrs, const char *name,
>  		     const void *value, size_t size, int flags);
>  int simple_xattr_remove(struct simple_xattrs *xattrs, const char *name);
> -ssize_t simple_xattr_list(struct simple_xattrs *xattrs, char *buffer,
> +ssize_t simple_xattr_list(struct inode *inode, struct simple_xattrs *xattrs, char *buffer,
>  			  size_t size);
>  void simple_xattr_list_add(struct simple_xattrs *xattrs,
>  			   struct simple_xattr *new_xattr);
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 48ce829..3d95547 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2645,7 +2645,7 @@ static int shmem_removexattr(struct dentry *dentry, const char *name)
>  static ssize_t shmem_listxattr(struct dentry *dentry, char *buffer, size_t size)
>  {
>  	struct shmem_inode_info *info = SHMEM_I(d_inode(dentry));
> -	return simple_xattr_list(&info->xattrs, buffer, size);
> +	return simple_xattr_list(d_inode(dentry), &info->xattrs, buffer, size);
>  }
>  #endif /* CONFIG_TMPFS_XATTR */
>  
> -- 
> 2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
