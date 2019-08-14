Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27F2CC32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 15:41:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8B862084D
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 15:41:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8B862084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D24B6B0005; Wed, 14 Aug 2019 11:41:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 883846B0006; Wed, 14 Aug 2019 11:41:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 798EB6B0007; Wed, 14 Aug 2019 11:41:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0242.hostedemail.com [216.40.44.242])
	by kanga.kvack.org (Postfix) with ESMTP id 561786B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:41:17 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 086E08248AA9
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 15:41:17 +0000 (UTC)
X-FDA: 75821447394.04.tent75_28478fa01092c
X-HE-Tag: tent75_28478fa01092c
X-Filterd-Recvd-Size: 2921
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 15:41:16 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7F76A51EF3;
	Wed, 14 Aug 2019 15:41:15 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-49.ams2.redhat.com [10.36.116.49])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1B9418069C;
	Wed, 14 Aug 2019 15:41:09 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Arun KS <arunks@codeaurora.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Borislav Petkov <bp@suse.de>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@kernel.org>,
	Michal Hocko <mhocko@suse.com>,
	Nadav Amit <namit@vmware.com>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: [PATCH v2 0/5] mm/memory_hotplug: online_pages() cleanups
Date: Wed, 14 Aug 2019 17:41:04 +0200
Message-Id: <20190814154109.3448-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Wed, 14 Aug 2019 15:41:15 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Some cleanups (+ one fix for a special case) in the context of
online_pages(). Hope I am not missing something obvious. Did a sanity tes=
t
with DIMMs only.

v1 -> v2:
- "mm/memory_hotplug: Handle unaligned start and nr_pages in
   online_pages_blocks()"
-- Turned into "mm/memory_hotplug: make sure the pfn is aligned to the
		order when onlining"
-- Dropped the "nr_pages not an order of two" condition for now as
   requested by Michal, but kept a simplified alignment check
- "mm/memory_hotplug: Drop PageReserved() check in online_pages_range()"
-- Split out from "mm/memory_hotplug: Simplify online_pages_range()"
- "mm/memory_hotplug: Simplify online_pages_range()"
-- Modified due to the other changes

David Hildenbrand (5):
  resource: Use PFN_UP / PFN_DOWN in walk_system_ram_range()
  mm/memory_hotplug: Drop PageReserved() check in online_pages_range()
  mm/memory_hotplug: Simplify online_pages_range()
  mm/memory_hotplug: Make sure the pfn is aligned to the order when
    onlining
  mm/memory_hotplug: online_pages cannot be 0 in online_pages()

 kernel/resource.c   |  4 +--
 mm/memory_hotplug.c | 61 ++++++++++++++++++++-------------------------
 2 files changed, 29 insertions(+), 36 deletions(-)

--=20
2.21.0


