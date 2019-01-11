Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B33CD8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 00:13:33 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id d18so9505115pfe.0
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 21:13:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c8sor1650019plr.70.2019.01.10.21.13.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 21:13:32 -0800 (PST)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCHv2 2/7] acpi: change the topo of acpi_table_upgrade()
Date: Fri, 11 Jan 2019 13:12:52 +0800
Message-Id: <1547183577-20309-3-git-send-email-kernelfans@gmail.com>
In-Reply-To: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Chao Fan <fanc.fnst@cn.fujitsu.com>, Baoquan He <bhe@redhat.com>, Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, x86@kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org

The current acpi_table_upgrade() relies on initrd_start, but this var is
only valid after relocate_initrd(). There is requirement to extract the
acpi info from initrd before memblock-allocator can work(see [2/4]), hence
acpi_table_upgrade() need to accept the input param directly.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Acked-by: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Len Brown <lenb@kernel.org>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Chao Fan <fanc.fnst@cn.fujitsu.com>
Cc: Baoquan He <bhe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: x86@kernel.org
Cc: linux-acpi@vger.kernel.org
Cc: linux-mm@kvack.org
---
 arch/arm64/kernel/setup.c | 2 +-
 arch/x86/kernel/setup.c   | 2 +-
 drivers/acpi/tables.c     | 4 +---
 include/linux/acpi.h      | 4 ++--
 4 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
index f4fc1e0..bc4b47d 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -315,7 +315,7 @@ void __init setup_arch(char **cmdline_p)
 	paging_init();
 	efi_apply_persistent_mem_reservations();
 
-	acpi_table_upgrade();
+	acpi_table_upgrade((void *)initrd_start, initrd_end - initrd_start);
 
 	/* Parse the ACPI tables for possible boot-time configuration */
 	acpi_boot_table_init();
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index ac432ae..dc8fc5d 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1172,8 +1172,8 @@ void __init setup_arch(char **cmdline_p)
 
 	reserve_initrd();
 
-	acpi_table_upgrade();
 
+	acpi_table_upgrade((void *)initrd_start, initrd_end - initrd_start);
 	vsmp_init();
 
 	io_delay_init();
diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index 61203ee..84e0a79 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -471,10 +471,8 @@ static DECLARE_BITMAP(acpi_initrd_installed, NR_ACPI_INITRD_TABLES);
 
 #define MAP_CHUNK_SIZE   (NR_FIX_BTMAPS << PAGE_SHIFT)
 
-void __init acpi_table_upgrade(void)
+void __init acpi_table_upgrade(void *data, size_t size)
 {
-	void *data = (void *)initrd_start;
-	size_t size = initrd_end - initrd_start;
 	int sig, no, table_nr = 0, total_offset = 0;
 	long offset = 0;
 	struct acpi_table_header *table;
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index ed80f14..0b6e0b6 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -1254,9 +1254,9 @@ acpi_graph_get_remote_endpoint(const struct fwnode_handle *fwnode,
 #endif
 
 #ifdef CONFIG_ACPI_TABLE_UPGRADE
-void acpi_table_upgrade(void);
+void acpi_table_upgrade(void *data, size_t size);
 #else
-static inline void acpi_table_upgrade(void) { }
+static inline void acpi_table_upgrade(void *data, size_t size) { }
 #endif
 
 #if defined(CONFIG_ACPI) && defined(CONFIG_ACPI_WATCHDOG)
-- 
2.7.4
