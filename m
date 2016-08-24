Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5AFAA6B0038
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 04:21:03 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u81so7738259wmu.3
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 01:21:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p145si7837814wme.109.2016.08.24.01.21.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Aug 2016 01:21:02 -0700 (PDT)
Date: Wed, 24 Aug 2016 09:20:57 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: what is the purpose of SLAB and SLUB (was: Re: [PATCH v3]
 mm/slab: Improve performance of gathering slabinfo) stats
Message-ID: <20160824082057.GT2693@suse.de>
References: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com>
 <20160818115218.GJ30162@dhcp22.suse.cz>
 <20160823021303.GB17039@js1304-P5Q-DELUXE>
 <20160823153807.GN23577@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160823153807.GN23577@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>

On Tue, Aug 23, 2016 at 05:38:08PM +0200, Michal Hocko wrote:
> Do we have any documentation/study about which particular workloads
> benefit from which allocator? It seems that most users will use whatever
> the default or what their distribution uses. E.g. SLES kernel use SLAB
> because this is what we used to have for ages and there was no strong
> reason to change that default.

Yes, with the downside that a reliance on high-orders contended on the
zone lock which would not scale and could degrade over time. If there
were multiple compelling reasons then it would have been an easier
switch.

I did prototype high-order pcp caching up to PAGE_ALLOC_COSTLY_ORDER
but it pushed the size of per_cpu_pages over a cache line which could
be problematic in itself. I never finished off the work as fixing the
allocator for SLUB was not a priority. The prototype no longer applies as
it conflicts with the removal of the fair zone allocation policy.

If/when I get back to the page allocator, the priority would be a bulk
API for faster allocs of batches of order-0 pages instead of allocating
a large page and splitting.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
