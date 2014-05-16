Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 24CD66B0072
	for <linux-mm@kvack.org>; Fri, 16 May 2014 11:03:27 -0400 (EDT)
Received: by mail-qc0-f170.google.com with SMTP id i8so4511681qcq.15
        for <linux-mm@kvack.org>; Fri, 16 May 2014 08:03:26 -0700 (PDT)
Received: from qmta13.emeryville.ca.mail.comcast.net (qmta13.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:243])
        by mx.google.com with ESMTP id m4si4304888qae.165.2014.05.16.08.03.25
        for <linux-mm@kvack.org>;
        Fri, 16 May 2014 08:03:26 -0700 (PDT)
Date: Fri, 16 May 2014 10:03:22 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH RFC 3/3] slub: reparent memcg caches' slabs on memcg
 offline
In-Reply-To: <20140516132234.GF32113@esperanza>
Message-ID: <alpine.DEB.2.10.1405160957100.32249@gentwo.org>
References: <cover.1399982635.git.vdavydov@parallels.com> <6eafe1e95d9a934228e9af785f5b5de38955aa6a.1399982635.git.vdavydov@parallels.com> <alpine.DEB.2.10.1405141119320.16512@gentwo.org> <20140515071650.GB32113@esperanza> <alpine.DEB.2.10.1405151015330.24665@gentwo.org>
 <20140516132234.GF32113@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 16 May 2014, Vladimir Davydov wrote:

> > Do we even know that all objects in that slab belong to a certain cgroup?
> > AFAICT the fastpath currently do not allow to make that distinction.
>
> All allocations from a memcg's cache are accounted to the owner memcg,
> so that all objects on the same slab belong to the same memcg, a pointer
> to which can be obtained from the page->slab_cache->memcg_params. At
> least, this is true since commit faebbfe10ec1 ("sl[au]b: charge slabs to
> kmemcg explicitly").

I doubt that. The accounting occurs when a new cpu slab page is allocated.
But the individual allocations in the fastpath are not accounted to a
specific group. Thus allocation in a slab page can belong to various
cgroups.

> > I wish you would find some other way to do this.
>
> The only practical alternative to re-parenting I see right now is
> periodic reaping, but Johannes isn't very fond of it, and his opinion is
> quite justified, because having caches that will never be allocated from
> hanging around indefinitely, only because they have a couple of active
> objects to be freed, doesn't look very good.

If all objects in the cache are in use then the slab page needs to hang
around since the objects presence is required. You may not know exactly
which cgroups these object belong to. The only thing that you may now (if
you keep a list of full slabs) is which cgroup was in use then the
slab page was initially allocated.

Isnt it sufficient to add a counter of full slabs to a cgroup? When you
allocate a new slab page add to the counter. When an object in a slab page
is freed and the slab page goes on a partial list decrement the counter.

That way you can avoid tracking full slabs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
