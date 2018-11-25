Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 524B76B3E41
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 16:45:04 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id s14so9742894pfk.16
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 13:45:04 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b4si58450537pgk.350.2018.11.25.13.45.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Nov 2018 13:45:03 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAPLi8XU095483
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 16:45:03 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2nymncf1u3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 16:45:01 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 25 Nov 2018 21:44:59 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 2/5] microblaze: prefer memblock API returning virtual address
Date: Sun, 25 Nov 2018 23:44:34 +0200
In-Reply-To: <1543182277-8819-1-git-send-email-rppt@linux.ibm.com>
References: <1543182277-8819-1-git-send-email-rppt@linux.ibm.com>
Message-Id: <1543182277-8819-3-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>

Rather than use the memblock_alloc_base that returns a physical address and
then convert this address to the virtual one, use appropriate memblock
function that returns a virtual address.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/microblaze/mm/init.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index b17fd8a..44f4b89 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -363,8 +363,9 @@ void __init *early_get_page(void)
 	 * Mem start + kernel_tlb -> here is limit
 	 * because of mem mapping from head.S
 	 */
-	return __va(memblock_alloc_base(PAGE_SIZE, PAGE_SIZE,
-				memory_start + kernel_tlb));
+	return memblock_alloc_try_nid_raw(PAGE_SIZE, PAGE_SIZE,
+				MEMBLOCK_LOW_LIMIT, memory_start + kernel_tlb,
+				NUMA_NO_NODE);
 }
 
 #endif /* CONFIG_MMU */
-- 
2.7.4
