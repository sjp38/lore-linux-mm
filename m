Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id E9E2C6B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 10:16:58 -0400 (EDT)
Date: Thu, 2 Aug 2012 16:16:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -mm] mm: hugetlbfs: Correctly populate shared pmd
Message-ID: <20120802141656.GB18084@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

Hi Andrew,
the following patch fixes yet-another race in the hugetlb pte sharing
code reported by Larry. It is based on top of the current -mm tree but
it cleanly applies to linus tree as well. It should go to stable as
well. The bug is there for ages but this fix is possible only since 3.0
because i_mmap_lock used to be a spinlock until 3d48ae45 which turned it
into mutex and so we can call pmd_alloc.
There was another candidate for the same issue by Mel
(https://lkml.org/lkml/2012/7/31/275) but we considered this one to be
better because it is more focused on the arch specific code and it also
highers chances for sharing.
---
