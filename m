Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3D1BC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 04:25:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 314A12184A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 04:25:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 314A12184A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=collabora.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DC488E0010; Mon, 11 Feb 2019 23:25:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98BEE8E000F; Mon, 11 Feb 2019 23:25:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A13E8E0010; Mon, 11 Feb 2019 23:25:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3792B8E000F
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 23:25:06 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id z16so495193wrt.5
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 20:25:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=D3f7YZgG53fKA6m5cTzIVu8kSwk5npW/TrqtKAxETAE=;
        b=QqyGTW+AqHHlF8e5bHZ1P33HIXGFRDo0HKSFDFCXD6vAjCN1yOfiz1+B9+0Kp9T/b5
         iSYyJW4kUJ1EP9sHzGXy9C+eZoxfEsKZr6YZM/M8x/whjr023SPdvO+O5JSNBv1MOTRq
         ENbWXe1m03pkSF2Bpph82Ro4g2cIpILyhPGTMdJB5o9hAWmChKbjorEOYICt2FV/xXlC
         xIfylfrBQOGuGvdNDg3f5/WjytFRnEr6UcC7JFeEqvrB8bhxAvHsSQk5bVIn3N9lQHC6
         aZ/NailX79TQW24RrpWkktkPILHcaaF7FZGyU4tCjiCHQky2sS8mkpaiH+PDWwi3LH89
         CG9A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of gael.portay@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=gael.portay@collabora.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
X-Gm-Message-State: AHQUAubXNKAIF77ncJ8LFh+oKBs7oXD4esW4KI8Tg8wYDJL72VkDOzmu
	4FXD5Htmh/HncEJdguQl95HHYX2kuNA2zN/f+dN13xSSsa8jH7/Gx8IvtRDizpc2bIrpacKFnwE
	jl8dms2suGyytfsTW2igTdfaZpKvdFZituKdP1yMPmPIqdF8cO9AkZ3Bv6U2GUuCmxQ==
X-Received: by 2002:adf:ecc8:: with SMTP id s8mr1120561wro.208.1549945505657;
        Mon, 11 Feb 2019 20:25:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaIBPINFPW83jX8j9TqLTSphomgSsyU9Tvsz9E5zaGyV0KJHKIztg6GtiJRD7Mv42z8IMKl
X-Received: by 2002:adf:ecc8:: with SMTP id s8mr1120514wro.208.1549945504246;
        Mon, 11 Feb 2019 20:25:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549945504; cv=none;
        d=google.com; s=arc-20160816;
        b=L2J/bxkSXJ+Rz8F96e0OsBeNNkGZTyrMuTC+b6IMQi11FmKKwY/lE1l6FxkMHVWgTL
         J1knwN4oh6VuMMeTIOMeVylbGorH6ARXJGIxrGmQrM1CQ6oxxuR7h6JyQiZQBVWeIAlH
         Xqqh3lF4xNoNOPm/2C07GxQzGvKIwbloRYmXAwORs2P5mnFh0PoSip7caceOg4SDC47n
         OUPeH+XpacMc18mRiAS7rMboPaC7NZ+I9RT87ENOukPFqcpKaRhELPxPuBE/84IDq/9o
         liCteOPex7VfGH6aH4IZkib6q1ZhbC+QdICYjLuoHk7C1G5UKZ1sa3EqEgEc4B0jGLy+
         VbFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=D3f7YZgG53fKA6m5cTzIVu8kSwk5npW/TrqtKAxETAE=;
        b=NshwAJdj5Gs9KVQOHbz5M97BYdUaV+3bROifNKRREaa5MmaPSam84LXQAfxN3yuCWf
         Sb51eWPSq9wWaP7OuJ/UR9S6GjdzccEBX+h4zv4pWLeu5iLxQLyNW5vUCwO2EOzPUxF/
         G79fjiK4O5+e/jXAPmnn1OCQ+rYiETktINjNx2Az1vIJV+/O41+uvKGhv6xsyexpSTUq
         Rk2K9Yk4lcdX85Eu1vO6X7Cbg754drn9ab5GbrAFhzAecgrDSUNsVZDXaENEUJiaKZAd
         y61wCL9/h/R7Ir9KGk9SmiYUwlCtvaYo86/cW4ggHqnkTEMFHuQriYM/9FsJaomOFhvi
         Q5Cg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of gael.portay@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=gael.portay@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [2a00:1098:0:82:1000:25:2eeb:e3e3])
        by mx.google.com with ESMTPS id t135si864424wmt.155.2019.02.11.20.25.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 20:25:04 -0800 (PST)
