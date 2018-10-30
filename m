Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id D1B566B0494
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 07:36:35 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id e11-v6so4201741lji.23
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 04:36:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y206sor3327092lfa.42.2018.10.30.04.36.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Oct 2018 04:36:33 -0700 (PDT)
From: Anders Roxell <anders.roxell@linaro.org>
Subject: [PATCH v2 2/2] writeback: don't decrement wb->refcnt if !wb->bdi
Date: Tue, 30 Oct 2018 12:35:45 +0100
Message-Id: <20181030113545.30999-2-anders.roxell@linaro.org>
In-Reply-To: <20181030113545.30999-1-anders.roxell@linaro.org>
References: <20181030113545.30999-1-anders.roxell@linaro.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@armlinux.org.uk, gregkh@linuxfoundation.org, akpm@linux-foundation.org
Cc: linux-serial@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, tj@kernel.org, Anders Roxell <anders.roxell@linaro.org>, Arnd Bergmann <arnd@arndb.de>

This happened while running in qemu-system-aarch64, the AMBA PL011 UART
driver when enabling CONFIG_DEBUG_TEST_DRIVER_REMOVE.
arch_initcall(pl011_init) came before subsys_initcall(default_bdi_init),
devtmpfs' handle_remove() crashes because the reference count is a NULL
pointer only because wb->bdi hasn't been initialized yet.

Rework so that wb_put have an extra check if wb->bdi before decrement
wb->refcnt and also add a WARN_ON_ONCE to get a warning if it happens again
in other drivers.

Fixes: 52ebea749aae ("writeback: make backing_dev_info host cgroup-specific bdi_writebacks")
Co-developed-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Anders Roxell <anders.roxell@linaro.org>
---
 include/linux/backing-dev-defs.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 9a6bc0951cfa..c31157135598 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -258,6 +258,14 @@ static inline void wb_get(struct bdi_writeback *wb)
  */
 static inline void wb_put(struct bdi_writeback *wb)
 {
+	if (WARN_ON_ONCE(!wb->bdi)) {
+		/*
+		 * A driver bug might cause a file to be removed before bdi was
+		 * initialized.
+		 */
+		return;
+	}
+
 	if (wb != &wb->bdi->wb)
 		percpu_ref_put(&wb->refcnt);
 }
-- 
2.19.1
