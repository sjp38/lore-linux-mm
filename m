Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53AFAC10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:30:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EDB6206C0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:30:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EDB6206C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AACAC6B028C; Wed,  3 Apr 2019 00:30:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5CA56B028E; Wed,  3 Apr 2019 00:30:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 924F86B028F; Wed,  3 Apr 2019 00:30:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 439C76B028C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:30:39 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n24so6818022edd.21
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:30:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=0tmsegy5nwxeJ1f1itRRHuF3L7n3Cp7BKyoDWcbyACM=;
        b=EOGEzWKfISYO5S1P/lIAwFXx2ySKI/1PjjEJ88B6ZMvuviJQVOrIA9h4lp2ompMCZq
         IlAQ8Vvoce2Caby3JP/36rrCMDct4xtUMnFx8bM73IVhVtHVx6aT6WFaz3WvY7hxFgGW
         Ndkw9pMUJfuTZesuNRGUjhB8SFawlzNdIk+FdBjVHw3F6mGYY42VFR2HTysdPUV+nJyy
         08D2DBe36o+dazIo5FMkknXDOyav4CKvc3srnAwwph6fUel+hlJHjqbUD/bw+mmkeQ3E
         o1jjg6Iz9pYvfkbr1dZ6lCK7c9YBaOkZv/0x92xoAwM6oxbH/vrE1uF1w7tHLD4SVZxj
         Fvhw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXHYrRMy+5VlQQWPZ7TdsrBSdnu0HTRcGGchTmHZe3kmajnwAxB
	hcgwWGCFYwLySFM8tVVSBU5KdLobRZXSnv9lsKSjACnE99sIT3F9eO1EE5mE+DBCO6ZFsBJ9new
	t7KcgRWPIDDtKMb4p6GEllRf7Z4KPSfZeZnLZPNZBx8SQJvsy8HguC3F4giBPvJtCSA==
X-Received: by 2002:a17:906:eb96:: with SMTP id mh22mr16017032ejb.186.1554265838773;
        Tue, 02 Apr 2019 21:30:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzC7VJ//Net1Cvt9zNZG5Moa9yejZdqDviyC6FZ/mzFfITGTou8EwHwv71Ju6JDHXQHPuD1
X-Received: by 2002:a17:906:eb96:: with SMTP id mh22mr16016999ejb.186.1554265837729;
        Tue, 02 Apr 2019 21:30:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554265837; cv=none;
        d=google.com; s=arc-20160816;
        b=Kr7vFewF8zuHyq8DnL4FSRNSVDcTopZN8++ezNcNt5KGL8ZYcZjoRRcOn6HPlXQjQ8
         3/anH3D9cqlJJqm9TuVGjYLrr0riOyh44qzhrei6doX0q/lgeth0l+3HUEbn/BtePRWK
         K8Ad1r8uoGW77jfpB31SNjcZetCIKVyGTruLQwBGvE9JhdqNMa0Z3htWYaKTxs2pAoKr
         JbHc47ckRHUH3N0CjyKXWjlQPvtJ/WXHzaGJRhHRPL3HhERvcExJjgJDR5GElsFaTaI+
         assAdwnRojeUpM6ZT4RmT4ycLLESLObifV4/hb3G0XvWZqsIeFNTAp6J0L71lQGeXpwG
         AdWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=0tmsegy5nwxeJ1f1itRRHuF3L7n3Cp7BKyoDWcbyACM=;
        b=yQbAwoyHdDYHDxZ9TopL3PKNF3TeavkqRM1kqxvusCH7PjpBCwUOS03KjzNnxNTtQ5
         f6N6X9+8tLlNHAkdmt6TcQHpQO7uiPQxnqRvYUKUwy6TgtUKefeefaT7JF4wAOgKCGts
         VyUBs/C5oL/fCqreyvtqbeC4fK1sH3RCtVfyg1iCVVsYNY3u29nVBWaOLSiYne2xaJap
         zTmpnAwqBAd8R3uQidHuvEdXGsJexTEJ67d5wCA0ISTHOXxvR9amdzKjyecsDdx1w6/O
         3GTmUNbxMfHROZE+EHItqkDE1z/SY7jKzghW3XHspXr+0ARV5RgIcEH3PnOIwmbNIaim
         xUAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x22si2315220ejf.205.2019.04.02.21.30.37
        for <linux-mm@kvack.org>;
        Tue, 02 Apr 2019 21:30:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8B98F1993;
	Tue,  2 Apr 2019 21:30:36 -0700 (PDT)
Received: from p8cg001049571a15.arm.com (unknown [10.163.1.97])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id EF1B43F721;
	Tue,  2 Apr 2019 21:30:30 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	akpm@linux-foundation.org,
	will.deacon@arm.com,
	catalin.marinas@arm.com
