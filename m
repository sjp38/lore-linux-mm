Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 399A86B0284
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 07:36:13 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id m3-v6so1673154lfh.14
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 04:36:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z12-v6sor14175738ljb.6.2018.10.30.04.36.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Oct 2018 04:36:10 -0700 (PDT)
From: Anders Roxell <anders.roxell@linaro.org>
Subject: [PATCH v2 1/2] serial: set suppress_bind_attrs flag only if builtin
Date: Tue, 30 Oct 2018 12:35:44 +0100
Message-Id: <20181030113545.30999-1-anders.roxell@linaro.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@armlinux.org.uk, gregkh@linuxfoundation.org, akpm@linux-foundation.org
Cc: linux-serial@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, tj@kernel.org, Anders Roxell <anders.roxell@linaro.org>, Arnd Bergmann <arnd@arndb.de>

When the test 'CONFIG_DEBUG_TEST_DRIVER_REMOVE=y' is enabled,
arch_initcall(pl011_init) came before subsys_initcall(default_bdi_init).
devtmpfs gets killed because we try to remove a file and decrement the
wb reference count before the noop_backing_device_info gets initialized.

[    0.332075] Serial: AMBA PL011 UART driver
[    0.485276] 9000000.pl011: ttyAMA0 at MMIO 0x9000000 (irq = 39, base_baud = 0) is a PL011 rev1
[    0.502382] console [ttyAMA0] enabled
[    0.515710] Unable to handle kernel paging request at virtual address 0000800074c12000
[    0.516053] Mem abort info:
[    0.516222]   ESR = 0x96000004
[    0.516417]   Exception class = DABT (current EL), IL = 32 bits
[    0.516641]   SET = 0, FnV = 0
[    0.516826]   EA = 0, S1PTW = 0
[    0.516984] Data abort info:
[    0.517149]   ISV = 0, ISS = 0x00000004
[    0.517339]   CM = 0, WnR = 0
[    0.517553] [0000800074c12000] user address but active_mm is swapper
[    0.517928] Internal error: Oops: 96000004 [#1] PREEMPT SMP
[    0.518305] Modules linked in:
[    0.518839] CPU: 0 PID: 13 Comm: kdevtmpfs Not tainted 4.19.0-rc5-next-20180928-00002-g2ba39ab0cd01-dirty #82
[    0.519307] Hardware name: linux,dummy-virt (DT)
[    0.519681] pstate: 80000005 (Nzcv daif -PAN -UAO)
[    0.519959] pc : __destroy_inode+0x94/0x2a8
[    0.520212] lr : __destroy_inode+0x78/0x2a8
[    0.520401] sp : ffff0000098c3b20
[    0.520590] x29: ffff0000098c3b20 x28: 00000000087a3714
[    0.520904] x27: 0000000000002000 x26: 0000000000002000
[    0.521179] x25: ffff000009583000 x24: 0000000000000000
[    0.521467] x23: ffff80007bb52000 x22: ffff80007bbaa7c0
[    0.521737] x21: ffff0000093f9338 x20: 0000000000000000
[    0.522033] x19: ffff80007bbb05d8 x18: 0000000000000400
[    0.522376] x17: 0000000000000000 x16: 0000000000000000
[    0.522727] x15: 0000000000000400 x14: 0000000000000400
[    0.523068] x13: 0000000000000001 x12: 0000000000000001
[    0.523421] x11: 0000000000000000 x10: 0000000000000970
[    0.523749] x9 : ffff0000098c3a60 x8 : ffff80007bbab190
[    0.524017] x7 : ffff80007bbaa880 x6 : 0000000000000c88
[    0.524305] x5 : ffff0000093d96c8 x4 : 61c8864680b583eb
[    0.524567] x3 : ffff0000093d6180 x2 : ffffffffffffffff
[    0.524872] x1 : 0000800074c12000 x0 : 0000800074c12000
[    0.525207] Process kdevtmpfs (pid: 13, stack limit = 0x(____ptrval____))
[    0.525529] Call trace:
[    0.525806]  __destroy_inode+0x94/0x2a8
[    0.526108]  destroy_inode+0x34/0x88
[    0.526370]  evict+0x144/0x1c8
[    0.526636]  iput+0x184/0x230
[    0.526871]  dentry_unlink_inode+0x118/0x130
[    0.527152]  d_delete+0xd8/0xe0
[    0.527420]  vfs_unlink+0x240/0x270
[    0.527665]  handle_remove+0x1d8/0x330
[    0.527875]  devtmpfsd+0x138/0x1c8
[    0.528085]  kthread+0x14c/0x158
[    0.528291]  ret_from_fork+0x10/0x18
[    0.528720] Code: 92800002 aa1403e0 d538d081 8b010000 (c85f7c04)
[    0.529367] ---[ end trace 5a3dee47727f877c ]---

Rework to set suppress_bind_attrs flag to avoid removing the device when
CONFIG_DEBUG_TEST_DRIVER_REMOVE=y. This applies for pic32_uart and
xilinx_uartps as well.

Co-developed-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Anders Roxell <anders.roxell@linaro.org>
---
 drivers/tty/serial/amba-pl011.c    | 2 ++
 drivers/tty/serial/pic32_uart.c    | 1 +
 drivers/tty/serial/xilinx_uartps.c | 1 +
 3 files changed, 4 insertions(+)

diff --git a/drivers/tty/serial/amba-pl011.c b/drivers/tty/serial/amba-pl011.c
index ebd33c0232e6..89ade213a1a9 100644
--- a/drivers/tty/serial/amba-pl011.c
+++ b/drivers/tty/serial/amba-pl011.c
@@ -2780,6 +2780,7 @@ static struct platform_driver arm_sbsa_uart_platform_driver = {
 		.name	= "sbsa-uart",
 		.of_match_table = of_match_ptr(sbsa_uart_of_match),
 		.acpi_match_table = ACPI_PTR(sbsa_uart_acpi_match),
+		.suppress_bind_attrs = IS_BUILTIN(CONFIG_SERIAL_AMBA_PL011),
 	},
 };
 
