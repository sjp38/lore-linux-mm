Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4FE236B0516
	for <linux-mm@kvack.org>; Wed,  9 May 2018 09:42:28 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id f23-v6so24135281wra.20
        for <linux-mm@kvack.org>; Wed, 09 May 2018 06:42:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v22-v6si1513297eda.271.2018.05.09.06.42.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 06:42:26 -0700 (PDT)
Date: Wed, 9 May 2018 15:42:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: vmalloc with GFP_NOFS
Message-ID: <20180509134222.GU32366@dhcp22.suse.cz>
References: <20180424162712.GL17484@dhcp22.suse.cz>
 <20180424183536.GF30619@thunk.org>
 <20180424192542.GS17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180424192542.GS17484@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: LKML <linux-kernel@vger.kernel.org>, Artem Bityutskiy <dedekind1@gmail.com>, Richard Weinberger <richard@nod.at>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>, Andreas Dilger <adilger.kernel@dilger.ca>, Steven Whitehouse <swhiteho@redhat.com>, Bob Peterson <rpeterso@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Adrian Hunter <adrian.hunter@intel.com>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mtd@lists.infradead.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org

On Tue 24-04-18 13:25:42, Michal Hocko wrote:
[...]
> > As a suggestion, could you take
> > documentation about how to convert to the memalloc_nofs_{save,restore}
> > scope api (which I think you've written about e-mails at length
> > before), and put that into a file in Documentation/core-api?
> 
> I can.

Does something like the below sound reasonable/helpful?
---
=================================
GFP masks used from FS/IO context
=================================

:Date: Mapy, 2018
:Author: Michal Hocko <mhocko@kernel.org>

Introduction
============

FS resp. IO submitting code paths have to be careful when allocating
memory to prevent from potential recursion deadlocks caused by direct
memory reclaim calling back into the FS/IO path and block on already
held resources (e.g. locks). Traditional way to avoid this problem
is to clear __GFP_FS resp. __GFP_IO (note the later implies clearing
the first as well) in the gfp mask when calling an allocator. GFP_NOFS
resp. GFP_NOIO can be used as shortcut.

This has been the traditional way to avoid deadlocks since ages. It
turned out though that above approach has led to abuses when the restricted
gfp mask is used "just in case" without a deeper consideration which leads
to problems because an excessive use of GFP_NOFS/GFP_NOIO can lead to
memory over-reclaim or other memory reclaim issues.

New API
=======

Since 4.12 we do have a generic scope API for both NOFS and NOIO context
``memalloc_nofs_save``, ``memalloc_nofs_restore`` resp. ``memalloc_noio_save``,
``memalloc_noio_restore`` which allow to mark a scope to be a critical
section from the memory reclaim recursion into FS/IO POV. Any allocation
from that scope will inherently drop __GFP_FS resp. __GFP_IO from the given
mask so no memory allocation can recurse back in the FS/IO.

FS/IO code then simply calls the appropriate save function right at
the layer where a lock taken from the reclaim context (e.g. shrinker)
is taken and the corresponding restore function when the lock is
released. All that ideally along with an explanation what is the reclaim
context for easier maintenance.

What about __vmalloc(GFP_NOFS)
==============================

vmalloc doesn't support GFP_NOFS semantic because there are hardcoded
GFP_KERNEL allocations deep inside the allocator which are quit non-trivial
to fix up. That means that calling ``vmalloc`` with GFP_NOFS/GFP_NOIO is
almost always a bug. The good news is that the NOFS/NOIO semantic can be
achieved by the scope api.

In the ideal world, upper layers should already mark dangerous contexts
and so no special care is required and vmalloc should be called without
any problems. Sometimes if the context is not really clear or there are
layering violations then the recommended way around that is to wrap ``vmalloc``
by the scope API with a comment explaining the problem.
-- 
Michal Hocko
SUSE Labs
