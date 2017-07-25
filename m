Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3F8336B02C3
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 10:47:21 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u199so88159557pgb.13
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 07:47:21 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id k1si8147058pfj.645.2017.07.25.07.47.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 07:47:20 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v12 6/8] mm: support reporting free page blocks
Date: Tue, 25 Jul 2017 14:47:16 +0000
Message-ID: <286AC319A985734F985F78AFA26841F739283F62@shsmsx102.ccr.corp.intel.com>
References: <20170714123023.GA2624@dhcp22.suse.cz>
 <20170714181523-mutt-send-email-mst@kernel.org>
 <20170717152448.GN12888@dhcp22.suse.cz> <596D6E7E.4070700@intel.com>
 <20170719081311.GC26779@dhcp22.suse.cz> <596F4A0E.4010507@intel.com>
 <20170724090042.GF25221@dhcp22.suse.cz> <59771010.6080108@intel.com>
 <20170725112513.GD26723@dhcp22.suse.cz> <597731E8.9040803@intel.com>
 <20170725124141.GF26723@dhcp22.suse.cz>
In-Reply-To: <20170725124141.GF26723@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On Tuesday, July 25, 2017 8:42 PM, hal Hocko wrote:
> On Tue 25-07-17 19:56:24, Wei Wang wrote:
> > On 07/25/2017 07:25 PM, Michal Hocko wrote:
> > >On Tue 25-07-17 17:32:00, Wei Wang wrote:
> > >>On 07/24/2017 05:00 PM, Michal Hocko wrote:
> > >>>On Wed 19-07-17 20:01:18, Wei Wang wrote:
> > >>>>On 07/19/2017 04:13 PM, Michal Hocko wrote:
> > >>>[...
> > We don't need to do the pfn walk in the guest kernel. When the API
> > reports, for example, a 2MB free page block, the API caller offers to
> > the hypervisor the base address of the page block, and size=3D2MB, to
> > the hypervisor.
>=20
> So you want to skip pfn walks by regularly calling into the page allocato=
r to
> update your bitmap. If that is the case then would an API that would allo=
w you
> to update your bitmap via a callback be s sufficient? Something like
> 	void walk_free_mem(int node, int min_order,
> 			void (*visit)(unsigned long pfn, unsigned long nr_pages))
>=20
> The function will call the given callback for each free memory block on t=
he given
> node starting from the given min_order. The callback will be strictly an =
atomic
> and very light context. You can update your bitmap from there.

I would need to introduce more about the background here:
The hypervisor and the guest live in their own address space. The hyperviso=
r's bitmap
isn't seen by the guest. I think we also wouldn't be able to give a callbac=
k function=20
from the hypervisor to the guest in this case.

>=20
> This would address my main concern that the allocator internals would get
> outside of the allocator proper.=20

What issue would it have to expose the internal, for_each_zone()?
I think new code which would call it will also be strictly checked when the=
y
are pushed to upstream.

Best,
Wei



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
