Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B345C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:02:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3E4D217F5
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:02:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="bn9CB8uQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3E4D217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 270BE6B0005; Wed, 27 Mar 2019 14:02:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 220EA6B0006; Wed, 27 Mar 2019 14:02:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E9C26B0007; Wed, 27 Mar 2019 14:02:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C83896B0005
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:02:26 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i23so14671547pfa.0
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:02:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dWYvGUbTzzKvOdF7nmXjedlOhm9Y8mmuknLbtd8dgVw=;
        b=U58nabOT8YHmV1C0UFrcdfBg6oq90nB/TE4YZE79ZwCty3YTkNM+b+0RR8eq3T1pbd
         ZUc+3Qc+X/lC9G670kS/Wyr2XPkouSbHFJbp8q5o0LgTug0fDttyyqxR6bOuI4q0PKIJ
         spVWKqEGhJmZNRffYyyA6Ps0UIztxGa5Kkjcw9bcidxijhwvhdeLnEIBH5NQbzuPFJej
         ZDdDt+zYJeQZtGTrxwijrUJBe0xkigeibedD0T2u+bubOx02MIH3CPl4mxjAp5aKUKAT
         Oy3awaGFMTM88/6Vq1nSE0hwLMKhePuwqH7qZASeNE3ov1p6ULSKeSsoML3pozB7G+UP
         TnBw==
X-Gm-Message-State: APjAAAXD5l4ZXhRKCugaCXfZDA6SdUfz0yaStoBB7iFLKHQv8gMylDRp
	TaFfVtSsqmOgHu5LKvPUV35J72jD8PJgJ8OPytkgI8iB3At5Vk/uCLaQ74yeo6BYtaEb3ICQs4H
	GuTHaD1cmMsJgoAMdUkaPFR+VYzAEYknfWzxg7xhNtd3pZNOGQSzlke8DOOorQAetWA==
X-Received: by 2002:a62:b602:: with SMTP id j2mr23631375pff.68.1553709746459;
        Wed, 27 Mar 2019 11:02:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxurqpjLmxcpozGSENRnRGwTMxJiZZJ7xuGWLoud2l3oQj5eXNp1bDOnebCDrSD4UK1Ffrg
X-Received: by 2002:a62:b602:: with SMTP id j2mr23631300pff.68.1553709745618;
        Wed, 27 Mar 2019 11:02:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553709745; cv=none;
        d=google.com; s=arc-20160816;
        b=VV7Ut6hwqi2NLYUutymM9wW1P3b0kciJNFZfCmdRd1h1jkPRqDR3q13gb+vBqQviwG
         69tHndTjN5mkzwaZ3Uc9h3bNvPdhz2Ul6jpCww7aA3IuYxj/GqzSVfc1T9kxZzIVi5pG
         bGcr5dbzjGf2c2gCng6yQJo6CtCNHvJ+GYiLgCjGJfIcUKMJxfWmp2GCScFbp6PoqF0A
         6ZXI/f+qjfgLxBH4/w7iPhTVOzpSAXfuMNuvSIHsFoIswQfaTJH631HFV/WBsWkYuwII
         B1MvYdDFyGc2BH58sH0B0jUF2IQ7tUlhC0hte0SBmmyz/KKjIZBZVckuOaCfkVEkTqgE
         uVYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=dWYvGUbTzzKvOdF7nmXjedlOhm9Y8mmuknLbtd8dgVw=;
        b=pL87JPRM7YFOqur66Lo0Q+f8pTUoTKZDIBBSykK1pcMDKrFTEadVvvN4bPauTeAp+0
         /3LhhDscY9hji/hZwXTS0WJN5Dws2DVqr1lcnG0xbNhi/oUZd6PKFFTEhY6poU9uR+s6
         viT8NsiBMaawFq7lF37P0leYii52H5nJ54ZfVXfXfK1CSttU8PPDok7RdxngEZ3ULHzB
         8mvpuPTN4nvSf56s5F5Yr69b4Fia+82qaiz2Nzus41zKhgE8yqbKwu4v9sJG2pvFG511
         mtIf+PzLLEAdDSOxPJFHSlhF9WWDDv8Z0fL0g4MDKezHC6RKUimj2ssO8dpXKKfJPOFO
         FC1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bn9CB8uQ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v131si16883152pgb.452.2019.03.27.11.02.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:02:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bn9CB8uQ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CB1A52146F;
	Wed, 27 Mar 2019 18:02:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553709745;
	bh=hOyhfl2oQp9beaVEdiXpd/rNdZl7HVN7AZx/JZPGlhI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=bn9CB8uQTyuorEN8f+aOAe1Szm8Ck4wwzvHTCusv1mSK24/7AXgrPpNDaoswKU+8G
	 ygZ4WKaNUbXK/ZwNXY90G2GBJvSSIJ45DI1/iiOBgqyv7rUzwHb5bvBNrfGaHQ3+Cl
	 T7m7TJpkoxAOW4KsvrK0r19PzW28WD7bqkqossIM=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Mike Rapoport <rppt@linux.ibm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Christoph Hellwig <hch@lst.de>,
	"David S. Miller" <davem@davemloft.net>,
	Dennis Zhou <dennis@kernel.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Greentime Hu <green.hu@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Guan Xuetao <gxt@pku.edu.cn>,
	Guo Ren <guoren@kernel.org>,
	Guo Ren <ren_guo@c-sky.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Juergen Gross <jgross@suse.com>,
	Mark Salter <msalter@redhat.com>,
	Matt Turner <mattst88@gmail.com>,
	Max Filippov <jcmvbkbc@gmail.com>,
	Michal Simek <monstr@monstr.eu>,
	Paul Burton <paul.burton@mips.com>,
	Petr Mladek <pmladek@suse.com>,
	Richard Weinberger <richard@nod.at>,
	Rich Felker <dalias@libc.org>,
	Rob Herring <robh+dt@kernel.org>,
	Rob Herring <robh@kernel.org>,
	Russell King <linux@armlinux.org.uk>,
	Stafford Horne <shorne@gmail.com>,
	Tony Luck <tony.luck@intel.com>,
	Vineet Gupta <vgupta@synopsys.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linuxppc-dev@lists.ozlabs.org,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 015/262] memblock: memblock_phys_alloc_try_nid(): don't panic