Received-SPF: pass (google.com: domain of gael.portay@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) client-ip=2a00:1098:0:82:1000:25:2eeb:e3e3;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of gael.portay@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=gael.portay@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from [127.0.0.1] (localhost [127.0.0.1])
	(Authenticated sender: gportay)
	with ESMTPSA id 92701260499
From: =?UTF-8?q?Ga=C3=ABl=20PORTAY?= <gael.portay@collabora.com>
To: linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	Gabriel Krisman Bertazi <krisman@collabora.com>
Cc: kernel@collabora.com,
	=?utf-8?q?Ga=C3=ABl=20PORTAY?= <gael.portay@collabora.com>,
	Laura Abbott <labbott@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH] ARM: dma-mapping: prevent writeback deadlock in CMA allocator
Date: Mon, 11 Feb 2019 23:24:58 -0500
Message-Id: <20190212042458.31856-1-gael.portay@collabora.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A deadlock happens when a task initiates a CMA allocation that triggers
a page migration *AND* the tasks holding the subsequent pages have to
writeback their pages using CMA allocations.

In such a situation, the task that has triggered the page migration
holds a mutex that prevents other tasks from migrating their pages using
that same CMA allocator. This leads to a deadlock.

The CMA is incapable of honoring the NOIO flags in some scenario, thus
cannot be used for writeback. The fix allows the code that chooses which
allocator to use in the ARM platform to avoid the CMA case for that
scenario.

The ARM DMA layer checks for allow blocking flag (__GFP_DIRECT_RECLAIM)
to decide whether to go for CMA or not. That test is not sufficient to
cover the case of writeback (GFP_NOIO).

The fix consists in adding a gfp_allow_writeback helper that tests for
the __GFP_IO flag. Then, the DMA layer uses it to decide not to go for
CMA in case of writeback.

