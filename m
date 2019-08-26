Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2C83C3A5A5
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 07:31:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F951206BA
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 07:31:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F951206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 346906B0536; Mon, 26 Aug 2019 03:31:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F7926B0537; Mon, 26 Aug 2019 03:31:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20E6A6B0538; Mon, 26 Aug 2019 03:31:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0244.hostedemail.com [216.40.44.244])
	by kanga.kvack.org (Postfix) with ESMTP id 024B76B0536
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 03:31:43 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 8756352B6
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:31:43 +0000 (UTC)
X-FDA: 75863759286.03.floor89_6649597cbff07
X-HE-Tag: floor89_6649597cbff07
X-Filterd-Recvd-Size: 1774
Received: from mga06.intel.com (mga06.intel.com [134.134.136.31])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:31:42 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Aug 2019 00:31:41 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,431,1559545200"; 
   d="scan'208";a="191648428"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by orsmga002.jf.intel.com with ESMTP; 26 Aug 2019 00:31:39 -0700
From: Wei Yang <richardw.yang@linux.intel.com>
To: akpm@linux-foundation.org,
	vbabka@suse.cz,
	kirill.shutemov@linux.intel.com,
	yang.shi@linux.alibaba.com
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: [PATCH 0/2] mm/mmap.c: reduce subtree gap propagation a little
Date: Mon, 26 Aug 2019 15:31:04 +0800
Message-Id: <20190826073106.29971-1-richardw.yang@linux.intel.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When insert and delete a vma, it will compute and propagate related subtree
gap. After some investigation, we can reduce subtree gap propagation a little.

[1]: This one reduce the propagation by update *next* gap after itself, since
     *next* must be a parent in this case.
[2]: This one achieve this by unlinking vma from list.

After applying these two patches, test shows it reduce 0.4% function all for
vma_compute_subtree_gap.

Wei Yang (2):
  mm/mmap.c: update *next* gap after itself
  mm/mmap.c: unlink vma before rb_erase

 mm/mmap.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

-- 
2.17.1


