Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 512736B0007
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 02:28:35 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a22-v6so1798410eds.13
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 23:28:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s37-v6si1667727edd.65.2018.07.03.23.28.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 23:28:34 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w646O2Ws078354
	for <linux-mm@kvack.org>; Wed, 4 Jul 2018 02:28:32 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k0m8j1m3x-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Jul 2018 02:28:31 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 4 Jul 2018 07:28:29 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2 1/3] m68k/bitops: convert __ffs to match generic declaration
Date: Wed,  4 Jul 2018 09:28:14 +0300
In-Reply-To: <1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1530685696-14672-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Sam Creasey <sammy@sammy.net>
Cc: Michal Hocko <mhocko@kernel.org>, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The generic bitops declare __ffs as

	static inline unsigned long __ffs(unsigned long word);

Convert the m68k version to match the generic declaration.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/m68k/include/asm/bitops.h | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/arch/m68k/include/asm/bitops.h b/arch/m68k/include/asm/bitops.h
index 93b47b1..54009ea 100644
--- a/arch/m68k/include/asm/bitops.h
+++ b/arch/m68k/include/asm/bitops.h
@@ -454,7 +454,7 @@ static inline unsigned long ffz(unsigned long word)
  */
 #if (defined(__mcfisaaplus__) || defined(__mcfisac__)) && \
 	!defined(CONFIG_M68000) && !defined(CONFIG_MCPU32)
-static inline int __ffs(int x)
+static inline unsigned long __ffs(unsigned long x)
 {
 	__asm__ __volatile__ ("bitrev %0; ff1 %0"
 		: "=d" (x)
@@ -493,7 +493,11 @@ static inline int ffs(int x)
 		: "dm" (x & -x));
 	return 32 - cnt;
 }
-#define __ffs(x) (ffs(x) - 1)
+
+static inline unsigned long __ffs(unsigned long x)
+{
+	return ffs(x) - 1;
+}
 
 /*
  *	fls: find last bit set.
-- 
2.7.4
