Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B399B6B027B
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 04:36:56 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id bk3so46526629wjc.4
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 01:36:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id us1si17774148wjc.102.2016.12.19.01.36.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Dec 2016 01:36:55 -0800 (PST)
Date: Fri, 16 Dec 2016 09:43:41 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 9/9] Revert "ext4: fix wrong gfp type under transaction"
Message-ID: <20161216084341.GG26608@quack2.suse.cz>
References: <20161215140715.12732-1-mhocko@kernel.org>
 <20161215140715.12732-10-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161215140715.12732-10-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu 15-12-16 15:07:15, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> This reverts commit 216553c4b7f3e3e2beb4981cddca9b2027523928. Now that
> the transaction context uses memalloc_nofs_save and all allocations
> within the this context inherit GFP_NOFS automatically, there is no
> reason to mark specific allocations explicitly.
> 
> This patch should not introduce any functional change. The main point
> of this change is to reduce explicit GFP_NOFS usage inside ext4 code
> to make the review of the remaining usage easier.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/ext4/acl.c     | 6 +++---
>  fs/ext4/extents.c | 2 +-
>  fs/ext4/resize.c  | 4 ++--
>  fs/ext4/xattr.c   | 4 ++--
>  4 files changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/ext4/acl.c b/fs/ext4/acl.c
> index fd389935ecd1..9e98092c2a4b 100644
> --- a/fs/ext4/acl.c
> +++ b/fs/ext4/acl.c
> @@ -32,7 +32,7 @@ ext4_acl_from_disk(const void *value, size_t size)
>  		return ERR_PTR(-EINVAL);
>  	if (count == 0)
>  		return NULL;
> -	acl = posix_acl_alloc(count, GFP_NOFS);
> +	acl = posix_acl_alloc(count, GFP_KERNEL);
>  	if (!acl)
>  		return ERR_PTR(-ENOMEM);
>  	for (n = 0; n < count; n++) {
> @@ -94,7 +94,7 @@ ext4_acl_to_disk(const struct posix_acl *acl, size_t *size)
>  
>  	*size = ext4_acl_size(acl->a_count);
>  	ext_acl = kmalloc(sizeof(ext4_acl_header) + acl->a_count *
> -			sizeof(ext4_acl_entry), GFP_NOFS);
> +			sizeof(ext4_acl_entry), GFP_KERNEL);
>  	if (!ext_acl)
>  		return ERR_PTR(-ENOMEM);
>  	ext_acl->a_version = cpu_to_le32(EXT4_ACL_VERSION);
> @@ -159,7 +159,7 @@ ext4_get_acl(struct inode *inode, int type)
>  	}
>  	retval = ext4_xattr_get(inode, name_index, "", NULL, 0);
>  	if (retval > 0) {
> -		value = kmalloc(retval, GFP_NOFS);
> +		value = kmalloc(retval, GFP_KERNEL);
>  		if (!value)
>  			return ERR_PTR(-ENOMEM);
>  		retval = ext4_xattr_get(inode, name_index, "", value, retval);
> diff --git a/fs/ext4/extents.c b/fs/ext4/extents.c
> index ef815eb72389..c901d89f0038 100644
> --- a/fs/ext4/extents.c
> +++ b/fs/ext4/extents.c
> @@ -2933,7 +2933,7 @@ int ext4_ext_remove_space(struct inode *inode, ext4_lblk_t start,
>  				le16_to_cpu(path[k].p_hdr->eh_entries)+1;
>  	} else {
>  		path = kzalloc(sizeof(struct ext4_ext_path) * (depth + 1),
> -			       GFP_NOFS);
> +			       GFP_KERNEL);
>  		if (path == NULL) {
>  			ext4_journal_stop(handle);
>  			return -ENOMEM;
> diff --git a/fs/ext4/resize.c b/fs/ext4/resize.c
> index cf681004b196..e121f4e048b8 100644
> --- a/fs/ext4/resize.c
> +++ b/fs/ext4/resize.c
> @@ -816,7 +816,7 @@ static int add_new_gdb(handle_t *handle, struct inode *inode,
>  
>  	n_group_desc = ext4_kvmalloc((gdb_num + 1) *
>  				     sizeof(struct buffer_head *),
> -				     GFP_NOFS);
> +				     GFP_KERNEL);
>  	if (!n_group_desc) {
>  		err = -ENOMEM;
>  		ext4_warning(sb, "not enough memory for %lu groups",
> @@ -943,7 +943,7 @@ static int reserve_backup_gdb(handle_t *handle, struct inode *inode,
>  	int res, i;
>  	int err;
>  
> -	primary = kmalloc(reserved_gdb * sizeof(*primary), GFP_NOFS);
> +	primary = kmalloc(reserved_gdb * sizeof(*primary), GFP_KERNEL);
>  	if (!primary)
>  		return -ENOMEM;
>  
> diff --git a/fs/ext4/xattr.c b/fs/ext4/xattr.c
> index 5a94fa52b74f..172317462238 100644
> --- a/fs/ext4/xattr.c
> +++ b/fs/ext4/xattr.c
> @@ -875,7 +875,7 @@ ext4_xattr_block_set(handle_t *handle, struct inode *inode,
>  
>  			unlock_buffer(bs->bh);
>  			ea_bdebug(bs->bh, "cloning");
> -			s->base = kmalloc(bs->bh->b_size, GFP_NOFS);
> +			s->base = kmalloc(bs->bh->b_size, GFP_KERNEL);
>  			error = -ENOMEM;
>  			if (s->base == NULL)
>  				goto cleanup;
> @@ -887,7 +887,7 @@ ext4_xattr_block_set(handle_t *handle, struct inode *inode,
>  		}
>  	} else {
>  		/* Allocate a buffer where we construct the new block. */
> -		s->base = kzalloc(sb->s_blocksize, GFP_NOFS);
> +		s->base = kzalloc(sb->s_blocksize, GFP_KERNEL);
>  		/* assert(header == s->base) */
>  		error = -ENOMEM;
>  		if (s->base == NULL)
> -- 
> 2.10.2
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
