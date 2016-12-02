Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DA77F6B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 04:49:35 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id hb5so43873638wjc.2
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 01:49:35 -0800 (PST)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id j13si2211996wmf.109.2016.12.02.01.49.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 01:49:34 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 43F991C14BB
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 09:49:34 +0000 (GMT)
Date: Fri, 2 Dec 2016 09:49:33 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/2] mm, page_alloc: Keep pcp count and list contents in
 sync if struct page is corrupted
Message-ID: <20161202094933.jxcgvtth2poqdm3n@techsingularity.net>
References: <20161202002244.18453-1-mgorman@techsingularity.net>
 <20161202002244.18453-2-mgorman@techsingularity.net>
 <20161202081216.GA6830@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161202081216.GA6830@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Fri, Dec 02, 2016 at 09:12:17AM +0100, Michal Hocko wrote:
> On Fri 02-12-16 00:22:43, Mel Gorman wrote:
> > Vlastimil Babka pointed out that commit 479f854a207c ("mm, page_alloc:
> > defer debugging checks of pages allocated from the PCP") will allow the
> > per-cpu list counter to be out of sync with the per-cpu list contents
> > if a struct page is corrupted. This patch keeps the accounting in sync.
> >
> > Fixes: 479f854a207c ("mm, page_alloc: defer debugging checks of pages allocated from the PCP")
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > cc: stable@vger.kernel.org [4.7+]
> 
> I am trying to think about what would happen if we did go out of sync
> and cannot spot a problem. Vlastimil has mentioned something about
> free_pcppages_bulk looping for ever but I cannot see it happening right
> now.

free_pcppages_bulk can infinite loop if the page count is positive and
there are no pages. While I've only seen this during development, a
corrupted count loops here

                do {
                        batch_free++;
                        if (++pindex == NR_PCP_LISTS)
                                pindex = 0;
                        list = &pcp->lists[pindex];
                } while (list_empty(list));

It would only be seen in a situation where struct page corruption was
detected so it's rare.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
