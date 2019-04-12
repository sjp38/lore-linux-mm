Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31969C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 15:15:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E60972171F
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 15:15:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="otZiKvwB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E60972171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 798A86B000C; Fri, 12 Apr 2019 11:15:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 746216B000D; Fri, 12 Apr 2019 11:15:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 636B06B0010; Fri, 12 Apr 2019 11:15:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 430996B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 11:15:22 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 18so9032446qtw.20
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 08:15:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=ExcVMXKMLAIGNf5KmSqXrW5PdcB9ts4NWl7/RwgO/jI=;
        b=AY4+h6AEX+ttHUOFCbqFJQMOqXslDAxM8hEgSpHEXvUFVrzMXvz07X27UJfSHEc3af
         W5chwgkzo2MXbGt1cag2OzMOXfg1tP35d/Q2gn+t1GEQMbopfuKfZPJPVd7GEx43jp5z
         AE+iZ+xrl/B+pTeSqLcw/rm5Zv8di0K1obePvwH8vriTKIEA0LITAd9kpwviN1owq8PR
         MR4ymJkMjKEpLqhriPJ4Z+0PSzWHObdD69P/der46ZaNX9SH+Hk66uaEuiB1q5PnPuWh
         q75ZDTKwZi/CyAG1wqMl9K8Xyx1NjL67w6T+kL3AGW5xSVAREKTWliw5DlLeePdSpFcn
         cdEw==
X-Gm-Message-State: APjAAAWyQDmMop+cz4eUbKaTKpjJZ/k1kVOHEfkdwYrLk1yjqj/AhxFJ
	y6M7/q2IwpZw/KHj0WJXAsrVymCKeQyHC9n2tYmBFkS8B3cshcMXdYT6xdTEJWURVpdA5IiKHKh
	fE/ScWnbvrGQXwWalpRL+VciA65J63cv/qniY6PvYCAboOL5fDN9vMd8og6BUJSifKw==
X-Received: by 2002:ac8:3f6f:: with SMTP id w44mr45673832qtk.59.1555082121982;
        Fri, 12 Apr 2019 08:15:21 -0700 (PDT)
X-Received: by 2002:ac8:3f6f:: with SMTP id w44mr45673727qtk.59.1555082120931;
        Fri, 12 Apr 2019 08:15:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555082120; cv=none;
        d=google.com; s=arc-20160816;
        b=BZwlSAHRUe4HY+902qTDP/7CWGRb/YO6g1a2mWoDscBwo3AAve172gj02wD4E9X6bn
         apNeAbh3AlXiPWShfnzxwhxpZI449z/gnV/4pF62RSURUBbwkwapDQGk64ysoclFeZ4t
         qsanmBJGBA4roY48x6vwOyrD+gas+GY8hLg25vdfTGuFF45gddIPhb1+tBAmaURD4rZW
         4IL0zVUpH1LsEj6X2UlbJvB392zTkbnte8EUcpxaVBxwWgaPcPAtTcwlXriZipmSRmOE
         Qe6GnUvSLR/ZAvHv+mKBpLbeWyY6wmi6LkVdV659+vT8YH28kg639lpRCaTZGfYHJbjr
         Ubng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=ExcVMXKMLAIGNf5KmSqXrW5PdcB9ts4NWl7/RwgO/jI=;
        b=o4i1y0IN5hKFRo8xIk0rIfp6RXzyW3pLIRK35gqBm8KpZViNJP1ADqBCPQn173fPPX
         qGdSkiCI27iZul1BlUY1S+19QHMyDiiMl0QSRv5PVFwMJ85TuS9V4QEsAvxzjEKfD8Sr
         N5UqecFn4uNGRDPVhz0sxRpBbiL2aHHu40rUU7xuHkfWwIOgOA04vmIkLJB+rjDaNLnz
         Da+0bNPrsE8+Pie3gZEjTLfXhnYU9SGDrmyKSbrVaYH0lrafAPHkwIHN+4fcS8XuuCw0
         bsfaAD1jJkeci5NdFjqZ+BJpFEItIK5YlAdLqu1nk0Cofh13ibK9ouysj2Gh8KKZhGAj
         4Axg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=otZiKvwB;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p92sor41415821qvp.7.2019.04.12.08.15.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 08:15:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=otZiKvwB;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=ExcVMXKMLAIGNf5KmSqXrW5PdcB9ts4NWl7/RwgO/jI=;
        b=otZiKvwBqdW+yp5E+sxlXMkmP/ZdX7vWtbD/mtd0dHs4PrW2KX3YuzFsZUDMkuJgc/
         w0UCkKwKdoYReI/dgPptzYV3khKBw7sj2riOqQ8G6vyQd6uSAtjgisNqVmD8di5ZiEqs
         Zw4BXpu40szBooKU5UTvQRGYhF7Gg+ic4rFebiZ5bv3sypeI/TiR625hnOx3fhnSWwzk
         aY9eyFzrLAiiyGiQYzvyO9HFpdX3PZ4wj/lfwRflCHJJUwNEBFWwL7sZvDIJ31Owagc4
         4KHAfGjPzWg9oqhFZ0KqE8gwCnV8C7jmrR+57NKQuzD6XBgU9SRxPlt99lPgk9K2KgXl
         JEUg==
X-Google-Smtp-Source: APXvYqzWgvKc4Fr5gRxDaJ6QTk0PaB7XEaAOjXMkq0vmcXUP6Zld9Yt2kxhFXms6m0K7drFhzvTUhQ==
X-Received: by 2002:a0c:89b5:: with SMTP id 50mr46177023qvr.156.1555082115847;
        Fri, 12 Apr 2019 08:15:15 -0700 (PDT)
Received: from localhost (pool-108-27-252-85.nycmny.fios.verizon.net. [108.27.252.85])
        by smtp.gmail.com with ESMTPSA id b7sm23214436qkc.47.2019.04.12.08.15.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Apr 2019 08:15:15 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 0/4] mm: memcontrol: memory.stat cost & correctness
Date: Fri, 12 Apr 2019 11:15:03 -0400
Message-Id: <20190412151507.2769-1-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The cgroup memory.stat file holds recursive statistics for the entire
subtree. The current implementation does this tree walk on-demand
whenever the file is read. This is giving us problems in production.

1. The cost of aggregating the statistics on-demand is high. A lot of
system service cgroups are mostly idle and their stats don't change
between reads, yet we always have to check them. There are also always
some lazily-dying cgroups sitting around that are pinned by a handful
of remaining page cache; the same applies to them.

In an application that periodically monitors memory.stat in our fleet,
we have seen the aggregation consume up to 5% CPU time.

2. When cgroups die and disappear from the cgroup tree, so do their
accumulated vm events. The result is that the event counters at
higher-level cgroups can go backwards and confuse some of our
automation, let alone people looking at the graphs over time.

To address both issues, this patch series changes the stat
implementation to spill counts upwards when the counters change.

The upward spilling is batched using the existing per-cpu cache. In a
sparse file stress test with 5 level cgroup nesting, the additional
cost of the flushing was negligible (a little under 1% of CPU at 100%
CPU utilization, compared to the 5% of reading memory.stat during
regular operation).

 include/linux/memcontrol.h |  96 +++++++-------
 mm/memcontrol.c            | 290 +++++++++++++++++++++++++++----------------
 mm/vmscan.c                |   4 +-
 mm/workingset.c            |   7 +-
 4 files changed, 234 insertions(+), 163 deletions(-)


