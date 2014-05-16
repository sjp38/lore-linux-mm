Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id C3D096B006C
	for <linux-mm@kvack.org>; Fri, 16 May 2014 09:22:47 -0400 (EDT)
Received: by mail-lb0-f174.google.com with SMTP id n15so1919090lbi.5
        for <linux-mm@kvack.org>; Fri, 16 May 2014 06:22:47 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ao4si5609493lac.85.2014.05.16.06.22.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 May 2014 06:22:45 -0700 (PDT)
Date: Fri, 16 May 2014 17:22:35 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH RFC 3/3] slub: reparent memcg caches' slabs on memcg
 offline
Message-ID: <20140516132234.GF32113@esperanza>
References: <cover.1399982635.git.vdavydov@parallels.com>
 <6eafe1e95d9a934228e9af785f5b5de38955aa6a.1399982635.git.vdavydov@parallels.com>
 <alpine.DEB.2.10.1405141119320.16512@gentwo.org>
 <20140515071650.GB32113@esperanza>
 <alpine.DEB.2.10.1405151015330.24665@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405151015330.24665@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, May 15, 2014 at 10:16:39AM -0500, Christoph Lameter wrote:
> On Thu, 15 May 2014, Vladimir Davydov wrote:
> 
> > I admit that's far not perfect, because kfree is really a hot path,
> > where every byte of code matters, but unfortunately I don't see how we
> > can avoid this in case we want slab re-parenting.
> 
> Do we even know that all objects in that slab belong to a certain cgroup?
> AFAICT the fastpath currently do not allow to make that distinction.

All allocations from a memcg's cache are accounted to the owner memcg,
so that all objects on the same slab belong to the same memcg, a pointer
to which can be obtained from the page->slab_cache->memcg_params. At
least, this is true since commit faebbfe10ec1 ("sl[au]b: charge slabs to
kmemcg explicitly").

> > Again, I'd like to hear from you if there is any point in moving in this
> > direction, or I should give up and concentrate on some other approach,
> > because you'll never accept it.
> 
> I wish you would find some other way to do this.

The only practical alternative to re-parenting I see right now is
periodic reaping, but Johannes isn't very fond of it, and his opinion is
quite justified, because having caches that will never be allocated from
hanging around indefinitely, only because they have a couple of active
objects to be freed, doesn't look very good.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
