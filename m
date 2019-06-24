Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D343C4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 17:43:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 382D520645
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 17:43:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 382D520645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D838B6B0005; Mon, 24 Jun 2019 13:43:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D34128E0003; Mon, 24 Jun 2019 13:43:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C21BE8E0002; Mon, 24 Jun 2019 13:43:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9EFCD6B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 13:43:25 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id i196so16917094qke.20
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:43:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=QEvz5537F98hhZqKH00mle/YPu5f5BtYscFuQJMXDb4=;
        b=dnqLNT92Db321HpyyZcjBjfkSfzG8uzel9tLTmDRaLTD2pbyZn56cvda5jVYmZP6p9
         OXgsUXCX2Zi2Qnv73SH7nGvW4CVWzvOEOpMKh78Do14GDXNkLI7rg7LvQLsDDp5KKOoZ
         wb2F9fos+0ztkufP11+VFtv4nP6yJjTWvjx8uU8O6WLoheq4/4YVqUv9KZzLGmSIn0PP
         TVipxPT4pnHrg/oYz7nOjqDtF1+qvUBgj0ZAr1Zuty1NQ5ZCgII91ymYyBLNnK10P6ms
         vp0dddL35diWP45YJIElNJKqFuRgFxD5maTXgyL1ZyuYzdz3hccThOWM990wYsCwqSPB
         KMBw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU4xqGuOT/dKjVWGlXaQuEM7H3H7It4RETraQ44rC32zEG97H88
	AuFjoiSbGUnZ7HIs2iSLviTiZBf4a+HL/05sZ4R7uWjR5orxQqCl17n+uOe7pQ6tXYGLYdTwKIo
	w0Ow3HMyYw/4bnMXv/35Gre2kqwZAXga+eKkMQhrCnaL14eRNcIYT5CnWRVZG75oCYA==
X-Received: by 2002:ac8:2410:: with SMTP id c16mr48628250qtc.108.1561398205419;
        Mon, 24 Jun 2019 10:43:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPmgY4k/+zDRsDY0viUvBQAQyUAucc2lQK0NST6bCEFvaoBL8FEjI2yoEQsYUrmXaeJg5o
X-Received: by 2002:ac8:2410:: with SMTP id c16mr48628213qtc.108.1561398204868;
        Mon, 24 Jun 2019 10:43:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561398204; cv=none;
        d=google.com; s=arc-20160816;
        b=FrklosN4BgMII3SQOycPg15POPlUssqUv1kiLpwMFIRvbTBY4hF6DIqbvliSaZAhh+
         uoJabS/21i5ZIuJrIcoiTxq934Hh/MKkfK1jjwrgdRFq6I6pDkaJ5qPkEZsZgn22LcXs
         MwG6NX7EcgzBPScazLsfFVn5eEu7xUZ3eKzr1M3X4LJ8x4iy8kRtXmRdo3Sa96nr8EYK
         fiOnugJd9SYu77GTSliqCOGjwUQLtpKIIkvpTRWH7HRWYouP+PjPLeoFmBKTipXOtAXs
         +D2v3ErNNpVhvctSjHoEcDHtdrf9tzaYktvSt/WHBVsla9sSa5ZJp2tFFJO3Nr3MgaO6
         BYuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=QEvz5537F98hhZqKH00mle/YPu5f5BtYscFuQJMXDb4=;
        b=Q2ZE1T1mq9ezZNM14yNiPEEvp8fZN4EaoA/Is6sts4/JOU7fTob+4AYVibrWKtyZH2
         ZOR+cuwvTkTnClDxZmJuTaZaclX/0iWt24PdkjYCtd5HLIy/Hl/XOq0tyxzV0LydrlaO
         kbQtcrO5n0EuisMUEms2sze7qmkEHaVAbyCzRhhqQm90y60oGz2Ay8Br8eorflVxvsQZ
         OrBsdk7JszIIvClctqevnVtXph0kUbHtmzU7BDWXqznVpG7oOn9CeQOdThPIsTcgBgJp
         F0fQgoYziDtaSGaAfAIuAKaNVy6/yLv5d1jag3h0cZz0rALjDl7OK3mX3nQ6TXIZ5gyr
         VqeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s47si4189292qth.305.2019.06.24.10.43.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 10:43:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EB82A13AA9;
	Mon, 24 Jun 2019 17:43:13 +0000 (UTC)
Received: from llong.com (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6F92A5D9C5;
	Mon, 24 Jun 2019 17:42:59 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: linux-mm@kvack.org,
	linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Roman Gushchin <guro@fb.com>,
	Shakeel Butt <shakeelb@google.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH 0/2] mm, slab: Extend vm/drop_caches to shrink kmem slabs
Date: Mon, 24 Jun 2019 13:42:17 -0400
Message-Id: <20190624174219.25513-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Mon, 24 Jun 2019 17:43:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The purpose of this patchset is to allow system administrators to have
the ability to shrink all the kmem slabs in order to free up memory
and get a more accurate picture of how many slab objects are actually
being used.

Patch 1 adds a new memcg_iterate_all() that is used by the patch 2 to
iterate on all the memory cgroups.

Waiman Long (2):
  mm, memcontrol: Add memcg_iterate_all()
  mm, slab: Extend vm/drop_caches to shrink kmem slabs

 Documentation/sysctl/vm.txt | 11 ++++++++--
 fs/drop_caches.c            |  4 ++++
 include/linux/memcontrol.h  |  3 +++
 include/linux/slab.h        |  1 +
 kernel/sysctl.c             |  4 ++--
 mm/memcontrol.c             | 13 +++++++++++
 mm/slab_common.c            | 44 +++++++++++++++++++++++++++++++++++++
 7 files changed, 76 insertions(+), 4 deletions(-)

-- 
2.18.1

