Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46FE9C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 16:08:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DACEA2085B
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 16:08:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="e5XfwYDU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DACEA2085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4185D8E0002; Thu, 31 Jan 2019 11:08:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A04F8E0001; Thu, 31 Jan 2019 11:08:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 240BB8E0002; Thu, 31 Jan 2019 11:08:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id E42F08E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:08:05 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id i142so2008445ybg.11
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 08:08:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=UP69wWmTtINd5/Z9K2WlkOH7AzazUM8Nzb3CPcSA8gQ=;
        b=gkZUpaRFZ2Ye2S8Zu9mdUweETlbCPeggCA3z73Z303tGlZuQu3JHJfE9RkC4sO/YXf
         24xmBJKIitdQ5ZkGm9Sos/BWJXvyn5v4r0rWqpcMzuPdsjbzNgp5LHr7qMMcMyJVnFMv
         dhgOrVVIG56Fvobml3EJ9orZYlLP+7KnNHtbImycx9zTvbNCA4qyqXeUz4cv6nCzNd1/
         jCJaTLSYPFcqr3zg+BeDQxaNA7qHRZoXUCHW6fzWNhCbfj+mNGmrEaN73vDMJ/cvjHs/
         r4ttmjGZLorbC/GBebX9m7peW3kjdd5OhXmnEcgJF70spwUkn01dw8bGRVurZaEMZ7JI
         QUJQ==
X-Gm-Message-State: AJcUukfiyawiYrkdo6MONrpwiZvPxHFjq75mx6cUAa9K/Jig0V3b7cT0
	0rD3mpcwUGIy1OeclpClOzRO2DBJM4FbF6MbeaNnwA1/A32f20cv9PETjn+vVfgm2SsgRt91tZR
	pEtnkn/CYQ63IY3suyFlDtitjENJvoIblBPK/lWLRCpZChuHYILygllshz4DrMq5Whh67cSnO1+
	w5SQ+G0e67AMncqgHLzzIoUnMUJLWPe7KpV1lJ4DO8NCUQYUCIQUNZx2h1kg0lGpnBSUiG78++K
	qEgeSTG87UK1inbCfRa2VWsoyE2NB/gUARpIBRow0xrG9iLxE3IcHTdvSqkD2E4FINXbndMd207
	G/CWflrTSw0iN6Nuugrslvyoaz+Rd8Tl4yToxzd9huDwtJUolGKAMWg/tF0xSqdjWJTa/8FgTaF
	E
X-Received: by 2002:a81:ec0d:: with SMTP id j13mr33447646ywm.5.1548950885570;
        Thu, 31 Jan 2019 08:08:05 -0800 (PST)
X-Received: by 2002:a81:ec0d:: with SMTP id j13mr33447575ywm.5.1548950884763;
        Thu, 31 Jan 2019 08:08:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548950884; cv=none;
        d=google.com; s=arc-20160816;
        b=BngfMP8sPFNa9ILG8Va1ZToWIr87GWkLYRqvVD/HKPtEw+DVv0V399D9CXkKFiXqNC
         EiTYMilQpeyqKpuI0w0hnkB5ddRaFPs4W7pfIgWucApQnWI0+9+8I4n086Yh0EhRU9Tm
         4BjEGnuZ69xm20lNV+clueaQeWwXTyPdJjJ7rhk9M1aFEL9nrLDY1ho8nrhh9UQKCxij
         a3dASAl5pI34SExMQCcUzTXhpa2lpKA8n9iMysfgMGdx6Ccby4wdNYIrv+CSKR6JJr67
         TvSH7RhUkEX8nh62LD6TimlHqb90eIGE10gOVtTzO7OV5vEzNQ3gqVSulFH62hotjUCE
         Ntug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=UP69wWmTtINd5/Z9K2WlkOH7AzazUM8Nzb3CPcSA8gQ=;
        b=OzyalMt5IhQ4rVqsExJ2JFfUkh7eJVxaYasqOLvaRM0Co6WfSw/f1DgBZLUaHnPAje
         s6stxRCyG4iBcuui46fAF8ftyE5Lqd9QLYRoBly13PfgsR9EYNH82KY0m2U88PhMTbn6
         VL0sI3bSUhnnGTYDccqrf+UC7nDVDohxl4HzIgGqzkAFgHLfZ2gLZZEfwy6L4Dh10Ruz
         pKI59LEZjM1KIbWeJUuwxX/0XW7P5i98BRKFVY1JnaG2iODZm2R5JT4Wf+CCZAFcKG59
         gnYkTv+wz73bTF9kbyHJjiSxQJDSUAUleS9UWFdheyAJW16AQam3zVojigmmTS6u/BQj
         KKnA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=e5XfwYDU;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 125sor2196633ybe.67.2019.01.31.08.08.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Jan 2019 08:08:04 -0800 (PST)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=e5XfwYDU;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=UP69wWmTtINd5/Z9K2WlkOH7AzazUM8Nzb3CPcSA8gQ=;
        b=e5XfwYDUxCjfYGxGVHOfo2wOQLLTu8dorggsDA1b94sfaIEhbQOcpTwGBL4wrv8DEB
         6aj6uOANmvjxCC9EDZok7Vk1Bpm49Kn7YW6vHp+em848JQLHEP8P1IkY6Akuwjl/Ke7x
         CEzZnIMsE9w8xVkUDaQEOrC4oaryD1DFRuQ18=
