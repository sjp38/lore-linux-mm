Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 902D4C28CC5
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:20:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DEF7272DE
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:20:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="mHDCelFL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DEF7272DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FB1F6B027D; Sat,  1 Jun 2019 09:20:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AD936B027E; Sat,  1 Jun 2019 09:20:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19B516B0280; Sat,  1 Jun 2019 09:20:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C3AE16B027D
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:20:18 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id k23so4286283pgh.10
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:20:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SVd5wm86dE1jOuxPHa00ZWw4TwzzqXWy+5qFrO8Pupc=;
        b=CFXvwJwwGuKbkf3DodGRX40ICcX3lyPyNCsUD4BvLAUXJ73xZ9fB6DNa3arJ3XzKDk
         CbMjNqxaBWp94dIR/uRhYYyiBu9qO9B2NNRFuH3WZqN5Wo1YZYrgm7a0z1SwfAK7XJJI
         riu8Vp/tPRYn1T79K2ynZoY7SHrF7tbZ4uqJH1hT4bUaZv4EbHEhDHzZBDd0WH4pG7jK
         AhfDuJaff8KEa3HI977lG9apFSkpnZCNH6vpt20AyrJeYKVhVfQubvZDa7m/3y3raobJ
         UxKrgogYTJFu4mZtyBmO8gWONXzZLSnJ9EsRfbhbFxuRycBtX4PHIPRHTTyTT8HS2izK
         LR7w==
X-Gm-Message-State: APjAAAW0TrG7gZN4I6zjENRC+w74d0pJubzxsAJRt0UtQC2bMAiWvFCT
	jtErnK5Xwq25pHwHoXENSnczeLTpkzTZGslWUI4UlCVE+BuWqegPHKRth3og38K6PK0YVOoEePb
	rYAuXhabmmlS62K/4d6xemCVd3TUCkx+hJ6AnMsP7Phes8Cue5Shn5JXb1/YjqYpiJQ==
X-Received: by 2002:aa7:8294:: with SMTP id s20mr9106462pfm.75.1559395218395;
        Sat, 01 Jun 2019 06:20:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNpA85cGpZoK3bP/xNPaNnuPKu8dwwSqvAtKdS6d5ZBfPwKD4x73br0Ff6bhjyRc96SN2f
X-Received: by 2002:aa7:8294:: with SMTP id s20mr9106375pfm.75.1559395217527;
        Sat, 01 Jun 2019 06:20:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395217; cv=none;
        d=google.com; s=arc-20160816;
        b=zEoPIi/g1eLXyuCf37W8wOVgayCmvw8GuBnHsCVGv0yN24oVVuoiJJSzV7Cp/e9ijw
         NM+ZRG/AwU43GjZ+i3BAFQA4KJQPb0JBHpPQ34/O+zxDlDDCmZfUugKoH9JqeEDqpPd5
         nFkdT0nCFyzyCPovHrqBacDRw1I3/TGl9IooIBOYAIf1u0p6Row8Z3I+s0B6j5/8hZQR
         kgpLS1az/EHPWHr9xB4P9SgO0S3Hw+XSyzt4Y/6dNLukkM2IHPdpb4j2hXdtoS0OW0Xy
         RJMfeyR3Mx378cpDSTEifkAsFHuJbKDk16eNIIkaiewt9LlTd1AvH4SPeIeVYANmbzY/
         f7Hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=SVd5wm86dE1jOuxPHa00ZWw4TwzzqXWy+5qFrO8Pupc=;
        b=QOrp88C4jHe6nwXvNkGh4/3oqqp/ElPZiEuMZS7PUn/96WxvxHGnULvl2z8VFfMFtZ
         mEJMqzS6xSW8A9DM3m+ql/RzLqu+Y6JykHYTIsJAfXilcHtB1SkeoXQL6iO6WgGIrD9w
         jpFuGPJg1UjfElP0KMVVR6fQf6snEzf9M8D70dmFbC1W0EBIgmwdCBu/L9kS57tzNgOH
         Zb8eWjUAMs/FTkj0yr6V0TWaEHrbSmkDu2sTm1LbL1/2pKw20Rrwgb4yrkzvpKRjuxK+
         jmlW4NDDL6EhXhfc6MXlA3TMe/aps8RMF5/AdXMsluo/ZFvnHbnqd/0Pa6dKez14Sy4M
         58eg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mHDCelFL;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b61si10559184pjc.46.2019.06.01.06.20.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:20:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mHDCelFL;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 04F89272E6;
	Sat,  1 Jun 2019 13:20:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395217;
	bh=ScgJYkGTk/PhPT3kjMb9ADqbqdufWP7M/9PRoLC1WvQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=mHDCelFL7I+6zvUsFsCkioMT7E3sWaMnhhGNDf34Bm1e1EjH5qe40sRJ5aZsMMAnb
	 yG94GWrBuY9ZOCYS2nVVB/WgikA1FapTtovCHV3usFMEFsekm+jY2CoGr5T9dtLaW/
	 DBHW4uDn36qp2LQ/0evnv0SGkq2jFFVUd1tKyW0g=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>,
	Andrew Banman <andrew.banman@hpe.com>,
	Andy Lutomirski <luto@kernel.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Borislav Petkov <bp@alien8.de>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@kernel.org>,
	Ingo Molnar <mingo@redhat.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Travis <mike.travis@hpe.com>,
	Nicholas Piggin <npiggin@gmail.com>,
	Oscar Salvador <osalvador@suse.com>,
	Paul Mackerras <paulus@samba.org>,
	Peter Zijlstra <peterz@infradead.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Rich Felker <dalias@libc.org>,
	Rob Herring <robh@kernel.org>,
	Stefan Agner <stefan@agner.ch>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tony Luck <tony.luck@intel.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 012/173] mm/memory_hotplug: release memory resource after arch_remove_memory()