Fixes:

        QSGRenderThread D    0  1852    564 0x00000000
        Backtrace:
        [<c091d038>] (__schedule) from [<c091d844>] (schedule+0x5c/0xcc) r10:c0f04068 r9:efc2e600 r8:ffffe000 r7:00004000 r6:efc2e600 r5:edd31a94 r4:ffffe000
        [<c091d7e8>] (schedule) from [<c01575fc>] (io_schedule+0x20/0x48) r5:edd31a94 r4:00000000
        [<c01575dc>] (io_schedule) from [<c0211d84>] (wait_on_page_bit+0x10c/0x158) r5:edd31a94 r4:c0f04064
        [<c0211c78>] (wait_on_page_bit) from [<c026b608>] (migrate_pages+0x658/0x8e0) r10:efc2e600 r9:00000000 r8:00000000 r7:00000000 r6:ef899260 r5:ea733c7c r4:efc2e5e0
        [<c026afb0>] (migrate_pages) from [<c0220e10>] (alloc_contig_range+0x17c/0x3b0) r10:00071700 r9:c026c21c r8:00071b31 r7:00071b60 r6:ffffe000 r5:00000000 r4:edd31b54
        [<c0220c94>] (alloc_contig_range) from [<c026c8c8>] (cma_alloc+0x110/0x2f4) r10:00000460 r9:00020000 r8:fffffff4 r7:00000460 r6:c0fe0444 r5:00071700 r4:00001700
        [<c026c7b8>] (cma_alloc) from [<c018edb0>] (dma_alloc_from_contiguous+0x44/0x4c) r10:ecfe4840 r9:00000460 r8:00000647 r7:edd31cb4 r6:ec217c10 r5:00000001 r4:00460000
        [<c018ed6c>] (dma_alloc_from_contiguous) from [<c0119f40>] (__alloc_from_contiguous+0x58/0xf8)
        [<c0119ee8>] (__alloc_from_contiguous) from [<c011a030>] (cma_allocator_alloc+0x50/0x58) r10:ecfe4840 r9:eccfbd58 r8:c0f04d08 r7:00000000 r6:ffffffff r5:ec217c10 r4:006002c0
        [<c0119fe0>] (cma_allocator_alloc) from [<c011a218>] (__dma_alloc+0x1e0/0x308) r5:ec217c10 r4:006002c0
        [<c011a038>] (__dma_alloc) from [<c011a3d8>] (arm_dma_alloc+0x4c/0x58) r10:edd31e24 r9:eccfbd58 r8:c0f04d08 r7:c011a38c r6:ec217c10 r5:00000000 r4:00000004
        [<c011a38c>] (arm_dma_alloc) from [<c05b4928>] (drm_gem_cma_create+0xd0/0x168) r5:eccfbcc0 r4:00460000
        [<c05b4858>] (drm_gem_cma_create) from [<c05b4f2c>] (drm_gem_cma_dumb_create+0x50/0xa4) r9:c05ad874 r8:00000010 r7:00000000 r6:00000000 r5:ecd9c500 r4:edd31e34
        [<c05b4edc>] (drm_gem_cma_dumb_create) from [<c05ad860>] (drm_mode_create_dumb+0xbc/0xd0) r7:00000000 r6:00000000 r5:00000000 r4:00460000
        [<c05ad7a4>] (drm_mode_create_dumb) from [<c05ad88c>] (drm_mode_create_dumb_ioctl+0x18/0x1c) r7:00000000 r6:c0f04d08 r5:ec559000 r4:ecd9c500
        [<c05ad874>] (drm_mode_create_dumb_ioctl) from [<c058f3c8>] (drm_ioctl_kernel+0x90/0xec)
        [<c058f338>] (drm_ioctl_kernel) from [<c058f8ac>] (drm_ioctl+0x2c4/0x3e4) r10:c0f04d08 r9:edd31e24 r8:000000b2 r7:c02064b2 r6:ecd9c500 r5:00000020 r4:c0a47ac8
        [<c058f5e8>] (drm_ioctl) from [<c0286be4>] (do_vfs_ioctl+0xac/0x934) r10:00000036 r9:0000001a r8:ec554b90 r7:c02064b2 r6:ed0d3d80 r5:ac5df5d8 r4:c0f04d08
        [<c0286b38>] (do_vfs_ioctl) from [<c02874b0>] (ksys_ioctl+0x44/0x68) r10:00000036 r9:edd30000 r8:ac5df5d8 r7:c02064b2 r6:0000001a r5:ed0d3d80 r4:ed0d3d81
        [<c028746c>] (ksys_ioctl) from [<c02874ec>] (sys_ioctl+0x18/0x1c) r9:edd30000 r8:c0101204 r7:00000036 r6:c02064b2 r5:ac5df5d8 r4:ac5df640
        [<c02874d4>] (sys_ioctl) from [<c0101000>] (ret_fast_syscall+0x0/0x54)
        Exception stack(0xedd31fa8 to 0xedd31ff0)
        1fa0:                   ac5df640 ac5df5d8 0000001a c02064b2 ac5df5d8 00000005
        1fc0: ac5df640 ac5df5d8 c02064b2 00000036 00000380 0188cfc0 ac5df640 ac5df60c
        1fe0: b4bd0094 ac5df5b4 b4bb7bb4 b55444fc

        usb-storage     D    0   349      2 0x00000000
        Backtrace:
        [<c091d038>] (__schedule) from [<c091d844>] (schedule+0x5c/0xcc) r10:00000002 r9:00020000 r8:c0f20b34 r7:00000000 r6:ece579a4 r5:ffffe000 r4:ffffe000
        [<c091d7e8>] (schedule) from [<c091dd90>] (schedule_preempt_disabled+0x30/0x4c) r5:ffffe000 r4:ffffe000
        [<c091dd60>] (schedule_preempt_disabled) from [<c091ee48>] (__mutex_lock.constprop.7+0x2f8/0x60c) r5:ffffe000 r4:c0f20b30
        [<c091eb50>] (__mutex_lock.constprop.7) from [<c091f274>] (__mutex_lock_slowpath+0x1c/0x20) r10:00000001 r9:00020000 r8:fffffff4 r7:00000001 r6:c0fe0444 r5:00070068 r4:00000068
        [<c091f258>] (__mutex_lock_slowpath) from [<c091f2c8>] (mutex_lock+0x50/0x54)
        [<c091f278>] (mutex_lock) from [<c026c8b4>] (cma_alloc+0xfc/0x2f4)
        [<c026c7b8>] (cma_alloc) from [<c018edb0>] (dma_alloc_from_contiguous+0x44/0x4c) r10:ed19e5c0 r9:00000001 r8:00000647 r7:ece57aec r6:ec215610 r5:00000001 r4:00001000
        [<c018ed6c>] (dma_alloc_from_contiguous) from [<c0119f40>] (__alloc_from_contiguous+0x58/0xf8)
        [<c0119ee8>] (__alloc_from_contiguous) from [<c011a030>] (cma_allocator_alloc+0x50/0x58) r10:ed19e5c0 r9:ed19e84c r8:c0f04d08 r7:00000000 r6:ffffffff r5:ec215610 r4:00600000
        [<c0119fe0>] (cma_allocator_alloc) from [<c011a218>] (__dma_alloc+0x1e0/0x308) r5:ec215610 r4:00600000
        [<c011a038>] (__dma_alloc) from [<c011a3d8>] (arm_dma_alloc+0x4c/0x58) r10:c011a38c r9:ec215610 r8:c0f04d08 r7:00600000 r6:ece6c808 r5:00000000 r4:00000000
        [<c011a38c>] (arm_dma_alloc) from [<c0264cec>] (dma_pool_alloc+0x21c/0x290) r5:ece6c800 r4:ed19e840
        [<c0264ad0>] (dma_pool_alloc) from [<bf25a40c>] (ehci_qtd_alloc+0x30/0x94 [ehci_hcd]) r10:00000200 r9:000000ca r8:e72e0260 r7:ece57c6c r6:f15c6f60 r5:c0f04d08 r4:00000200
        [<bf25a3dc>] (ehci_qtd_alloc [ehci_hcd]) from [<bf25cec8>] (qh_urb_transaction+0x150/0x42c [ehci_hcd]) r6:f15c6f60 r5:00019400 r4:00000200
        [<bf25cd78>] (qh_urb_transaction [ehci_hcd]) from [<bf25fad8>] (ehci_urb_enqueue+0x74/0xe3c [ehci_hcd]) r10:000000ef r9:eccd8c00 r8:ed236308 r7:ed236300 r6:00000000 r5:ece57c6c r4:00000003
        [<bf25fa64>] (ehci_urb_enqueue [ehci_hcd]) from [<bf1c478c>] (usb_hcd_submit_urb+0xc8/0x980 [usbcore]) r10:000000ef r9:00600000 r8:ed236308 r7:c0f04d08 r6:00000000 r5:eccd8c00 r4:ed236300
        [<bf1c46c4>] (usb_hcd_submit_urb [usbcore]) from [<bf1c6160>] (usb_submit_urb+0x360/0x564 [usbcore]) r10:000000ef r9:bf1d8924 r8:00000000 r7:00600000 r6:00000002 r5:eccc1800 r4:ed236300
        [<bf1c5e00>] (usb_submit_urb [usbcore]) from [<bf1c75b8>] (usb_sg_wait+0x68/0x154 [usbcore]) r10:0000001f r9:00000000 r8:00000001 r7:eca5951c r6:c0008200 r5:00000000 r4:eca59514
        [<bf1c7550>] (usb_sg_wait [usbcore]) from [<bf2bd618>] (usb_stor_bulk_transfer_sglist.part.2+0x80/0xdc [usb_storage]) r9:0001e000 r8:eca594ac r7:0001e000 r6:c0008200 r5:eca59514 r4:eca59488
        [<bf2bd598>] (usb_stor_bulk_transfer_sglist.part.2 [usb_storage]) from [<bf2bd6c0>] (usb_stor_bulk_srb+0x4c/0x7c [usb_storage]) r8:c0f04d08 r7:00000000 r6:ed71f0c0 r5:c0f04d08 r4:ed71f0c0
        [<bf2bd674>] (usb_stor_bulk_srb [usb_storage]) from [<bf2bd810>] (usb_stor_Bulk_transport+0x120/0x390 [usb_storage]) r5:f19e2000 r4:eca59488
        [<bf2bd6f0>] (usb_stor_Bulk_transport [usb_storage]) from [<bf2be14c>] (usb_stor_invoke_transport+0x3c/0x490 [usb_storage]) r10:ecd0bb3c r9:c0f03d00 r8:c0f04d08 r7:ed71f0c0 r6:c0f04d08 r5:ed71f0c0 r4:eca59488
        [<bf2be110>] (usb_stor_invoke_transport [usb_storage]) from [<bf2bcd58>] (usb_stor_transparent_scsi_command+0x18/0x1c [usb_storage]) r10:ecd0bb3c r9:c0f03d00 r8:c0f04d08 r7:ed71f0c0 r6:00000000 r5:eca59550 r4:eca59488
        [<bf2bcd40>] (usb_stor_transparent_scsi_command [usb_storage]) from [<bf2bf5e4>] (usb_stor_control_thread+0x174/0x29c [usb_storage])
        [<bf2bf470>] (usb_stor_control_thread [usb_storage]) from [<c0149fc4>] (kthread+0x154/0x16c)
         r10:ecd0bb3c r9:bf2bf470 r8:eca59488 r7:ece56000 r6:ed1f4f80 r5:ecba3140
         r4:00000000
        [<c0149e70>] (kthread) from [<c01010e8>] (ret_from_fork+0x14/0x2c)
        Exception stack(0xece57fb0 to 0xece57ff8)
        7fa0:                                     00000000 00000000 00000000 00000000
        7fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
        7fe0: 00000000 00000000 00000000 00000000 00000013 00000000
         r10:00000000 r9:00000000 r8:00000000 r7:00000000 r6:00000000 r5:c0149e70
         r4:ed1f4f80

