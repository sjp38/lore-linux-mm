Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2788F6B0047
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 12:20:42 -0500 (EST)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.1/8.13.1) with ESMTP id o29HKdYl007217
	for <linux-mm@kvack.org>; Tue, 9 Mar 2010 17:20:39 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o29HKdoT1720508
	for <linux-mm@kvack.org>; Tue, 9 Mar 2010 18:20:39 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o29HKdHs000895
	for <linux-mm@kvack.org>; Tue, 9 Mar 2010 18:20:39 +0100
Date: Tue, 9 Mar 2010 18:20:52 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH 2/2] memory hotplug/s390: set phys_device
Message-ID: <20100309172052.GC2360@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <haveblue@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>

Implement arch specific arch_get_memory_phys_device function and initialize
phys_device for each memory section. That way we finally can tell which
piece of memory belongs to which physical device.

Cc: Dave Hansen <haveblue@us.ibm.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by:  Heiko Carstens <heiko.carstens@de.ibm.com>
---
 drivers/s390/char/sclp_cmd.c |    7 +++++++
 1 file changed, 7 insertions(+)

--- a/drivers/s390/char/sclp_cmd.c
+++ b/drivers/s390/char/sclp_cmd.c
@@ -704,6 +704,13 @@ int sclp_chp_deconfigure(struct chp_id c
 	return do_chp_configure(SCLP_CMDW_DECONFIGURE_CHPATH | chpid.id << 8);
 }
 
+int arch_get_memory_phys_device(unsigned long start_pfn)
+{
+	if (!rzm)
+		return 0;
+	return PFN_PHYS(start_pfn) / rzm;
+}
+
 struct chp_info_sccb {
 	struct sccb_header header;
 	u8 recognized[SCLP_CHP_INFO_MASK_SIZE];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
