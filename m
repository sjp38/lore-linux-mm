Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 929C3C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11015241B1
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="hOCZMeOh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11015241B1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A420B6B026F; Mon,  3 Jun 2019 17:08:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F37A6B0270; Mon,  3 Jun 2019 17:08:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 908806B0271; Mon,  3 Jun 2019 17:08:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5575D6B026F
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 17:08:24 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d125so14511692pfd.3
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 14:08:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=hcbe5XK5tsFMWxSLs2tZ84hRD+cj/6YTqAC2Tmv3P6A=;
        b=LnQqge0S4AxtQa1lswAaeVn+4uyAbB7BZXhzO5yGjIn5/uBEzWaVR/M9bB1dIjlLr+
         fSirIl8spjajR6U/fCXdON9o5url++sZAhg+A9UhIOjN03bd0OprTn9KYKneQFAjaIU9
         arygp1NcEjvRbUFajVct7v8EVpBaNxKwXjdeShQveziuSV/5a6d4ahjTmMjlMSrcqIzW
         wcKYgX6TbEiuoOqI3fVQmupUUPrTKhWGnPP02GzmwNkOjzutxBagRAtdGh6ZuzTU57r9
         PqXbJ+8Z/IzNCsz9D/1aAZzDtbwPkIBhOiuXs55aGT6HLGkn/Mex+15Z1IE6+viBuT1w
         RHzQ==
X-Gm-Message-State: APjAAAXxQ24bgUIuW6dtAFUsB/WXrw6hsemPGpkqQDaQLTW0RnKjhMs2
	OzAOSOI2Kn8Hvk0dJ6PmFvP4WFqcKO/XXhspN7jfmrYqipwlP/KtXOBbcthne9GalYrDnOwqMMd
	WF5rjWNOBbKA18URAhksrC2gbSQL1GK5w+cKOSWC2wehY7xHDR1MEY2Y0tb4ip3vKTw==
X-Received: by 2002:a17:90a:2488:: with SMTP id i8mr25014102pje.123.1559596103795;
        Mon, 03 Jun 2019 14:08:23 -0700 (PDT)
X-Received: by 2002:a17:90a:2488:: with SMTP id i8mr25013964pje.123.1559596102645;
        Mon, 03 Jun 2019 14:08:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559596102; cv=none;
        d=google.com; s=arc-20160816;
        b=JDRUej9HUlgJJGPfpcsAJH4XMqjo2RzkvEbTxzYXC3sHsD8mw20Ja34Mz9uzY/czCy
         /D9p8A70S39+8913sCblRiu8yNjWOP76plswA/WGAL+AFfUyL6EZ8rtwR7ggBh//vDh0
         WHB5GnKhdtB89SLQ3o7Uk3Fc627DYQVUwKFTYsXSx/Dkr2/I8rc4JW1w23Z07Fw+b8cs
         /Pd6bwGgj2x4SYFRBpDg3TfI4GOo86U2B04UaXWIO8CgDISDuUq1h6CPJR1ppRHJGVMB
         YJ8uLmitFtUlPEvOR+i6TKRzoRYbPGekkK3XAKUUOzyYtV7sXosOF3qCd3DqfrcN7GnH
         Dzjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=hcbe5XK5tsFMWxSLs2tZ84hRD+cj/6YTqAC2Tmv3P6A=;
        b=B8kocSNvGfqZclO4tisLTWBpIY2byQsiXmKSJu9UnyhflA9nKNMjcoB8VIwyuLSaNA
         oBo8CXyPwHERC5LDKUFlfu5LVpZH+X5QJYlSO0W6+6axCiZsXrYtVbXcgO/b2/8/F9vb
         gnwlmqy4FKZtSSxahV957NJpFrkBfyzL1IQBLDLBaLnXPF6+RBU2zEuPrj0J/qgYmt7a
         ZQOxqsPxPzqB5WrLd+N9aI7cz768Qxquv97aKfYUfBRgtM3wtQMXrQ4nU+Vem+SHIFdC
         1cpcU9FmWB1pS3ZJbSBP+tMJCz6VNmX3Xy+DWx2F4jkgxe3CRNexEl7CicykEcWWeJ9j
         l7jw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=hOCZMeOh;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r65sor18688661pjb.6.2019.06.03.14.08.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 14:08:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=hOCZMeOh;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=hcbe5XK5tsFMWxSLs2tZ84hRD+cj/6YTqAC2Tmv3P6A=;
        b=hOCZMeOhk+mnIUArMWNnC4vOoecC/JJjH016s1tw4Q96mSLD+0XvEFZfhYCyOuiLe3
         3JPco6SQFbsgOo3tJVA/rGxuMMqV+PxWgHbtFyYjLLr4aJ45fWaaT3ONrFh3O59CMhRv
         1a7SdQk8hx4KAgvnXTXy4jWGFB5OfJ5r7LCWoltwNWxy5L9bf/dZJoxBT8mbb0BqQ+14
         aoRFh3Hi+L5+3to6drNMaTiQ5MWNn112T5jPH2jmcr2nTpfYazs2lHbfT0EgV4wDf9p7
         +ZAzMj5wXkBDVcVYUtZ37FLCh0uEdyTwkwGCZK2XRuhvUzzguAJo+j34T00y0fKG5UdN
         paFA==
