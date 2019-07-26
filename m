Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 439B8C76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:41:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFC8E22CD7
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:41:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="nNG3PX+Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFC8E22CD7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AF236B000E; Fri, 26 Jul 2019 09:41:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 939FC8E0003; Fri, 26 Jul 2019 09:41:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B3C88E0002; Fri, 26 Jul 2019 09:41:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4501F6B000E
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 09:41:42 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g18so28431014plj.19
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 06:41:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Bwnrp1T2+t8DrtT6DY1r7uyZsBm5+2fiJW66p2Nk8kg=;
        b=accg93HcN/VldkEMeOlMks+a3/ydmlg7ivkHTFlV+6XyfS8tu87gue/OvRSCZf2ImP
         cPIMQyXmAcipycN/aX68h6hAzen/XvoRrRzNL6EZ0POVGE+jYhM6S7IWQDe8xqJ0VhZi
         u+UkK7C/HSmNL7iVe6E7qn3Ry7LKzboaNNaFNJZYntrqsXiDNN3q0cUA13ahwQRwALwR
         A5P4N39XFQxUPHdNOFaEWrB08HgXE79cu6yzhok7rrge7GzMCd+aN8C6xsWDLGk0/jCS
         0qK/vZFJAqk2dbEQPoLuZlTcxFq0DOkEPoFrvyVKTiCvtpr8z4BWlRcC6hVvXaCBiJ8U
         oIWQ==
X-Gm-Message-State: APjAAAWhk51H4c1taRabmv2NX/EpaHDJPXhYr46JC9ew3LNYyKTdX8yn
	KQSm+Oep9CK+Qhg9aN0oshSSzyekffRUlDaQtVJhX7dAlA/OXRzZCKttNrcoEov8N5ZYc/Va8Yb
	Lu/QIAYR9jIFz+xQPUSiLD5Wvh0ROQJ1yZOljjajYI6gKtLkTYpa37C7VdV967O38JQ==
X-Received: by 2002:a62:584:: with SMTP id 126mr22470126pff.73.1564148501847;
        Fri, 26 Jul 2019 06:41:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4+2aiChRDzMqlmykt+Tu8ru1ydqWSdgCHLPOqrSOGXf5HbJil2dwZTpZmn308MRTMOZ+F
X-Received: by 2002:a62:584:: with SMTP id 126mr22470082pff.73.1564148501035;
        Fri, 26 Jul 2019 06:41:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564148501; cv=none;
        d=google.com; s=arc-20160816;
        b=YqFbSEWc8yVyRc76OCT21AJ3z9bq9pBNSwCSh1g2LaozRs1sHZPfo/j98tjzwwUWdn
         TR8QFuIj2C6zJKDmtt0OfXAhypZfof8CdBLlzdEzX73ncQVw4GRWtjtc/p44Ocq1N9lp
         GDnk4UR22E1SfaB7ZZDxPuXE4HyB3FeU2X/+XtCvf8jfD4yvwVLoIwwlIXgdxoSBisoZ
         djNlm8THhV3ya9YQ70UNwntF6EgHJruREGeUR8KIbOhB4xjRxgMETRDUJKjzH6i7dxF9
         J1pa81L+f4Hh8d8275FkM2zRNDKDBYUPs1XHHPIvPddesaOLdyTZOGbFBctjjqjCJtdb
         hUFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Bwnrp1T2+t8DrtT6DY1r7uyZsBm5+2fiJW66p2Nk8kg=;
        b=IArGnrsHs++OZ6jKpTSpO76bY101Ve7Bobk2I1TO4GJ2pBh0dnZyriXElPI2u9vFmp
         8qextATem+eSDWFbOWnUBHExR5scDxWhsyJkae/udjLKd2NeITkJ1xnl3eFyFvRpy0b5
         YMn9Yo9Ho7bwGPUx5z2bXbIp9pCSnJB3qq36+rgh+EGoxfd0U6IO6/389fAmFwyTparn
         kR5GxJTuPb/XLiDDKDLDl+31atnkWqiop1aTpAKFfwnRru1Ri+jLPOjy2HJ19uvBj6g1
         h7UzMwbO+F46aHEpPABlhtxes+qaOO36rhYDivG068ANOGMv1hZDs0dbj+UHGQOgSilk
         JHsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=nNG3PX+Y;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t15si18247871ply.162.2019.07.26.06.41.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 06:41:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=nNG3PX+Y;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6E2EB22CBF;
	Fri, 26 Jul 2019 13:41:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564148500;
	bh=MqGPuAd/09un9pvEONnjVVqLC4j4SaxXxFGtTddUVgg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=nNG3PX+Yveh4yO47r+uIQxPc7uuypydwTDmL7xsydA7LFwebemDSKnV5mGw5JhJr1
	 M1pxW1aAa7LDAPMohxnd67phQtR9rueOZuGviFv40UXEgTgHslbPbSc47kV08cjHeL
	 dQiR7hmf+G645VLh+KMoU8cDUzqN0hbqTMk5wGrA=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>,
	David Hildenbrand <david@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Borislav Petkov <bp@suse.de>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Dave Jiang <dave.jiang@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	Huang Ying <ying.huang@intel.com>,
	James Morris <jmorris@namei.org>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Keith Busch <keith.busch@intel.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Sasha Levin <sashal@kernel.org>,
	Takashi Iwai <tiwai@suse.de>,
	Tom Lendacky <thomas.lendacky@amd.com>,
	Vishal Verma <vishal.l.verma@intel.com>,
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.2 68/85] mm/hotplug: make remove_memory() interface usable
Date: Fri, 26 Jul 2019 09:39:18 -0400
Message-Id: <20190726133936.11177-68-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190726133936.11177-1-sashal@kernel.org>
References: <20190726133936.11177-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Pavel Tatashin <pasha.tatashin@soleen.com>

