Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id DE6596B05B3
	for <linux-mm@kvack.org>; Sun, 30 Jul 2017 12:18:42 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id c2so41099192qkb.10
        for <linux-mm@kvack.org>; Sun, 30 Jul 2017 09:18:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l2si15751995qtf.200.2017.07.30.09.18.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Jul 2017 09:18:42 -0700 (PDT)
Date: Sun, 30 Jul 2017 19:18:33 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v12 5/8] virtio-balloon: VIRTIO_BALLOON_F_SG
Message-ID: <20170730191735-mutt-send-email-mst@kernel.org>
References: <20170713210819-mutt-send-email-mst@kernel.org>
 <59686EEB.8080805@intel.com>
 <20170723044036-mutt-send-email-mst@kernel.org>
 <59781119.8010200@intel.com>
 <20170726155856-mutt-send-email-mst@kernel.org>
 <597954E3.2070801@intel.com>
 <20170729020231-mutt-send-email-mst@kernel.org>
 <597C83CC.7060702@intel.com>
 <20170730043922-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F739288D85@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <286AC319A985734F985F78AFA26841F739288D85@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Wei W" <wei.w.wang@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On Sun, Jul 30, 2017 at 05:59:17AM +0000, Wang, Wei W wrote:
> On Sunday, July 30, 2017 12:23 PM, Michael S. Tsirkin wrote:
> > On Sat, Jul 29, 2017 at 08:47:08PM +0800, Wei Wang wrote:
> > > On 07/29/2017 07:08 AM, Michael S. Tsirkin wrote:
> > > > On Thu, Jul 27, 2017 at 10:50:11AM +0800, Wei Wang wrote:
> > > > > > > > OK I thought this over. While we might need these new APIs
> > > > > > > > in the future, I think that at the moment, there's a way to
> > > > > > > > implement this feature that is significantly simpler. Just
> > > > > > > > add each s/g as a separate input buffer.
> > > > > > > Should it be an output buffer?
> > > > > > Hypervisor overwrites these pages with zeroes. Therefore it is
> > > > > > writeable by device: DMA_FROM_DEVICE.
> > > > > Why would the hypervisor need to zero the buffer?
> > > > The page is supplied to hypervisor and can lose the value that is
> > > > there.  That is the definition of writeable by device.
> > >
> > > I think for the free pages, it should be clear that they will be added
> > > as output buffer to the device, because (as we discussed) they are
> > > just hints, and some of them may be used by the guest after the report_ API is
> > invoked.
> > > The device/hypervisor should not use or discard them.
> > 
> > Discarding contents is exactly what you propose doing if migration is going on,
> > isn't it?
> 
> That's actually a different concept. Please let me explain it with this example:
> 
> The hypervisor receives the hint saying the guest PageX is a free page, but as we know, 
> after that report_ API exits, the guest kernel may take PageX to use, so PageX is not free
> page any more. At this time, if the hypervisor writes to the page, that would crash the guest.
> So, I think the cornerstone of this work is that the hypervisor should not touch the
> reported pages.
> 
> Best,
> Wei    

That's a hypervisor implementation detail. From guest point of view,
discarding contents can not be distinguished from writing old contents.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
