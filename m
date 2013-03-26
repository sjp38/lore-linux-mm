Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 8226E6B00D8
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 05:32:29 -0400 (EDT)
Date: Tue, 26 Mar 2013 05:32:27 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1122269504.6445741.1364290347815.JavaMail.root@redhat.com>
In-Reply-To: <0000013da2b53120-1c207286-3e36-483e-9fd9-90fc529d48aa-000000@email.amazonses.com>
Subject: Re: BUG at kmem_cache_alloc
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Dave Jones <davej@redhat.com>



----- Original Message -----
> From: "Christoph Lameter" <cl@linux.com>
> To: "CAI Qian" <caiqian@redhat.com>
> Cc: "David Rientjes" <rientjes@google.com>, "linux-mm" <linux-mm@kvack.or=
g>, linux-kernel@vger.kernel.org, "Oleg
> Nesterov" <oleg@redhat.com>
> Sent: Tuesday, March 26, 2013 2:00:16 AM
> Subject: Re: BUG at kmem_cache_alloc
>=20
>=20
> Please enable CONFIG_SLUB_DEBUG_ON or run the kernel with slub_debug
> on
> the command line to get detailed diagnostics as to what causes this.
>=20
Still running and will update ASAP. One thing I noticed was that trinity
threw out this error before the kernel crash.

[19380] Random reseed: 644697889=20
trinity(19380): Randomness reseeded to 0x266d4f21=20
trinity: trinity(19380) Randomness reseeded to 0x266d4f21=20
[19380] Random reseed: 1927643389=20
trinity(19380): Randomness reseeded to 0x72e580fd=20
trinity: trinity(19380) Randomness reseeded to 0x72e580fd=20
[watchdog] 9381710 iterations. [F:8140812 S:1240290]=20
[watchdog] 9383499 iterations. [F:8142333 S:1240558]=20
=20
Session terminated, killing shell...     =20
BUG!:      =20
CHILD (pid:28825) GOT REPARENTED! parent pid:19380. Watchdog pid:19379=20
     =20
BUG!:      =20
Last syscalls:=20
[0]  pid:28515 call:settimeofday callno:10356=20
[1]  pid:28822 call:setgid callno:322=20
[2]  pid:28581 call:init_module callno:3622=20
[3]  pid:28825 call:readlinkat callno:403=20
child 28581 exiting=20
child 28515 exiting=20
 ...killed.=20

Then, some tests in LTP called epoll triggered it eventually.

