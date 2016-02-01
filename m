Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id B5B856B0005
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 08:53:54 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l66so71346154wml.0
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 05:53:54 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id o11si39986118wjw.191.2016.02.01.05.53.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Feb 2016 05:53:53 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 0FD1098C54
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 13:53:53 +0000 (UTC)
Date: Mon, 1 Feb 2016 13:53:51 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC PATCH 0/2] avoid external fragmentation related to
 migration fallback
Message-ID: <20160201135351.GB8337@techsingularity.net>
References: <cover.1454094692.git.chengyihetaipei@gmail.com>
 <56ABD3B8.3080306@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <56ABD3B8.3080306@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: ChengYi He <chengyihetaipei@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Yaowei Bai <bywxiaobai@163.com>, Xishi Qiu <qiuxishi@huawei.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 29, 2016 at 10:03:52PM +0100, Vlastimil Babka wrote:
> > Since the root cause is that fallbacks might frequently split order-2
> > and order-3 pages of the other migration types. This patch tweaks
> > fallback mechanism to avoid splitting order-2 and order-3 pages. while
> > fallbacks happen, if the largest feasible pages are less than or queal to
> > COSTLY_ORDER, i.e. 3, then try to select the smallest feasible pages. The
> > reason why fallbacks prefer the largest feasiable pages is to increase
> > fallback efficiency since fallbacks are likely to happen again. By
> > stealing the largest feasible pages, it could reduce the oppourtunities
> > of antoher fallback. Besides, it could make consecutive allocations more
> > approximate to each other and make system less fragment. However, if the
> > largest feasible pages are less than or equal to order-3, fallbacks might
> > split it and make the upcoming order-3 page allocations fail.
> 
> In theory I don't see immediately why preferring smaller pages for
> fallback should be a clear win. If it's Unmovable allocations stealing
> from Movable pageblocks, the allocations will spread over larger areas
> instead of being grouped together. Maybe, for Movable allocations
> stealing from Unmovable allocations, preferring smallest might make
> sense and be safe, as any extra fragmentation is fixable bycompaction.

I strongly agree that spreading the fallback allocations over a larger
area is likely to have a negative impact. Given the age of the kernel
being tested, it would make sense to either rebase or at the very last
backport the patches that affect watermark calculations and the
treatment of high-order pages.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
