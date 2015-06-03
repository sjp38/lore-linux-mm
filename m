Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id BA673900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 10:32:10 -0400 (EDT)
Received: by wgez8 with SMTP id z8so10932883wge.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 07:32:10 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id aq6si1541026wjc.144.2015.06.03.07.32.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 07:32:07 -0700 (PDT)
Received: by wibut5 with SMTP id ut5so104908717wib.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 07:32:07 -0700 (PDT)
Date: Wed, 3 Jun 2015 10:32:00 -0400
From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [PATCH 3/4] sunrpc: if we're closing down a socket, clear
 memalloc on it first
Message-ID: <20150603103200.4f66bae5@synchrony.poochiereds.net>
In-Reply-To: <20150602124025.GG26425@suse.de>
References: <1432987393-15604-1-git-send-email-jeff.layton@primarydata.com>
	<1432987393-15604-4-git-send-email-jeff.layton@primarydata.com>
	<20150602124025.GG26425@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jerome Marchand <jmarchan@redhat.com>

On Tue, 2 Jun 2015 13:40:26 +0100
Mel Gorman <mgorman@suse.de> wrote:

> On Sat, May 30, 2015 at 08:03:12AM -0400, Jeff Layton wrote:
> > We currently increment the memalloc_socks counter if we have a xprt that
> > is associated with a swapfile. That socket can be replaced however
> > during a reconnect event, and the memalloc_socks counter is never
> > decremented if that occurs.
> > 
> > When tearing down a xprt socket, check to see if the xprt is set up for
> > swapping and sk_clear_memalloc before releasing the socket if so.
> > 
> > Cc: Mel Gorman <mgorman@suse.de>
> > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> 
> Acked-by: Mel Gorman <mgorman@suse.de>
> 

Thanks Mel,

I should also mention that I see this warning pop when working with
swapfiles on NFS. This trace is with this patchset, but I see a similar
one without it:

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

...that comes from this in sk_clear_memalloc:

        /*
         * SOCK_MEMALLOC is allowed to ignore rmem limits to ensure forward
         * progress of swapping. However, if SOCK_MEMALLOC is cleared while
         * it has rmem allocations there is a risk that the user of the
         * socket cannot make forward progress due to exceeding the rmem
         * limits. By rights, sk_clear_memalloc() should only be called
         * on sockets being torn down but warn and reset the accounting if
         * that assumption breaks.
         */
        if (WARN_ON(sk->sk_forward_alloc))
                sk_mem_reclaim(sk);

Is it wrong to call sk_clear_memalloc on swapoff? Should we try to keep
it set up as a memalloc socket on the last swapoff and just wait until
the socket is being freed to clear it? If so, then maybe the right
thing to do is to call sk_clear_memalloc in __sk_free or somewhere
similar if it's set up for memalloc?

-- 
Jeff Layton <jlayton@poochiereds.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
