Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 80EA16B000C
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 11:16:27 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 5so8210853wrt.12
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 08:16:27 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.18])
        by mx.google.com with ESMTPS id f9si18318455wrf.83.2018.02.20.08.16.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 08:16:26 -0800 (PST)
From: =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
Subject: [PATCH 2/6] powerpc: numa: Fix overshift on PPC32
Date: Tue, 20 Feb 2018 17:14:20 +0100
Message-Id: <20180220161424.5421-3-j.neuschaefer@gmx.net>
In-Reply-To: <20180220161424.5421-1-j.neuschaefer@gmx.net>
References: <20180220161424.5421-1-j.neuschaefer@gmx.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, Joel Stanley <joel@jms.id.au>, =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Michael Bringmann <mwb@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

When read_n_cells is compiled for PPC32, "result << 32" causes an
overshift, which GCC doesn't like. Fix this by using u64 instead of
unsigned long.

Signed-off-by: Jonathan NeuschA?fer <j.neuschaefer@gmx.net>
---
 arch/powerpc/mm/numa.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index edd8d0bc9364..0570bc2a0b13 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -357,9 +357,9 @@ static void __init get_n_mem_cells(int *n_addr_cells, int *n_size_cells)
 	of_node_put(memory);
 }
 
-static unsigned long read_n_cells(int n, const __be32 **buf)
+static u64 read_n_cells(int n, const __be32 **buf)
 {
-	unsigned long result = 0;
+	u64 result = 0;
 
 	while (n--) {
 		result = (result << 32) | of_read_number(*buf, 1);
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
