Message-Id: <20080318222701.788442216@sgi.com>
Date: Tue, 18 Mar 2008 15:27:01 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [0/2] vmalloc: Add /proc/vmallocinfo to display mappings
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The following two patches implement /proc/vmallocinfo. /proc/vmallocinfo
displays data about the vmalloc allocations. The second patch introduces
a tracing feature that allows to display the function that allocated the
vmalloc area.

Example:

cat /proc/vmallocinfo

0xffffc20000000000-0xffffc20000801000 8392704 alloc_large_system_hash+0x127/0x246 pages=2048 vmalloc vpages
0xffffc20000801000-0xffffc20000806000   20480 alloc_large_system_hash+0x127/0x246 pages=4 vmalloc
0xffffc20000806000-0xffffc20000c07000 4198400 alloc_large_system_hash+0x127/0x246 pages=1024 vmalloc vpages
0xffffc20000c07000-0xffffc20000c0a000   12288 alloc_large_system_hash+0x127/0x246 pages=2 vmalloc
0xffffc20000c0a000-0xffffc20000c0c000    8192 acpi_os_map_memory+0x13/0x1c phys=cff68000 ioremap
0xffffc20000c0c000-0xffffc20000c0f000   12288 acpi_os_map_memory+0x13/0x1c phys=cff64000 ioremap
0xffffc20000c10000-0xffffc20000c15000   20480 acpi_os_map_memory+0x13/0x1c phys=cff65000 ioremap
0xffffc20000c16000-0xffffc20000c18000    8192 acpi_os_map_memory+0x13/0x1c phys=cff69000 ioremap
0xffffc20000c18000-0xffffc20000c1a000    8192 acpi_os_map_memory+0x13/0x1c phys=fed1f000 ioremap
0xffffc20000c1a000-0xffffc20000c1c000    8192 acpi_os_map_memory+0x13/0x1c phys=cff68000 ioremap
0xffffc20000c1c000-0xffffc20000c1e000    8192 acpi_os_map_memory+0x13/0x1c phys=cff68000 ioremap
0xffffc20000c1e000-0xffffc20000c20000    8192 acpi_os_map_memory+0x13/0x1c phys=cff68000 ioremap
0xffffc20000c20000-0xffffc20000c22000    8192 acpi_os_map_memory+0x13/0x1c phys=cff68000 ioremap
0xffffc20000c22000-0xffffc20000c24000    8192 acpi_os_map_memory+0x13/0x1c phys=cff68000 ioremap
0xffffc20000c24000-0xffffc20000c26000    8192 acpi_os_map_memory+0x13/0x1c phys=e0081000 ioremap
0xffffc20000c26000-0xffffc20000c28000    8192 acpi_os_map_memory+0x13/0x1c phys=e0080000 ioremap
0xffffc20000c28000-0xffffc20000c2d000   20480 alloc_large_system_hash+0x127/0x246 pages=4 vmalloc
0xffffc20000c2d000-0xffffc20000c31000   16384 tcp_init+0xd5/0x31c pages=3 vmalloc
0xffffc20000c31000-0xffffc20000c34000   12288 alloc_large_system_hash+0x127/0x246 pages=2 vmalloc
0xffffc20000c34000-0xffffc20000c36000    8192 init_vdso_vars+0xde/0x1f1
0xffffc20000c36000-0xffffc20000c38000    8192 pci_iomap+0x8a/0xb4 phys=d8e00000 ioremap
0xffffc20000c38000-0xffffc20000c3a000    8192 usb_hcd_pci_probe+0x139/0x295 [usbcore] phys=d8e00000 ioremap
0xffffc20000c3a000-0xffffc20000c3e000   16384 sys_swapon+0x509/0xa15 pages=3 vmalloc
0xffffc20000c40000-0xffffc20000c61000  135168 e1000_probe+0x1c4/0xa32 phys=d8a20000 ioremap
0xffffc20000c61000-0xffffc20000c6a000   36864 _xfs_buf_map_pages+0x8e/0xc0 vmap
0xffffc20000c6a000-0xffffc20000c73000   36864 _xfs_buf_map_pages+0x8e/0xc0 vmap
0xffffc20000c73000-0xffffc20000c7c000   36864 _xfs_buf_map_pages+0x8e/0xc0 vmap
0xffffc20000c7c000-0xffffc20000c7f000   12288 e1000e_setup_tx_resources+0x29/0xbe pages=2 vmalloc
0xffffc20000c80000-0xffffc20001481000 8392704 pci_mmcfg_arch_init+0x90/0x118 phys=e0000000 ioremap
0xffffc20001481000-0xffffc20001682000 2101248 alloc_large_system_hash+0x127/0x246 pages=512 vmalloc
0xffffc20001682000-0xffffc20001e83000 8392704 alloc_large_system_hash+0x127/0x246 pages=2048 vmalloc vpages
0xffffc20001e83000-0xffffc20002204000 3674112 alloc_large_system_hash+0x127/0x246 pages=896 vmalloc vpages
0xffffc20002204000-0xffffc2000220d000   36864 _xfs_buf_map_pages+0x8e/0xc0 vmap
0xffffc2000220d000-0xffffc20002216000   36864 _xfs_buf_map_pages+0x8e/0xc0 vmap
0xffffc20002216000-0xffffc2000221f000   36864 _xfs_buf_map_pages+0x8e/0xc0 vmap
0xffffc2000221f000-0xffffc20002228000   36864 _xfs_buf_map_pages+0x8e/0xc0 vmap
0xffffc20002228000-0xffffc20002231000   36864 _xfs_buf_map_pages+0x8e/0xc0 vmap
0xffffc20002231000-0xffffc20002234000   12288 e1000e_setup_rx_resources+0x35/0x122 pages=2 vmalloc
0xffffc20002240000-0xffffc20002261000  135168 e1000_probe+0x1c4/0xa32 phys=d8a60000 ioremap
0xffffc20002261000-0xffffc2000270c000 4894720 sys_swapon+0x509/0xa15 pages=1194 vmalloc vpages
0xffffffffa0000000-0xffffffffa0022000  139264 module_alloc+0x4f/0x55 pages=33 vmalloc
0xffffffffa0022000-0xffffffffa0029000   28672 module_alloc+0x4f/0x55 pages=6 vmalloc
0xffffffffa002b000-0xffffffffa0034000   36864 module_alloc+0x4f/0x55 pages=8 vmalloc
0xffffffffa0034000-0xffffffffa003d000   36864 module_alloc+0x4f/0x55 pages=8 vmalloc
0xffffffffa003d000-0xffffffffa0049000   49152 module_alloc+0x4f/0x55 pages=11 vmalloc
0xffffffffa0049000-0xffffffffa0050000   28672 module_alloc+0x4f/0x55 pages=6 vmalloc


-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
