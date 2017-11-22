Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B89A6B0038
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 05:14:25 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id d14so9821828wrg.15
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 02:14:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 35si12416881edp.380.2017.11.22.02.14.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 02:14:23 -0800 (PST)
Date: Wed, 22 Nov 2017 11:14:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: migrate: fix an incorrect call of
 prep_transhuge_page()
Message-ID: <20171122101422.ny5tyyyje5dhx343@dhcp22.suse.cz>
References: <20171121021855.50525-1-zi.yan@sent.com>
 <20171122085416.ycrvahu2bznlx37s@dhcp22.suse.cz>
 <26CA724E-070E-4D06-B75E-F1880B1F2CF9@cs.rutgers.edu>
 <20171122093510.baxsmzvvid7c7yrq@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171122093510.baxsmzvvid7c7yrq@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Reale <ar@linux.vnet.ibm.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, stable@vger.kernel.org

On Wed 22-11-17 10:35:10, Michal Hocko wrote:
[...]
> Moreover I am not really sure this is really working properly. Just look
> at the split_huge_page. It moves all the tail pages to the LRU list
> while migrate_pages has a list of pages to migrate. So we will migrate
> the head page and all the rest will get back to the LRU list. What
> guarantees that they will get migrated as well.

OK, so this is as I've expected. It doesn't work! Some pfn walker based
migration will just skip tail pages see madvise_inject_error.
__alloc_contig_migrate_range will simply fail on THP page see
isolate_migratepages_block so we even do not try to migrate it.
do_move_page_to_node_array will simply migrate head and do not care
about tail pages. do_mbind splits the page and then fall back to pte
walk when thp migration is not supported but it doesn't handle tail
pages if the THP migration path is not able to allocate a fresh THP
AFAICS. Memory hotplug should be safe because it doesn't skip the whole
THP when doing pfn walk.

Unless I am missing something here this looks like a huge mess to me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