X-Google-Smtp-Source: AHgI3IZ/iJQHuRIvFfVhJaEbmX7+ulluGReoNKwobgLbR9DjpGSjtPwGcIGYuyndENHvcMjuWlV6Ag==
X-Received: by 2002:a25:6041:: with SMTP id u62mr11459176ybb.149.1548950883984;
        Thu, 31 Jan 2019 08:08:03 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::7:7e97])
        by smtp.gmail.com with ESMTPSA id v9sm1968192ywh.2.2019.01.31.08.08.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 31 Jan 2019 08:08:03 -0800 (PST)
Date: Thu, 31 Jan 2019 11:08:02 -0500
From: Chris Down <chris@chrisdown.name>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com
Subject: [PATCH] fixup: mm: memcontrol: Unbreak memcontrol build when THP is
 disabled
Message-ID: <20190131160802.GA5777@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This can be folded into "mm: memcontrol: Expose THP events on a
per-memcg basis"
(mm-memcontrol-expose-thp-events-on-a-per-memcg-basis.patch).

kbuild points out that this patch can't be built with
CONFIG_TRANSPARENT_HUGEPAGE not set. I had originally worried about
this, but had only checked NR_ANON_THPS (which is not ifdeffed), not the
event counters.

NR_ANON_THPS is not #ifdeffed in node_stat_item, so we don't need to
also guard MEMCG_RSS_HUGE to futureproof it.

Signed-off-by: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Roman Gushchin <guro@fb.com>
Cc: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: kernel-team@fb.com
---
 Documentation/admin-guide/cgroup-v2.rst | 8 +++++---
 mm/memcontrol.c                         | 2 ++
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-guide/cgroup-v2.rst
index b6989b39ed8e..53d3288c328b 100644
--- a/Documentation/admin-guide/cgroup-v2.rst
+++ b/Documentation/admin-guide/cgroup-v2.rst
@@ -1255,12 +1255,14 @@ PAGE_SIZE multiple when read back.
 	  thp_fault_alloc
 
 		Number of transparent hugepages which were allocated to satisfy
-		a page fault, including COW faults
+		a page fault, including COW faults. This counter is not present
+		when CONFIG_TRANSPARENT_HUGEPAGE is not set.
 
 	  thp_collapse_alloc
 
-		Number of transparent hugepages which were allocated to
-		allow collapsing an existing range of pages
+		Number of transparent hugepages which were allocated to allow
+		collapsing an existing range of pages. This counter is not
+		present when CONFIG_TRANSPARENT_HUGEPAGE is not set.
 
   memory.swap.current
 	A read-only single value file which exists on non-root
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2f4fe2fb9046..bc4da016b8ce 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5643,9 +5643,11 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	seq_printf(m, "pglazyfree %lu\n", acc.events[PGLAZYFREE]);
 	seq_printf(m, "pglazyfreed %lu\n", acc.events[PGLAZYFREED]);
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	seq_printf(m, "thp_fault_alloc %lu\n", acc.events[THP_FAULT_ALLOC]);
 	seq_printf(m, "thp_collapse_alloc %lu\n",
 		   acc.events[THP_COLLAPSE_ALLOC]);
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 	return 0;
 }
-- 
2.20.1

