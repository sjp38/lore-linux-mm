Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id B8F996B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 17:09:00 -0400 (EDT)
Received: by pacti10 with SMTP id ti10so62700052pac.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 14:09:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ki6si489292pdb.252.2015.08.25.14.08.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 14:08:59 -0700 (PDT)
Date: Tue, 25 Aug 2015 14:08:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/backing-dev: Check return value of the
 debugfs_create_dir()
Message-Id: <20150825140858.8185db77fed42cf5df5faeb5@linux-foundation.org>
In-Reply-To: <1440489263-3547-1-git-send-email-kuleshovmail@gmail.com>
References: <1440489263-3547-1-git-send-email-kuleshovmail@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Kuleshov <kuleshovmail@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 25 Aug 2015 13:54:23 +0600 Alexander Kuleshov <kuleshovmail@gmail.com> wrote:

> The debugfs_create_dir() function may fail and return error. If the
> root directory not created, we can't create anything inside it. This
> patch adds check for this case.
> 
> ...
>
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -117,15 +117,21 @@ static const struct file_operations bdi_debug_stats_fops = {
>  
>  static void bdi_debug_register(struct backing_dev_info *bdi, const char *name)
>  {
> -	bdi->debug_dir = debugfs_create_dir(name, bdi_debug_root);
> -	bdi->debug_stats = debugfs_create_file("stats", 0444, bdi->debug_dir,
> -					       bdi, &bdi_debug_stats_fops);
> +	if (bdi_debug_root) {
> +		bdi->debug_dir = debugfs_create_dir(name, bdi_debug_root);
> +		if (bdi->debug_dir)
> +			bdi->debug_stats = debugfs_create_file("stats", 0444,
> +							bdi->debug_dir, bdi,
> +							&bdi_debug_stats_fops);
> +	}

If debugfs_create_dir() fails, debugfs_create_file() will go ahead and
attempt to create the debugfs file in the debugfs root directory:

: static struct dentry *start_creating(const char *name, struct dentry *parent)
: {
: ...
: 	/* If the parent is not specified, we create it in the root.
: 	 * We need the root dentry to do this, which is in the super
: 	 * block. A pointer to that is in the struct vfsmount that we
: 	 * have around.
: 	 */
: 	if (!parent)
: 		parent = debugfs_mount->mnt_root;

I'm not sure that this is very useful behaviour, and putting the files
in the wrong place is a very obscure way of informing the user that
debugfs_create_dir() failed :(


I don't think it's worth making little changes such as this - handling
debugfs failures needs a deeper rethink.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
