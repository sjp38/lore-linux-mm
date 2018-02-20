Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 35F316B0008
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 11:16:16 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 30so8366722wrw.6
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 08:16:16 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.18])
        by mx.google.com with ESMTPS id w63si4983010wma.74.2018.02.20.08.16.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 08:16:14 -0800 (PST)
From: =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
Subject: [PATCH 0/6] DISCONTIGMEM support for PPC32
Date: Tue, 20 Feb 2018 17:14:18 +0100
Message-Id: <20180220161424.5421-1-j.neuschaefer@gmx.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, Joel Stanley <joel@jms.id.au>, =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>

This patchset adds support for DISCONTIGMEM on 32-bit PowerPC. This is
required to properly support the Nintendo Wii's memory layout, in which
there are two blocks of RAM and MMIO in the middle.

Previously, this memory layout was handled by code that joins the two
RAM blocks into one, reserves the MMIO hole, and permits allocations of
reserved memory in ioremap. This hack didn't work with resource-based
allocation (as used for example in the GPIO driver for Wii[1]), however.

After this patchset, users of the Wii can either select CONFIG_FLATMEM
to get the old behaviour, or CONFIG_DISCONTIGMEM to get the new
behaviour.

Some parts of this patchset are probably not ideal (I'm thinking of my
implementation of pfn_to_nid here), and will require some discussion/
changes.

[1]: https://www.spinics.net/lists/devicetree/msg213956.html

Jonathan NeuschA?fer (6):
  powerpc/mm/32: Use pfn_valid to check if pointer is in RAM
  powerpc: numa: Fix overshift on PPC32
  powerpc: numa: Use the right #ifdef guards around functions
  powerpc: numa: Restrict fake NUMA enulation to CONFIG_NUMA systems
  powerpc: Implement DISCONTIGMEM and allow selection on PPC32
  powerpc: wii: Don't rely on reserved memory hack if DISCONTIGMEM is
    set

 arch/powerpc/Kconfig                     |  5 ++++-
 arch/powerpc/include/asm/mmzone.h        | 21 +++++++++++++++++++++
 arch/powerpc/mm/numa.c                   | 18 +++++++++++++++---
 arch/powerpc/mm/pgtable_32.c             |  2 +-
 arch/powerpc/platforms/embedded6xx/wii.c | 10 +++++++---
 5 files changed, 48 insertions(+), 8 deletions(-)

-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
