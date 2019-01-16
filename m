Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E00938E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 12:06:17 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id m16so4265035pgd.0
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:06:17 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b131si6666436pga.394.2019.01.16.09.06.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 16 Jan 2019 09:06:16 -0800 (PST)
Date: Wed, 16 Jan 2019 09:06:12 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 6/6] drivers/IB,core: reduce scope of mmap_sem
Message-ID: <20190116170612.GK6310@bombadil.infradead.org>
References: <20190115181300.27547-1-dave@stgolabs.net>
 <20190115181300.27547-7-dave@stgolabs.net>
 <20190115205311.GD22031@mellanox.com>
 <20190115211207.GD6310@bombadil.infradead.org>
 <20190115211722.GA3758@mellanox.com>
 <20190116160026.iyg7pwmzy5o35h5l@linux-r8p5>
 <20190116170252.GG3758@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190116170252.GG3758@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Davidlohr Bueso <dbueso@suse.de>

On Wed, Jan 16, 2019 at 05:02:59PM +0000, Jason Gunthorpe wrote:
> On Wed, Jan 16, 2019 at 08:00:26AM -0800, Davidlohr Bueso wrote:
> > On Tue, 15 Jan 2019, Jason Gunthorpe wrote:
> > 
> > > On Tue, Jan 15, 2019 at 01:12:07PM -0800, Matthew Wilcox wrote:
> > > > On Tue, Jan 15, 2019 at 08:53:16PM +0000, Jason Gunthorpe wrote:
> > > > > > -	new_pinned = atomic_long_read(&mm->pinned_vm) + npages;
> > > > > > +	new_pinned = atomic_long_add_return(npages, &mm->pinned_vm);
> > > > > >  	if (new_pinned > lock_limit && !capable(CAP_IPC_LOCK)) {
> > > > >
> > > > > I thought a patch had been made for this to use check_overflow...
> > > > 
> > > > That got removed again by patch 1 ...
> > > 
> > > Well, that sure needs a lot more explanation. :(
> > 
> > What if we just make the counter atomic64?
> 
> That could work.

atomic_long, perhaps?  No need to use 64-bits on 32-bit architectures.
