Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F5E3C3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 10:41:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F05720828
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 10:41:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F05720828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB67C6B055D; Mon, 26 Aug 2019 06:41:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8D316B055F; Mon, 26 Aug 2019 06:41:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7C506B0560; Mon, 26 Aug 2019 06:41:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0117.hostedemail.com [216.40.44.117])
	by kanga.kvack.org (Postfix) with ESMTP id A23966B055D
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 06:41:56 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 3B0A8441E
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 10:41:56 +0000 (UTC)
X-FDA: 75864238632.18.snow18_10dc4805fa951
X-HE-Tag: snow18_10dc4805fa951
X-Filterd-Recvd-Size: 3543
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 10:41:55 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2D3E9AF8D;
	Mon, 26 Aug 2019 10:41:53 +0000 (UTC)
Date: Mon, 26 Aug 2019 12:41:50 +0200
From: Oscar Salvador <osalvador@suse.de>
To: n-horiguchi@ah.jp.nec.com
Cc: mhocko@kernel.org, mike.kravetz@oracle.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, vbabka@suse.cz
Subject: poisoned pages do not play well in the buddy allocator
Message-ID: <20190826104144.GA7849@linux>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

When analyzing a problem reported by one of our customers, I stumbbled upon an issue
that origins from the fact that poisoned pages end up in the buddy allocator.

Let me break down the stepts that lie to the problem:

1) We soft-offline a page
2) Page gets flagged as HWPoison and is being sent to the buddy allocator.
   This is done through set_hwpoison_free_buddy_page().
3) Kcompactd wakes up in order to perform some compaction.
4) compact_zone() will call migrate_pages()
5) migrate_pages() will try to get a new page from compaction_alloc() to migrate to
6) if cc->freelist is empty, compaction_alloc() will call isolate_free_pagesblock()
7) isolate_free_pagesblock only checks for PageBuddy() to assume that a page is OK
   to be used to migrate to. Since HWPoisoned page are also PageBuddy, we add
   the page to the list. (same problem exists in fast_isolate_freepages()).

The outcome of that is that we end up happily handing poisoned pages in compaction_alloc,
so if we ever got a fault on that page through *_fault, we will return VM_FAULT_HWPOISON,
and the process will be killed.

I first though that I could get away with it by checking PageHWPoison in
{fast_isolate_freepages/isolate_free_pagesblock}, but not really.
It might be that the page we are checking is an order > 0 page, so the first page
might not be poisoned, but the one the follows might be, and we end up in the
same situation.

After some more thought, I really came to the conclusion that HWPoison pages should not
really be in the buddy allocator, as this is only asking for problems.
In this case it is only compaction code, but it could be happening somewhere else,
and one would expect that the pages you got from the buddy allocator are __ready__ to use.

I __think__ that we thought we were safe to put HWPoison pages in the buddy allocator as we
perform healthy checks when getting a page from there, so we skip poisoned pages

Of course, this is not the end of the story, now that someone got a page, if he frees it,
there is a high chance that this page ends up in a pcplist (I saw that).
Unless we are on CONFIG_VM_DEBUG, we do not check for the health of pages got from pcplist,
as we do when getting a page from the buddy allocator.

I checked [1], and it seems that [2] was going towards fixing this kind of issue.

I think it is about time to revamp the whole thing.

@Naoya: I could give it a try if you are busy.

[1] https://lore.kernel.org/linux-mm/1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com/
[2] https://lore.kernel.org/linux-mm/1541746035-13408-9-git-send-email-n-horiguchi@ah.jp.nec.com/

-- 
Oscar Salvador
SUSE L3