Cc: Laura Abbott <labbott@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Gaël PORTAY <gael.portay@collabora.com>
---
Hi,

I am suggesting this patch after the discussion on that thread[1].

Regards, 
Gael

[1]: https://marc.info/?l=linux-mm&m=154750965506335&w=2

 arch/arm/mm/dma-mapping.c | 5 +++--
 include/linux/gfp.h       | 5 +++++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index f1e2922e447c..98479b6bb425 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -725,7 +725,7 @@ static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
 	u64 mask = get_coherent_dma_mask(dev);
 	struct page *page = NULL;
 	void *addr;
-	bool allowblock, cma;
+	bool allowblock, allowwriteback, cma;
 	struct arm_dma_buffer *buf;
 	struct arm_dma_alloc_args args = {
 		.dev = dev,
@@ -769,7 +769,8 @@ static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
 
 	*handle = DMA_MAPPING_ERROR;
 	allowblock = gfpflags_allow_blocking(gfp);
-	cma = allowblock ? dev_get_cma_area(dev) : false;
+	allowwriteback = gfpflags_allow_writeback(gfp);
+	cma = (allowblock && !allowwriteback) ? dev_get_cma_area(dev) : false;
 
 	if (cma)
 		buf->allocator = &cma_allocator;
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 5f5e25fd6149..70d7c598eb21 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -325,6 +325,11 @@ static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
 	return !!(gfp_flags & __GFP_DIRECT_RECLAIM);
 }
 
+static inline bool gfpflags_allow_writeback(const gfp_t gfp_flags)
+{
+	return !!(gfp_flags & __GFP_IO);
+}
+
 #ifdef CONFIG_HIGHMEM
 #define OPT_ZONE_HIGHMEM ZONE_HIGHMEM
 #else
-- 
2.20.1

