Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 43BB76B02C3
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 12:15:52 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id q1so10992407qkb.3
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 09:15:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r74si1950723qka.21.2017.07.20.09.15.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 09:15:51 -0700 (PDT)
Date: Thu, 20 Jul 2017 18:15:45 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mm, something wrong in page_lock_anon_vma_read()?
Message-ID: <20170720161545.GD29716@redhat.com>
References: <591FB173.4020409@huawei.com>
 <a94c202d-7d9f-0a62-3049-9f825a1db50d@suse.cz>
 <5923FF31.5020801@huawei.com>
 <aea91199-2b40-85fd-8c93-2d807ed726bd@suse.cz>
 <593954BD.9060703@huawei.com>
 <e8dacd42-e5c5-998b-5f9a-a34dbfb986f1@suse.cz>
 <596DEA07.5000009@huawei.com>
 <24bd80c6-1bb7-c8b8-2acf-b91e5e10dbb1@suse.cz>
 <596F2D65.8020902@huawei.com>
 <20170720125835.GC29716@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170720125835.GC29716@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, zhong jiang <zhongjiang@huawei.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, sumeet.keswani@hpe.com, Rik van Riel <riel@redhat.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 20, 2017 at 02:58:35PM +0200, Andrea Arcangeli wrote:
> but if zap_pte in a fremap fails to drop the anon page that was under
> memory migration/compaction the exact same thing will happen. Either

... except it is ok to clear a migration entry, it will be migration
that will free the new page after migration completes, zap_pte doesn't
need to wait. So this fix is good, but I was too optimistic about its
ability to explain the whole problem. It only can explain Rss cosmetic
errors, not a anon page left hanging around after its anon vma has
been freed.

About the theory this could be THP related, the Rss stats being off by
one as symptom of the bug, don't seem to point in that direction, all
complex THP operations don't mess with the rss or they tend to act in
blocks of 512. Furthermore the BZ already confirmed it can be
reproduced with THP disabled. Said that it also was supposedly already
fixed by the various patches you manually backported to your build.

I believe for fairness (mailing list traffic etc..) it's be preferable
to continue the debugging in the open BZ and not here because you
didn't reproduce it on a upstraem kernel yet so we cannot be 100% sure
if upstream (if only -stable) could reproduce it.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
