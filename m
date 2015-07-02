Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 19B686B0255
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 21:26:55 -0400 (EDT)
Received: by qgeg89 with SMTP id g89so26993671qge.3
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 18:26:54 -0700 (PDT)
Received: from mail-qk0-x22e.google.com (mail-qk0-x22e.google.com. [2607:f8b0:400d:c09::22e])
        by mx.google.com with ESMTPS id k8si4583190qkh.27.2015.07.01.18.26.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 18:26:54 -0700 (PDT)
Received: by qkei195 with SMTP id i195so42509389qke.3
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 18:26:54 -0700 (PDT)
Date: Wed, 1 Jul 2015 21:26:51 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 26/51] writeback: let balance_dirty_pages() work on the
 matching cgroup bdi_writeback
Message-ID: <20150702012651.GD26440@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-27-git-send-email-tj@kernel.org>
 <20150630143100.GL7252@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150630143100.GL7252@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

Hello, Jan.

On Tue, Jun 30, 2015 at 04:31:00PM +0200, Jan Kara wrote:
...
> > +	if (inode_cgwb_enabled(inode))
> > +		wb = wb_get_create_current(bdi, GFP_KERNEL);
> > +	if (!wb)
> > +		wb = &bdi->wb;
> > +
> 
> So this effectively adds a radix tree lookup (of wb belonging to memcg) for
> every set_page_dirty() call. That seems relatively costly to me. And all

Hmmm... idk, radix tree lookups should be cheap especially when
shallow and set_page_dirty().  It's a glorified array indexing.  If
not, we should really be improving radix tree implementation.  That
said,

> that just to check wb->dirty_exceeded. Cannot we just use inode_to_wb()
> instead? I understand results may be different if multiple memcgs share an
> inode and that's the reason why you use wb_get_create_current(), right?
> But for dirty_exceeded check it may be good enough?

Yeah, that probably should work.  I'll think more about it.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
