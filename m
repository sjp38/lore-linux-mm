Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6359C6B0272
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:59:27 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v189so1247660wmf.4
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:59:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t24si283316edb.353.2018.04.13.06.59.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 06:59:26 -0700 (PDT)
Date: Fri, 13 Apr 2018 15:59:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] dcache: account external names as indirectly
 reclaimable memory
Message-ID: <20180413135923.GT17484@dhcp22.suse.cz>
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-5-guro@fb.com>
 <20180413133519.GA213834@rodete-laptop-imager.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180413133519.GA213834@rodete-laptop-imager.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri 13-04-18 22:35:19, Minchan Kim wrote:
> On Mon, Mar 05, 2018 at 01:37:43PM +0000, Roman Gushchin wrote:
[...]
> > @@ -1614,9 +1623,11 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
> >  		name = &slash_name;
> >  		dname = dentry->d_iname;
> >  	} else if (name->len > DNAME_INLINE_LEN-1) {
> > -		size_t size = offsetof(struct external_name, name[1]);
> > -		struct external_name *p = kmalloc(size + name->len,
> > -						  GFP_KERNEL_ACCOUNT);
> > +		struct external_name *p;
> > +
> > +		reclaimable = offsetof(struct external_name, name[1]) +
> > +			name->len;
> > +		p = kmalloc(reclaimable, GFP_KERNEL_ACCOUNT);
> 
> Can't we use kmem_cache_alloc with own cache created with SLAB_RECLAIM_ACCOUNT
> if they are reclaimable? 

No, because names have different sizes and so we would basically have to
duplicate many caches.
-- 
Michal Hocko
SUSE Labs
