Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 51AFB900002
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 02:49:58 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y13so653310pdi.13
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 23:49:57 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id tf3si101423pac.14.2014.06.11.23.49.55
        for <linux-mm@kvack.org>;
        Wed, 11 Jun 2014 23:49:57 -0700 (PDT)
Date: Thu, 12 Jun 2014 15:53:45 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH -mm v2 8/8] slab: make dead memcg caches discard free
 slabs immediately
Message-ID: <20140612065345.GD19918@js1304-P5Q-DELUXE>
References: <cover.1402060096.git.vdavydov@parallels.com>
 <27a202c6084d6bb19cc3e417793f05104b908ded.1402060096.git.vdavydov@parallels.com>
 <20140610074317.GE19036@js1304-P5Q-DELUXE>
 <20140610100313.GA6293@esperanza>
 <alpine.DEB.2.10.1406100925270.17142@gentwo.org>
 <20140610151830.GA8692@esperanza>
 <20140611212431.GA16589@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140611212431.GA16589@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Christoph Lameter <cl@gentwo.org>, akpm@linux-foundation.org, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jun 12, 2014 at 01:24:34AM +0400, Vladimir Davydov wrote:
> On Tue, Jun 10, 2014 at 07:18:34PM +0400, Vladimir Davydov wrote:
> > On Tue, Jun 10, 2014 at 09:26:19AM -0500, Christoph Lameter wrote:
> > > On Tue, 10 Jun 2014, Vladimir Davydov wrote:
> > > 
> > > > Frankly, I incline to shrinking dead SLAB caches periodically from
> > > > cache_reap too, because it looks neater and less intrusive to me. Also
> > > > it has zero performance impact, which is nice.
> > > >
> > > > However, Christoph proposed to disable per cpu arrays for dead caches,
> > > > similarly to SLUB, and I decided to give it a try, just to see the end
> > > > code we'd have with it.
> > > >
> > > > I'm still not quite sure which way we should choose though...
> > > 
> > > Which one is cleaner?
> > 
> > To shrink dead caches aggressively, we only need to modify cache_reap
> > (see https://lkml.org/lkml/2014/5/30/271).
> 
> Hmm, reap_alien, which is called from cache_reap to shrink per node
> alien object arrays, only processes one node at a time. That means with
> the patch I gave a link to above it will take up to
> (REAPTIMEOUT_AC*nr_online_nodes) seconds to destroy a virtually empty
> dead cache, which may be quite long on large machines. Of course, we can
> make reap_alien walk over all alien caches of the current node, but that
> will probably hurt performance...

Hmm, maybe we have a few of objects on other node, doesn't it?

BTW, I have a question about cache_reap(). If there are many kmemcg
users, we would have a lot of slab caches and just to traverse slab
cache list could take some times. Is it no problem?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
