Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 88C486B027B
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 12:49:50 -0400 (EDT)
Received: by ioii196 with SMTP id i196so54600820ioi.3
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 09:49:50 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id 16si1362176ion.57.2015.09.30.09.49.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 09:49:49 -0700 (PDT)
Date: Wed, 30 Sep 2015 19:49:40 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 2/5] fs: charge pipe buffers to memcg
Message-ID: <20150930164940.GB19988@esperanza>
References: <cover.1443262808.git.vdavydov@parallels.com>
 <94f055dc719129a26149b0f8b22af7c61a3fb4e6.1443262808.git.vdavydov@parallels.com>
 <20150929155711.3b139dab622848a14af64ca4@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150929155711.3b139dab622848a14af64ca4@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 29, 2015 at 03:57:11PM -0700, Andrew Morton wrote:
> On Sat, 26 Sep 2015 13:45:54 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:
> 
> > Pipe buffers can be generated unrestrictedly by an unprivileged
> > userspace process, so they shouldn't go unaccounted.
> > 
> > ...
> >
> > --- a/fs/pipe.c
> > +++ b/fs/pipe.c
> > @@ -400,7 +400,7 @@ pipe_write(struct kiocb *iocb, struct iov_iter *from)
> >  			int copied;
> >  
> >  			if (!page) {
> > -				page = alloc_page(GFP_HIGHUSER);
> > +				page = alloc_kmem_pages(GFP_HIGHUSER, 0);
> >  				if (unlikely(!page)) {
> >  					ret = ret ? : -ENOMEM;
> >  					break;
> 
> This seems broken.  We have a page buffer page which has a weird
> ->mapcount.  Now it gets stolen (generic_pipe_buf_steal()) and spliced
> into pagecache.  Then the page gets mmapped and MM starts playing with
> its ->_mapcount?

Right you are! I completely forgot of vmsplice case. Surely, we need to
uncharge the page in the ->steal method and clear its PageKmem. Will fix
that.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
