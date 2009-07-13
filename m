Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A1EFD6B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 10:36:04 -0400 (EDT)
Received: by yxe35 with SMTP id 35so799479yxe.12
        for <linux-mm@kvack.org>; Mon, 13 Jul 2009 07:59:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090713115158.0a4892b0@mjolnir.ossman.eu>
References: <20090713115158.0a4892b0@mjolnir.ossman.eu>
Date: Mon, 13 Jul 2009 23:59:52 +0900
Message-ID: <28c262360907130759w29c84117w635b21408090a06c@mail.gmail.com>
Subject: Re: Page allocation failures in guest
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus-list@drzeus.cx>
Cc: avi@redhat.com, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 13, 2009 at 6:51 PM, Pierre Ossman<drzeus-list@drzeus.cx> wrote=
:
> I upgraded my Fedora 10 host to 2.6.29 a few days ago and since then
> one of the guests keeps getting page allocation failures after a few
> hours. I've upgraded the kernel in the guest from 2.6.27 to 2.6.29
> without any change. There are also a few other guests running on the
> machine that aren't having any issues.
>
> The only noticable thing that dies for me is the network. The machine
> still logs properly and I can attach to the local console and reboot it.
>
> This is what I see in dmesg/logs:
>
> Jul 12 23:04:54 loki kernel: sshd: page allocation failure. order:0, mode=
:0x4020

GFP_ATOMIC.
We don't have a many thing for reclaiming.

> Jul 12 23:04:54 loki kernel: Pid: 1682, comm: sshd Not tainted 2.6.29.5-8=
4.fc10.x86_64 #1
> Jul 12 23:04:54 loki kernel: Call Trace:
> Jul 12 23:04:54 loki kernel: <IRQ> =C2=A0[<ffffffff810a1896>] __alloc_pag=
es_internal+0x42f/0x451
> Jul 12 23:04:54 loki kernel: [<ffffffff810c52f8>] alloc_pages_current+0xb=
9/0xc2
> Jul 12 23:04:54 loki kernel: [<ffffffff810c926c>] alloc_slab_page+0x19/0x=
69
> Jul 12 23:04:54 loki kernel: [<ffffffff810c931f>] new_slab+0x63/0x1cb
> Jul 12 23:04:54 loki kernel: [<ffffffff810c99fd>] __slab_alloc+0x23d/0x3a=
c
> Jul 12 23:04:54 loki kernel: [<ffffffff812d49f2>] ? __netdev_alloc_skb+0x=
31/0x4d
> Jul 12 23:04:54 loki kernel: [<ffffffff810cac1b>] __kmalloc_node_track_ca=
ller+0xbb/0x11f
> Jul 12 23:04:54 loki kernel: [<ffffffff812d49f2>] ? __netdev_alloc_skb+0x=
31/0x4d
> Jul 12 23:04:54 loki kernel: [<ffffffff812d3dfc>] __alloc_skb+0x6f/0x130
> Jul 12 23:04:54 loki kernel: [<ffffffff812d49f2>] __netdev_alloc_skb+0x31=
/0x4d
> Jul 12 23:04:54 loki kernel: [<ffffffffa002e668>] try_fill_recv_maxbufs+0=
x5a/0x20d [virtio_net]
> Jul 12 23:04:54 loki kernel: [<ffffffffa002e83d>] try_fill_recv+0x22/0x17=
e [virtio_net]
> Jul 12 23:04:54 loki kernel: [<ffffffff812d9c74>] ? netif_receive_skb+0x4=
0a/0x42f
> Jul 12 23:04:54 loki kernel: [<ffffffffa002f4b9>] virtnet_poll+0x57f/0x5e=
e [virtio_net]
> Jul 12 23:04:54 loki kernel: [<ffffffff81374b45>] ? _spin_lock_irq+0x21/0=
x26
> Jul 12 23:04:54 loki kernel: [<ffffffff812d8372>] net_rx_action+0xb3/0x1a=
f
> Jul 12 23:04:54 loki kernel: [<ffffffff8104d9f0>] __do_softirq+0x94/0x150
> Jul 12 23:04:54 loki kernel: [<ffffffff8101274c>] call_softirq+0x1c/0x30
> Jul 12 23:04:54 loki kernel: <EOI> =C2=A0[<ffffffff81013869>] do_softirq+=
0x4d/0xb4
> Jul 12 23:04:54 loki kernel: [<ffffffff812cf149>] ? release_sock+0xb0/0xb=
b
> Jul 12 23:04:54 loki kernel: [<ffffffff8104d86f>] _local_bh_enable_ip+0xc=
5/0xe5
> Jul 12 23:04:54 loki kernel: [<ffffffff8104d898>] local_bh_enable_ip+0x9/=
0xb
> Jul 12 23:04:54 loki kernel: [<ffffffff81374954>] _spin_unlock_bh+0x13/0x=
15
> Jul 12 23:04:54 loki kernel: [<ffffffff812cf149>] release_sock+0xb0/0xbb
> Jul 12 23:04:54 loki kernel: [<ffffffff812d2f38>] ? __kfree_skb+0x82/0x86
> Jul 12 23:04:54 loki kernel: [<ffffffff8130f088>] tcp_recvmsg+0x974/0xa99
> Jul 12 23:04:54 loki kernel: [<ffffffff812ce566>] sock_common_recvmsg+0x3=
2/0x47
> Jul 12 23:04:54 loki kernel: [<ffffffff812cc5a1>] __sock_recvmsg+0x6d/0x7=
a
> Jul 12 23:04:54 loki kernel: [<ffffffff812cc69c>] sock_aio_read+0xee/0xfe
> Jul 12 23:04:54 loki kernel: [<ffffffff810d1ecb>] do_sync_read+0xe7/0x12d
> Jul 12 23:04:54 loki kernel: [<ffffffff811867ba>] ? rb_erase+0x278/0x2a0
> Jul 12 23:04:54 loki kernel: [<ffffffff8105bdc8>] ? autoremove_wake_funct=
ion+0x0/0x38
> Jul 12 23:04:54 loki kernel: [<ffffffff81374845>] ? _spin_lock+0x9/0xc
> Jul 12 23:04:54 loki kernel: [<ffffffff811502e8>] ? security_file_permiss=
ion+0x11/0x13
> Jul 12 23:04:54 loki kernel: [<ffffffff810d2884>] vfs_read+0xbb/0x102
> Jul 12 23:04:54 loki kernel: [<ffffffff810d298f>] sys_read+0x47/0x6e
> Jul 12 23:04:54 loki kernel: [<ffffffff8101133a>] system_call_fastpath+0x=
16/0x1b
> Jul 12 23:04:54 loki kernel: Mem-Info:
> Jul 12 23:04:54 loki kernel: Node 0 DMA per-cpu:
> Jul 12 23:04:54 loki kernel: CPU =C2=A0 =C2=A00: hi: =C2=A0 =C2=A00, btch=
: =C2=A0 1 usd: =C2=A0 0
> Jul 12 23:04:54 loki kernel: Node 0 DMA32 per-cpu:
> Jul 12 23:04:54 loki kernel: CPU =C2=A0 =C2=A00: hi: =C2=A0186, btch: =C2=
=A031 usd: 119
> Jul 12 23:04:54 loki kernel: Active_anon:14065 active_file:87384 inactive=
_anon:37480
> Jul 12 23:04:54 loki kernel: inactive_file:95821 unevictable:4 dirty:8 wr=
iteback:0 unstable:0
> Jul 12 23:04:54 loki kernel: free:1344 slab:7113 mapped:4283 pagetables:5=
656 bounce:0
> Jul 12 23:04:54 loki kernel: Node 0 DMA free:3988kB min:24kB low:28kB hig=
h:36kB active_anon:0kB inactive_anon:0kB active_file:3532kB inactive_file:1=
032kB unevictable:0kB present:6840kB pages_scanned:0 all_un

