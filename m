Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFA00C4740A
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:30:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99F2A20863
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:30:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99F2A20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF5AE6B000D; Tue, 10 Sep 2019 06:30:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B36486B000A; Tue, 10 Sep 2019 06:30:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D43B6B000D; Tue, 10 Sep 2019 06:30:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0237.hostedemail.com [216.40.44.237])
	by kanga.kvack.org (Postfix) with ESMTP id 4AC1D6B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 06:30:52 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id ED647824376D
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:51 +0000 (UTC)
X-FDA: 75918642702.05.day08_41b1dd66ee735
X-HE-Tag: day08_41b1dd66ee735
X-Filterd-Recvd-Size: 4866
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:51 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 78914B11B;
	Tue, 10 Sep 2019 10:30:23 +0000 (UTC)
From: Oscar Salvador <osalvador@suse.de>
To: n-horiguchi@ah.jp.nec.com
Cc: mhocko@kernel.org,
	mike.kravetz@oracle.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 00/10] Hwpoison soft-offline rework
Date: Tue, 10 Sep 2019 12:30:06 +0200
Message-Id: <20190910103016.14290-1-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


This patchset was based on Naoya's hwpoison rework [1], so thanks to him
for the initial work.

This patchset aims to fix some issues laying in soft-offline handling,
but it also takes the chance and takes some further steps to perform 
cleanups and some refactoring as well.

 - Motivation:

   A customer and I were facing an issue where poisoned pages we returned
   back to user-space after having offlined them properly.
   This was only seend under some memory stress + soft offlining pages.
   After some anaylsis, it became clear that the problem was that
   when kcompactd kicked in to migrate pages over, compaction_alloc
   callback was handing poisoned pages to the migrate routine.
   Once this page was later on fault in, __do_page_fault returned
   VM_FAULT_HWPOISON making the process being killed.

   All this could happen because isolate_freepages_block and
   fast_isolate_freepages just check for the page to be PageBuddy,
   and since 1) poisoned pages can be part of a higher order page
   and 2) poisoned pages are also Page Buddy, they can sneak in easily.

   I also saw some problem with swap pages, but I suspected to be the
   same sort of problem, so I did not follow that trace.

   The full explanation can be see in [2].

 - Approach:

   The taken approach is to not let poisoned pages hit neither
   pcplists nor buddy freelists.
   This is achieved by:

In-use pages:

   * Normal pages

   1) do not release the last reference count after the
      invalidation/migration of the page.
   2) the page is being handed to page_set_poison, which does:
      2a) sets PageHWPoison flag
      2b) calls put_page (only to be able to call __page_cache_release)
          Since poisoned pages are skipped in free_pages_prepare,
          this put_page is safe.
      2c) Sets the refcount to 1
    
   * Hugetlb pages

   1) Hand the page to page_set_poison after migration
   2) page_set_poison does:
      2a) Calls dissolve_free_huge_page
      2b) If ranged to be dissolved contains poisoned pages,
          we free the rangeas order-0 pages (as we do with gigantic hugetlb page),
          so free_pages_prepare will skip them accordingly.
      2c) Sets the refcount to 1

Free pages:

   * Normal pages:

   1) Take the page off the buddy freelist
   2) Set PageHWPoison flag and set refcount to 1

   * Hugetlb pages

   1) Try to allocate a new hugetlb page to the pool
   2) Take off the pool the poisoned hugetlb


With this patchset, I no longer see the issues I faced before.

Note:
I presented this as RFC to open discussion of the taken aproach.
I think that furthers cleanups and refactors could be made, but I would
like to get some insight of the taken approach before touching more
code.

Thanks

[1] https://lore.kernel.org/linux-mm/1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com/
[2] https://lore.kernel.org/linux-mm/20190826104144.GA7849@linux/T/#u

Naoya Horiguchi (5):
  mm,hwpoison: cleanup unused PageHuge() check
  mm,madvise: call soft_offline_page() without MF_COUNT_INCREASED
  mm,hwpoison-inject: don't pin for hwpoison_filter
  mm,hwpoison: remove MF_COUNT_INCREASED
  mm: remove flag argument from soft offline functions

Oscar Salvador (5):
  mm,hwpoison: Unify THP handling for hard and soft offline
  mm,hwpoison: Rework soft offline for in-use pages
  mm,hwpoison: Refactor soft_offline_huge_page and __soft_offline_page
  mm,hwpoison: Rework soft offline for free pages
  mm,hwpoison: Use hugetlb_replace_page to replace free hugetlb pages

 drivers/base/memory.c      |   2 +-
 include/linux/mm.h         |   9 +-
 include/linux/page-flags.h |   5 -
 mm/hugetlb.c               |  51 +++++++-
 mm/hwpoison-inject.c       |  18 +--
 mm/madvise.c               |  25 ++--
 mm/memory-failure.c        | 319 +++++++++++++++++++++------------------------
 mm/migrate.c               |  11 +-
 mm/page_alloc.c            |  62 +++++++--
 9 files changed, 267 insertions(+), 235 deletions(-)

-- 
2.12.3


