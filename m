Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id B810E6B0032
	for <linux-mm@kvack.org>; Sun, 11 Jan 2015 13:16:55 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id i13so12991851qae.13
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 10:16:55 -0800 (PST)
Received: from mail-qa0-x22a.google.com (mail-qa0-x22a.google.com. [2607:f8b0:400d:c00::22a])
        by mx.google.com with ESMTPS id c5si19694997qas.120.2015.01.11.10.16.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 11 Jan 2015 10:16:55 -0800 (PST)
Received: by mail-qa0-f42.google.com with SMTP id n8so12976147qaq.1
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 10:16:54 -0800 (PST)
Date: Sun, 11 Jan 2015 13:16:51 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 07/12] fs: export inode_to_bdi and use it in favor of
 mapping->backing_dev_info
Message-ID: <20150111181651.GN25319@htj.dyndns.org>
References: <1420739133-27514-1-git-send-email-hch@lst.de>
 <1420739133-27514-8-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420739133-27514-8-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org

Hello,

On Thu, Jan 08, 2015 at 06:45:28PM +0100, Christoph Hellwig wrote:
> Now that we got ri of the bdi abuse on character devices we can always use
                  ^^^
		  rid

> sb->s_bdi to get at the backing_dev_info for a file, except for the block
> device special case.  Export inode_to_bdi and replace uses of
> mapping->backing_dev_info with it to prepare for the removal of
> mapping->backing_dev_info.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Ah, this is so much better.  Thanks a lot for doing this.  Just one
nit below.

> +struct backing_dev_info *inode_to_bdi(struct inode *inode)
>  {
>  	struct super_block *sb = inode->i_sb;
>  #ifdef CONFIG_BLOCK
> @@ -75,6 +75,7 @@ static inline struct backing_dev_info *inode_to_bdi(struct inode *inode)
>  #endif
>  	return sb->s_bdi;
>  }
> +EXPORT_SYMBOL_GPL(inode_to_bdi);

This is rather trivial.  Maybe we wanna make this an inline function?

 Reviewed-by: Tejun Heo <tj@kernel.org>

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
