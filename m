Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 682676B0253
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 10:25:41 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id o17so7595438pli.7
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:25:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e7sor4004203pgq.135.2017.12.19.07.25.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 07:25:40 -0800 (PST)
Date: Wed, 20 Dec 2017 00:25:36 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v2] mm/zsmalloc: simplify shrinker init/destroy
Message-ID: <20171219152536.GA591@tigerII.localdomain>
References: <20171219102213.GA435@jagdpanzerIV>
 <1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com>
 <20171219151341.GC15210@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219151341.GC15210@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Aliaksei Karaliou <akaraliou.dev@gmail.com>, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Hi Michal,

On (12/19/17 16:13), Michal Hocko wrote:
> On Tue 19-12-17 13:49:12, Aliaksei Karaliou wrote:
> [...]
> > @@ -2428,8 +2422,8 @@ struct zs_pool *zs_create_pool(const char *name)
> >  	 * Not critical, we still can use the pool
> >  	 * and user can trigger compaction manually.
> >  	 */
> > -	if (zs_register_shrinker(pool) == 0)
> > -		pool->shrinker_enabled = true;
> > +	(void) zs_register_shrinker(pool);
> > +
> >  	return pool;
> 
> So what will happen if the pool is alive and used without any shrinker?
> How do objects get freed?

we use shrinker for "optional" de-fragmentation of zsmalloc pools. we
don't free any objects from that path. just move them around within their
size classes - to consolidate objects and to, may be, free unused pages
[but we first need to make them "unused"]. it's not a mandatory thing for
zsmalloc, we are just trying to be nice.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
