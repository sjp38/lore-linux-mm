Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA9D8C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 11:49:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 844472053B
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 11:49:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="znIzqg9/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 844472053B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3BA16B0005; Wed, 15 May 2019 07:49:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DEC416B0006; Wed, 15 May 2019 07:49:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDAC96B0007; Wed, 15 May 2019 07:49:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6A0586B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 07:49:51 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id y62so547195lfc.16
        for <linux-mm@kvack.org>; Wed, 15 May 2019 04:49:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=alH5k1PNJm4GaPT+kDtijaHC8uREaNw9t/O/7YUmZy4=;
        b=ewSzbO1PGynkeW0UNclH68vImG78pcKX01UckE85Sc9AQveYNEoqTYFBFZfEQg25fj
         Sb1BS3DsA1ue/7yaoDveTRUlKCamzqRkRFHdSCyo7KM6ydAioB7kKR8K0BBEqlzKyycn
         06mwn7EevIKLg61/mQ45rGHKIseaEuXbPONlD3xhvjIxnDXD7UFPZlb0eR5F51YVk/bd
         Iy2kgaZjtzgyiSZkB7usne8PHHVnZf8vE0r/nH5o8uHZIJvZa+dNUP7hYl6h0i9aEYIr
         //dLli8GZl1YMs/HEMfk+6y+ilsisXZ2vP5A8n9F++WjTTdW8xF1iQwyFCcoZyMGw+hT
         Dgag==
X-Gm-Message-State: APjAAAWt9lYcWfwNK8YwqU22cuPtQnzghESISkGhrTRSnG6uynKUHQwo
	UL1aUEhG3YhAwR5lPw5/K4b38uN+2LEZ54PmBhe1lMqo5W8Mymt2Mu3kZzX/+gbeFQS3yLWq3B9
	aC3q96wQ2P2a5+7FthIYZkpQbgIlcSJocCKYurTj2vCy3HmgvF1RkES6gp8NSntl2qQ==
X-Received: by 2002:a05:6512:6c:: with SMTP id i12mr1477500lfo.130.1557920990732;
        Wed, 15 May 2019 04:49:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxChAZ688gux2Bjq8Al/WThOdeem+MprtA6cmCHjEP0Mly+GpnV3pX69z8lzV1w+GRgq+EH
