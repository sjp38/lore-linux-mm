Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7C7176B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 03:05:21 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v31so11710045wrc.7
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 00:05:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 125si4314103wmy.54.2017.08.10.00.05.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 00:05:20 -0700 (PDT)
Date: Thu, 10 Aug 2017 09:05:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [virtio-dev] Re: [PATCH v13 4/5] mm: support reporting free page
 blocks
Message-ID: <20170810070517.GB23863@dhcp22.suse.cz>
References: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com>
 <1501742299-4369-5-git-send-email-wei.w.wang@intel.com>
 <20170803091151.GF12521@dhcp22.suse.cz>
 <59895668.9090104@intel.com>
 <59895B71.7050709@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59895B71.7050709@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mawilcox@microsoft.com, akpm@linux-foundation.org, virtio-dev@lists.oasis-open.org, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Tue 08-08-17 14:34:25, Wei Wang wrote:
> On 08/08/2017 02:12 PM, Wei Wang wrote:
> >On 08/03/2017 05:11 PM, Michal Hocko wrote:
> >>On Thu 03-08-17 14:38:18, Wei Wang wrote:
> >>This is just too ugly and wrong actually. Never provide struct page
> >>pointers outside of the zone->lock. What I've had in mind was to simply
> >>walk free lists of the suitable order and call the callback for each
> >>one.
> >>Something as simple as
> >>
> >>    for (i = 0; i < MAX_NR_ZONES; i++) {
> >>        struct zone *zone = &pgdat->node_zones[i];
> >>
> >>        if (!populated_zone(zone))
> >>            continue;
> >
> >Can we directly use for_each_populated_zone(zone) here?

yes, my example couldn't because I was still assuming per-node API

> >>spin_lock_irqsave(&zone->lock, flags);
> >>        for (order = min_order; order < MAX_ORDER; ++order) {
> >
> >
> >This appears to be covered by for_each_migratetype_order(order, mt) below.

yes but
#define for_each_migratetype_order(order, type) \
	for (order = 0; order < MAX_ORDER; order++) \
		for (type = 0; type < MIGRATE_TYPES; type++)

so you would have to skip orders < min_order
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
