Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1B2EC6B026E
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 09:01:29 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id l33so10353035wrl.5
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 06:01:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m123sor1932196wme.17.2017.12.04.06.01.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Dec 2017 06:01:27 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 0/5] mm, hugetlb: allocation API and migration improvements
Date: Mon,  4 Dec 2017 15:01:12 +0100
Message-Id: <20171204140117.7191-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi,
this is a follow up for [1] for the allocation API and [2] for the
hugetlb migration. It wasn't really easy to split those into two
separate patch series as they share some code.

My primary motivation to touch this code is to make the gigantic pages
migration working. The giga pages allocation code is just too fragile
and hacked into the hugetlb code now. This series tries to move giga
pages closer to the first class citizen. We are not there yet but having
5 patches is quite a lot already and it will already make the code much
easier to follow. I will come with other changes on top after this sees
some review.

The first two patches should be trivial to review. The third patch
changes the way how we migrate huge pages. Newly allocated pages are a
subject of the overcommit check and they participate surplus accounting
which is quite unfortunate as the changelog explains. This patch doesn't
change anything wrt. giga pages.
Patch #4 removes the surplus accounting hack from
__alloc_surplus_huge_page.  I hope I didn't miss anything there and a
deeper review is really due there.
Patch #5 finally unifies allocation paths and giga pages shouldn't be
any special anymore. There is also some renaming going on as well.

Shortlog
Michal Hocko (5):
      mm, hugetlb: unify core page allocation accounting and initialization
      mm, hugetlb: integrate giga hugetlb more naturally to the allocation path
      mm, hugetlb: do not rely on overcommit limit during migration
      mm, hugetlb: get rid of surplus page accounting tricks
      mm, hugetlb: further simplify hugetlb allocation API

Diffstat:
 include/linux/hugetlb.h |   3 +
 mm/hugetlb.c            | 305 +++++++++++++++++++++++++++---------------------
 mm/migrate.c            |   3 +-
 3 files changed, 175 insertions(+), 136 deletions(-)


[1] http://lkml.kernel.org/r/20170622193034.28972-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20171122152832.iayefrlxbugphorp@dhcp22.suse.cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