[ Upstream commit eca499ab3749a4537dee77ffead47a1a2c0dee19 ]

Presently the remove_memory() interface is inherently broken.  It tries
to remove memory but panics if some memory is not offline.  The problem
is that it is impossible to ensure that all memory blocks are offline as
this function also takes lock_device_hotplug that is required to change
memory state via sysfs.

So, between calling this function and offlining all memory blocks there
is always a window when lock_device_hotplug is released, and therefore,
there is always a chance for a panic during this window.

Make this interface to return an error if memory removal fails.  This
way it is safe to call this function without panicking machine, and also
makes it symmetric to add_memory() which already returns an error.

Link: http://lkml.kernel.org/r/20190517215438.6487-3-pasha.tatashin@soleen.com
Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Reviewed-by: David Hildenbrand <david@redhat.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Borislav Petkov <bp@suse.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: James Morris <jmorris@namei.org>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Sasha Levin <sashal@kernel.org>
Cc: Takashi Iwai <tiwai@suse.de>
Cc: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Vishal Verma <vishal.l.verma@intel.com>
Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 include/linux/memory_hotplug.h |  8 +++--
 mm/memory_hotplug.c            | 64 +++++++++++++++++++++++-----------
 2 files changed, 49 insertions(+), 23 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index ae892eef8b82..988fde33cd7f 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -324,7 +324,7 @@ static inline void pgdat_resize_init(struct pglist_data *pgdat) {}
 extern bool is_mem_section_removable(unsigned long pfn, unsigned long nr_pages);
 extern void try_offline_node(int nid);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
-extern void remove_memory(int nid, u64 start, u64 size);
+extern int remove_memory(int nid, u64 start, u64 size);
 extern void __remove_memory(int nid, u64 start, u64 size);
 
 #else
@@ -341,7 +341,11 @@ static inline int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 	return -EINVAL;
 }
 
-static inline void remove_memory(int nid, u64 start, u64 size) {}
+static inline int remove_memory(int nid, u64 start, u64 size)
+{
+	return -EBUSY;
+}
+
 static inline void __remove_memory(int nid, u64 start, u64 size) {}
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e096c987d261..77d1f69cdead 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1736,9 +1736,10 @@ static int check_memblock_offlined_cb(struct memory_block *mem, void *arg)
 		endpa = PFN_PHYS(section_nr_to_pfn(mem->end_section_nr + 1))-1;
 		pr_warn("removing memory fails, because memory [%pa-%pa] is onlined\n",
 			&beginpa, &endpa);
-	}
 
-	return ret;
+		return -EBUSY;
+	}
+	return 0;
 }
 
 static int check_cpu_on_node(pg_data_t *pgdat)
@@ -1821,19 +1822,9 @@ static void __release_memory_resource(resource_size_t start,
 	}
 }
 
-/**
- * remove_memory
- * @nid: the node ID
- * @start: physical address of the region to remove
- * @size: size of the region to remove
- *
- * NOTE: The caller must call lock_device_hotplug() to serialize hotplug
- * and online/offline operations before this call, as required by
- * try_offline_node().
- */
-void __ref __remove_memory(int nid, u64 start, u64 size)
+static int __ref try_remove_memory(int nid, u64 start, u64 size)
 {
-	int ret;
+	int rc = 0;
 
 	BUG_ON(check_hotplug_memory_range(start, size));
 
@@ -1841,13 +1832,13 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
 
 	/*
 	 * All memory blocks must be offlined before removing memory.  Check
-	 * whether all memory blocks in question are offline and trigger a BUG()
+	 * whether all memory blocks in question are offline and return error
 	 * if this is not the case.
 	 */
-	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
-				check_memblock_offlined_cb);
-	if (ret)
-		BUG();
+	rc = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
+			       check_memblock_offlined_cb);
+	if (rc)
+		goto done;
 
 	/* remove memmap entry */
 	firmware_map_remove(start, start + size, "System RAM");
@@ -1859,14 +1850,45 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
 
 	try_offline_node(nid);
 
+done:
 	mem_hotplug_done();
+	return rc;
 }
 
-void remove_memory(int nid, u64 start, u64 size)
+/**
+ * remove_memory
+ * @nid: the node ID
+ * @start: physical address of the region to remove
+ * @size: size of the region to remove
+ *
+ * NOTE: The caller must call lock_device_hotplug() to serialize hotplug
+ * and online/offline operations before this call, as required by
+ * try_offline_node().
+ */
+void __remove_memory(int nid, u64 start, u64 size)
+{
+
+	/*
+	 * trigger BUG() is some memory is not offlined prior to calling this
+	 * function
+	 */
+	if (try_remove_memory(nid, start, size))
+		BUG();
+}
+
+/*
+ * Remove memory if every memory block is offline, otherwise return -EBUSY is
+ * some memory is not offline
+ */
+int remove_memory(int nid, u64 start, u64 size)
 {
+	int rc;
+
 	lock_device_hotplug();
-	__remove_memory(nid, start, size);
+	rc  = try_remove_memory(nid, start, size);
 	unlock_device_hotplug();
+
+	return rc;
 }
 EXPORT_SYMBOL_GPL(remove_memory);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
-- 
2.20.1

