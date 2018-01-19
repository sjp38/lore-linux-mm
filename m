Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id B86B96B0260
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 20:51:54 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id h32so345633qtb.9
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 17:51:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i95sor6314255qtb.132.2018.01.18.17.51.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jan 2018 17:51:54 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v10 05/27] powerpc: helper function to read,write AMR,IAMR,UAMOR registers
Date: Thu, 18 Jan 2018 17:50:26 -0800
Message-Id: <1516326648-22775-6-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
References: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

Implements helper functions to read and write the key related
registers; AMR, IAMR, UAMOR.

AMR register tracks the read,write permission of a key
IAMR register tracks the execute permission of a key
UAMOR register enables and disables a key

Acked-by: Balbir Singh <bsingharora@gmail.com>
Reviewed-by: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/mm/pkeys.c |   36 ++++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index e2f3992..6e8df6e 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -71,3 +71,39 @@ void pkey_mm_init(struct mm_struct *mm)
 		return;
 	mm_pkey_allocation_map(mm) = initial_allocation_mask;
 }
+
+static inline u64 read_amr(void)
+{
+	return mfspr(SPRN_AMR);
+}
+
+static inline void write_amr(u64 value)
+{
+	mtspr(SPRN_AMR, value);
+}
+
+static inline u64 read_iamr(void)
+{
+	if (!likely(pkey_execute_disable_supported))
+		return 0x0UL;
+
+	return mfspr(SPRN_IAMR);
+}
+
+static inline void write_iamr(u64 value)
+{
+	if (!likely(pkey_execute_disable_supported))
+		return;
+
+	mtspr(SPRN_IAMR, value);
+}
+
+static inline u64 read_uamor(void)
+{
+	return mfspr(SPRN_UAMOR);
+}
+
+static inline void write_uamor(u64 value)
+{
+	mtspr(SPRN_UAMOR, value);
+}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
