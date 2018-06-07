Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE4856B0007
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 09:37:38 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k12-v6so5493917wrl.21
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 06:37:38 -0700 (PDT)
Received: from baptiste.telenet-ops.be (baptiste.telenet-ops.be. [2a02:1800:120:4::f00:13])
        by mx.google.com with ESMTPS id o15-v6si7239772wrh.142.2018.06.07.06.37.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 06:37:37 -0700 (PDT)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] xsk: Fix umem fill/completion queue mmap on 32-bit
Date: Thu,  7 Jun 2018 15:37:34 +0200
Message-Id: <1528378654-1484-1-git-send-email-geert@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S . Miller" <davem@davemloft.net>, =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>, Magnus Karlsson <magnus.karlsson@intel.com>, Alexei Starovoitov <ast@kernel.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>

With gcc-4.1.2 on 32-bit:

    net/xdp/xsk.c:663: warning: integer constant is too large for a??longa?? type
    net/xdp/xsk.c:665: warning: integer constant is too large for a??longa?? type

Add the missing "ULL" suffixes to the large XDP_UMEM_PGOFF_*_RING values
to fix this.

    net/xdp/xsk.c:663: warning: comparison is always false due to limited range of data type
    net/xdp/xsk.c:665: warning: comparison is always false due to limited range of data type

"unsigned long" is 32-bit on 32-bit systems, hence the offset is
truncated, and can never be equal to any of the XDP_UMEM_PGOFF_*_RING
values.  Use loff_t (and the required cast) to fix this.

Fixes: 423f38329d267969 ("xsk: add umem fill queue support and mmap")
Fixes: fe2308328cd2f26e ("xsk: add umem completion queue support and mmap")
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
Compile-tested only.
---
 include/uapi/linux/if_xdp.h | 4 ++--
 net/xdp/xsk.c               | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/if_xdp.h b/include/uapi/linux/if_xdp.h
index 1fa0e977ea8d0224..caed8b1614ffc0aa 100644
--- a/include/uapi/linux/if_xdp.h
+++ b/include/uapi/linux/if_xdp.h
@@ -63,8 +63,8 @@ struct xdp_statistics {
 /* Pgoff for mmaping the rings */
 #define XDP_PGOFF_RX_RING			  0
 #define XDP_PGOFF_TX_RING		 0x80000000
-#define XDP_UMEM_PGOFF_FILL_RING	0x100000000
-#define XDP_UMEM_PGOFF_COMPLETION_RING	0x180000000
+#define XDP_UMEM_PGOFF_FILL_RING	0x100000000ULL
+#define XDP_UMEM_PGOFF_COMPLETION_RING	0x180000000ULL
 
 /* Rx/Tx descriptor */
 struct xdp_desc {
diff --git a/net/xdp/xsk.c b/net/xdp/xsk.c
index c6ed2454f7ce55e8..36919a254ba370c3 100644
--- a/net/xdp/xsk.c
+++ b/net/xdp/xsk.c
@@ -643,7 +643,7 @@ static int xsk_getsockopt(struct socket *sock, int level, int optname,
 static int xsk_mmap(struct file *file, struct socket *sock,
 		    struct vm_area_struct *vma)
 {
-	unsigned long offset = vma->vm_pgoff << PAGE_SHIFT;
+	loff_t offset = (loff_t)vma->vm_pgoff << PAGE_SHIFT;
 	unsigned long size = vma->vm_end - vma->vm_start;
 	struct xdp_sock *xs = xdp_sk(sock->sk);
 	struct xsk_queue *q = NULL;
-- 
2.7.4
