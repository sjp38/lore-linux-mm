Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5028C2803DB
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 11:04:51 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z91so25650882wrc.4
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 08:04:51 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id a1si9530797wrd.47.2017.08.21.08.04.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Aug 2017 08:04:49 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20170821140641.GN25956@dhcp22.suse.cz>
References: <20170606120436.8683-1-chris@chris-wilson.co.uk>
 <20170606121418.GM1189@dhcp22.suse.cz>
 <150314853540.7354.10275185301153477504@mail.alporthouse.com>
 <20170821140641.GN25956@dhcp22.suse.cz>
Message-ID: <150332781184.13047.15448500819676507290@mail.alporthouse.com>
Subject: Re: [RFC] mm,drm/i915: Mark pinned shmemfs pages as unevictable
Date: Mon, 21 Aug 2017 16:03:31 +0100
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Matthew Auld <matthew.auld@intel.com>, Dave Hansen <dave.hansen@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>

Quoting Michal Hocko (2017-08-21 15:06:42)
> On Sat 19-08-17 14:15:35, Chris Wilson wrote:
> > Quoting Michal Hocko (2017-06-06 13:14:18)
> > > On Tue 06-06-17 13:04:36, Chris Wilson wrote:
> > > > Similar in principle to the treatment of get_user_pages, pages that
> > > > i915.ko acquires from shmemfs are not immediately reclaimable and so
> > > > should be excluded from the mm accounting and vmscan until they have
> > > > been returned to the system via shrink_slab/i915_gem_shrink. By mov=
ing
> > > > the unreclaimable pages off the inactive anon lru, not only should
> > > > vmscan be improved by avoiding walking unreclaimable pages, but the
> > > > system should also have a better idea of how much memory it can rec=
laim
> > > > at that moment in time.
> > > =

> > > That is certainly desirable. Peter has proposed a generic pin_page (or
> > > similar) API. What happened with it? I think it would be a better
> > > approach than (ab)using mlock API. I am also not familiar with the i9=
15
> > > code to be sure that using lock_page is really safe here. I think that
> > > all we need is to simply move those pages in/out to/from unevictable =
LRU
> > > list on pin/unpining.
> > =

> > I just had the opportunity to try this mlock_vma_page() hack on a
> > borderline swapping system (i.e. lots of vmpressure between i915 buffers
> > and the buffercache), and marking the i915 pages as unevictable makes a
> > huge difference in avoiding stalls in direct reclaim across the system.
> > =

> > Reading back over the thread, it seems that the simplest approach going
> > forward is a small api for managing the pages on the unevictable LRU?
> =

> Yes and I thought that pin_page API would do exactly that.

My googlefu says "[RFC][PATCH 1/5] mm: Introduce VM_PINNED and
interfaces" is the series, and it certainly targets the very same
problem.

Peter, is that the latest version?
-Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
