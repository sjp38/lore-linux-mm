Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8210FC28CC1
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 09:16:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5408120665
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 09:16:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5408120665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5E866B000C; Wed, 29 May 2019 05:16:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E12126B0010; Wed, 29 May 2019 05:16:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD7A16B0266; Wed, 29 May 2019 05:16:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7FBAD6B000C
	for <linux-mm@kvack.org>; Wed, 29 May 2019 05:16:31 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z5so2484007edz.3
        for <linux-mm@kvack.org>; Wed, 29 May 2019 02:16:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=JZND1Y4YyPcCZ9xJ+jjp+6LxXZaNcWkZP+CX//HNdqM=;
        b=QmI66DEGdY46MGEjopgZOoIfJ6PQo+EpoAScsLu1yf761LCdCL1dTM8wqnKX7rvTCa
         JZcOHeaPScFGDmxwCDFHhPa6chnJfUP7ROE/NAuyg/7jM09a9+jkaTVpUd2YRzFumUTR
         IL0JUVOLumjxjAXr+T3f2JyfvuUSUP85ZYr9yu/m6iFVxx6lBkyqVIwZZNM4rEbzHtSz
         DlyQfZwDR8/gnRK66BV1ESHcgmTJj4jQ0PARNPQljRXX5FSDTcXx6KYHueY/SoPemNbx
         6+5E/33XHGryfaSSwDhfPm4UKUsk9hfrp8hY/O+z2phBDdCB6ppdA9WXzNsP27H8RNqf
         pejg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAW6haBna82ePq9gmpKAeG6EHPX1F3cPSYKZx/lbVb8dxsQ2LcxF
	G6k0Ah35XhHt6XUKto1j0dm3rqJk21KghQvDmP7YwzR/nI/HaBgHrWuRvMqU1lIYMu+NGB8EiBf
	F2LsdnG4r9JcEGfLYhLiLLNTxCL3/jMQEvNu3PAJ6v1PXmHFgF+BWzJ1vQPsA+VuL7A==
X-Received: by 2002:a17:906:1288:: with SMTP id k8mr23941676ejb.303.1559121390971;
        Wed, 29 May 2019 02:16:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAZIYYZrXGkvB2urvZu066i/7lVWq6xbHie7nXQBk9FDtF5mC8KejeifTGzXJUy6qq8qH8
X-Received: by 2002:a17:906:1288:: with SMTP id k8mr23941602ejb.303.1559121389808;
        Wed, 29 May 2019 02:16:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559121389; cv=none;
        d=google.com; s=arc-20160816;
        b=FJ+xmR7akRsNRlo2LEqwFYpplmmX6x9E2zE9itliP8zHnIkBo05gRe6YyrC3zkoo9r
         3JtP/IkvXMDKWY0HcWqOMlP3kT4rTbsGsqdwOGXbkpklnqB5CEiN4BqJESb6bZ9/qp9g
         nr7Empird20Xvd7NkHFthVbTbbs+/WTYVzmkwIjNgqrdHSlPbzKKj6VBv1aNJcJri4HU
         BTi80kvwiyaTVvsvPzrsKX3voRZCMI2sIx1Lq+nTG/z8//Mwix1jn6n+ztHZe0XjHCyT
         6St1MoXQJQM7Wdrr9mj45E4ZmPARjTkdSjMgenndmAH/OBMpJcQ7vxyJ1OETULEaxtez
         0PAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=JZND1Y4YyPcCZ9xJ+jjp+6LxXZaNcWkZP+CX//HNdqM=;
        b=Q7UDBRWwP0npPcDdw72pQkgnncG6rfDRg8x3PLb08MyfxkrSnn712uTpt3leUSfAgX
         c4cReyyjJnEytbFoWx6YAm7ikiJG1HIrMKR0QnTD6EjtU+ViBCK7XmArLwwtHvfVGYKg
         gpRKivv2LHKQF0NwYv/ZnS5cNSb9FtoHKk9H5UhU3ts3GjM2x3QUQcsvQv7b+imFPB2T
         1kcnTPM6UDeib7s270adSDQHVpGKEY7IKQzn5wOmma5lHO2/nyKJlHKDXyY52D9IpoI7
         6IES5HpcBXNeuFCZeRoRU7H6OAxTJEqfaSjgnIacem9QpEKpGFuLYox6EXrfbrZn89Yf
         yGHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h18si4738282ejq.269.2019.05.29.02.16.29
        for <linux-mm@kvack.org>;
        Wed, 29 May 2019 02:16:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id AFFB7A78;
	Wed, 29 May 2019 02:16:28 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.41.181])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 6FDE23F5AF;
	Wed, 29 May 2019 02:16:23 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org,
	catalin.marinas@arm.com,
	will.deacon@arm.com
Cc: mark.rutland@arm.com,
	mhocko@suse.com,
	ira.weiny@intel.com,
	david@redhat.com,
	cai@lca.pw,
	logang@deltatee.com,
	james.morse@arm.com,
	cpandya@codeaurora.org,
	arunks@codeaurora.org,
	dan.j.williams@intel.com,
	mgorman@techsingularity.net,
	osalvador@suse.de,
	ard.biesheuvel@arm.com
Subject: [PATCH V5 1/3] mm/hotplug: Reorder arch_remove_memory() call in __remove_memory()
Date: Wed, 29 May 2019 14:46:25 +0530
Message-Id: <1559121387-674-2-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1559121387-674-1-git-send-email-anshuman.khandual@arm.com>
References: <1559121387-674-1-git-send-email-anshuman.khandual@arm.com>
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
is safe because there is no other memblock (bootmem) allocator user that
late. So nobody is going to allocate from the removed range just to blow
up later. Also nobody should be using the bootmem allocated range else
we wouldn't allow to remove it. So reordering is indeed safe.

Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: David Hildenbrand <david@redhat.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 mm/memory_hotplug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e096c98..67dfdb8 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1851,10 +1851,10 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
 
 	/* remove memmap entry */
 	firmware_map_remove(start, start + size, "System RAM");
+	arch_remove_memory(nid, start, size, NULL);
 	memblock_free(start, size);
 	memblock_remove(start, size);
 
-	arch_remove_memory(nid, start, size, NULL);
 	__release_memory_resource(start, size);
 
 	try_offline_node(nid);
-- 
2.7.4

