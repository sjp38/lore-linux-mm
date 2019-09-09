Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E78B0C4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 11:48:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B793C218DE
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 11:48:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B793C218DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 542236B0005; Mon,  9 Sep 2019 07:48:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F3036B0006; Mon,  9 Sep 2019 07:48:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E1C06B0007; Mon,  9 Sep 2019 07:48:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0093.hostedemail.com [216.40.44.93])
	by kanga.kvack.org (Postfix) with ESMTP id 1B71B6B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 07:48:42 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 6FD2555FB2
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:48:41 +0000 (UTC)
X-FDA: 75915210042.04.touch48_68e4d412f3d10
X-HE-Tag: touch48_68e4d412f3d10
X-Filterd-Recvd-Size: 2473
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:48:40 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5F33A302455F;
	Mon,  9 Sep 2019 11:48:39 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-173.ams2.redhat.com [10.36.116.173])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 69F13100197A;
	Mon,  9 Sep 2019 11:48:31 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	Souptick Joarder <jrdr.linux@gmail.com>,
	linux-hyperv@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Michal Hocko <mhocko@suse.com>,
	Oscar Salvador <osalvador@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Qian Cai <cai@lca.pw>,
	Sasha Levin <sashal@kernel.org>,
	Stephen Hemminger <sthemmin@microsoft.com>,
	Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH v1 0/3] mm/memory_hotplug: Export generic_online_page()
Date: Mon,  9 Sep 2019 13:48:27 +0200
Message-Id: <20190909114830.662-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Mon, 09 Sep 2019 11:48:39 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Based on linux/next + "[PATCH 0/3] Remove __online_page_set_limits()"

Let's replace the __online_page...() functions by generic_online_page().
Hyper-V only wants to delay the actual onlining of un-backed pages, so we
can simpy re-use the generic function.

Only compile-tested.

Cc: Souptick Joarder <jrdr.linux@gmail.com>

David Hildenbrand (3):
  mm/memory_hotplug: Export generic_online_page()
  hv_balloon: Use generic_online_page()
  mm/memory_hotplug: Remove __online_page_free() and
    __online_page_increment_counters()

 drivers/hv/hv_balloon.c        |  3 +--
 include/linux/memory_hotplug.h |  4 +---
 mm/memory_hotplug.c            | 17 ++---------------
 3 files changed, 4 insertions(+), 20 deletions(-)

--=20
2.21.0


