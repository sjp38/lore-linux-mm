Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 551196B0313
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 06:25:04 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g32so6888581wrd.8
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 03:25:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a186si5469595wmd.270.2017.07.26.03.25.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 03:25:03 -0700 (PDT)
Date: Wed, 26 Jul 2017 12:24:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v12 6/8] mm: support reporting free page blocks
Message-ID: <20170726102458.GH2981@dhcp22.suse.cz>
References: <20170719081311.GC26779@dhcp22.suse.cz>
 <596F4A0E.4010507@intel.com>
 <20170724090042.GF25221@dhcp22.suse.cz>
 <59771010.6080108@intel.com>
 <20170725112513.GD26723@dhcp22.suse.cz>
 <597731E8.9040803@intel.com>
 <20170725124141.GF26723@dhcp22.suse.cz>
 <286AC319A985734F985F78AFA26841F739283F62@shsmsx102.ccr.corp.intel.com>
 <20170725145333.GK26723@dhcp22.suse.cz>
 <5977FCDF.7040606@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5977FCDF.7040606@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On Wed 26-07-17 10:22:23, Wei Wang wrote:
> On 07/25/2017 10:53 PM, Michal Hocko wrote:
> >On Tue 25-07-17 14:47:16, Wang, Wei W wrote:
> >>On Tuesday, July 25, 2017 8:42 PM, hal Hocko wrote:
> >>>On Tue 25-07-17 19:56:24, Wei Wang wrote:
> >>>>On 07/25/2017 07:25 PM, Michal Hocko wrote:
> >>>>>On Tue 25-07-17 17:32:00, Wei Wang wrote:
> >>>>>>On 07/24/2017 05:00 PM, Michal Hocko wrote:
> >>>>>>>On Wed 19-07-17 20:01:18, Wei Wang wrote:
> >>>>>>>>On 07/19/2017 04:13 PM, Michal Hocko wrote:
> >>>>>>>[...
> >>>>We don't need to do the pfn walk in the guest kernel. When the API
> >>>>reports, for example, a 2MB free page block, the API caller offers to
> >>>>the hypervisor the base address of the page block, and size=2MB, to
> >>>>the hypervisor.
> >>>So you want to skip pfn walks by regularly calling into the page allocator to
> >>>update your bitmap. If that is the case then would an API that would allow you
> >>>to update your bitmap via a callback be s sufficient? Something like
> >>>	void walk_free_mem(int node, int min_order,
> >>>			void (*visit)(unsigned long pfn, unsigned long nr_pages))
> >>>
> >>>The function will call the given callback for each free memory block on the given
> >>>node starting from the given min_order. The callback will be strictly an atomic
> >>>and very light context. You can update your bitmap from there.
> >>I would need to introduce more about the background here:
> >>The hypervisor and the guest live in their own address space. The hypervisor's bitmap
> >>isn't seen by the guest. I think we also wouldn't be able to give a callback function
> >>from the hypervisor to the guest in this case.
> >How did you plan to use your original API which export struct page array
> >then?
> 
> 
> That's where the virtio-balloon driver comes in. It uses a shared ring
> mechanism to
> send the guest memory info to the hypervisor.
> 
> We didn't expose the struct page array from the guest to the hypervisor. For
> example, when
> a 2MB free page block is reported from the free page list, the info put on
> the ring is just
> (base address of the 2MB continuous memory, size=2M).

So what exactly prevents virtio-balloon from using the above proposed
callback mechanism and export what is needed to the hypervisor?
 
> >>>This would address my main concern that the allocator internals would get
> >>>outside of the allocator proper.
> >>What issue would it have to expose the internal, for_each_zone()?
> >zone is a MM internal concept. No code outside of the MM proper should
> >really care about zones.
> 
> I think this is also what Andrew suggested in the previous discussion:
> https://lkml.org/lkml/2017/3/16/951
> 
> Move the code to virtio-balloon and a little layering violation seems
> acceptable.

Andrew didn't suggest to expose zones to modules. If I read his words
properly he said that a functionality which "provides a snapshot of the
present system unused pages" is just too specific for virtio usecase
to be a generic function and as such it should be in virtio. I tend
to agree. Even the proposed callback API is a layer violation. We
should just make sure that the API is not inherently dangerous. That
is why I have chosen to give only pfn and nr_pages to the caller. Sure
somebody could argue that the caller could do pfn_to_page and do nasty
things. That would be a fair argument but nothing really prevents
anybody to do th pfn walk already so there shouldn't inherently more
risk. We can document what we expect from the API user and that would be
much easier to describe than struct page API IMHO.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
