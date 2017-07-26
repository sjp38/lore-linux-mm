Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D1F266B03A1
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:55:10 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a186so11167968wmh.9
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:55:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 36si12660559wrv.297.2017.07.26.04.55.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 04:55:09 -0700 (PDT)
Date: Wed, 26 Jul 2017 13:55:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v12 6/8] mm: support reporting free page blocks
Message-ID: <20170726115506.GM2981@dhcp22.suse.cz>
References: <20170724090042.GF25221@dhcp22.suse.cz>
 <59771010.6080108@intel.com>
 <20170725112513.GD26723@dhcp22.suse.cz>
 <597731E8.9040803@intel.com>
 <20170725124141.GF26723@dhcp22.suse.cz>
 <286AC319A985734F985F78AFA26841F739283F62@shsmsx102.ccr.corp.intel.com>
 <20170725145333.GK26723@dhcp22.suse.cz>
 <5977FCDF.7040606@intel.com>
 <20170726102458.GH2981@dhcp22.suse.cz>
 <59788097.6010402@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59788097.6010402@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On Wed 26-07-17 19:44:23, Wei Wang wrote:
[...]
> I thought about it more. Probably we can use the callback function with a
> little change like this:
> 
> void walk_free_mem(void *opaque1, void (*visit)(void *opaque2, unsigned long
> pfn,
>            unsigned long nr_pages))
> {
>     ...
>     for_each_populated_zone(zone) {
>                    for_each_migratetype_order(order, type) {
>                         report_unused_page_block(zone, order, type, &page);
> // from patch 6
>                         pfn = page_to_pfn(page);
>                         visit(opaque1, pfn, 1 << order);
>                     }
>     }
> }
> 
> The above function scans all the free list and directly sends each free page
> block to the
> hypervisor via the virtio_balloon callback below. No need to implement a
> bitmap.
> 
> In virtio-balloon, we have the callback:
> void *virtio_balloon_report_unused_pages(void *opaque,  unsigned long pfn,
> unsigned long nr_pages)
> {
>     struct virtio_balloon *vb = (struct virtio_balloon *)opaque;
>     ...put the free page block to the the ring of vb;
> }
> 
> 
> What do you think?

I do not mind conveying a context to the callback. I would still prefer
to keep the original min_order to check semantic though. Why? Well,
it doesn't make much sense to scan low order free blocks all the time
because they are simply too volatile. Larger blocks tend to surivive for
longer. So I assume you would only care about larger free blocks. This
will also make the call cheaper.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
