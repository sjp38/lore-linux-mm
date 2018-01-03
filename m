Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C715A6B031D
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 04:32:27 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q186so439472pga.23
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 01:32:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m8sor177091plt.148.2018.01.03.01.32.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 01:32:26 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/6] mm, hugetlb: allocation API and migration improvements
Date: Wed,  3 Jan 2018 10:32:07 +0100
Message-Id: <20180103093213.26329-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

Hi,
I've posted this as an RFC [1] and both Mike and Naoya seem to be OK
both with patches and the approach. I have rebased this on top of [2]
because there is a small conflict in mm/mempolicy.c. I know it is late
in the release cycle but similarly to [2] I would really like to see
this in linux-next for a longer time for a wider testing exposure.

Motivation:
this is a follow up for [3] for the allocation API and [4] for the
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
Michal Hocko (6):
      mm, hugetlb: unify core page allocation accounting and initialization
      mm, hugetlb: integrate giga hugetlb more naturally to the allocation path
      mm, hugetlb: do not rely on overcommit limit during migration
      mm, hugetlb: get rid of surplus page accounting tricks
      mm, hugetlb: further simplify hugetlb allocation API
      hugetlb, mempolicy: fix the mbind hugetlb migration

Diffstat:
 include/linux/hugetlb.h |   8 +-
 mm/hugetlb.c            | 338 +++++++++++++++++++++++++++---------------------
 mm/mempolicy.c          |   3 +-
 mm/migrate.c            |   3 +-
 4 files changed, 198 insertions(+), 154 deletions(-)


[1] http://lkml.kernel.org/r/20171204140117.7191-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20180103082555.14592-1-mhocko@kernel.org
[3] http://lkml.kernel.org/r/20170622193034.28972-1-mhocko@kernel.org
[4] http://lkml.kernel.org/r/20171122152832.iayefrlxbugphorp@dhcp22.suse.cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
