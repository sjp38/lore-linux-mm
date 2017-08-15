Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 181506B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 18:54:42 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z36so2891935wrb.13
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 15:54:42 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id j17si2914831wrd.108.2017.08.15.15.54.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 15:54:41 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20170815153010.e3cfc177af0b2c0dc421b84c@linux-foundation.org>
References: <20170812113437.7397-1-chris@chris-wilson.co.uk>
 <20170815153010.e3cfc177af0b2c0dc421b84c@linux-foundation.org>
Message-ID: <150283758841.13477.1932975129094549388@mail.alporthouse.com>
Subject: Re: [PATCH] mm: Reward slab shrinkers that reclaim more than they were asked
Date: Tue, 15 Aug 2017 23:53:08 +0100
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Shaohua Li <shli@fb.com>

Quoting Andrew Morton (2017-08-15 23:30:10)
> On Sat, 12 Aug 2017 12:34:37 +0100 Chris Wilson <chris@chris-wilson.co.uk=
> wrote:
> =

> > Some shrinkers may only be able to free a bunch of objects at a time, a=
nd
> > so free more than the requested nr_to_scan in one pass. Account for the
> > extra freed objects against the total number of objects we intend to
> > free, otherwise we may end up penalising the slab far more than intende=
d.
> > =

> > ...
> >
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -398,6 +398,7 @@ static unsigned long do_shrink_slab(struct shrink_c=
ontrol *shrinkctl,
> >                       break;
> >               freed +=3D ret;
> >  =

> > +             nr_to_scan =3D max(nr_to_scan, ret);
> >               count_vm_events(SLABS_SCANNED, nr_to_scan);
> >               total_scan -=3D nr_to_scan;
> >               scanned +=3D nr_to_scan;
> =

> Well...  kinda.  But what happens if the shrinker scanned more objects
> than requested but failed to free many of them?  Of if the shrinker
> scanned less than requested?
> =

> We really want to return nr_scanned from the shrinker invocation. =

> Could we add a field to shrink_control for this?

Yes, that will work better overall.
-Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
