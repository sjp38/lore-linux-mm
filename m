Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id C5CEF6B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 13:52:45 -0400 (EDT)
Received: by qcbgy10 with SMTP id gy10so25078528qcb.3
        for <linux-mm@kvack.org>; Thu, 07 May 2015 10:52:45 -0700 (PDT)
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com. [209.85.220.182])
        by mx.google.com with ESMTPS id b4si2780243qkb.29.2015.05.07.10.52.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 10:52:44 -0700 (PDT)
Received: by qkgx75 with SMTP id x75so32697006qkg.1
        for <linux-mm@kvack.org>; Thu, 07 May 2015 10:52:44 -0700 (PDT)
Message-ID: <554BA665.5010000@hurleysoftware.com>
Date: Thu, 07 May 2015 13:52:37 -0400
From: Peter Hurley <peter@hurleysoftware.com>
MIME-Version: 1.0
Subject: Re: [PATCH] devpts: If initialization failed, don't crash when opening
 /dev/ptmx
References: <20150507003547.GA6862@jtriplet-mobl1>
In-Reply-To: <20150507003547.GA6862@jtriplet-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Iulia Manda <iulia.manda21@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Fabian Frederick <fabf@skynet.be>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On 05/06/2015 08:35 PM, Josh Triplett wrote:
> If devpts failed to initialize, it would store an ERR_PTR in the global
> devpts_mnt.  A subsequent open of /dev/ptmx would call devpts_new_index,
> which would dereference devpts_mnt and crash.
> 
> Avoid storing invalid values in devpts_mnt; leave it NULL instead.
> Make both devpts_new_index and devpts_pty_new fail gracefully with
> ENODEV in that case, which then becomes the return value to the
> userspace open call on /dev/ptmx.
> 
> Signed-off-by: Josh Triplett <josh@joshtriplett.org>
> ---
> 
> This fixes a crash found by Fengguang Wu's 0-day service ("BUG: unable to
> handle kernel paging request at ffffffee").  It doesn't yet fix the underlying
> initialization failure in init_devpts_fs, but it stops that failure from
> becoming a kernel crash.  I'm working on the initialization failure now.
> 
>  fs/devpts/inode.c | 30 +++++++++++++++++++++++-------
>  1 file changed, 23 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
> index cfe8466..03e9076 100644
> --- a/fs/devpts/inode.c
> +++ b/fs/devpts/inode.c
> @@ -142,6 +142,8 @@ static inline struct super_block *pts_sb_from_inode(struct inode *inode)
>  	if (inode->i_sb->s_magic == DEVPTS_SUPER_MAGIC)
>  		return inode->i_sb;
>  #endif
> +	if (!devpts_mnt)
> +		return NULL;
>  	return devpts_mnt->mnt_sb;
>  }
>  
> @@ -525,10 +527,14 @@ static struct file_system_type devpts_fs_type = {
>  int devpts_new_index(struct inode *ptmx_inode)
>  {
>  	struct super_block *sb = pts_sb_from_inode(ptmx_inode);
> -	struct pts_fs_info *fsi = DEVPTS_SB(sb);
> +	struct pts_fs_info *fsi;
>  	int index;
>  	int ida_ret;
>  
> +	if (!sb)
> +		return -ENODEV;
> +
> +	fsi = DEVPTS_SB(sb);
>  retry:
>  	if (!ida_pre_get(&fsi->allocated_ptys, GFP_KERNEL))
>  		return -ENOMEM;
> @@ -584,11 +590,18 @@ struct inode *devpts_pty_new(struct inode *ptmx_inode, dev_t device, int index,
>  	struct dentry *dentry;
>  	struct super_block *sb = pts_sb_from_inode(ptmx_inode);
>  	struct inode *inode;
> -	struct dentry *root = sb->s_root;
> -	struct pts_fs_info *fsi = DEVPTS_SB(sb);
> -	struct pts_mount_opts *opts = &fsi->mount_opts;
> +	struct dentry *root;
> +	struct pts_fs_info *fsi;
> +	struct pts_mount_opts *opts;
>  	char s[12];
>  
> +	if (!sb)
> +		return ERR_PTR(-ENODEV);
> +
> +	root = sb->s_root;
> +	fsi = DEVPTS_SB(sb);
> +	opts = &fsi->mount_opts;
> +
>  	inode = new_inode(sb);
>  	if (!inode)
>  		return ERR_PTR(-ENOMEM);
> @@ -676,12 +689,15 @@ static int __init init_devpts_fs(void)
>  	struct ctl_table_header *table;
>  
>  	if (!err) {
> +		static struct vfsmount *mnt;
                ^^^^^^
Not static storage. Other than that,

Reviewed-by: Peter Hurley <peter@hurleysoftware.com>

>  		table = register_sysctl_table(pty_root_table);
> -		devpts_mnt = kern_mount(&devpts_fs_type);
> -		if (IS_ERR(devpts_mnt)) {
> -			err = PTR_ERR(devpts_mnt);
> +		mnt = kern_mount(&devpts_fs_type);
> +		if (IS_ERR(mnt)) {
> +			err = PTR_ERR(mnt);
>  			unregister_filesystem(&devpts_fs_type);
>  			unregister_sysctl_table(table);
> +		} else {
> +			devpts_mnt = mnt;
>  		}
>  	}
>  	return err;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