@@ -2808,6 +2809,7 @@ static struct amba_driver pl011_driver = {
 	.drv = {
 		.name	= "uart-pl011",
 		.pm	= &pl011_dev_pm_ops,
+		.suppress_bind_attrs = IS_BUILTIN(CONFIG_SERIAL_AMBA_PL011),
 	},
 	.id_table	= pl011_ids,
 	.probe		= pl011_probe,
diff --git a/drivers/tty/serial/pic32_uart.c b/drivers/tty/serial/pic32_uart.c
index fd80d999308d..0bdf1687983f 100644
--- a/drivers/tty/serial/pic32_uart.c
+++ b/drivers/tty/serial/pic32_uart.c
@@ -919,6 +919,7 @@ static struct platform_driver pic32_uart_platform_driver = {
 	.driver		= {
 		.name	= PIC32_DEV_NAME,
 		.of_match_table	= of_match_ptr(pic32_serial_dt_ids),
+		.suppress_bind_attrs = IS_BUILTIN(CONFIG_SERIAL_PIC32),
 	},
 };
 
diff --git a/drivers/tty/serial/xilinx_uartps.c b/drivers/tty/serial/xilinx_uartps.c
index 57c66d2c3471..379242b96790 100644
--- a/drivers/tty/serial/xilinx_uartps.c
+++ b/drivers/tty/serial/xilinx_uartps.c
@@ -1719,6 +1719,7 @@ static struct platform_driver cdns_uart_platform_driver = {
 		.name = CDNS_UART_NAME,
 		.of_match_table = cdns_uart_of_match,
 		.pm = &cdns_uart_dev_pm_ops,
+		.suppress_bind_attrs = IS_BUILTIN(CONFIG_SERIAL_XILINX_PS_UART),
 		},
 };
 
-- 
2.19.1
