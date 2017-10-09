Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E4A1B6B0260
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 02:24:31 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l188so41870537pfc.7
        for <linux-mm@kvack.org>; Sun, 08 Oct 2017 23:24:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r7si6302949pfi.372.2017.10.08.23.24.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 08 Oct 2017 23:24:30 -0700 (PDT)
Date: Mon, 9 Oct 2017 08:24:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171009062426.hmqedtqz5hkmhnff@dhcp22.suse.cz>
References: <20171005222144.123797-1-shakeelb@google.com>
 <20171006075900.icqjx5rr7hctn3zd@dhcp22.suse.cz>
 <CALvZod7YN4JCG7Anm2FViyZ0-APYy+nxEd3nyxe5LT_P0FC9wg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod7YN4JCG7Anm2FViyZ0-APYy+nxEd3nyxe5LT_P0FC9wg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Fri 06-10-17 12:33:03, Shakeel Butt wrote:
> >>       names_cachep = kmem_cache_create("names_cache", PATH_MAX, 0,
> >> -                     SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
> >> +                     SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_ACCOUNT, NULL);
> >
> > I might be wrong but isn't name cache only holding temporary objects
> > used for path resolution which are not stored anywhere?
> >
> 
> Even though they're temporary, many containers can together use a
> significant amount of transient uncharged memory. We've seen machines
> with 100s of MiBs in names_cache.

Yes that might be possible but are we prepared for random ENOMEM from
vfs calls which need to allocate a temporary name?

> 
> >>       filp_cachep = kmem_cache_create("filp", sizeof(struct file), 0,
> >> -                     SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
> >> +                     SLAB_HWCACHE_ALIGN | SLAB_PANIC | SLAB_ACCOUNT, NULL);
> >>       percpu_counter_init(&nr_files, 0, GFP_KERNEL);
> >>  }
> >
> > Don't we have a limit for the maximum number of open files?
> >
> 
> Yes, there is a system limit of maximum number of open files. However
> this limit is shared between different users on the system and one
> user can hog this resource. To cater that, we set the maximum limit
> very high and let the memory limit of each user limit the number of
> files they can open.

Similarly here. Are all syscalls allocating a fd prepared to return
ENOMEM?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
