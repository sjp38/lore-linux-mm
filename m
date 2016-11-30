From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: PROBLEM-PERSISTS: dmesg spam: alloc_contig_range: [XX, YY) PFNs busy
Date: Wed, 30 Nov 2016 14:08:00 +0100
Message-ID: <xa1ty4012k0f.fsf@mina86.com>
References: <robbat2-20161129T223723-754929513Z@orbis-terrarum.net> <20161130092239.GD18437@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161130092239.GD18437@dhcp22.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>, "Robin H. Johnson" <robbat2@orbis-terrarum.net>
Cc: linux-kernel@vger.kernel.org, robbat2@gentoo.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Wed, Nov 30 2016, Michal Hocko wrote:
> [Let's CC linux-mm and Michal]
>
> On Tue 29-11-16 22:43:08, Robin H. Johnson wrote:
>> I didn't get any responses to this.
>>=20
>> git bisect shows that the problem did actually exist in 4.5.0-rc6, but
>> has gotten worse by many orders of magnitude (< 1/week to ~20M/hour).
>>=20
>> Presently with 4.9-rc5, it's now writing ~2.5GB/hour to syslog.
>
> This is really not helpful. I think we should simply make it pr_debug or
> need some ratelimitting.  AFAIU the message is far from serious

On the other hand, if this didn=E2=80=99t happen and now happens all the ti=
me,
this indicates a regression in CMA=E2=80=99s capability to allocate pages so
just rate limiting the output would hide the potential actual issue.

>=20=20
>> The list of addresses in that time is only ~80 unique ranges, each
>> appearing ~320K times. They don't appear exactly in order, so the kernel
>> does not squelch the log message for appearing too frequently.
>>=20
>> Could somebody at least make a suggestion on how to trace the printed
>> range to somewhere in the kernel?
>>=20
>> On Sat, Nov 19, 2016 at 03:25:32AM +0000, Robin H. Johnson wrote:
>> > (Replies CC to list and direct to me please)
>> >=20
>> > Summary:
>> > --------
>> > dmesg spammed with alloc_contig_range: [XX, YY) PFNs busy
>> >=20
>> > Description:
>> > ------------
>> > I recently upgrading 4.9-rc5, (previous kernel 4.5.0-rc6-00141-g679440=
2),=20
>> > and since then my dmesg has been absolutely flooded with 'PFNs busy'
>> > (>3GiB/day). My config did not change (all new options =3Dn).
>> >=20
>> > It's not consistent addresses, so the squelch of identical printk lines
>> > hasn't helped.
>> > Eg output:
>> > [187487.621916] alloc_contig_range: [83f0a9, 83f0aa) PFNs busy
>> > [187487.621924] alloc_contig_range: [83f0ce, 83f0cf) PFNs busy
>> > [187487.621976] alloc_contig_range: [83f125, 83f126) PFNs busy
>> > [187487.622013] alloc_contig_range: [83f127, 83f128) PFNs busy
>> >=20
>> > Keywords:
>> > ---------
>> > mm, alloc_contig_range, CMA
>> >=20
>> > Most recent kernel version which did not have the bug:
>> > ------------------------------------------------------
>> > Known 4.5.0-rc6-00141-g6794402
>> >=20
>> > ver_linux:
>> > ----------
>> > Linux bohr-int 4.9.0-rc5-00177-g81bcfe5 #12 SMP Wed Nov 16 13:16:32 PST
>> > 2016 x86_64 Intel(R) Core(TM) i7-2600K CPU @ 3.40GHz GenuineIntel
>> > GNU/Linux
>> >=20
>> > GNU C					5.3.0
>> > GNU Make				4.2.1
>> > Binutils				2.25.1
>> > Util-linux				2.29
>> > Mount					2.29
>> > Quota-tools				4.03
>> > Linux C Library			2.23
>> > Dynamic linker (ldd)	2.23
>> > readlink: missing operand
>> > Try 'readlink --help' for more information.
>> > Procps					3.3.12
>> > Net-tools				1.60
>> > Kbd						2.0.3
>> > Console-tools			2.0.3
>> > Sh-utils				8.25
>> > Udev					230
>> > Modules Loaded			3w_sas 3w_xxxx ablk_helper aesni_intel
>> > aes_x86_64 af_packet ahci aic79xx amdgpu async_memcpy async_pq
>> > async_raid6_recov async_tx async_xor ata_piix auth_rpcgss binfmt_misc
>> > bluetooth bnep bnx2 bonding btbcm btintel btrfs btrtl btusb button cdr=
om
>> > cn configs coretemp crc32c_intel crc32_pclmul crc_ccitt crc_itu_t
>> > crct10dif_pclmul cryptd dca dm_bio_prison dm_bufio dm_cache dm_cache_s=
mq
>> > dm_crypt dm_delay dm_flakey dm_log dm_log_userspace dm_mirror dm_mod
>> > dm_multipath dm_persistent_data dm_queue_length dm_raid dm_region_hash
>> > dm_round_robin dm_service_time dm_snapshot dm_thin_pool dm_zero drm
>> > drm_kms_helper dummy e1000 e1000e evdev ext2 fat fb_sys_fops
>> > firewire_core firewire_ohci fjes fscache fuse ghash_clmulni_intel
>> > glue_helper grace hangcheck_timer hid_a4tech hid_apple hid_belkin
>> > hid_cherry hid_chicony hid_cypress hid_ezkey hid_generic hid_gyration
>> > hid_logitech hid_logitech_dj hid_microsoft hid_monterey hid_petalynx
>> > hid_pl hid_samsung hid_sony hid_sunplus hwmon_vid i2c_algo_bit i2c_i801
>> > i2c_smbus igb input_leds intel_rapl ip6_udp_tunnel ipv6 irqbypass
>> > iscsi_tcp iTCO_vendor_support iTCO_wdt ixgb ixgbe jfs kvm kvm_intel
>> > libahci libata libcrc32c libiscsi libiscsi_tcp linear lockd lpc_ich lp=
fc
>> > lrw macvlan mdio md_mod megaraid_mbox megaraid_mm megaraid_sas mii
>> > mptbase mptfc mptsas mptscsih mptspi multipath nfs nfs_acl nfsd
>> > nls_cp437 nls_iso8859_1 nvram ohci_hcd pata_jmicron pata_marvell
>> > pata_platform pcspkr psmouse qla1280 qla2xxx r8169 radeon raid0 raid10
>> > raid1 raid456 raid6_pq reiserfs rfkill sata_mv sata_sil24
>> > scsi_transport_fc scsi_transport_iscsi scsi_transport_sas
>> > scsi_transport_spi sd_mod sg sky2 snd snd_hda_codec
>> > snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_codec_realtek
>> > snd_hda_core snd_hda_intel snd_hwdep snd_pcm snd_timer soundcore sr_mod
>> > sunrpc syscopyarea sysfillrect sysimgblt tg3 ttm uas udp_tunnel
>> > usb_storage vfat virtio virtio_net virtio_ring vxlan w83627ehf
>> > x86_pkg_temp_thermal xfs xhci_hcd xhci_pci xor zlib_deflate
>>=20
>> --=20
>> Robin Hugh Johnson
>> E-Mail     : robbat2@orbis-terrarum.net
>> Home Page  : http://www.orbis-terrarum.net/?l=3Dpeople.robbat2
>> ICQ#       : 30269588 or 41961639
>> GnuPG FP   : 11ACBA4F 4778E3F6 E4EDF38E B27B944E 34884E85
>
>
>
> --=20
> Michal Hocko
> SUSE Labs

--=20
Best regards
=E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9C=F0=9D=93=B6=F0=9D=93=B2=F0=9D=93=B7=
=F0=9D=93=AA86=E2=80=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=83=
=84
=C2=ABIf at first you don=E2=80=99t succeed, give up skydiving=C2=BB
