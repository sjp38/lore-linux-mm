Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id E3E986B0031
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 00:05:32 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id r20so1699891wiv.4
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 21:05:32 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id bs19si4547353wib.12.2014.06.24.21.05.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 21:05:31 -0700 (PDT)
Date: Wed, 25 Jun 2014 00:05:26 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm 3/3] page-cgroup: fix flags definition
Message-ID: <20140625040526.GR7331@cmpxchg.org>
References: <9f5abf8dcb07fe5462f12f81867f199c22e883d3.1403626729.git.vdavydov@parallels.com>
 <aacc50fb60eeb9cbe14e07235310fb9295b2658b.1403626729.git.vdavydov@parallels.com>
 <20140624162052.6778a13e3b3f4af251e300e7@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140624162052.6778a13e3b3f4af251e300e7@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 24, 2014 at 04:20:52PM -0700, Andrew Morton wrote:
> On Tue, 24 Jun 2014 20:33:06 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:
> 
> > Since commit a9ce315aaec1f ("mm: memcontrol: rewrite uncharge API"),
> > PCG_* flags are used as bit masks, but they are still defined in a enum
> > as bit numbers. Fix it.
> > 
> > ...
> >
> > --- a/include/linux/page_cgroup.h
> > +++ b/include/linux/page_cgroup.h
> > @@ -1,12 +1,10 @@
> >  #ifndef __LINUX_PAGE_CGROUP_H
> >  #define __LINUX_PAGE_CGROUP_H
> >  
> > -enum {
> > -	/* flags for mem_cgroup */
> > -	PCG_USED,	/* This page is charged to a memcg */
> > -	PCG_MEM,	/* This page holds a memory charge */
> > -	PCG_MEMSW,	/* This page holds a memory+swap charge */
> > -};
> > +/* flags for mem_cgroup */
> > +#define PCG_USED	0x01	/* This page is charged to a memcg */
> > +#define PCG_MEM		0x02	/* This page holds a memory charge */
> > +#define PCG_MEMSW	0x04	/* This page holds a memory+swap charge */
> >  
> >  struct pglist_data;
> >  
> > @@ -44,7 +42,7 @@ struct page *lookup_cgroup_page(struct page_cgroup *pc);
> >  
> >  static inline int PageCgroupUsed(struct page_cgroup *pc)
> >  {
> > -	return test_bit(PCG_USED, &pc->flags);
> > +	return !!(pc->flags & PCG_USED);
> >  }
> >  #else /* !CONFIG_MEMCG */
> >  struct page_cgroup;
> 
> hm, yes, whoops.  I think I'll redo this as a fix against
> mm-memcontrol-rewrite-uncharge-api.patch:

Ouch, yes please.  Thanks for catching this, Vladimir.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
