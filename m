Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED4D1C5ACAE
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 15:06:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA1D82075C
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 15:06:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA1D82075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C8F36B0269; Wed, 11 Sep 2019 11:06:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47BD56B026A; Wed, 11 Sep 2019 11:06:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 390A46B026B; Wed, 11 Sep 2019 11:06:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0033.hostedemail.com [216.40.44.33])
	by kanga.kvack.org (Postfix) with ESMTP id 17F326B0269
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 11:06:09 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id CC78452CB
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 15:06:08 +0000 (UTC)
X-FDA: 75922965216.17.rule61_359d9c7c2d118
X-HE-Tag: rule61_359d9c7c2d118
X-Filterd-Recvd-Size: 3283
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 15:06:08 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E2CB510576C6;
	Wed, 11 Sep 2019 15:06:06 +0000 (UTC)
Received: from llong.com (ovpn-125-196.rdu2.redhat.com [10.10.125.196])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 848AD1FB;
	Wed, 11 Sep 2019 15:06:01 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Will Deacon <will.deacon@arm.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Davidlohr Bueso <dave@stgolabs.net>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH 0/5] hugetlbfs: Disable PMD sharing for large systems
Date: Wed, 11 Sep 2019 16:05:32 +0100
Message-Id: <20190911150537.19527-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.64]); Wed, 11 Sep 2019 15:06:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A customer with large SMP systems (up to 16 sockets) with application
that uses large amount of static hugepages (~500-1500GB) are experiencing
random multisecond delays. These delays was caused by the long time it
took to scan the VMA interval tree with mmap_sem held.

To fix this problem while perserving existing behavior as much as
possible, we need to allow timeout in down_write() and disabling PMD
sharing when it is taking too long to do so. Since a transaction can
involving touching multiple huge pages, timing out for each of the huge
page interactions does not completely solve the problem. So a threshold
is set to completely disable PMD sharing if too many timeouts happen.

The first 4 patches of this 5-patch series adds a new
down_write_timedlock() API which accepts a timeout argument and return
true is locking is successful or false otherwise. It works more or less
than a down_write_trylock() but the calling thread may sleep.

The last patch implements the timeout mechanism as described above. With
the patched kernel installed, the customer confirmed that the problem
was gone.

Waiman Long (5):
  locking/rwsem: Add down_write_timedlock()
  locking/rwsem: Enable timeout check when spinning on owner
  locking/osq: Allow early break from OSQ
  locking/rwsem: Enable timeout check when staying in the OSQ
  hugetlbfs: Limit wait time when trying to share huge PMD

 include/linux/fs.h                |   7 ++
 include/linux/osq_lock.h          |  13 +--
 include/linux/rwsem.h             |   4 +-
 kernel/locking/lock_events_list.h |   1 +
 kernel/locking/mutex.c            |   2 +-
 kernel/locking/osq_lock.c         |  12 +-
 kernel/locking/rwsem.c            | 183 +++++++++++++++++++++++++-----
 mm/hugetlb.c                      |  24 +++-
 8 files changed, 201 insertions(+), 45 deletions(-)

-- 
2.18.1


