Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 661BB6B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:32:10 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id f66so20873707iof.10
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 02:32:10 -0700 (PDT)
Received: from mail-io0-f194.google.com (mail-io0-f194.google.com. [209.85.223.194])
        by mx.google.com with ESMTPS id c130si1949314ioe.287.2017.06.26.02.32.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 02:32:09 -0700 (PDT)
Received: by mail-io0-f194.google.com with SMTP id h134so12391215iof.3
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 02:32:09 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm: document highmem_is_dirtyable sysctl
Date: Mon, 26 Jun 2017 11:32:00 +0200
Message-Id: <20170626093200.18958-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Alkis Georgopoulos <alkisg@gmail.com>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

It seems that there are still people using 32b kernels which a lot of
memory and the IO tend to suck a lot for them by default. Mostly because
writers are throttled too when the lowmem is used. We have
highmem_is_dirtyable to work around that issue but it seems we never
bothered to document it. Let's do it now, finally.

Cc: Alkis Georgopoulos <alkisg@gmail.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
JFYI this came out from recent discussion [1].

[1] http://lkml.kernel.org/r/20170622123736.1d80f1318eac41cd661b7757@linux-foundation.org

 Documentation/sysctl/vm.txt | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index b4ad97f10b8e..48244c42ff52 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -240,6 +240,26 @@ fragmentation index is <= extfrag_threshold. The default value is 500.
 
 ==============================================================
 
+highmem_is_dirtyable
+
+Available only for systems with CONFIG_HIGHMEM enabled (32b systems).
+
+This parameter controls whether the high memory is considered for dirty
+writers throttling.  This is not the case by default which means that
+only the amount of memory directly visible/usable by the kernel can
+be dirtied. As a result, on systems with a large amount of memory and
+lowmem basically depleted writers might be throttled too early and
+streaming writes can get very slow.
+
+Changing the value to non zero would allow more memory to be dirtied
+and thus allow writers to write more data which can be flushed to the
+storage more effectively. Note this also comes with a risk of pre-mature
+OOM killer because some writers (e.g. direct block device writes) can
+only use the low memory and they can fill it up with dirty data without
+any throttling.
+
+==============================================================
+
 hugepages_treat_as_movable
 
 This parameter controls whether we can allocate hugepages from ZONE_MOVABLE
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