X-Received: by 2002:a05:6512:6c:: with SMTP id i12mr1477433lfo.130.1557920989360;
        Wed, 15 May 2019 04:49:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557920989; cv=none;
        d=google.com; s=arc-20160816;
        b=TCOVt67zUe08wWNqGePqhU45g6Tlm9VZIV67hKxsRAJCpfQYhk4DL7pkPIknPO0DzZ
         BgzPlOJGP5x3kNITgEwQ1zhFs/L+zNVphvXynPek+axp3KnyK0+xMmXZuS00pdizG+Cj
         pAM/aTXeTEFo9w3H2+4aX2CiULDOla4AMeePamNQK/YOZZA9UuXHpiKf7++RguIgFBs6
         Nqoy4cnO1u0Ly0I4q/Ut9Z8EQGcRbKyybN0btB88KqpGlypJJcqkqeM8xf9ghAXQhfgQ
         cZDbrHVH+Z33tCJHE6D/tSntizcbktvwD7a3I9hc5X9sXsypKZB/aMxMPnOyWsEc/X6i
         QfOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :to:from:subject:dkim-signature;
        bh=alH5k1PNJm4GaPT+kDtijaHC8uREaNw9t/O/7YUmZy4=;
        b=dd2Y3k3B2xOqhG4CVZ+rebiK0SWgJdf9KZ7XS99oFObT69/vArmnCEqja7dNw97pY2
         TIzAOjdtTxtnrgPlSaxPx87hcpr45deR/rTF7c+O2FPedggmX4tq551LwKs84XM+2JPP
         2cajK9FFfEYuy/K8KrATWeLlUfvI8Nx+Ud5AF3spWB44f8Nqev31mQ2OoZ0v92wYg+rq
         IAwVVK5A7FNIa71Iiac+5LaQ1P+eexNd62D9IQNlpfC6eFMgkZHkVNh+5+jImmFpa7Qb
         /nGsqkhud+S7L+fmGRWYq6hY3PVUyrcaSOJF+1szd5z/chnh4JoGmvagJf0N0yEIqoFP
         vdhA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b="znIzqg9/";
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1j.mail.yandex.net (forwardcorp1j.mail.yandex.net. [5.45.199.163])
        by mx.google.com with ESMTP id v22si1221494ljc.99.2019.05.15.04.49.49
        for <linux-mm@kvack.org>;
        Wed, 15 May 2019 04:49:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) client-ip=5.45.199.163;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b="znIzqg9/";
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1j.mail.yandex.net (Yandex) with ESMTP id D60B82E149B;
	Wed, 15 May 2019 14:49:48 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id pJ6tum1Z9K-nm0OmG23;
	Wed, 15 May 2019 14:49:48 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1557920988; bh=alH5k1PNJm4GaPT+kDtijaHC8uREaNw9t/O/7YUmZy4=;
	h=Message-ID:Date:To:From:Subject;
	b=znIzqg9/ngOeS3fHiE8MN2BO+J2dJ6ks5jQ+p1cRHJMbe2W0/uzVk8wq6yhiG8zns
	 ChZzw7O3mUfGMNH/9nEcuU1BXNh9cFalHl9jlGpnxrwSrOeivKTgLSg5XTMhV9ZXh5
	 znBZ2y+31vvCp6gcMKP0r2/TwqssR19FpPwgEXCE=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:ed19:3833:7ce1:2324])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id b7fTz8WA2V-nml8HR87;
	Wed, 15 May 2019 14:49:48 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH RFC] proc/meminfo: add KernelMisc counter
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Wed, 15 May 2019 14:49:48 +0300
Message-ID: <155792098821.1536.17069603544573830315.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Some kernel memory allocations are not accounted anywhere.
This adds easy-read counter for them by subtracting all tracked kinds.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 Documentation/filesystems/proc.txt |    2 ++
 fs/proc/meminfo.c                  |   41 +++++++++++++++++++++++++-----------
 2 files changed, 30 insertions(+), 13 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 66cad5c86171..f11ce167124c 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -891,6 +891,7 @@ VmallocTotal:   112216 kB
 VmallocUsed:       428 kB
 VmallocChunk:   111088 kB
 Percpu:          62080 kB
+KernelMisc:     212856 kB
 HardwareCorrupted:   0 kB
 AnonHugePages:   49152 kB
 ShmemHugePages:      0 kB
@@ -988,6 +989,7 @@ VmallocTotal: total size of vmalloc memory area
 VmallocChunk: largest contiguous block of vmalloc area which is free
       Percpu: Memory allocated to the percpu allocator used to back percpu
               allocations. This stat excludes the cost of metadata.
+  KernelMisc: All other kinds of kernel memory allocaitons
 
 ..............................................................................
 
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 568d90e17c17..7bc14716fc5d 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -38,15 +38,21 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	long cached;
 	long available;
 	unsigned long pages[NR_LRU_LISTS];
-	unsigned long sreclaimable, sunreclaim;
+	unsigned long sreclaimable, sunreclaim, misc_reclaimable;
+	unsigned long kernel_stack_kb, page_tables, percpu_pages;
+	unsigned long anon_pages, file_pages, swap_cached;
+	long kernel_misc;
 	int lru;
 
 	si_meminfo(&i);
 	si_swapinfo(&i);
 	committed = percpu_counter_read_positive(&vm_committed_as);
 
-	cached = global_node_page_state(NR_FILE_PAGES) -
-			total_swapcache_pages() - i.bufferram;
+	anon_pages = global_node_page_state(NR_ANON_MAPPED);
+	file_pages = global_node_page_state(NR_FILE_PAGES);
+	swap_cached = total_swapcache_pages();
+
+	cached = file_pages - swap_cached - i.bufferram;
 	if (cached < 0)
 		cached = 0;
 
