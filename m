Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7458C6B02A4
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 10:28:36 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id s75so16415342pgs.12
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 07:28:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 32si14051895plg.75.2017.11.22.07.28.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 07:28:35 -0800 (PST)
Date: Wed, 22 Nov 2017 16:28:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: hugetlb page migration vs. overcommit
Message-ID: <20171122152832.iayefrlxbugphorp@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

Hi,
is there any reason why we enforce the overcommit limit during hugetlb
pages migration? It's in alloc_huge_page_node->__alloc_buddy_huge_page
path. I am wondering whether this is really an intentional behavior.
The page migration allocates a page just temporarily so we should be
able to go over the overcommit limit for the migration duration. The
reason I am asking is that hugetlb pages tend to be utilized usually
(otherwise the memory would be just wasted and pool shrunk) but then
the migration simply fails which breaks memory hotplug and other
migration dependent functionality which is quite suboptimal. You can
workaround that by increasing the overcommit limit.

Why don't we simply migrate as long as we are able to allocate the
target hugetlb page? I have a half baked patch to remove this
restriction, would there be an opposition to do something like that?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
