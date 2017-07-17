Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 129666B02B4
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 11:24:53 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w126so5215373wme.10
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 08:24:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i18si11813323wra.141.2017.07.17.08.24.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 08:24:51 -0700 (PDT)
Date: Mon, 17 Jul 2017 17:24:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v12 6/8] mm: support reporting free page blocks
Message-ID: <20170717152448.GN12888@dhcp22.suse.cz>
References: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com>
 <1499863221-16206-7-git-send-email-wei.w.wang@intel.com>
 <20170714123023.GA2624@dhcp22.suse.cz>
 <20170714181523-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170714181523-mutt-send-email-mst@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Wei Wang <wei.w.wang@intel.com>, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Fri 14-07-17 22:17:13, Michael S. Tsirkin wrote:
> On Fri, Jul 14, 2017 at 02:30:23PM +0200, Michal Hocko wrote:
> > On Wed 12-07-17 20:40:19, Wei Wang wrote:
> > > This patch adds support for reporting blocks of pages on the free list
> > > specified by the caller.
> > > 
> > > As pages can leave the free list during this call or immediately
> > > afterwards, they are not guaranteed to be free after the function
> > > returns. The only guarantee this makes is that the page was on the free
> > > list at some point in time after the function has been invoked.
> > > 
> > > Therefore, it is not safe for caller to use any pages on the returned
> > > block or to discard data that is put there after the function returns.
> > > However, it is safe for caller to discard data that was in one of these
> > > pages before the function was invoked.
> > 
> > I do not understand what is the point of such a function and how it is
> > used because the patch doesn't give us any user (I haven't checked other
> > patches yet).
> > 
> > But just from the semantic point of view this sounds like a horrible
> > idea. The only way to get a free block of pages is to call the page
> > allocator. I am tempted to give it Nack right on those grounds but I
> > would like to hear more about what you actually want to achieve.
> 
> Basically it's a performance hint to the hypervisor.
> For example, these pages would be good candidates to
> move around as they are not mapped into any running
> applications.
>
> As such, it's important not to slow down other parts of the system too
> much - otherwise we are speeding up one part of the system while we slow
> down other parts of it, which is why it's trying to drop the lock as
> soon a possible.

So why cannot you simply allocate those page and then do whatever you
need. You can tell the page allocator to do only a lightweight
allocation by the gfp_mask - e.g. GFP_NOWAIT or if you even do not want
to risk kswapd intervening then 0 mask.

> As long as hypervisor does not assume it can drop these pages, and as
> long it's correct in most cases.  we are OK even if the hint is slightly
> wrong because hypervisor notifications are racing with allocations.

But the page could have been reused anytime after the lock is dropped
and you cannot check for that except for elevating the reference count.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
