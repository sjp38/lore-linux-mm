Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 459756B0069
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 18:18:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g202so390043672pfb.3
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 15:18:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b191si7456368pfb.240.2016.09.12.15.18.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 15:18:24 -0700 (PDT)
Date: Mon, 12 Sep 2016 15:18:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] fs: use mapping_set_error instead of opencoded
 set_bit
Message-Id: <20160912151823.45d01e5acc44fa082c94dd2c@linux-foundation.org>
In-Reply-To: <20160912151146.9999e6b1a9b18eac61d177d2@linux-foundation.org>
References: <20160901091347.GC12147@dhcp22.suse.cz>
	<20160912111608.2588-1-mhocko@kernel.org>
	<20160912111608.2588-2-mhocko@kernel.org>
	<20160912151146.9999e6b1a9b18eac61d177d2@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, 12 Sep 2016 15:11:46 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> > @@ -409,7 +408,7 @@ static int afs_write_back_from_locked_page(struct afs_writeback *wb,
> >  		case -ENOMEDIUM:
> >  		case -ENXIO:
> >  			afs_kill_pages(wb->vnode, true, first, last);
> > -			set_bit(AS_EIO, &wb->vnode->vfs_inode.i_mapping->flags);
> > +			mapping_set_error(wb->vnode->vfs_inode.i_mapping, -ENXIO);
> 
> This one is a functional change: mapping_set_error() will rewrite
> -ENXIO into -EIO.  Doesn't seem at all important though.

hm, OK, it's not a functional change - the code was already doing
s/ENXIO/EIO/.

Let's make it look more truthful?

--- a/fs/afs/write.c~fs-use-mapping_set_error-instead-of-opencoded-set_bit-fix
+++ a/fs/afs/write.c
@@ -408,7 +408,7 @@ no_more:
 		case -ENOMEDIUM:
 		case -ENXIO:
 			afs_kill_pages(wb->vnode, true, first, last);
-			mapping_set_error(wb->vnode->vfs_inode.i_mapping, -ENXIO);
+			mapping_set_error(wb->vnode->vfs_inode.i_mapping, -EIO);
 			break;
 		case -EACCES:
 		case -EPERM:
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
