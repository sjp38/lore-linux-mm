Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7526B0069
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 18:11:48 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ex14so215845049pac.0
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 15:11:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m2si23581685pam.255.2016.09.12.15.11.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 15:11:47 -0700 (PDT)
Date: Mon, 12 Sep 2016 15:11:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] fs: use mapping_set_error instead of opencoded
 set_bit
Message-Id: <20160912151146.9999e6b1a9b18eac61d177d2@linux-foundation.org>
In-Reply-To: <20160912111608.2588-2-mhocko@kernel.org>
References: <20160901091347.GC12147@dhcp22.suse.cz>
	<20160912111608.2588-1-mhocko@kernel.org>
	<20160912111608.2588-2-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, 12 Sep 2016 13:16:07 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> mapping_set_error helper sets the correct AS_ flag for the mapping so
> there is no reason to open code it. Use the helper directly.
> 
> ...
>
> --- a/drivers/staging/lustre/lustre/llite/vvp_page.c
> +++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
> @@ -247,10 +247,7 @@ static void vvp_vmpage_error(struct inode *inode, struct page *vmpage, int ioret
>  		obj->vob_discard_page_warned = 0;
>  	} else {
>  		SetPageError(vmpage);
> -		if (ioret == -ENOSPC)
> -			set_bit(AS_ENOSPC, &inode->i_mapping->flags);
> -		else
> -			set_bit(AS_EIO, &inode->i_mapping->flags);
> +		mapping_set_error(inode->i_mapping, ioret);
>  
>  		if ((ioret == -ESHUTDOWN || ioret == -EINTR) &&
>  		     obj->vob_discard_page_warned == 0) {
> diff --git a/fs/afs/write.c b/fs/afs/write.c
> index 14d506efd1aa..20ed04ab833c 100644
> --- a/fs/afs/write.c
> +++ b/fs/afs/write.c
> @@ -398,8 +398,7 @@ static int afs_write_back_from_locked_page(struct afs_writeback *wb,
>  		switch (ret) {
>  		case -EDQUOT:
>  		case -ENOSPC:
> -			set_bit(AS_ENOSPC,
> -				&wb->vnode->vfs_inode.i_mapping->flags);
> +			mapping_set_error(wb->vnode->vfs_inode.i_mapping, -ENOSPC);
>  			break;
>  		case -EROFS:
>  		case -EIO:
> @@ -409,7 +408,7 @@ static int afs_write_back_from_locked_page(struct afs_writeback *wb,
>  		case -ENOMEDIUM:
>  		case -ENXIO:
>  			afs_kill_pages(wb->vnode, true, first, last);
> -			set_bit(AS_EIO, &wb->vnode->vfs_inode.i_mapping->flags);
> +			mapping_set_error(wb->vnode->vfs_inode.i_mapping, -ENXIO);

This one is a functional change: mapping_set_error() will rewrite
-ENXIO into -EIO.  Doesn't seem at all important though.

> ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
