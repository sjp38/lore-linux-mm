Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 406264402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 16:42:18 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id l126so41601904wml.1
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 13:42:18 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id xb1si20439649wjc.147.2015.12.17.13.42.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Dec 2015 13:42:16 -0800 (PST)
Date: Thu, 17 Dec 2015 21:42:09 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: sata with dma-debug enabled: DMA-API: cpu touching an active dma
 mapped cacheline [cln=0x00f270c0]
Message-ID: <20151217214208.GJ8644@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, linux-mm@kvack.org

Booting 4.4-rc5 on iMX6 with a SATA rootfs produces the following
DMA-API warning:

WARNING: CPU: 1 PID: 404 at lib/dma-debug.c:604 debug_dma_assert_idle+0x1ac/0x218()
ahci-imx 2200000.sata: DMA-API: cpu touching an active dma mapped cacheline [cln=0x00f270c0]
Modules linked in: caam_jr snd_soc_imx_sgtl5000 snd_soc_fsl_asoc_card hid_cypress snd_soc_imx_spdif snd_soc_sgtl5000 snd_soc_imx_audmux cec_dev imx_sdma rc_cec caam imx2_wdt snd_soc_fsl_spdif snd_soc_fsl_ssi coda v4l2_mem2mem imx_pcm_dma videobuf2_dma_contig videobuf2_vmalloc dw_hdmi_cec videobuf2_memops imx_thermal dw_hdmi_ahb_audio cec etnaviv(C) fuse rc_pinnacle_pctv_hd
CPU: 1 PID: 404 Comm: alsactl Tainted: G        WC      4.4.0-rc5+ #1934
Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
Backtrace:
[<c00138a4>] (dump_backtrace) from [<c0013a40>] (show_stack+0x18/0x1c)
 r6:c033dcac r5:0000025c r4:00000000 r3:00000000
[<c0013a28>] (show_stack) from [<c0313220>] (dump_stack+0x7c/0x98)
[<c03131a4>] (dump_stack) from [<c002d8f4>] (warn_slowpath_common+0x80/0xbc)
 r4:ec4add20 r3:ec40f300
[<c002d874>] (warn_slowpath_common) from [<c002d9d4>] (warn_slowpath_fmt+0x38/0x40)
 r8:c09bfad4 r7:a0070113 r6:c13d52c0 r5:c097fb2c r4:ef235400
[<c002d9a0>] (warn_slowpath_fmt) from [<c033dcac>] (debug_dma_assert_idle+0x1ac/0x218)
 r3:c08930b8 r2:c086d0e4
[<c033db00>] (debug_dma_assert_idle) from [<c0121c90>] (wp_page_copy+0x6c/0x38c)
 r10:0003c9c3 r8:efd8a860 r7:efd8a720 r6:b6956000 r5:efd8a860 r4:ec46ed68
[<c0121c24>] (wp_page_copy) from [<c0122260>] (do_wp_page+0xb0/0x540)
 r10:ee453558 r9:ee440000 r8:efd8a860 r7:ee440000 r6:3c9c379f r5:b6956000
 r4:ec46ed68
[<c01221b0>] (do_wp_page) from [<c0125374>] (handle_mm_fault+0xa60/0xe14)
 r10:00000001 r9:ee440000 r8:3c9c379f r7:b6956000 r6:ec4fc000 r5:eeaf3e80
 r4:ec46ed68
[<c0124914>] (handle_mm_fault) from [<c001db7c>] (do_page_fault+0x26c/0x388)
 r10:ee440054 r9:00000055 r8:b6956f44 r7:0000081f r6:ee440000 r5:ec40f300
 r4:ec4adfb0
[<c001d910>] (do_page_fault) from [<c000934c>] (do_DataAbort+0x3c/0xbc)
 r10:00000002 r9:becbad04 r8:ec4adfb0 r7:c0984ac4 r6:b6956f44 r5:c001d910
 r4:0000081f
[<c0009310>] (do_DataAbort) from [<c00148e4>] (__dabt_usr+0x44/0x60)
Exception stack(0xec4adfb0 to 0xec4adff8)
dfa0:                                     015b2c00 00000005 b694d3f8 b6956f40
dfc0: b6941000 015b2be0 effffef9 becbab98 becbab70 becbad04 00000002 b69597b4
dfe0: 00000000 becbab70 b6ef8783 b6ef84d4 a0070030 ffffffff
 r8:10c5387d r7:10c5387d r6:ffffffff r5:a0070030 r4:b6ef84d4
---[ end trace 41e5fc6596fc8197 ]---
Mapped at:
 [<c0421830>] ata_qc_issue+0x294/0x3f0
 [<c04267c4>] ata_scsi_translate+0xa0/0x160
 [<c042a6c0>] ata_scsi_queuecmd+0x90/0x268
 [<c040e1e0>] scsi_dispatch_cmd+0xdc/0x24c
 [<c0410964>] scsi_request_fn+0x4f4/0x6d0
EXT4-fs (sda1): re-mounted. Opts: errors=remount-ro

(This is the second warning: the first warning is down to SDHCI
DMA-mapping the same memory multiple times, which I'm about to report
as well.)

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
