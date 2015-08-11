Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4DE736B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 04:51:16 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so125830395pab.0
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 01:51:16 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id km1si2306138pdb.43.2015.08.11.01.51.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Aug 2015 01:51:15 -0700 (PDT)
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NSW02Y53TXC3Y00@mailout3.samsung.com> for linux-mm@kvack.org;
 Tue, 11 Aug 2015 17:51:12 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
References: <1438619141-22215-1-git-send-email-vbabka@suse.cz>
 <1086308416.1472237.1439134679684.JavaMail.yahoo@mail.yahoo.com>
 <55C8726E.4090103@suse.cz>
In-reply-to: <55C8726E.4090103@suse.cz>
Subject: RE: [RFC v3 1/2] mm, compaction: introduce kcompactd
Date: Tue, 11 Aug 2015 14:20:23 +0530
Message-id: <03f801d0d412$d56cedd0$8046c970$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: quoted-printable
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Vlastimil Babka' <vbabka@suse.cz>, 'PINTU KUMAR' <pintu_agarwal@yahoo.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, 'Andrew Morton' <akpm@linux-foundation.org>, 'Hugh Dickins' <hughd@google.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Rik van Riel' <riel@redhat.com>, 'Mel Gorman' <mgorman@suse.de>, 'David Rientjes' <rientjes@google.com>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, cpgs@samsung.com, pintu.k@outlook.com

Hi,

> -----Original Message-----
> From: Vlastimil Babka [mailto:vbabka@suse.cz]
> Sent: Monday, August 10, 2015 3:14 PM
> To: PINTU KUMAR; linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org; Andrew Morton; Hugh Dickins; Andrea
> Arcangeli; Kirill A. Shutemov; Rik van Riel; Mel Gorman; David =
Rientjes; Joonsoo
> Kim; Pintu Kumar
> Subject: Re: [RFC v3 1/2] mm, compaction: introduce kcompactd
>=20
> On 08/09/2015 05:37 PM, PINTU KUMAR wrote:
> >> Waking up of the kcompactd threads is also tied to kswapd activity
> >> and follows these rules:
> >> - we don't want to affect any fastpaths, so wake up kcompactd only =
from the
> >>    slowpath, as it's done for kswapd
> >> - if kswapd is doing reclaim, it's more important than compaction, =
so
> >> don't
> >>    invoke kcompactd until kswapd goes to sleep
> >> - the target order used for kswapd is passed to kcompactd
> >>
> >> The kswapd compact/reclaim loop for high-order pages is left alone
> >> for now and precedes kcompactd wakeup, but this might be revisited =
later.
> >
> > kcompactd, will be really nice thing to have, but I oppose calling =
it from
> kswapd.
> > Because, just after kswapd, we already have direct_compact.
>=20
> Just to be clear, here you mean that kswapd already does the =
compact/reclaim
> loop?
>=20
No, I mean in slowpath, after kswapd, there is already =
direct_compact/reclaim.

> > So it may end up in doing compaction 2 times.
>=20
> The compact/reclaim loop might already do multiple iterations. The =
point is,
> kswapd will terminate the loop as soon as single page of desired order =
becomes
> available. Kcompactd is meant to go beyond that.
> And having kcompactd run in parallel with kswapd's reclaim looks like =
nonsense
> to me, so I don't see other way than have kswapd wake up kcompactd =
when it's
> finished.
>
But, if kswapd is disabled then even kcompactd will not be called. Then =
it will be same situation.
Just a thought, how about creating a kworker thread for performing =
kcompactd?
May be schedule it on demand (based on current fragmentation level of =
COSTLY_ORDER), from other sub-system.
Or, may be invoke it when direct_reclaim fails.
Because, as per my observation, running compaction, immediately after =
reclaim gives more benefit.
How about tracking all higher order in kernel and understand who =
actually needs it.

> > Or, is it like, with kcompactd, we dont need direct_compact?
>=20
> That will have to be evaluated. It would be nice to not need the =
compact/reclaim
> loop, but I'm not sure it's always possible. We could move it to =
kcompactd, but it
> would still mean that no daemon does exclusively just reclaim or just
> compaction.
>=20
> > In embedded world situation is really worse.
> > As per my experience in embedded world, just compaction does not =
help
> always in longer run.
> >
> > As I know there are already some Android model in market, that =
already run
> background compaction (from user space).
> > But still there are sluggishness issues due to bad memory state in =
the long run.
>=20
> It should still be better with background compaction than without it. =
Of course,
> avoiding a permanent fragmentation completely is not possible to =
guarantee as it
> depends on the allocation patterns.
>=20
> > In embedded world, the major problems are related to camera and =
browser use
> cases that requires almost order-8 allocations.
> > Also, for low RAM configurations (less than 512M, 256M etc.), the =
rate of
> failure of compaction is much higher than the rate of success.
>=20
> I was under impression that CMA was introduced to deal with such =
high-order
> requirements in the embedded world?
>=20
CMA has its own limitations and drawbacks (because of movable pages =
criteria).
Please check this:
https://lkml.org/lkml/2014/5/7/810=20
So, for low RAM devices we try to make CMA as tight and low as possible.
For IOMMU supported devices (camera etc.), we don=E2=80=99t need CMA.
For Android case, they use ION system heap that rely on higher-order =
(with fallback mechanism), then perform scatter/gather.
For more information, please check this:
drivers/staging/android/ion/ion_system_heap.c

> > How can we guarantee that kcompactd is suitable for all situations?
>=20
> We can't :) we can only hope to improve the average case. Anything =
that needs
> high-order *guarantees* has to rely on CMA or another kind of =
reservation (yeah
> even CMA is a pageblock reservation in some sense).
>=20
> > In an case, we need large amount of testing to cover all scenarios.
> > It should be called at the right time.
> > I dont have any data to present right now.
> > May be I will try to capture some data, and present here.
>=20
> That would be nice. I'm going to collect some as well.

Specially, I would like to see the results on low RAM (less than 512M).
I will also share if I get anything interesting.
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
