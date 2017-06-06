Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E89E76B02F3
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 12:17:35 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n81so35331703pfb.14
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 09:17:35 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id i13si8311681plk.72.2017.06.06.09.17.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 09:17:35 -0700 (PDT)
Subject: Re: [RFC] mm,drm/i915: Mark pinned shmemfs pages as unevictable
References: <20170606120436.8683-1-chris@chris-wilson.co.uk>
 <20170606121418.GM1189@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <2a23dabf-54b4-451f-fec4-5cd1dba92719@intel.com>
Date: Tue, 6 Jun 2017 09:17:12 -0700
MIME-Version: 1.0
In-Reply-To: <20170606121418.GM1189@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Matthew Auld <matthew.auld@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>

On 06/06/2017 05:14 AM, Michal Hocko wrote:
> On Tue 06-06-17 13:04:36, Chris Wilson wrote:
>> Similar in principle to the treatment of get_user_pages, pages that
>> i915.ko acquires from shmemfs are not immediately reclaimable and so
>> should be excluded from the mm accounting and vmscan until they have
>> been returned to the system via shrink_slab/i915_gem_shrink. By moving
>> the unreclaimable pages off the inactive anon lru, not only should
>> vmscan be improved by avoiding walking unreclaimable pages, but the
>> system should also have a better idea of how much memory it can reclaim
>> at that moment in time.
> That is certainly desirable. Peter has proposed a generic pin_page (or
> similar) API. What happened with it? I think it would be a better
> approach than (ab)using mlock API. I am also not familiar with the i915
> code to be sure that using lock_page is really safe here. I think that
> all we need is to simply move those pages in/out to/from unevictable LRU
> list on pin/unpining.

Yes, very true.  I just suggested mlock'ing them because it was the
simplest way to get page_evictable() to return true.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
