Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1ED196B000E
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 06:05:28 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h48-v6so4837014edh.22
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 03:05:28 -0700 (PDT)
Received: from outbound-smtp27.blacknight.com (outbound-smtp27.blacknight.com. [81.17.249.195])
        by mx.google.com with ESMTPS id v13-v6si1194958edb.343.2018.10.01.03.05.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Oct 2018 03:05:26 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp27.blacknight.com (Postfix) with ESMTPS id 35154B8821
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 11:05:26 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/2] Faster migration for automatic NUMA balancing
Date: Mon,  1 Oct 2018 11:05:23 +0100
Message-Id: <20181001100525.29789-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Jirka Hladky <jhladky@redhat.com>, Rik van Riel <riel@surriel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

These two patches are based on top of Srikar Dronamraju's recent work
on automatic NUMA balancing and are motivated by a bug report from Jirka
Hladky that STREAM performance has regressed.

The STREAM workload is mildly interesting in that it only works as a valid
benchmark if tasks are pinned to memory channels. Otherwise it is very
sensitive to the starting conditions of the benchmark. Recent scheduler
changes prevent prematurely spreading a workload across multiple sockets
which benefits many workloads but not STREAM. This series restores STREAM
performance without reintroducing other regressions.

The first patch removes migration rate limiting as it's expected that
automatic NUMA balancing decisions are mature enough that we do not
need the safety net. The second patch migrates pages faster early in the
lifetime of the process which has an impact if the load balancer spreads
a workload to remote nodes.

 include/linux/mmzone.h         |  6 ----
 include/trace/events/migrate.h | 27 ------------------
 kernel/sched/fair.c            | 12 +++++++-
 mm/migrate.c                   | 65 ------------------------------------------
 mm/page_alloc.c                |  2 --
 5 files changed, 11 insertions(+), 101 deletions(-)

-- 
2.16.4
