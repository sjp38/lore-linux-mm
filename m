Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 355126B006C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 21:02:17 -0400 (EDT)
Received: by igbpi8 with SMTP id pi8so46935162igb.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 18:02:17 -0700 (PDT)
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com. [209.85.223.175])
        by mx.google.com with ESMTPS id p20si5193956igs.34.2015.06.10.18.02.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 18:02:15 -0700 (PDT)
Received: by iesa3 with SMTP id a3so44672455ies.2
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 18:02:15 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
Subject: [PATCH v2] net, swap: Remove a warning and clarify why sk_mem_reclaim is required when deactivating swap
Date: Wed, 10 Jun 2015 21:02:04 -0400
Message-Id: <1433984524-28063-1-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1433875204-18060-1-git-send-email-jeff.layton@primarydata.com>
References: <1433875204-18060-1-git-send-email-jeff.layton@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trond.myklebust@primarydata.com
Cc: davem@davemloft.net, netdev@vger.kernel.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, mgorman@suse.de, linux-mm@kvack.org, Leon Romanovsky <leon@leon.nu>

From: Mel Gorman <mgorman@suse.de>

Jeff Layton reported the following;

 [   74.232485] ------------[ cut here ]------------
 [   74.233354] WARNING: CPU: 2 PID: 754 at net/core/sock.c:364 sk_clear_memalloc+0x51/0x80()
 [   74.234790] Modules linked in: cts rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache xfs libcrc32c snd_hda_codec_generic snd_hda_intel snd_hda_controller snd_hda_codec snd_hda_core snd_hwdep snd_seq snd_seq_device nfsd snd_pcm snd_timer snd e1000 ppdev parport_pc joydev parport pvpanic soundcore floppy serio_raw i2c_piix4 pcspkr nfs_acl lockd virtio_balloon acpi_cpufreq auth_rpcgss grace sunrpc qxl drm_kms_helper ttm drm virtio_console virtio_blk virtio_pci ata_generic virtio_ring pata_acpi virtio
 [   74.243599] CPU: 2 PID: 754 Comm: swapoff Not tainted 4.1.0-rc6+ #5
 [   74.244635] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
 [   74.245546]  0000000000000000 0000000079e69e31 ffff8800d066bde8 ffffffff8179263d
 [   74.246786]  0000000000000000 0000000000000000 ffff8800d066be28 ffffffff8109e6fa
 [   74.248175]  0000000000000000 ffff880118d48000 ffff8800d58f5c08 ffff880036e380a8
 [   74.249483] Call Trace:
 [   74.249872]  [<ffffffff8179263d>] dump_stack+0x45/0x57
 [   74.250703]  [<ffffffff8109e6fa>] warn_slowpath_common+0x8a/0xc0
 [   74.251655]  [<ffffffff8109e82a>] warn_slowpath_null+0x1a/0x20
 [   74.252585]  [<ffffffff81661241>] sk_clear_memalloc+0x51/0x80
 [   74.253519]  [<ffffffffa0116c72>] xs_disable_swap+0x42/0x80 [sunrpc]
 [   74.254537]  [<ffffffffa01109de>] rpc_clnt_swap_deactivate+0x7e/0xc0 [sunrpc]
 [   74.255610]  [<ffffffffa03e4fd7>] nfs_swap_deactivate+0x27/0x30 [nfs]
 [   74.256582]  [<ffffffff811e99d4>] destroy_swap_extents+0x74/0x80
 [   74.257496]  [<ffffffff811ecb52>] SyS_swapoff+0x222/0x5c0
 [   74.258318]  [<ffffffff81023f27>] ? syscall_trace_leave+0xc7/0x140
 [   74.259253]  [<ffffffff81798dae>] system_call_fastpath+0x12/0x71
 [   74.260158] ---[ end trace 2530722966429f10 ]---

The warning in question was unnecessary but with Jeff's series the rules
are also clearer.  This patch removes the warning and updates the comment
to explain why sk_mem_reclaim() may still be called.

[jlayton: remove if (sk->sk_forward_alloc) conditional. As Leon
          points out that it's not needed.]

Cc: Leon Romanovsky <leon@leon.nu>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 net/core/sock.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 292f42228bfb..469d6039c7f5 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -354,15 +354,12 @@ void sk_clear_memalloc(struct sock *sk)
 
 	/*
 	 * SOCK_MEMALLOC is allowed to ignore rmem limits to ensure forward
-	 * progress of swapping. However, if SOCK_MEMALLOC is cleared while
-	 * it has rmem allocations there is a risk that the user of the
-	 * socket cannot make forward progress due to exceeding the rmem
-	 * limits. By rights, sk_clear_memalloc() should only be called
-	 * on sockets being torn down but warn and reset the accounting if
-	 * that assumption breaks.
+	 * progress of swapping. SOCK_MEMALLOC may be cleared while
+	 * it has rmem allocations due to the last swapfile being deactivated
+	 * but there is a risk that the socket is unusable due to exceeding
+	 * the rmem limits. Reclaim the reserves and obey rmem limits again.
 	 */
-	if (WARN_ON(sk->sk_forward_alloc))
-		sk_mem_reclaim(sk);
+	sk_mem_reclaim(sk);
 }
 EXPORT_SYMBOL_GPL(sk_clear_memalloc);
 
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
