Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE786B000A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:55:48 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t10-v6so1482887pfh.0
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 08:55:48 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id a72-v6si8406297pge.497.2018.06.29.08.55.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 08:55:47 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v34 0/4] Virtio-balloon: support free page reporting
Date: Fri, 29 Jun 2018 15:55:04 +0000
Message-ID: <286AC319A985734F985F78AFA26841F7396C254C@shsmsx102.ccr.corp.intel.com>
References: <1529928312-30500-1-git-send-email-wei.w.wang@intel.com>
 <c4dd0a13-91fb-c0f5-b41f-54421fdacca9@redhat.com>
 <5B35ACD5.4090800@intel.com>
 <4840cbb7-dd3f-7540-6a7c-13427de2f0d1@redhat.com>
 <5B36189E.5050204@intel.com>
 <34bb25eb-97f3-8a9f-8a13-401dfcf39a2c@redhat.com>
In-Reply-To: <34bb25eb-97f3-8a9f-8a13-401dfcf39a2c@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mst@redhat.com" <mst@redhat.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu0@gmail.com" <quan.xu0@gmail.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "peterx@redhat.com" <peterx@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Luiz Capitulino <lcapitulino@redhat.com>

On Friday, June 29, 2018 7:54 PM, David Hildenbrand wrote:
> On 29.06.2018 13:31, Wei Wang wrote:
> > On 06/29/2018 03:46 PM, David Hildenbrand wrote:
> >>>
> >>> I'm afraid it can't. For example, when we have a guest booted,
> >>> without too many memory activities. Assume the guest has 8GB free
> >>> memory. The arch_free_page there won't be able to capture the 8GB
> >>> free pages since there is no free() called. This results in no free p=
ages
> reported to host.
> >>
> >> So, it takes some time from when the guest boots up until the balloon
> >> device was initialized and therefore page hinting can start. For that
> >> period, you won't get any arch_free_page()/page hinting callbacks, cor=
rect.
> >>
> >> However in the hypervisor, you can theoretically track which pages
> >> the guest actually touched ("dirty"), so you already know "which
> >> pages were never touched while booting up until virtio-balloon was
> >> brought to life". These, you can directly exclude from migration. No
> >> interface required.
> >>
> >> The remaining problem is pages that were touched ("allocated") by the
> >> guest during bootup but freed again, before virtio-balloon came up.
> >> One would have to measure how many pages these usually are, I would
> >> say it would not be that many (because recently freed pages are
> >> likely to be used again next for allocation). However, there are some
> >> pages not being reported.
> >>
> >> During the lifetime of the guest, this should not be a problem,
> >> eventually one of these pages would get allocated/freed again, so the
> >> problem "solves itself over time". You are looking into the special
> >> case of migrating the VM just after it has been started. But we have
> >> the exact same problem also for ordinary free page hinting, so we
> >> should rather solve that problem. It is not migration specific.
> >>
> >> If we are looking for an alternative to "problem solves itself",
> >> something like "if virtio-balloon comes up, it will report all free
> >> pages step by step using free page hinting, just like we would have
> >> from "arch_free_pages()"". This would be the same interface we are
> >> using for free page hinting - and it could even be made configurable i=
n the
> guest.
> >>
> >> The current approach we are discussing internally for details about
> >> Nitesh's work ("how the magic inside arch_fee_pages() will work
> >> efficiently) would allow this as far as I can see just fine.
> >>
> >> There would be a tiny little window between virtio-balloon comes up
> >> and it has reported all free pages step by step, but that can be
> >> considered a very special corner case that I would argue is not worth
> >> it to be optimized.
> >>
> >> If I am missing something important here, sorry in advance :)
> >>
> >
> > Probably I didn't explain that well. Please see my re-try:
> >
> > That work is to monitor page allocation and free activities via
> > arch_alloc_pages and arch_free_pages. It has per-CPU lists to record
> > the pages that are freed to the mm free list, and the per-CPU lists
> > dump the recorded pages to a global list when any of them is full.
> > So its own per-CPU list will only be able to get free pages when there
> > is an mm free() function gets called. If we have 8GB free memory on
> > the mm free list, but no application uses them and thus no mm free()
> > calls are made. In that case, the arch_free_pages isn't called, and no
> > free pages added to the per-CPU list, but we have 8G free memory right
> > on the mm free list.
> > How would you guarantee the per-CPU lists have got all the free pages
> > that the mm free lists have?
>=20
> As I said, if we have some mechanism that will scan the free pages (not
> arch_free_page() once and report hints using the same mechanism step by
> step (not your bulk interface)), this problem is solved. And as I said, t=
his is
> not a migration specific problem, we have the same problem in the current
> page hinting RFC. These pages have to be reported.
>=20
> >
> > - I'm also worried about the overhead of maintaining so many per-CPU
> > lists and the global list. For example, if we have applications
> > frequently allocate and free 4KB pages, and each per-CPU list needs to
> > implement the buddy algorithm to sort and merge neighbor pages. Today
> > a server can have more than 100 CPUs, then there will be more than 100
> > per-CPU lists which need to sync to a global list under a lock, I'm
> > not sure if this would scale well.
>=20
> The overhead in the current RFC is definitely too high. But I consider th=
is a
> problem to be solved before page hinting would go upstream. And we are
> discussing right now "if we have a reasonable page hinting implementation=
,
> why would we need your interface in addition".
>=20
> >
> > - This seems to be a burden imposed on the core mm memory
> > allocation/free path. The whole overhead needs to be carried during
> > the whole system life cycle. What we actually expected is to just make
> > one call to get the free page hints only when live migration happens.
>=20
> You're focusing too much on the actual implementation of the page hinting
> RFC right now. Assume for now that we would have
> - efficient page hinting without degrading other CPUs and little
>   overhead
> - a mechanism that solves reporting free pages once after we started up
>   virtio-balloon and actual free page hinting starts
>=20
> Why would your suggestion still be applicable?
>=20
> Your point for now is "I might not want to have page hinting enabled due =
to
> the overhead, but still a live migration speedup". If that overhead actua=
lly
> exists (we'll have to see) or there might be another reason to disable pa=
ge
> hinting, then we have to decide if that specific setup is worth it mergin=
g your
> changes.

All the above "if we have", "assume we have" don't sound like a valid argum=
ent to me.
=20
> I am not (and don't want to be) in the position to make any decisions her=
e :) I
> just want to understand if two interfaces for free pages actually make se=
nse.

I responded to Nitesh about the differences, you may want to check with him=
 about this.
I would suggest you to send out your patches to LKML to get a discussion wi=
th the mm folks.

Best,
Wei
