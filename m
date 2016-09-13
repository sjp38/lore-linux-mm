Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id A9C016B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 02:53:04 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id n4so104200083lfb.3
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 23:53:04 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id a4si19353965wme.75.2016.09.12.23.53.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 23:53:03 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id b184so874045wma.3
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 23:53:03 -0700 (PDT)
Date: Tue, 13 Sep 2016 08:53:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] fs: use mapping_set_error instead of opencoded
 set_bit
Message-ID: <20160913065259.GA31898@dhcp22.suse.cz>
References: <20160901091347.GC12147@dhcp22.suse.cz>
 <20160912111608.2588-1-mhocko@kernel.org>
 <20160912111608.2588-2-mhocko@kernel.org>
 <20160912151146.9999e6b1a9b18eac61d177d2@linux-foundation.org>
 <20160912151823.45d01e5acc44fa082c94dd2c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160912151823.45d01e5acc44fa082c94dd2c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 12-09-16 15:18:23, Andrew Morton wrote:
> On Mon, 12 Sep 2016 15:11:46 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > > @@ -409,7 +408,7 @@ static int afs_write_back_from_locked_page(struct afs_writeback *wb,
> > >  		case -ENOMEDIUM:
> > >  		case -ENXIO:
> > >  			afs_kill_pages(wb->vnode, true, first, last);
> > > -			set_bit(AS_EIO, &wb->vnode->vfs_inode.i_mapping->flags);
> > > +			mapping_set_error(wb->vnode->vfs_inode.i_mapping, -ENXIO);
> > 
> > This one is a functional change: mapping_set_error() will rewrite
> > -ENXIO into -EIO.  Doesn't seem at all important though.
> 
> hm, OK, it's not a functional change - the code was already doing
> s/ENXIO/EIO/.

Yes the rewrite is silent but I've decided to keep the current errno
because I have no idea whether this can change in future. It doesn't
sound probable but it also sounds safer to do an overwrite at a single
place rather than all over the place /me thinks.

> Let's make it look more truthful?
> 
> --- a/fs/afs/write.c~fs-use-mapping_set_error-instead-of-opencoded-set_bit-fix
> +++ a/fs/afs/write.c
> @@ -408,7 +408,7 @@ no_more:
>  		case -ENOMEDIUM:
>  		case -ENXIO:
>  			afs_kill_pages(wb->vnode, true, first, last);
> -			mapping_set_error(wb->vnode->vfs_inode.i_mapping, -ENXIO);
> +			mapping_set_error(wb->vnode->vfs_inode.i_mapping, -EIO);
>  			break;
>  		case -EACCES:
>  		case -EPERM:
> _
> 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