X-Google-Smtp-Source: APXvYqz4Qw8yGDgRFudiuxfXs7P+jDtt3/2W1h5CX5aNY5aXM70fQ7T4ZIHJj3eYv41Qd3NLYGM9aQ==
X-Received: by 2002:a17:90a:7146:: with SMTP id g6mr32429865pjs.45.1559596101827;
        Mon, 03 Jun 2019 14:08:21 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:9fa4])
        by smtp.gmail.com with ESMTPSA id i12sm17107336pfd.33.2019.06.03.14.08.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 14:08:21 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@suse.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 00/11] mm: fix page aging across multiple cgroups
Date: Mon,  3 Jun 2019 17:07:35 -0400
Message-Id: <20190603210746.15800-1-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When applications are put into unconfigured cgroups for memory
accounting purposes, the cgrouping itself should not change the
behavior of the page reclaim code. We expect the VM to reclaim the
coldest pages in the system. But right now the VM can reclaim hot
pages in one cgroup while there is eligible cold cache in others.

This is because one part of the reclaim algorithm isn't truly cgroup
hierarchy aware: the inactive/active list balancing. That is the part
that is supposed to protect hot cache data from one-off streaming IO.

The recursive cgroup reclaim scheme will scan and rotate the physical
LRU lists of each eligible cgroup at the same rate in a round-robin
fashion, thereby establishing a relative order among the pages of all
those cgroups. However, the inactive/active balancing decisions are
made locally within each cgroup, so when a cgroup is running low on
cold pages, its hot pages will get reclaimed - even when sibling
cgroups have plenty of cold cache eligible in the same reclaim run.

For example:

   [root@ham ~]# head -n1 /proc/meminfo 
   MemTotal:        1016336 kB

   [root@ham ~]# ./reclaimtest2.sh 
   Establishing 50M active files in cgroup A...
   Hot pages cached: 12800/12800 workingset-a
   Linearly scanning through 18G of file data in cgroup B:
   real    0m4.269s
   user    0m0.051s
   sys     0m4.182s
   Hot pages cached: 134/12800 workingset-a

The streaming IO in B, which doesn't benefit from caching at all,
pushes out most of the workingset in A.

Solution

This series fixes the problem by elevating inactive/active balancing
decisions to the toplevel of the reclaim run. This is either a cgroup
that hit its limit, or straight-up global reclaim if there is physical
memory pressure. From there, it takes a recursive view of the cgroup
subtree to decide whether page deactivation is necessary.

In the test above, the VM will then recognize that cgroup B has plenty
of eligible cold cache, and that thet hot pages in A can be spared:

   [root@ham ~]# ./reclaimtest2.sh 
   Establishing 50M active files in cgroup A...
   Hot pages cached: 12800/12800 workingset-a
   Linearly scanning through 18G of file data in cgroup B:
   real    0m4.244s
   user    0m0.064s
   sys     0m4.177s
   Hot pages cached: 12800/12800 workingset-a

Implementation

Whether active pages can be deactivated or not is influenced by two
factors: the inactive list dropping below a minimum size relative to
the active list, and the occurence of refaults.

After some cleanups and preparations, this patch series first moves
refault detection to the reclaim root, then enforces the minimum
inactive size based on a recursive view of the cgroup tree's LRUs.

History

Note that this actually never worked correctly in Linux cgroups. In
the past it worked for global reclaim and leaf limit reclaim only (we
used to have two physical LRU linkages per page), but it never worked
for intermediate limit reclaim over multiple leaf cgroups.

We're noticing this now because 1) we're putting everything into
cgroups for accounting, not just the things we want to control and 2)
we're moving away from leaf limits that invoke reclaim on individual
cgroups, toward large tree reclaim, triggered by high-level limits or
physical memory pressure, that is influenced by local protections such
as memory.low and memory.min instead.

Requirements

These changes are based on the fast recursive memcg stats merged in
5.2-rc1. The patches are against v5.2-rc2-mmots-2019-05-29-20-56-12
plus the page cache fix in https://lkml.org/lkml/2019/5/24/813.

 include/linux/memcontrol.h |  37 +--
 include/linux/mmzone.h     |  30 +-
 include/linux/swap.h       |   2 +-
 mm/memcontrol.c            |   6 +-
 mm/page_alloc.c            |   2 +-
 mm/vmscan.c                | 667 ++++++++++++++++++++++---------------------
 mm/workingset.c            |  74 +++--
 7 files changed, 437 insertions(+), 381 deletions(-)


