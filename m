Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A816A6B0005
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 09:33:51 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id d2so6014029plr.11
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 06:33:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f90-v6si3820181plb.63.2018.02.19.06.33.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Feb 2018 06:33:50 -0800 (PST)
Date: Mon, 19 Feb 2018 15:33:43 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC PATCH 3/3] fs: fsnotify: account fsnotify metadata to kmemcg
Message-ID: <20180219143343.u5ckigir7svpkiem@quack2.suse.cz>
References: <20180214025653.132942-1-shakeelb@google.com>
 <20180214025653.132942-4-shakeelb@google.com>
 <CAOQ4uxjHtV+9=T3wGdg9na0zPiBYzDtDAOJx7rWUMv5KS6Bi2g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxjHtV+9=T3wGdg9na0zPiBYzDtDAOJx7rWUMv5KS6Bi2g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Shakeel Butt <shakeelb@google.com>, Jan Kara <jack@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, cgroups@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>

On Wed 14-02-18 10:08:31, Amir Goldstein wrote:
> On Wed, Feb 14, 2018 at 4:56 AM, Shakeel Butt <shakeelb@google.com> wrote:
> > This is RFC patch and the discussion on the API is still happening at
> > the following link but I am sending the early draft for feedback.
> > [link] https://marc.info/?l=linux-api&m=151850343717274
> >
> > A lot of memory can be consumed by the events generated for the huge or
> > unlimited queues if there is either no or slow listener. This can cause
> > system level memory pressure or OOMs. So, it's better to account the
> > fsnotify kmem caches to the memcg of the listener.
> >
> > There are seven fsnotify kmem caches and among them allocations from
> > dnotify_struct_cache, dnotify_mark_cache, fanotify_mark_cache and
> > inotify_inode_mark_cachep happens in the context of syscall from the
> 
> fsnotify_mark_connector_cachep as well.

Yes, but for the purposes of memcg accounting, I'd just ignore this cache
and not account fsnotify_mark_connector objects at all. They are small
compared to the notification mark or events and it is unclear whom to
account connector to since it is shared by all events attached to the
inode.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
