Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0966B0005
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:53:15 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j8-v6so4697497pfn.6
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 08:53:15 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id f7-v6si9789618plb.253.2018.06.29.08.53.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 08:53:13 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v34 0/4] Virtio-balloon: support free page reporting
Date: Fri, 29 Jun 2018 15:52:40 +0000
Message-ID: <286AC319A985734F985F78AFA26841F7396C251E@shsmsx102.ccr.corp.intel.com>
References: <1529928312-30500-1-git-send-email-wei.w.wang@intel.com>
 <c4dd0a13-91fb-c0f5-b41f-54421fdacca9@redhat.com>
 <20180629172216-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180629172216-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>, David Hildenbrand <david@redhat.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu0@gmail.com" <quan.xu0@gmail.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "peterx@redhat.com" <peterx@redhat.com>

On Friday, June 29, 2018 10:46 PM, Michael S. Tsirkin wrote:
> To: David Hildenbrand <david@redhat.com>
> Cc: Wang, Wei W <wei.w.wang@intel.com>; virtio-dev@lists.oasis-open.org;
> linux-kernel@vger.kernel.org; virtualization@lists.linux-foundation.org;
> kvm@vger.kernel.org; linux-mm@kvack.org; mhocko@kernel.org;
> akpm@linux-foundation.org; torvalds@linux-foundation.org;
> pbonzini@redhat.com; liliang.opensource@gmail.com;
> yang.zhang.wz@gmail.com; quan.xu0@gmail.com; nilal@redhat.com;
> riel@redhat.com; peterx@redhat.com
> Subject: Re: [PATCH v34 0/4] Virtio-balloon: support free page reporting
>=20
> On Wed, Jun 27, 2018 at 01:06:32PM +0200, David Hildenbrand wrote:
> > On 25.06.2018 14:05, Wei Wang wrote:
> > > This patch series is separated from the previous "Virtio-balloon
> > > Enhancement" series. The new feature,
> > > VIRTIO_BALLOON_F_FREE_PAGE_HINT, implemented by this series
> enables
> > > the virtio-balloon driver to report hints of guest free pages to the
> > > host. It can be used to accelerate live migration of VMs. Here is an
> introduction of this usage:
> > >
> > > Live migration needs to transfer the VM's memory from the source
> > > machine to the destination round by round. For the 1st round, all
> > > the VM's memory is transferred. From the 2nd round, only the pieces
> > > of memory that were written by the guest (after the 1st round) are
> > > transferred. One method that is popularly used by the hypervisor to
> > > track which part of memory is written is to write-protect all the gue=
st
> memory.
> > >
> > > This feature enables the optimization by skipping the transfer of
> > > guest free pages during VM live migration. It is not concerned that
> > > the memory pages are used after they are given to the hypervisor as
> > > a hint of the free pages, because they will be tracked by the
> > > hypervisor and transferred in the subsequent round if they are used a=
nd
> written.
> > >
> > > * Tests
> > > - Test Environment
> > >     Host: Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz
> > >     Guest: 8G RAM, 4 vCPU
> > >     Migration setup: migrate_set_speed 100G, migrate_set_downtime 2
> > > second
> > >
> > > - Test Results
> > >     - Idle Guest Live Migration Time (results are averaged over 10 ru=
ns):
> > >         - Optimization v.s. Legacy =3D 284ms vs 1757ms --> ~84% reduc=
tion
> > >     - Guest with Linux Compilation Workload (make bzImage -j4):
> > >         - Live Migration Time (average)
> > >           Optimization v.s. Legacy =3D 1402ms v.s. 2528ms --> ~44% re=
duction
> > >         - Linux Compilation Time
> > >           Optimization v.s. Legacy =3D 5min6s v.s. 5min12s
> > >           --> no obvious difference
> > >
> >
> > Being in version 34 already, this whole thing still looks and feels
> > like a big hack to me. It might just be me, but especially if I read
> > about assumptions like "QEMU will not hotplug memory during
> > migration". This does not feel like a clean solution.
> >
> > I am still not sure if we really need this interface, especially as
> > real free page hinting might be on its way.
> >
> > a) we perform free page hinting by setting all free pages
> > (arch_free_page()) to zero. Migration will detect zero pages and
> > minimize #pages to migrate. I don't think this is a good idea but
> > Michel suggested to do a performance evaluation and Nitesh is looking
> > into that right now.
>=20
> Yes this test is needed I think. If we can get most of the benefit withou=
t PV
> interfaces, that's nice.
>=20
> Wei, I think you need this as part of your performance comparison
> too: set page poisoning value to 0 and enable KSM, compare with your
> patches.

Do you mean live migration with zero pages?
I can first share the amount of memory transferred during live migration I =
saw,
Legacy is around 380MB,
Optimization is around 340MB.
This proves that most pages have already been 0 and skipped during the lega=
cy live migration. But the legacy time is still much larger because zero pa=
ge checking is costly.=20
(It's late night here, I can get you that with my server probably tomorrow)

Best,
Wei
