Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 31DA76B0390
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 23:54:49 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id a72so98448734pge.10
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 20:54:49 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id i67si1948843pfk.218.2017.03.27.20.54.47
        for <linux-mm@kvack.org>;
        Mon, 27 Mar 2017 20:54:48 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170327170534.GA16903@shells.gnugeneration.com>
In-Reply-To: <20170327170534.GA16903@shells.gnugeneration.com>
Subject: Re: [PATCH] shmem: fix __shmem_file_setup error path leaks
Date: Tue, 28 Mar 2017 11:54:33 +0800
Message-ID: <018001d2a777$031dff10$0959fd30$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Vito Caputo' <vcaputo@pengaru.com>, hughd@google.com
Cc: 'linux-kernel' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org


On March 28, 2017 1:06 AM Vito Caputo wrote:
> 
> The existing path and memory cleanups appear to be in reverse order, and
> there's no iput() potentially leaking the inode in the last two error gotos.
> 
> Also make put_memory shmem_unacct_size() conditional on !inode since if we
> entered cleanup at put_inode, shmem_evict_inode() occurs via
> iput()->iput_final(), which performs the shmem_unacct_size() for us.
> 
> Signed-off-by: Vito Caputo <vcaputo@pengaru.com>
> ---
> 
> This caught my eye while looking through the memfd_create() implementation.
> Included patch was compile tested only...
> 
>  mm/shmem.c | 15 +++++++++------
>  1 file changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index e67d6ba..a1a84eaf 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -4134,7 +4134,7 @@ static struct file *__shmem_file_setup(const char *name, loff_t size,
>  				       unsigned long flags, unsigned int i_flags)
>  {
>  	struct file *res;
> -	struct inode *inode;
> +	struct inode *inode = NULL;
>  	struct path path;
>  	struct super_block *sb;
>  	struct qstr this;
> @@ -4162,7 +4162,7 @@ static struct file *__shmem_file_setup(const char *name, loff_t size,
>  	res = ERR_PTR(-ENOSPC);
>  	inode = shmem_get_inode(sb, NULL, S_IFREG | S_IRWXUGO, 0, flags);
>  	if (!inode)
> -		goto put_memory;
> +		goto put_path;
> 
>  	inode->i_flags |= i_flags;
>  	d_instantiate(path.dentry, inode);

After this routine, the inode is in use of the dcache, as its comment says.

> @@ -4170,19 +4170,22 @@ static struct file *__shmem_file_setup(const char *name, loff_t size,
>  	clear_nlink(inode);	/* It is unlinked */
>  	res = ERR_PTR(ramfs_nommu_expand_for_mapping(inode, size));
>  	if (IS_ERR(res))
> -		goto put_path;
> +		goto put_inode;
> 
>  	res = alloc_file(&path, FMODE_WRITE | FMODE_READ,
>  		  &shmem_file_operations);
>  	if (IS_ERR(res))
> -		goto put_path;
> +		goto put_inode;
> 
>  	return res;
> 
> -put_memory:
> -	shmem_unacct_size(flags, size);
> +put_inode:
> +	iput(inode);
>  put_path:
>  	path_put(&path);
> +put_memory:
> +	if (!inode)
> +		shmem_unacct_size(flags, size);
>  	return res;
>  }
> 
> --
> 2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
