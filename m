Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4C65E6B025F
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 10:47:30 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o63so703561qkb.4
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 07:47:30 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id f56si251318qta.496.2017.09.01.07.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Sep 2017 07:47:28 -0700 (PDT)
Message-Id: <1504277247.293591.1092309696.3D87457A@webmail.messagingengine.com>
From: Jeff Cook <jeff@jeffcook.io>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="utf-8"
Date: Fri, 01 Sep 2017 10:47:27 -0400
In-Reply-To: <20170830145742.xird3lgsb3nemtye@angband.pl>
Subject: Re: [PATCH 00/13] mmu_notifier kill invalidate_page callback
References: <20170829235447.10050-1-jglisse@redhat.com>
 <CA+55aFz6ArJ-ADXiYCu6xMUzdY=mKBtkzfJmLaBohC6Ub9t2SQ@mail.gmail.com>
 <20170830005615.GA2386@redhat.com>
 <20170830145742.xird3lgsb3nemtye@angband.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Adam Borowski <kilobyte@angband.pl>, Jerome Glisse <jglisse@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Joerg Roedel <jroedel@suse.de>, Dan Williams <dan.j.williams@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Jack Steiner <steiner@sgi.com>, Paolo Bonzini <pbonzini@redhat.com>, =?utf-8?Q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, DRI <dri-devel@lists.freedesktop.org>, amd-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, "open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>, xen-devel <xen-devel@lists.xenproject.org>, KVM list <kvm@vger.kernel.org>

On Wed, Aug 30, 2017, at 10:57 AM, Adam Borowski wrote:
> On Tue, Aug 29, 2017 at 08:56:15PM -0400, Jerome Glisse wrote:
> > I will wait for people to test and for result of my own test before
> > reposting if need be, otherwise i will post as separate patch.
> >
> > > But from a _very_ quick read-through this looks fine. But it obviously
> > > needs testing.
> > >=20
> > > People - *especially* the people who saw issues under KVM - can you
> > > try out J=C3=A9r=C3=B4me's patch-series? I aded some people to the cc=
, the full
> > > series is on lkml. J=C3=A9r=C3=B4me - do you have a git branch for pe=
ople to
> > > test that they could easily pull and try out?
> >=20
> > https://cgit.freedesktop.org/~glisse/linux mmu-notifier branch
> > git://people.freedesktop.org/~glisse/linux
>=20
> Tested your branch as of 10f07641, on a long list of guest VMs.
> No earth-shattering kaboom.

I've been using the mmu_notifier branch @ a3d944233bcf8c for the last 36
hours or so, also without incident.

Unlike most other reporters, I experienced a similar splat on 4.12:

Aug 03 15:02:47 kvm_master kernel: ------------[ cut here ]------------
Aug 03 15:02:47 kvm_master kernel: WARNING: CPU: 13 PID: 1653 at
arch/x86/kvm/mmu.c:682 mmu_spte_clear_track_bits+0xfb/0x100 [kvm]
Aug 03 15:02:47 kvm_master kernel: Modules linked in: vhost_net vhost
tap xt_conntrack xt_CHECKSUM iptable_mangle ipt_REJECT nf_reject_ipv4
xt_tcpudp tun ebtable_filter ebtables ip6table_filter ip6_tables
iptable_filter msr nls_iso8859_1 nls_cp437 intel_rapl ipt_
MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_conntrack_ipv4
nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack sb_edac
x86_pkg_temp_thermal intel_powerclamp coretemp crct10dif_pclmul
crc32_pclmul ghash_clmulni_intel input_leds pcbc aesni_intel led_class
aes_x86_6
4 mxm_wmi crypto_simd glue_helper uvcvideo cryptd videobuf2_vmalloc
videobuf2_memops igb videobuf2_v4l2 videobuf2_core snd_usb_audio
videodev media joydev ptp evdev mousedev intel_cstate pps_core mac_hid
intel_rapl_perf snd_hda_intel snd_virtuoso snd_usbmidi_lib snd_hda_codec
snd_oxygen_lib snd_hda_core=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20
Aug 03 15:02:47 kvm_master kernel:  snd_mpu401_uart snd_rawmidi
snd_hwdep snd_seq_device snd_pcm snd_timer snd soundcore i2c_algo_bit
pcspkr i2c_i801 lpc_ich ioatdma shpchp dca wmi acpi_power_meter tpm_tis
tpm_tis_core tpm button bridge stp llc sch_fq_codel virtio_pci
virtio_blk virtio_balloon virtio_net virtio_ring virtio kvm_intel kvm sg
ip_tables x_tables hid_logitech_hidpp hid_logitech_dj hid_generic
hid_microsoft usbhid hid sr_mod cdrom sd_mod xhci_pci ahci libahci
xhci_hcd libata usbcore scsi_mod usb_common zfs(PO) zunicode(PO)
zavl(PO) icp(PO) zcommon(PO) znvpair(PO) spl(O) drm_kms_helper
syscopyarea sysfillrect sysimgblt fb_sys_fops drm vfio_pci irqbypass
vfio_virqfd vfio_iommu_type1 vfio vfat fat ext4 crc16 jbd2 fscrypto
mbcache dm_thin_pool dm_cache dm_persistent_data dm_bio_prison dm_bufio
dm_raid raid456 libcrc32c=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
Aug 03 15:02:47 kvm_master kernel:  crc32c_generic crc32c_intel
async_raid6_recov async_memcpy async_pq async_xor xor async_tx raid6_pq
dm_mod dax raid1 md_mod=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20
Aug 03 15:02:47 kvm_master kernel: CPU: 13 PID: 1653 Comm: kworker/13:2
Tainted: P    B D W  O    4.12.3-1-ARCH #1=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20
Aug 03 15:02:47 kvm_master kernel: Hardware name: Supermicro
SYS-7038A-I/X10DAI, BIOS 2.0a 11/09/2016=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
Aug 03 15:02:47 kvm_master kernel: Workqueue: events mmput_async_fn=20=20=
=20=20=20=20
Aug 03 15:02:47 kvm_master kernel: task: ffff9fa89751b900 task.stack:
ffffc179880d8000=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20
Aug 03 15:02:47 kvm_master kernel: RIP:
0010:mmu_spte_clear_track_bits+0xfb/0x100 [kvm]=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
Aug 03 15:02:47 kvm_master kernel: RSP: 0018:ffffc179880dbc20 EFLAGS:
00010246=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20
Aug 03 15:02:47 kvm_master kernel: RAX: 0000000000000000 RBX:
00000009c07cce77 RCX: dead0000000000ff=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
Aug 03 15:02:47 kvm_master kernel: RDX: 0000000000000000 RSI:
ffff9fa82d6d6f08 RDI: fffff6e76701f300=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
Aug 03 15:02:47 kvm_master kernel: RBP: ffffc179880dbc38 R08:
0000000000100000 R09: 000000000000000d=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
Aug 03 15:02:47 kvm_master kernel: R10: ffff9fa0a56b0008 R11:
ffff9fa0a56b0000 R12: 00000000009c07cc=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
Aug 03 15:02:47 kvm_master kernel: R13: ffff9fa88b990000 R14:
ffff9f9e19dbb1b8 R15: 0000000000000000=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
Aug 03 15:02:47 kvm_master kernel: FS:  0000000000000000(0000)
GS:ffff9fac5f340000(0000) knlGS:0000000000000000=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20
Aug 03 15:02:47 kvm_master kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
0000000080050033=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20
Aug 03 15:02:47 kvm_master kernel: CR2: ffffd1b542d71000 CR3:
0000000570a09000 CR4: 00000000003426e0=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
Aug 03 15:02:47 kvm_master kernel: DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
Aug 03 15:02:47 kvm_master kernel: DR3: 0000000000000000 DR6:
00000000fffe0ff0 DR7: 0000000000000400=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
Aug 03 15:02:47 kvm_master kernel: Call Trace:=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20
Aug 03 15:02:47 kvm_master kernel:  drop_spte+0x1a/0xb0 [kvm]=20=20=20=20
Aug 03 15:02:47 kvm_master kernel:  mmu_page_zap_pte+0x9c/0xe0 [kvm]=20=20=
=20=20=20
Aug 03 15:02:47 kvm_master kernel:  kvm_mmu_prepare_zap_page+0x65/0x310
[kvm]
Aug 03 15:02:47 kvm_master kernel:=20
kvm_mmu_invalidate_zap_all_pages+0x10d/0x160 [kvm]
Aug 03 15:02:47 kvm_master kernel:  kvm_arch_flush_shadow_all+0xe/0x10
[kvm]
Aug 03 15:02:47 kvm_master kernel:  kvm_mmu_notifier_release+0x2c/0x40
[kvm]
Aug 03 15:02:47 kvm_master kernel:  __mmu_notifier_release+0x44/0xc0
Aug 03 15:02:47 kvm_master kernel:  exit_mmap+0x142/0x150
Aug 03 15:02:47 kvm_master kernel:  ? kfree+0x175/0x190
Aug 03 15:02:47 kvm_master kernel:  ? kfree+0x175/0x190
Aug 03 15:02:47 kvm_master kernel:  ? exit_aio+0xc6/0x100
Aug 03 15:02:47 kvm_master kernel:  mmput_async_fn+0x4c/0x130
Aug 03 15:02:47 kvm_master kernel:  process_one_work+0x1de/0x430
Aug 03 15:02:47 kvm_master kernel:  worker_thread+0x47/0x3f0
Aug 03 15:02:47 kvm_master kernel:  kthread+0x125/0x140
Aug 03 15:02:47 kvm_master kernel:  ? process_one_work+0x430/0x430
Aug 03 15:02:47 kvm_master kernel:  ? kthread_create_on_node+0x70/0x70
Aug 03 15:02:47 kvm_master kernel:  ret_from_fork+0x25/0x30
Aug 03 15:02:47 kvm_master kernel: Code: ec 75 04 00 48 b8 00 00 00 00
00 00 00 40 48 21 da 48 39 c2 0f 95 c0 eb b2 48 d1 eb 83 e3 01 eb c0 4c
89 e7 e8 f7 3d fe ff eb a4 <0f> ff eb 8a 90 0f 1f 44 00 00 55 48 89 e5
53 89 d3 e8 ff 4a fe=20
Aug 03 15:02:47 kvm_master kernel: ---[ end trace 8710f4d700a7d36e ]---

This would typically take 36-48 hours to surface, so we're good so far,
but not completely out of the woods yet. I'm optimistic that since this
patchset changes the mmu_notifier behavior to something safer in
general, this issue will also be resolved by it.

Jeff

>=20
>=20
> Meow!
> --=20
> =E2=A2=80=E2=A3=B4=E2=A0=BE=E2=A0=BB=E2=A2=B6=E2=A3=A6=E2=A0=80=20
> =E2=A3=BE=E2=A0=81=E2=A2=B0=E2=A0=92=E2=A0=80=E2=A3=BF=E2=A1=81 Vat kind =
uf sufficiently advanced technology iz dis!?
> =E2=A2=BF=E2=A1=84=E2=A0=98=E2=A0=B7=E2=A0=9A=E2=A0=8B=E2=A0=80          =
                       -- Genghis Ht'rok'din
> =E2=A0=88=E2=A0=B3=E2=A3=84=E2=A0=80=E2=A0=80=E2=A0=80=E2=A0=80=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