I don't know why present is bigger than free + [in]active anon ?
Who know this ?

There are 258 pages in inactive file.
Unfortunately, it seems we don't have any discardable pages.
The reclaimer can't sync dirty pages to reclaim them, too.
That's because we are going on GFP_ATOMIC as I mentioned.

> reclaimable? no
> Jul 12 23:04:54 loki kernel: lowmem_reserve[]: 0 994 994 994
> Jul 12 23:04:54 loki kernel: Node 0 DMA32 free:1388kB min:4020kB low:5024=
kB high:6028kB active_anon:56260kB inactive_anon:149920kB active_file:34600=
4kB inactive_file:382252kB unevictable:16kB present:1018016


free : 1388KB min : 4020KB. In addtion, now GFP_HIGH. so calculation
is as follow for zone_watermark_ok.

1388 < (4020 / 2)

So failed it in zone_watermark_ok.
AFAIU, it's fairy OOM problem.

> kB pages_scanned:96 all_unreclaimable? no
> Jul 12 23:04:54 loki kernel: lowmem_reserve[]: 0 0 0 0
> Jul 12 23:04:54 loki kernel: Node 0 DMA: 1*4kB 0*8kB 1*16kB 0*32kB 0*64kB=
 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB =3D 3988kB
> Jul 12 23:04:54 loki kernel: Node 0 DMA32: 4*4kB 77*8kB 3*16kB 0*32kB 1*6=
4kB 1*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB =3D 1384kB
> Jul 12 23:04:54 loki kernel: 183936 total pagecache pages
> Jul 12 23:04:54 loki kernel: 0 pages in swap cache
> Jul 12 23:04:54 loki kernel: Swap cache stats: add 0, delete 0, find 0/0
> Jul 12 23:04:54 loki kernel: Free swap =C2=A0=3D 1015800kB
> Jul 12 23:04:54 loki kernel: Total swap =3D 1015800kB
> Jul 12 23:04:54 loki kernel: 262128 pages RAM
> Jul 12 23:04:54 loki kernel: 8339 pages reserved
> Jul 12 23:04:54 loki kernel: 34783 pages shared
> Jul 12 23:04:54 loki kernel: 245277 pages non-shared
>
> It doesn't look like it's out of memory to me, so I'm not sure what is
> going on.
>
> Rgds
> --
> =C2=A0 =C2=A0 -- Pierre Ossman
>
> =C2=A0Linux kernel, MMC maintainer =C2=A0 =C2=A0 =C2=A0 =C2=A0http://www.=
kernel.org
> =C2=A0rdesktop, core developer =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0http://w=
ww.rdesktop.org
> =C2=A0TigerVNC, core developer =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0http://w=
ww.tigervnc.org
>
> =C2=A0WARNING: This correspondence is being monitored by the
> =C2=A0Swedish government. Make sure your server uses encryption
> =C2=A0for SMTP traffic and consider using PGP for end-to-end
> =C2=A0encryption.
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