[ 9788.955733] BUG: unable to handle kernel paging request at 00000000fffff=
ff7=20
[ 9788.956687] IP: [<ffffffff811876a8>] kmem_cache_alloc+0x68/0x1e0=20
[ 9788.956687] PGD bebd3067 PUD 0 =20
[ 9788.956687] Oops: 0000 [#1] SMP =20
[ 9788.956687] Modules linked in: l2tp_ppp l2tp_netlink l2tp_core tun cmtp =
kernelcapi bnep fuse rfcomm hidp ipt_ULOG rds af_key pppoe pppox ppp_generi=
c slhc af_802154 nfc atm ip6table_filter ip6_tables iptable_filter ip_table=
s btrfs zlib_deflate vfat fat nfs_layout_nfsv41_files nfsv4 auth_rpcgss nfs=
v3 nfs_acl nfsv2 nfs lockd sunrpc fscache nfnetlink_log nfnetlink bluetooth=
 rfkill arc4 md4 nls_utf8 cifs dns_resolver nf_tproxy_core nls_koi8_u nls_c=
p932 ts_kmp sctp sg i5000_edac coretemp edac_core kvm_intel iTCO_wdt iTCO_v=
endor_support kvm lpc_ich ipmi_si ipmi_msghandler i5k_amb mfd_core hpilo hp=
wdt shpchp serio_raw microcode pcspkr xfs sd_mod crc_t10dif sr_mod cdrom at=
a_generic hpsa pata_acpi radeon i2c_algo_bit drm_kms_helper ttm drm ata_pii=
x libata i2c_core bnx2 bnx2x cciss 3w_9xxx libcrc32c dm_mirror dm_region_ha=
sh dm_log dm_mod iscsi_tcp be2iscsi bnx2i cnic uio cxgb4i cxgb4 cxgb3i cxgb=
3 mdio libcxgbi libiscsi_tcp qla4xxx libiscsi scsi_transport_iscsi iscsi_ib=
ft iscsi_boot_sysfs [last unloaded: ipt_REJECT]=20
[ 9788.956687] CPU 0 =20
[ 9788.956687] Pid: 25412, comm: epoll-ltp Tainted: G        W I  3.8.4+ #1=
 HP ProLiant DL380 G5=20
[ 9788.956687] RIP: 0010:[<ffffffff811876a8>]  [<ffffffff811876a8>] kmem_ca=
che_alloc+0x68/0x1e0=20
[ 9788.956687] RSP: 0018:ffff8800bbee9dd0  EFLAGS: 00010246=20
[ 9788.956687] RAX: 0000000000000000 RBX: ffff8801a356e5c0 RCX: 00000000000=
00000=20
[ 9788.956687] RDX: 0000000000036b0a RSI: 00000000000080d0 RDI: ffff8801a90=
6ad00=20
[ 9788.956687] RBP: ffff8800bbee9e10 R08: 00000000000176b0 R09: ffffffff810=
fe2e2=20
[ 9788.956687] R10: 0000000000000016 R11: ffffffffffffffdc R12: 00000000fff=
ffff7=20
[ 9788.956687] R13: 00000000000080d0 R14: ffff8801a906ad00 R15: ffff8801a90=
6ad00=20
[ 9788.956687] FS:  00007fbf42058740(0000) GS:ffff8801afc00000(0000) knlGS:=
0000000000000000=20
[ 9788.956687] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b=20
[ 9788.956687] CR2: 00000000fffffff7 CR3: 00000000aece6000 CR4: 00000000000=
407f0=20
[ 9788.956687] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000=20
[ 9788.956687] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000=
00400=20
[ 9788.956687] Process epoll-ltp (pid: 25412, threadinfo ffff8800bbee8000, =
task ffff8801a6524c50)=20
[ 9788.956687] Stack:=20
[ 9788.956687]  ffffffff810fe2e2 ffffffff8108cf0f 0000000001200011 ffff8801=
a356e5c0=20
[ 9788.956687]  0000000000000000 00007fbf42058a10 0000000000000000 ffff8801=
a356e5c0=20
[ 9788.956687]  ffff8800bbee9e30 ffffffff810fe2e2 0000000000000000 00000000=
01200011=20
[ 9788.956687] Call Trace:=20
[ 9788.956687]  [<ffffffff810fe2e2>] ? __delayacct_tsk_init+0x22/0x40=20
[ 9788.956687]  [<ffffffff8108cf0f>] ? prepare_creds+0xdf/0x190=20
[ 9788.956687]  [<ffffffff810fe2e2>] __delayacct_tsk_init+0x22/0x40=20
[ 9788.956687]  [<ffffffff8106027f>] copy_process.part.25+0x31f/0x13f0=20
[ 9788.956687]  [<ffffffff8106765b>] ? do_wait+0x12b/0x250=20
[ 9788.956687]  [<ffffffff81097f3e>] ? wake_up_new_task+0xfe/0x160=20
[ 9788.956687]  [<ffffffff81061449>] do_fork+0xa9/0x350=20
[ 9788.956687]  [<ffffffff81068810>] ? sys_wait4+0x80/0xf0=20
[ 9788.956687]  [<ffffffff81061776>] sys_clone+0x16/0x20=20
[ 9788.956687]  [<ffffffff8161a7f9>] stub_clone+0x69/0x90=20
[ 9788.956687]  [<ffffffff8161a499>] ? system_call_fastpath+0x16/0x1b=20
[ 9788.956687] Code: 90 4d 89 fe 4d 8b 06 65 4c 03 04 25 c8 db 00 00 49 8b =
50 08 4d 8b 20 4d 85 e4 0f 84 2b 01 00 00 49 63 46 20 4d 8b 06 41 f6 c0 0f =
<49> 8b 1c 04 0f 85 55 01 00 00 48 8d 4a 01 4c 89 e0 65 49 0f c7 =20
[ 9788.956687] RIP  [<ffffffff811876a8>] kmem_cache_alloc+0x68/0x1e0=20
[ 9788.956687]  RSP <ffff8800bbee9dd0>=20
[ 9788.956687] CR2: 00000000fffffff7=20
[ 9789.029177] ---[ end trace 001669df502cd1ce ]---

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
