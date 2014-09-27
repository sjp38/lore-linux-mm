Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5BDA96B0038
	for <linux-mm@kvack.org>; Sat, 27 Sep 2014 04:12:21 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa1so6251440pad.0
        for <linux-mm@kvack.org>; Sat, 27 Sep 2014 01:12:21 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id te6si12862945pbc.227.2014.09.27.01.12.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Sep 2014 01:12:20 -0700 (PDT)
Date: Sat, 27 Sep 2014 12:12:03 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 3/4] slab: fix cpuset check in fallback_alloc
Message-ID: <20140927081203.GA1633@esperanza>
References: <cover.1411741632.git.vdavydov@parallels.com>
 <5ccdd901946feaf88fd6d2441b18a6845cc56571.1411741632.git.vdavydov@parallels.com>
 <alpine.DEB.2.11.1409261130550.3870@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1409261130550.3870@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Hi Christoph,

On Fri, Sep 26, 2014 at 11:31:31AM -0500, Christoph Lameter wrote:
> On Fri, 26 Sep 2014, Vladimir Davydov wrote:
> 
> > To avoid this we should use softwall cpuset check in fallback_alloc.
> 
> Its weird that softwall checking occurs by setting __GFP_HARDWALL.

Hmm, I don't think I follow. Currently we enforce *hardwall* check by
passing __GFP_HARDWALL to cpuset_zone_allowed(). However, we need
softwall check there to conform to the page allocator behavior, so I
remove the __GFP_HARDWALL flag from cpuset_zone_allowed() to get
softwall check.

Actually, initially we used softwall check in fallback_alloc(). This was
changed to hardwall check by commit b8b50b6519afa ("mm: fallback_alloc
cpuset_zone_allowed irq fix") in order to fix sleep-in-atomic bug,
because at that time softwall check required taking the callback_mutex
while fallback_alloc is called with interrupts disabled.

Thanks,
Vladimir

> >
> > Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> > ---
> >  mm/slab.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/mm/slab.c b/mm/slab.c
> > index eb6f0cf6875c..e35822d07821 100644
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -3051,7 +3051,7 @@ retry:
> >  	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
> >  		nid = zone_to_nid(zone);
> >
> > -		if (cpuset_zone_allowed(zone, flags | __GFP_HARDWALL) &&
> > +		if (cpuset_zone_allowed(zone, flags) &&
> >  			get_node(cache, nid) &&
> >  			get_node(cache, nid)->free_objects) {
> >  				obj = ____cache_alloc_node(cache,
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
