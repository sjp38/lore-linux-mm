Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C23F6B02FA
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 10:53:41 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w63so28624331wrc.5
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 07:53:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i65si7976740wme.37.2017.07.25.07.53.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Jul 2017 07:53:40 -0700 (PDT)
Date: Tue, 25 Jul 2017 16:53:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v12 6/8] mm: support reporting free page blocks
Message-ID: <20170725145333.GK26723@dhcp22.suse.cz>
References: <20170717152448.GN12888@dhcp22.suse.cz>
 <596D6E7E.4070700@intel.com>
 <20170719081311.GC26779@dhcp22.suse.cz>
 <596F4A0E.4010507@intel.com>
 <20170724090042.GF25221@dhcp22.suse.cz>
 <59771010.6080108@intel.com>
 <20170725112513.GD26723@dhcp22.suse.cz>
 <597731E8.9040803@intel.com>
 <20170725124141.GF26723@dhcp22.suse.cz>
 <286AC319A985734F985F78AFA26841F739283F62@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <286AC319A985734F985F78AFA26841F739283F62@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Wei W" <wei.w.wang@intel.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On Tue 25-07-17 14:47:16, Wang, Wei W wrote:
> On Tuesday, July 25, 2017 8:42 PM, hal Hocko wrote:
> > On Tue 25-07-17 19:56:24, Wei Wang wrote:
> > > On 07/25/2017 07:25 PM, Michal Hocko wrote:
> > > >On Tue 25-07-17 17:32:00, Wei Wang wrote:
> > > >>On 07/24/2017 05:00 PM, Michal Hocko wrote:
> > > >>>On Wed 19-07-17 20:01:18, Wei Wang wrote:
> > > >>>>On 07/19/2017 04:13 PM, Michal Hocko wrote:
> > > >>>[...
> > > We don't need to do the pfn walk in the guest kernel. When the API
> > > reports, for example, a 2MB free page block, the API caller offers to
> > > the hypervisor the base address of the page block, and size=2MB, to
> > > the hypervisor.
> > 
> > So you want to skip pfn walks by regularly calling into the page allocator to
> > update your bitmap. If that is the case then would an API that would allow you
> > to update your bitmap via a callback be s sufficient? Something like
> > 	void walk_free_mem(int node, int min_order,
> > 			void (*visit)(unsigned long pfn, unsigned long nr_pages))
> > 
> > The function will call the given callback for each free memory block on the given
> > node starting from the given min_order. The callback will be strictly an atomic
> > and very light context. You can update your bitmap from there.
> 
> I would need to introduce more about the background here:
> The hypervisor and the guest live in their own address space. The hypervisor's bitmap
> isn't seen by the guest. I think we also wouldn't be able to give a callback function 
> from the hypervisor to the guest in this case.

How did you plan to use your original API which export struct page array
then?

> > This would address my main concern that the allocator internals would get
> > outside of the allocator proper. 
> 
> What issue would it have to expose the internal, for_each_zone()?

zone is a MM internal concept. No code outside of the MM proper should
really care about zones. 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
