Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 380EA6B0038
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 17:29:46 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ex14so278086775pac.0
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 14:29:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e185si29415414pfe.238.2016.09.13.14.29.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 14:29:45 -0700 (PDT)
Date: Tue, 13 Sep 2016 14:29:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] fs: use mapping_set_error instead of opencoded
 set_bit
Message-Id: <20160913142944.fcb0067c66924a14be92b6dc@linux-foundation.org>
In-Reply-To: <20160913065259.GA31898@dhcp22.suse.cz>
References: <20160901091347.GC12147@dhcp22.suse.cz>
	<20160912111608.2588-1-mhocko@kernel.org>
	<20160912111608.2588-2-mhocko@kernel.org>
	<20160912151146.9999e6b1a9b18eac61d177d2@linux-foundation.org>
	<20160912151823.45d01e5acc44fa082c94dd2c@linux-foundation.org>
	<20160913065259.GA31898@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 13 Sep 2016 08:53:01 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Mon 12-09-16 15:18:23, Andrew Morton wrote:
> > On Mon, 12 Sep 2016 15:11:46 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > > > @@ -409,7 +408,7 @@ static int afs_write_back_from_locked_page(struct afs_writeback *wb,
> > > >  		case -ENOMEDIUM:
> > > >  		case -ENXIO:
> > > >  			afs_kill_pages(wb->vnode, true, first, last);
> > > > -			set_bit(AS_EIO, &wb->vnode->vfs_inode.i_mapping->flags);
> > > > +			mapping_set_error(wb->vnode->vfs_inode.i_mapping, -ENXIO);
> > > 
> > > This one is a functional change: mapping_set_error() will rewrite
> > > -ENXIO into -EIO.  Doesn't seem at all important though.
> > 
> > hm, OK, it's not a functional change - the code was already doing
> > s/ENXIO/EIO/.
> 
> Yes the rewrite is silent but I've decided to keep the current errno
> because I have no idea whether this can change in future. It doesn't
> sound probable but it also sounds safer to do an overwrite at a single
> place rather than all over the place /me thinks.

Well, this is the only place in the kernel where we attempt to set
anything other than EIO.  I do think it's better to be honest about
what's happening, right here at the callsite.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
