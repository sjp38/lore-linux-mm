Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CA5F26B0005
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 20:44:42 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b4so1064177pgs.5
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 17:44:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p4sor102376pgc.299.2018.02.07.17.44.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Feb 2018 17:44:41 -0800 (PST)
Date: Wed, 7 Feb 2018 17:44:38 -0800
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net: Whitelist the skbuff_head_cache "cb" field
Message-ID: <20180208014438.GA12186@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: syzbot+e2d6cfb305e9f3911dea@syzkaller.appspotmail.com, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, ebiggers3@gmail.com, james.morse@arm.com, keun-o.park@darkmatter.ae, labbott@redhat.com, linux-mm@kvack.org

Most callers of put_cmsg() use a "sizeof(foo)" for the length argument.
Within put_cmsg(), a copy_to_user() call is made with a dynamic size, as a
result of the cmsg header calculations. This means that hardened usercopy
will examine the copy, even though it was technically a fixed size and
should be implicitly whitelisted. All the put_cmsg() calls being built
from values in skbuff_head_cache are coming out of the protocol-defined
"cb" field, so whitelist this field entirely instead of creating per-use
bounce buffers, for which there are concerns about performance.

Original report was:

Bad or missing usercopy whitelist? Kernel memory exposure attempt detected from SLAB object 'skbuff_head_cache' (offset 64, size 16)!
WARNING: CPU: 0 PID: 3663 at mm/usercopy.c:81 usercopy_warn+0xdb/0x100 mm/usercopy.c:76
...
 __check_heap_object+0x89/0xc0 mm/slab.c:4426
 check_heap_object mm/usercopy.c:236 [inline]
 __check_object_size+0x272/0x530 mm/usercopy.c:259
 check_object_size include/linux/thread_info.h:112 [inline]
 check_copy_size include/linux/thread_info.h:143 [inline]
 copy_to_user include/linux/uaccess.h:154 [inline]
 put_cmsg+0x233/0x3f0 net/core/scm.c:242
 sock_recv_errqueue+0x200/0x3e0 net/core/sock.c:2913
 packet_recvmsg+0xb2e/0x17a0 net/packet/af_packet.c:3296
 sock_recvmsg_nosec net/socket.c:803 [inline]
 sock_recvmsg+0xc9/0x110 net/socket.c:810
 ___sys_recvmsg+0x2a4/0x640 net/socket.c:2179
 __sys_recvmmsg+0x2a9/0xaf0 net/socket.c:2287
 SYSC_recvmmsg net/socket.c:2368 [inline]
 SyS_recvmmsg+0xc4/0x160 net/socket.c:2352
 entry_SYSCALL_64_fastpath+0x29/0xa0

Reported-by: syzbot+e2d6cfb305e9f3911dea@syzkaller.appspotmail.com
Fixes: 6d07d1cd300f ("usercopy: Restrict non-usercopy caches to size 0")
Signed-off-by: Kees Cook <keescook@chromium.org>
---
I tried the inlining, it was awful. Splitting put_cmsg() was awful. So,
instead, whitelist the "cb" field as the least bad option if bounce
buffers are unacceptable. Dave, do you want to take this through net, or
should I take it through the usercopy tree?
---
 net/core/skbuff.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6b0ff396fa9d..201b96c8f414 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3889,10 +3889,12 @@ EXPORT_SYMBOL_GPL(skb_gro_receive);
 
 void __init skb_init(void)
 {
-	skbuff_head_cache = kmem_cache_create("skbuff_head_cache",
+	skbuff_head_cache = kmem_cache_create_usercopy("skbuff_head_cache",
 					      sizeof(struct sk_buff),
 					      0,
 					      SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+					      offsetof(struct sk_buff, cb),
+					      sizeof_field(struct sk_buff, cb),
 					      NULL);
 	skbuff_fclone_cache = kmem_cache_create("skbuff_fclone_cache",
 						sizeof(struct sk_buff_fclones),
-- 
2.7.4


-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
