Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1DB4C6B0032
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 14:17:13 -0400 (EDT)
Received: by qcbii10 with SMTP id ii10so63150774qcb.2
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 11:17:12 -0700 (PDT)
Received: from mail-qg0-x22a.google.com (mail-qg0-x22a.google.com. [2607:f8b0:400d:c04::22a])
        by mx.google.com with ESMTPS id 199si20279613qhe.36.2015.04.20.11.17.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Apr 2015 11:17:12 -0700 (PDT)
Received: by qgej70 with SMTP id j70so56819241qge.2
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 11:17:12 -0700 (PDT)
Date: Mon, 20 Apr 2015 14:17:07 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 15/49] writeback: move backing_dev_info->wb_lock and
 ->worklist into bdi_writeback
Message-ID: <20150420181707.GD4206@htj.duckdns.org>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
 <1428350318-8215-16-git-send-email-tj@kernel.org>
 <20150420153224.GD17020@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150420153224.GD17020@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com

Hello, Jan.

On Mon, Apr 20, 2015 at 05:32:24PM +0200, Jan Kara wrote:
> > @@ -454,9 +451,9 @@ EXPORT_SYMBOL(bdi_init);
> >  
> >  void bdi_destroy(struct backing_dev_info *bdi)
> >  {
> > -	bdi_wb_shutdown(bdi);
> > -
> > -	WARN_ON(!list_empty(&bdi->work_list));
> > +	/* make sure nobody finds us on the bdi_list anymore */
> > +	bdi_remove_from_list(bdi);
> > +	wb_shutdown(&bdi->wb);
> >  
> >  	if (bdi->dev) {
> >  		bdi_debug_unregister(bdi);
>   But if someone ends up calling bdi_destroy() on unregistered bdi,
> bdi_remove_from_list() will be corrupting memory, won't it? And if I

bdi_init() does INIT_LIST_HEAD() on it, so it should be fine, no?

> remember right there were some corner cases where this really happened.
> Previously we were careful and checked WB_registered. I guess we could
> check for !list_empty(&bdi->bdi_list) and also reinit bdi_list in
> bdi_remove_from_list() after synchronize_rcu_expedited().

But we can't call bdi_destroy() more than once no matter what.  We'd
be doing double frees.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
