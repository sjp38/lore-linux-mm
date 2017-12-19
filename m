Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id F2D346B026A
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 10:58:16 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 55so11540067wrx.21
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:58:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b62si1483793wma.55.2017.12.19.07.58.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 07:58:15 -0800 (PST)
Date: Tue, 19 Dec 2017 16:58:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm/zsmalloc: simplify shrinker init/destroy
Message-ID: <20171219155815.GC2787@dhcp22.suse.cz>
References: <20171219102213.GA435@jagdpanzerIV>
 <1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com>
 <20171219151341.GC15210@dhcp22.suse.cz>
 <20171219152536.GA591@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219152536.GA591@tigerII.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Aliaksei Karaliou <akaraliou.dev@gmail.com>, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed 20-12-17 00:25:36, Sergey Senozhatsky wrote:
> Hi Michal,
> 
> On (12/19/17 16:13), Michal Hocko wrote:
> > On Tue 19-12-17 13:49:12, Aliaksei Karaliou wrote:
> > [...]
> > > @@ -2428,8 +2422,8 @@ struct zs_pool *zs_create_pool(const char *name)
> > >  	 * Not critical, we still can use the pool
> > >  	 * and user can trigger compaction manually.
> > >  	 */
> > > -	if (zs_register_shrinker(pool) == 0)
> > > -		pool->shrinker_enabled = true;
> > > +	(void) zs_register_shrinker(pool);
> > > +
> > >  	return pool;
> > 
> > So what will happen if the pool is alive and used without any shrinker?
> > How do objects get freed?
> 
> we use shrinker for "optional" de-fragmentation of zsmalloc pools. we
> don't free any objects from that path. just move them around within their
> size classes - to consolidate objects and to, may be, free unused pages
> [but we first need to make them "unused"]. it's not a mandatory thing for
> zsmalloc, we are just trying to be nice.

OK, it smells like an abuse of the API but please add a comment
clarifying that.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