Cc: mhocko@suse.com,
	mgorman@techsingularity.net,
	james.morse@arm.com,
	mark.rutland@arm.com,
	robin.murphy@arm.com,
	cpandya@codeaurora.org,
	arunks@codeaurora.org,
	dan.j.williams@intel.com,
	osalvador@suse.de,
	logang@deltatee.com,
	pasha.tatashin@oracle.com,
	david@redhat.com,
	cai@lca.pw
Subject: [PATCH 4/6] mm/hotplug: Reorder arch_remove_memory() call in __remove_memory()
Date: Wed,  3 Apr 2019 10:00:04 +0530
Message-Id: <1554265806-11501-5-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Memory hot remove uses get_nid_for_pfn() while tearing down linked sysfs
entries between memory block and node. It first checks pfn validity with
pfn_valid_within() before fetching nid. With CONFIG_HOLES_IN_ZONE config
(arm64 has this enabled) pfn_valid_within() calls pfn_valid().

pfn_valid() is an arch implementation on arm64 (CONFIG_HAVE_ARCH_PFN_VALID)
which scans all mapped memblock regions with memblock_is_map_memory(). This
creates a problem in memory hot remove path which has already removed given
memory range from memory block with memblock_[remove|free] before arriving
at unregister_mem_sect_under_nodes(). Hence get_nid_for_pfn() returns -1
skipping subsequent sysfs_remove_link() calls leaving node <-> memory block
sysfs entries as is. Subsequent memory add operation hits BUG_ON() because
of existing sysfs entries.

[   62.007176] NUMA: Unknown node for memory at 0x680000000, assuming node 0
[   62.052517] ------------[ cut here ]------------
[   62.053211] kernel BUG at mm/memory_hotplug.c:1143!
[   62.053868] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
[   62.054589] Modules linked in:
[   62.054999] CPU: 19 PID: 3275 Comm: bash Not tainted 5.1.0-rc2-00004-g28cea40b2683 #41
[   62.056274] Hardware name: linux,dummy-virt (DT)
[   62.057166] pstate: 40400005 (nZcv daif +PAN -UAO)
[   62.058083] pc : add_memory_resource+0x1cc/0x1d8
[   62.058961] lr : add_memory_resource+0x10c/0x1d8
[   62.059842] sp : ffff0000168b3ce0
[   62.060477] x29: ffff0000168b3ce0 x28: ffff8005db546c00
[   62.061501] x27: 0000000000000000 x26: 0000000000000000
[   62.062509] x25: ffff0000111ef000 x24: ffff0000111ef5d0
[   62.063520] x23: 0000000000000000 x22: 00000006bfffffff
[   62.064540] x21: 00000000ffffffef x20: 00000000006c0000
[   62.065558] x19: 0000000000680000 x18: 0000000000000024
[   62.066566] x17: 0000000000000000 x16: 0000000000000000
[   62.067579] x15: ffffffffffffffff x14: ffff8005e412e890
[   62.068588] x13: ffff8005d6b105d8 x12: 0000000000000000
[   62.069610] x11: ffff8005d6b10490 x10: 0000000000000040
[   62.070615] x9 : ffff8005e412e898 x8 : ffff8005e412e890
[   62.071631] x7 : ffff8005d6b105d8 x6 : ffff8005db546c00
[   62.072640] x5 : 0000000000000001 x4 : 0000000000000002
[   62.073654] x3 : ffff8005d7049480 x2 : 0000000000000002
[   62.074666] x1 : 0000000000000003 x0 : 00000000ffffffef
[   62.075685] Process bash (pid: 3275, stack limit = 0x00000000d754280f)
[   62.076930] Call trace:
[   62.077411]  add_memory_resource+0x1cc/0x1d8
[   62.078227]  __add_memory+0x70/0xa8
[   62.078901]  probe_store+0xa4/0xc8
[   62.079561]  dev_attr_store+0x18/0x28
[   62.080270]  sysfs_kf_write+0x40/0x58
[   62.080992]  kernfs_fop_write+0xcc/0x1d8
[   62.081744]  __vfs_write+0x18/0x40
[   62.082400]  vfs_write+0xa4/0x1b0
[   62.083037]  ksys_write+0x5c/0xc0
[   62.083681]  __arm64_sys_write+0x18/0x20
[   62.084432]  el0_svc_handler+0x88/0x100
[   62.085177]  el0_svc+0x8/0xc

Re-ordering arch_remove_memory() with memblock_[free|remove] solves the
problem on arm64 as pfn_valid() behaves correctly and returns positive
as memblock for the address range still exists. arch_remove_memory()
removes applicable memory sections from zone with __remove_pages() and
tears down kernel linear mapping. Removing memblock regions afterwards
is consistent.

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 mm/memory_hotplug.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 0082d69..71d0d79 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1872,11 +1872,10 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
 
 	/* remove memmap entry */
 	firmware_map_remove(start, start + size, "System RAM");
+	arch_remove_memory(nid, start, size, NULL);
 	memblock_free(start, size);
 	memblock_remove(start, size);
 
-	arch_remove_memory(nid, start, size, NULL);
-
 	try_offline_node(nid);
 
 	mem_hotplug_done();
-- 
2.7.4