@@ -56,13 +62,25 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	available = si_mem_available();
 	sreclaimable = global_node_page_state(NR_SLAB_RECLAIMABLE);
 	sunreclaim = global_node_page_state(NR_SLAB_UNRECLAIMABLE);
+	misc_reclaimable = global_node_page_state(NR_KERNEL_MISC_RECLAIMABLE);
+	kernel_stack_kb = global_zone_page_state(NR_KERNEL_STACK_KB);
+	page_tables = global_zone_page_state(NR_PAGETABLE);
+	percpu_pages = pcpu_nr_pages();
+
+	/* all other kinds of kernel memory allocations */
+	kernel_misc = i.totalram - i.freeram - anon_pages - file_pages
+		      - sreclaimable - sunreclaim - misc_reclaimable
+		      - (kernel_stack_kb >> (PAGE_SHIFT - 10))
+		      - page_tables - percpu_pages;
+	if (kernel_misc < 0)
+		kernel_misc = 0;
 
 	show_val_kb(m, "MemTotal:       ", i.totalram);
 	show_val_kb(m, "MemFree:        ", i.freeram);
 	show_val_kb(m, "MemAvailable:   ", available);
 	show_val_kb(m, "Buffers:        ", i.bufferram);
 	show_val_kb(m, "Cached:         ", cached);
-	show_val_kb(m, "SwapCached:     ", total_swapcache_pages());
+	show_val_kb(m, "SwapCached:     ", swap_cached);
 	show_val_kb(m, "Active:         ", pages[LRU_ACTIVE_ANON] +
 					   pages[LRU_ACTIVE_FILE]);
 	show_val_kb(m, "Inactive:       ", pages[LRU_INACTIVE_ANON] +
@@ -92,20 +110,16 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		    global_node_page_state(NR_FILE_DIRTY));
 	show_val_kb(m, "Writeback:      ",
 		    global_node_page_state(NR_WRITEBACK));
-	show_val_kb(m, "AnonPages:      ",
-		    global_node_page_state(NR_ANON_MAPPED));
+	show_val_kb(m, "AnonPages:      ", anon_pages);
 	show_val_kb(m, "Mapped:         ",
 		    global_node_page_state(NR_FILE_MAPPED));
 	show_val_kb(m, "Shmem:          ", i.sharedram);
-	show_val_kb(m, "KReclaimable:   ", sreclaimable +
-		    global_node_page_state(NR_KERNEL_MISC_RECLAIMABLE));
+	show_val_kb(m, "KReclaimable:   ", sreclaimable + misc_reclaimable);
 	show_val_kb(m, "Slab:           ", sreclaimable + sunreclaim);
 	show_val_kb(m, "SReclaimable:   ", sreclaimable);
 	show_val_kb(m, "SUnreclaim:     ", sunreclaim);
-	seq_printf(m, "KernelStack:    %8lu kB\n",
-		   global_zone_page_state(NR_KERNEL_STACK_KB));
-	show_val_kb(m, "PageTables:     ",
-		    global_zone_page_state(NR_PAGETABLE));
+	seq_printf(m, "KernelStack:    %8lu kB\n", kernel_stack_kb);
+	show_val_kb(m, "PageTables:     ", page_tables);
 #ifdef CONFIG_QUICKLIST
 	show_val_kb(m, "Quicklists:     ", quicklist_total_size());
 #endif
@@ -122,7 +136,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		   (unsigned long)VMALLOC_TOTAL >> 10);
 	show_val_kb(m, "VmallocUsed:    ", 0ul);
 	show_val_kb(m, "VmallocChunk:   ", 0ul);
-	show_val_kb(m, "Percpu:         ", pcpu_nr_pages());
+	show_val_kb(m, "Percpu:         ", percpu_pages);
+	show_val_kb(m, "KernelMisc:     ", kernel_misc);
 
 #ifdef CONFIG_MEMORY_FAILURE
 	seq_printf(m, "HardwareCorrupted: %5lu kB\n",