Date: Wed, 27 Mar 2019 13:57:50 -0400
Message-Id: <20190327180158.10245-15-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327180158.10245-1-sashal@kernel.org>
References: <20190327180158.10245-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Mike Rapoport <rppt@linux.ibm.com>

[ Upstream commit 337555744e6e39dd1d87698c6084dd88a606d60a ]

The memblock_phys_alloc_try_nid() function tries to allocate memory from
the requested node and then falls back to allocation from any node in
the system.  The memblock_alloc_base() fallback used by this function
panics if the allocation fails.

Replace the memblock_alloc_base() fallback with the direct call to
memblock_alloc_range_nid() and update the memblock_phys_alloc_try_nid()
callers to check the returned value and panic in case of error.

Link: http://lkml.kernel.org/r/1548057848-15136-7-git-send-email-rppt@linux.ibm.com
Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
Acked-by: Michael Ellerman <mpe@ellerman.id.au>		[powerpc]
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Christoph Hellwig <hch@lst.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Dennis Zhou <dennis@kernel.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Greentime Hu <green.hu@gmail.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Guan Xuetao <gxt@pku.edu.cn>
Cc: Guo Ren <guoren@kernel.org>
Cc: Guo Ren <ren_guo@c-sky.com>				[c-sky]
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Juergen Gross <jgross@suse.com>			[Xen]
Cc: Mark Salter <msalter@redhat.com>
Cc: Matt Turner <mattst88@gmail.com>
Cc: Max Filippov <jcmvbkbc@gmail.com>
Cc: Michal Simek <monstr@monstr.eu>
Cc: Paul Burton <paul.burton@mips.com>
Cc: Petr Mladek <pmladek@suse.com>
Cc: Richard Weinberger <richard@nod.at>
Cc: Rich Felker <dalias@libc.org>
Cc: Rob Herring <robh+dt@kernel.org>
Cc: Rob Herring <robh@kernel.org>
Cc: Russell King <linux@armlinux.org.uk>
Cc: Stafford Horne <shorne@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 arch/arm64/mm/numa.c   | 4 ++++
 arch/powerpc/mm/numa.c | 4 ++++
 mm/memblock.c          | 4 +++-
 3 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
index ae34e3a1cef1..2c61ea4e290b 100644
--- a/arch/arm64/mm/numa.c
+++ b/arch/arm64/mm/numa.c
@@ -237,6 +237,10 @@ static void __init setup_node_data(int nid, u64 start_pfn, u64 end_pfn)
 		pr_info("Initmem setup node %d [<memory-less node>]\n", nid);
 
 	nd_pa = memblock_phys_alloc_try_nid(nd_size, SMP_CACHE_BYTES, nid);
+	if (!nd_pa)
+		panic("Cannot allocate %zu bytes for node %d data\n",
+		      nd_size, nid);
+
 	nd = __va(nd_pa);
 
 	/* report and initialize */
diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index 87f0dd004295..8ec2ed30d44c 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -788,6 +788,10 @@ static void __init setup_node_data(int nid, u64 start_pfn, u64 end_pfn)
 	int tnid;
 
 	nd_pa = memblock_phys_alloc_try_nid(nd_size, SMP_CACHE_BYTES, nid);
+	if (!nd_pa)
+		panic("Cannot allocate %zu bytes for node %d data\n",
+		      nd_size, nid);
+
 	nd = __va(nd_pa);
 
 	/* report and initialize */
diff --git a/mm/memblock.c b/mm/memblock.c
index ea31045ba704..d5923df56acc 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1342,7 +1342,9 @@ phys_addr_t __init memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t ali
 
 	if (res)
 		return res;
-	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
+	return memblock_alloc_range_nid(size, align, 0,
+					MEMBLOCK_ALLOC_ACCESSIBLE,
+					NUMA_NO_NODE, MEMBLOCK_NONE);
 }
 
 /**
-- 
2.19.1

