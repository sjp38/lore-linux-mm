Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id A0AC66B006C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 04:12:37 -0400 (EDT)
Received: by wgez8 with SMTP id z8so29543020wge.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 01:12:37 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id y7si8090081wij.68.2015.06.10.01.12.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 01:12:35 -0700 (PDT)
Received: by wiwd19 with SMTP id d19so40027493wiw.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 01:12:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1433875204-18060-1-git-send-email-jeff.layton@primarydata.com>
References: <1433875204-18060-1-git-send-email-jeff.layton@primarydata.com>
From: Leon Romanovsky <leon@leon.nu>
Date: Wed, 10 Jun 2015 11:12:14 +0300
Message-ID: <CALq1K=J2JHswhYX+z4RX-fm75JqXeR8Yq8sMzeDqCjSoRN0oEw@mail.gmail.com>
Subject: Re: [PATCH] net, swap: Remove a warning and clarify why
 sk_mem_reclaim is required when deactivating swap
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: trond.myklebust@primarydata.com, davem@davemloft.net, netdev@vger.kernel.org, linux-nfs@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>

On Tue, Jun 9, 2015 at 9:40 PM, Jeff Layton <jlayton@poochiereds.net> wrote=
:
> From: Mel Gorman <mgorman@suse.de>
>
> Jeff Layton reported the following;
>
>  [   74.232485] ------------[ cut here ]------------
>  [   74.233354] WARNING: CPU: 2 PID: 754 at net/core/sock.c:364 sk_clear_=
memalloc+0x51/0x80()
>  [   74.234790] Modules linked in: cts rpcsec_gss_krb5 nfsv4 dns_resolver=
 nfs fscache xfs libcrc32c snd_hda_codec_generic snd_hda_intel snd_hda_cont=
roller snd_hda_codec snd_hda_core snd_hwdep snd_seq snd_seq_device nfsd snd=
_pcm snd_timer snd e1000 ppdev parport_pc joydev parport pvpanic soundcore =
floppy serio_raw i2c_piix4 pcspkr nfs_acl lockd virtio_balloon acpi_cpufreq=
 auth_rpcgss grace sunrpc qxl drm_kms_helper ttm drm virtio_console virtio_=
blk virtio_pci ata_generic virtio_ring pata_acpi virtio
>  [   74.243599] CPU: 2 PID: 754 Comm: swapoff Not tainted 4.1.0-rc6+ #5
>  [   74.244635] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
>  [   74.245546]  0000000000000000 0000000079e69e31 ffff8800d066bde8 fffff=
fff8179263d
>  [   74.246786]  0000000000000000 0000000000000000 ffff8800d066be28 fffff=
fff8109e6fa
>  [   74.248175]  0000000000000000 ffff880118d48000 ffff8800d58f5c08 ffff8=
80036e380a8
>  [   74.249483] Call Trace:
>  [   74.249872]  [<ffffffff8179263d>] dump_stack+0x45/0x57
>  [   74.250703]  [<ffffffff8109e6fa>] warn_slowpath_common+0x8a/0xc0
>  [   74.251655]  [<ffffffff8109e82a>] warn_slowpath_null+0x1a/0x20
>  [   74.252585]  [<ffffffff81661241>] sk_clear_memalloc+0x51/0x80
>  [   74.253519]  [<ffffffffa0116c72>] xs_disable_swap+0x42/0x80 [sunrpc]
>  [   74.254537]  [<ffffffffa01109de>] rpc_clnt_swap_deactivate+0x7e/0xc0 =
[sunrpc]
>  [   74.255610]  [<ffffffffa03e4fd7>] nfs_swap_deactivate+0x27/0x30 [nfs]
>  [   74.256582]  [<ffffffff811e99d4>] destroy_swap_extents+0x74/0x80
>  [   74.257496]  [<ffffffff811ecb52>] SyS_swapoff+0x222/0x5c0
>  [   74.258318]  [<ffffffff81023f27>] ? syscall_trace_leave+0xc7/0x140
>  [   74.259253]  [<ffffffff81798dae>] system_call_fastpath+0x12/0x71
>  [   74.260158] ---[ end trace 2530722966429f10 ]---
>
> The warning in question was unnecessary but with Jeff's series the rules
> are also clearer.  This patch removes the warning and updates the comment
> to explain why sk_mem_reclaim() may still be called.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  net/core/sock.c | 12 +++++-------
>  1 file changed, 5 insertions(+), 7 deletions(-)
>
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 292f42228bfb..2bb4c56370e5 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -354,14 +354,12 @@ void sk_clear_memalloc(struct sock *sk)
>
>         /*
>          * SOCK_MEMALLOC is allowed to ignore rmem limits to ensure forwa=
rd
> -        * progress of swapping. However, if SOCK_MEMALLOC is cleared whi=
le
> -        * it has rmem allocations there is a risk that the user of the
> -        * socket cannot make forward progress due to exceeding the rmem
> -        * limits. By rights, sk_clear_memalloc() should only be called
> -        * on sockets being torn down but warn and reset the accounting i=
f
> -        * that assumption breaks.
> +        * progress of swapping. SOCK_MEMALLOC may be cleared while
> +        * it has rmem allocations due to the last swapfile being deactiv=
ated
> +        * but there is a risk that the socket is unusable due to exceedi=
ng
> +        * the rmem limits. Reclaim the reserves and obey rmem limits aga=
in.
>          */
> -       if (WARN_ON(sk->sk_forward_alloc))
> +       if (sk->sk_forward_alloc)
You don't really need this IF. if sk->sk_forward_alloc is equal to
zero, it will be less than SK_MEM_QUANTUM.
http://lxr.free-electrons.com/source/include/net/sock.h#L1405

1405 static inline void sk_mem_reclaim(struct sock *sk)
1406 {
1407         if (!sk_has_account(sk))
1408                 return;
1409         if (sk->sk_forward_alloc >=3D SK_MEM_QUANTUM)
1410                 __sk_mem_reclaim(sk);
1411 }


>                 sk_mem_reclaim(sk);
>  }
>  EXPORT_SYMBOL_GPL(sk_clear_memalloc);
> --
> 2.4.2
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>



--=20
Leon Romanovsky | Independent Linux Consultant
        www.leon.nu | leon@leon.nu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
