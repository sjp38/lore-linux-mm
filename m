Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 86CD56B0037
	for <linux-mm@kvack.org>; Wed, 21 May 2014 11:14:35 -0400 (EDT)
Received: by mail-lb0-f174.google.com with SMTP id n15so1686069lbi.19
        for <linux-mm@kvack.org>; Wed, 21 May 2014 08:14:34 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id g5si13027130laa.34.2014.05.21.08.14.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 May 2014 08:14:33 -0700 (PDT)
Date: Wed, 21 May 2014 19:14:24 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH RFC 3/3] slub: reparent memcg caches' slabs on memcg
 offline
Message-ID: <20140521151423.GC23193@esperanza>
References: <alpine.DEB.2.10.1405141119320.16512@gentwo.org>
 <20140515071650.GB32113@esperanza>
 <alpine.DEB.2.10.1405151015330.24665@gentwo.org>
 <20140516132234.GF32113@esperanza>
 <alpine.DEB.2.10.1405160957100.32249@gentwo.org>
 <20140519152437.GB25889@esperanza>
 <alpine.DEB.2.10.1405191056580.22956@gentwo.org>
 <537A4D27.1050909@parallels.com>
 <20140521135826.GA23193@esperanza>
 <alpine.DEB.2.10.1405210944140.8038@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405210944140.8038@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 21, 2014 at 09:45:54AM -0500, Christoph Lameter wrote:
> On Wed, 21 May 2014, Vladimir Davydov wrote:
> 
> > Seems I've found a better way to avoid this race, which does not involve
> > messing up free hot paths. The idea is to explicitly zap each per-cpu
> > partial list by setting it pointing to an invalid ptr. Since
> > put_cpu_partial(), which is called from __slab_free(), uses atomic
> > cmpxchg for adding a new partial slab to a per cpu partial list, it is
> > enough to add a check if partials are zapped there and bail out if so.
> >
> > The patch doing the trick is attached. Could you please take a look at
> > it once time permit?
> 
> Well if you set s->cpu_partial = 0 then the slab should not be added to
> the partial lists. Ok its put on there temporarily but then immediately
> moved to the node partial list in put_cpu_partial().

Don't think so. AFAIU put_cpu_partial() first checks if the per-cpu
partial list has more than s->cpu_partial objects draining it if so, but
then it adds the newly frozen slab there anyway.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