Date: Sat,  1 Jun 2019 09:16:44 -0400
Message-Id: <20190601131934.25053-12-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601131934.25053-1-sashal@kernel.org>
References: <20190601131934.25053-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: David Hildenbrand <david@redhat.com>

[ Upstream commit d9eb1417c77df7ce19abd2e41619e9dceccbdf2a ]

Patch series "mm/memory_hotplug: Better error handling when removing
memory", v1.

Error handling when removing memory is somewhat messed up right now.  Some
errors result in warnings, others are completely ignored.  Memory unplug
code can essentially not deal with errors properly as of now.
remove_memory() will never fail.

We have basically two choices:
1. Allow arch_remov_memory() and friends to fail, propagating errors via
   remove_memory(). Might be problematic (e.g. DIMMs consisting of multiple
   pieces added/removed separately).
2. Don't allow the functions to fail, handling errors in a nicer way.

It seems like most errors that can theoretically happen are really corner
cases and mostly theoretical (e.g.  "section not valid").  However e.g.
aborting removal of sections while all callers simply continue in case of
errors is not nice.

If we can gurantee that removal of memory always works (and WARN/skip in
case of theoretical errors so we can figure out what is going on), we can
go ahead and implement better error handling when adding memory.

E.g. via add_memory():

arch_add_memory()
ret = do_stuff()
if (ret) {
	arch_remove_memory();
	goto error;
}

Handling here that arch_remove_memory() might fail is basically
impossible.  So I suggest, let's avoid reporting errors while removing
memory, warning on theoretical errors instead and continuing instead of
aborting.

This patch (of 4):

__add_pages() doesn't add the memory resource, so __remove_pages()
shouldn't remove it.  Let's factor it out.  Especially as it is a special
case for memory used as system memory, added via add_memory() and friends.

We now remove the resource after removing the sections instead of doing it
the other way around.  I don't think this change is problematic.

add_memory()
	register memory resource
	arch_add_memory()

remove_memory
	arch_remove_memory()
	release memory resource

While at it, explain why we ignore errors and that it only happeny if
we remove memory in a different granularity as we added it.

[david@redhat.com: fix printk warning]
  Link: http://lkml.kernel.org/r/20190417120204.6997-1-david@redhat.com
Link: http://lkml.kernel.org/r/20190409100148.24703-2-david@redhat.com
Signed-off-by: David Hildenbrand <david@redhat.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Mathieu Malaterre <malat@debian.org>
Cc: Andrew Banman <andrew.banman@hpe.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Mike Travis <mike.travis@hpe.com>
Cc: Nicholas Piggin <npiggin@gmail.com>
Cc: Oscar Salvador <osalvador@suse.com>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Rich Felker <dalias@libc.org>
Cc: Rob Herring <robh@kernel.org>
Cc: Stefan Agner <stefan@agner.ch>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Vasily Gorbik <gor@linux.ibm.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/memory_hotplug.c | 35 +++++++++++++++++++++--------------
 1 file changed, 21 insertions(+), 14 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 7493f50ee8800..e06e7a89d0e5b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -559,20 +559,6 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 	if (is_dev_zone(zone)) {
 		if (altmap)
 			map_offset = vmem_altmap_offset(altmap);
-	} else {
-		resource_size_t start, size;
-
-		start = phys_start_pfn << PAGE_SHIFT;
-		size = nr_pages * PAGE_SIZE;
-
-		ret = release_mem_region_adjustable(&iomem_resource, start,
-					size);
-		if (ret) {
-			resource_size_t endres = start + size - 1;
-
-			pr_warn("Unable to release resource <%pa-%pa> (%d)\n",
-					&start, &endres, ret);
-		}
 	}
 
 	clear_zone_contiguous(zone);
@@ -1828,6 +1814,26 @@ void try_offline_node(int nid)
 }
 EXPORT_SYMBOL(try_offline_node);
 
+static void __release_memory_resource(resource_size_t start,
+				      resource_size_t size)
+{
+	int ret;
+
+	/*
+	 * When removing memory in the same granularity as it was added,
+	 * this function never fails. It might only fail if resources
+	 * have to be adjusted or split. We'll ignore the error, as
+	 * removing of memory cannot fail.
+	 */
+	ret = release_mem_region_adjustable(&iomem_resource, start, size);
+	if (ret) {
+		resource_size_t endres = start + size - 1;
+
+		pr_warn("Unable to release resource <%pa-%pa> (%d)\n",
+			&start, &endres, ret);
+	}
+}
+
 /**
  * remove_memory
  * @nid: the node ID
@@ -1862,6 +1868,7 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
 	memblock_remove(start, size);
 
 	arch_remove_memory(nid, start, size, NULL);
+	__release_memory_resource(start, size);
 
 	try_offline_node(nid);
 
-- 
2.20.1

