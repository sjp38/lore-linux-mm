Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 507976B0038
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 12:58:10 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id gt1so79825065wjc.0
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 09:58:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r20si25575329wrc.97.2017.02.01.09.58.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Feb 2017 09:58:08 -0800 (PST)
Date: Wed, 1 Feb 2017 18:58:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 7/9] md: use kvmalloc rather than opencoded variant
Message-ID: <20170201175802.GA9839@dhcp22.suse.cz>
References: <20170130094940.13546-1-mhocko@kernel.org>
 <20170130094940.13546-8-mhocko@kernel.org>
 <alpine.LRH.2.02.1702011213070.20806@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1702011213070.20806@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mike Snitzer <snitzer@redhat.com>

On Wed 01-02-17 12:29:56, Mikulas Patocka wrote:
> 
> 
> On Mon, 30 Jan 2017, Michal Hocko wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > copy_params uses kmalloc with vmalloc fallback. We already have a helper
> > for that - kvmalloc. This caller requires GFP_NOIO semantic so it hasn't
> > been converted with many others by previous patches. All we need to
> > achieve this semantic is to use the scope memalloc_noio_{save,restore}
> > around kvmalloc.
> > 
> > Cc: Mikulas Patocka <mpatocka@redhat.com>
> > Cc: Mike Snitzer <snitzer@redhat.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  drivers/md/dm-ioctl.c | 13 ++++---------
> >  1 file changed, 4 insertions(+), 9 deletions(-)
> > 
> > diff --git a/drivers/md/dm-ioctl.c b/drivers/md/dm-ioctl.c
> > index a5a9b17f0f7f..dbf5b981f7d7 100644
> > --- a/drivers/md/dm-ioctl.c
> > +++ b/drivers/md/dm-ioctl.c
> > @@ -1698,6 +1698,7 @@ static int copy_params(struct dm_ioctl __user *user, struct dm_ioctl *param_kern
> >  	struct dm_ioctl *dmi;
> >  	int secure_data;
> >  	const size_t minimum_data_size = offsetof(struct dm_ioctl, data);
> > +	unsigned noio_flag;
> >  
> >  	if (copy_from_user(param_kernel, user, minimum_data_size))
> >  		return -EFAULT;
> > @@ -1720,15 +1721,9 @@ static int copy_params(struct dm_ioctl __user *user, struct dm_ioctl *param_kern
> >  	 * Use kmalloc() rather than vmalloc() when we can.
> >  	 */
> >  	dmi = NULL;
> > -	if (param_kernel->data_size <= KMALLOC_MAX_SIZE)
> > -		dmi = kmalloc(param_kernel->data_size, GFP_NOIO | __GFP_NORETRY | __GFP_NOMEMALLOC | __GFP_NOWARN);
> > -
> > -	if (!dmi) {
> > -		unsigned noio_flag;
> > -		noio_flag = memalloc_noio_save();
> > -		dmi = __vmalloc(param_kernel->data_size, GFP_NOIO | __GFP_HIGH | __GFP_HIGHMEM, PAGE_KERNEL);
> > -		memalloc_noio_restore(noio_flag);
> > -	}
> > +	noio_flag = memalloc_noio_save();
> > +	dmi = kvmalloc(param_kernel->data_size, GFP_KERNEL);
> > +	memalloc_noio_restore(noio_flag);
> >  
> >  	if (!dmi) {
> >  		if (secure_data && clear_user(user, param_kernel->data_size))
> > -- 
> > 2.11.0
> 
> I would push these memalloc_noio_save/memalloc_noio_restore calls to 
> kvmalloc, so that the othe callers can use them too.
> 
> Something like
> 	if ((flags & (__GFP_IO | __GFP_FS)) != (__GFP_IO | __GFP_FS))
> 		noio_flag = memalloc_noio_save();
> 	ptr = __vmalloc_node_flags(size, node, flags);
> 	if ((flags & (__GFP_IO | __GFP_FS)) != (__GFP_IO | __GFP_FS))
> 		memalloc_noio_restore(noio_flag)
> 
> Or perhaps even better - push memalloc_noio_save/memalloc_noio_restore 
> directly to __vmalloc, so that __vmalloc respects the gfp flags properly - 
> note that there are 14 places in the kernel where __vmalloc is called with 
> GFP_NOFS and they are all buggy because __vmalloc doesn't respect the 
> GFP_NOFS flag.

That is out of scope of this patch series. I would like to deal with
NOIO an NOFS contexts separately.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
