Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA8F6B0315
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 04:24:14 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x23so1849630wrb.6
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 01:24:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v200si2671503wmv.51.2017.06.15.01.24.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Jun 2017 01:24:13 -0700 (PDT)
Date: Thu, 15 Jun 2017 10:24:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, memory_hotplug: support movable_node for hotplugable
 nodes
Message-ID: <20170615082410.GE1486@dhcp22.suse.cz>
References: <20170608122318.31598-1-mhocko@kernel.org>
 <20170615032927.GA17971@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170615032927.GA17971@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 15-06-17 11:29:27, Wei Yang wrote:
[...]
> >+static inline bool movable_pfn_range(int nid, struct zone *default_zone,
> >+		unsigned long start_pfn, unsigned long nr_pages)
> >+{
> >+	if (!allow_online_pfn_range(nid, start_pfn, nr_pages,
> >+				MMOP_ONLINE_KERNEL))
> >+		return true;
> >+
> >+	if (!movable_node_is_enabled())
> >+		return false;
> >+
> >+	return !zone_intersects(default_zone, start_pfn, nr_pages);
> >+}
> >+
> 
> To be honest, I don't understand this clearly.
> 
> move_pfn_range() will choose and move the range to a zone based on the
> online_type, where we have two cases:
> 1. ONLINE_MOVABLE -> ZONE_MOVABLE will be chosen
> 2. ONLINE_KEEP    -> ZONE_NORMAL is the default while ZONE_MOVABLE will be
> chosen in case movable_pfn_range() returns true.
> 
> There are three conditions in movable_pfn_range():
> 1. Not allowed in kernel_zone, returns true
> 2. Movable_node not enabled, return false 
> 3. Range [start_pfn, start_pfn + nr_pages) doesn't intersect with
> default_zone, return true
> 
> The first one is inherited from original code, so lets look at the other two.
> 
> Number 3 is easy to understand, if the hot-added range is already part of
> ZONE_NORMAL, use it.
> 
> Number 2 makes me confused. If movable_node is not enabled, ZONE_NORMAL will
> be chosen. If movable_node is enabled, it still depends on other two
> condition. So how a memory_block is onlined to ZONE_MOVABLE because
> movable_node is enabled?

This is simple. If the movable_node is set then ONLINE_KEEP defaults to
the movable zone unless the range is already covered by a kernel zone
(read Normal zone most of the time).

> What I see is you would forbid a memory_block to be
> onlined to ZONE_MOVABLE when movable_node is not enabled.

Please note that this is ONLINE_KEEP not ONLINE_MOVABLE and as such the
movable zone is used only if we are withing the movable zone range
already (test 1).

> Instead of you would
> online a memory_block to ZONE_MOVABLE when movable_node is enabled, which is
> implied in your change log.
> 
> BTW, would you mind giving me these two information?
> 1. Which branch your code is based on? I have cloned your
> git(//git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git), while still see
> some difference.

yes this is based on the mmotm tree (use since-4.11 or auto-latest
branch)

> 2. Any example or test case I could try your patch and see the difference? It
> would be better if it could run in qemu+kvm.

See http://lkml.kernel.org/r/20170421120512.23960-1-mhocko@kernel.org
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
