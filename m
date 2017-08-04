Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2171F6B0725
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 04:24:26 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p43so4977557wrb.6
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 01:24:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y10si3041706wry.96.2017.08.04.01.24.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Aug 2017 01:24:24 -0700 (PDT)
Date: Fri, 4 Aug 2017 10:24:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v13 4/5] mm: support reporting free page blocks
Message-ID: <20170804082423.GG26029@dhcp22.suse.cz>
References: <59830897.2060203@intel.com>
 <20170803112831.GN12521@dhcp22.suse.cz>
 <5983130E.2070806@intel.com>
 <20170803124106.GR12521@dhcp22.suse.cz>
 <59832265.1040805@intel.com>
 <20170803135047.GV12521@dhcp22.suse.cz>
 <286AC319A985734F985F78AFA26841F73928C971@shsmsx102.ccr.corp.intel.com>
 <20170804000043-mutt-send-email-mst@kernel.org>
 <20170804075337.GC26029@dhcp22.suse.cz>
 <59842D1C.5020608@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59842D1C.5020608@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On Fri 04-08-17 16:15:24, Wei Wang wrote:
> On 08/04/2017 03:53 PM, Michal Hocko wrote:
> >On Fri 04-08-17 00:02:01, Michael S. Tsirkin wrote:
> >>On Thu, Aug 03, 2017 at 03:20:09PM +0000, Wang, Wei W wrote:
> >>>On Thursday, August 3, 2017 9:51 PM, Michal Hocko:
> >>>>As I've said earlier. Start simple optimize incrementally with some numbers to
> >>>>justify a more subtle code.
> >>>>--
> >>>OK. Let's start with the simple implementation as you suggested.
> >>>
> >>>Best,
> >>>Wei
> >>The tricky part is when you need to drop the lock and
> >>then restart because the device is busy. Would it maybe
> >>make sense to rotate the list so that new head
> >>will consist of pages not yet sent to device?
> >No, I this should be strictly non-modifying API.
> 
> 
> Just get the context here for discussion:
> 
>     spin_lock_irqsave(&zone->lock, flags);
>     ...
>     visit(opaque2, pfn, 1<<order);
>     spin_unlock_irqrestore(&zone->lock, flags);
> 
> The concern is that the callback may cause the lock be
> taken too long.
> 
> 
> I think here we can have two options:
> - Option 1: Put a Note for the callback: the callback function
>     should not block and it should finish as soon as possible.
>     (when implementing an interrupt handler, we also have
>     such similar rules in mind, right?).

absolutely

> For our use case, the callback just puts the reported page
> block to the ring, then returns. If the ring is full as the host
> is busy, then I think it should skip this one, and just return.
> Because:
>     A. This is an optimization feature, losing a couple of free
>          pages to report isn't that important;
>     B. In reality, I think it's uncommon to see this ring getting
>         full (I didn't observe ring full in the tests), since the host
>         (consumer) is notified to take out the page block right
>         after it is added.

I thought you only updated a pre allocated bitmat... Anyway, I cannot
comment on this part much as I am not familiar with your usecase.
 
> - Option 2: Put the callback function outside the lock
>     What's input into the callback is just a pfn, and the callback
>     won't access the corresponding pages. So, I still think it won't
>     be an issue no matter what status of the pages is after they
>     are reported (even they doesn't exit due to hot-remove).

This would make the API implementation more complex and I am not yet
convinced we really need that.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
