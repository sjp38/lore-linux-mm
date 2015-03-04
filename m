Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id BA8326B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 23:10:33 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so30390540pdb.3
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 20:10:33 -0800 (PST)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id gs2si3425349pac.121.2015.03.03.20.10.31
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 20:10:32 -0800 (PST)
Message-ID: <54F681A7.4050203@cn.fujitsu.com>
Date: Wed, 4 Mar 2015 11:53:11 +0800
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: node-hotplug: is memset 0 safe in try_offline_node()?
References: <54F52ACF.4030103@huawei.com> <54F58AE3.50101@cn.fujitsu.com> <54F66C52.4070600@huawei.com>
In-Reply-To: <54F66C52.4070600@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Toshi Kani <toshi.kani@hp.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

Hi Xishi,

On 03/04/2015 10:22 AM, Xishi Qiu wrote:

> On 2015/3/3 18:20, Gu Zheng wrote:
>=20
>> Hi Xishi,
>> On 03/03/2015 11:30 AM, Xishi Qiu wrote:
>>
>>> When hot-remove a numa node, we will clear pgdat,
>>> but is memset 0 safe in try_offline_node()?
>>
>> It is not safe here. In fact, this is a temporary solution here.
>> As you know, pgdat is accessed lock-less now, so protection
>> mechanism (RCU=EF=BC=9F) is needed to make it completely safe here,
>> but it seems a bit over-kill.
>>
>>>
>>> process A:			offline node XX:
>>> for_each_populated_zone()
>>> find online node XX
>>> cond_resched()
>>> 				offline cpu and memory, then try_offline_node()
>>> 				node_set_offline(nid), and memset(pgdat, 0, sizeof(*pgdat))
>>> access node XX's pgdat
>>> NULL pointer access error
>>
>> It's possible, but I did not meet this condition, did you?
>>
>=20
> Yes, we test hot-add/hot-remove node with stress, and meet the following
> call trace several times.

Thanks.

>=20
> 	next_online_pgdat()
> 		int nid =3D next_online_node(pgdat->node_id);  // it's here, pgdat is N=
ULL

	memset(pgdat, 0, sizeof(*pgdat));
This memset just sets the context of pgdat to 0, but it will not free pgdat=
, so the *pgdat is
NULL* is strange here.
But anyway, the bug is real, we must fix it.

Regards,
Gu

>=20
> I add some printk, it shows the above pgdat is just the offline node's pg=
dat.
> The reason may be that for_each_zone() and for_each_populated_zone() are =
lock-less.
> And stop machine could not resolve it, because cond_resched() maybe in cy=
clical code.
>=20
> [ 1422.011064] BUG: unable to handle kernel paging request at 00000000000=
25f60
> [ 1422.011086] IP: [<ffffffff81126b91>] next_online_pgdat+0x1/0x50
> [ 1422.011178] PGD 0=20
> [ 1422.011180] Oops: 0000 [#1] SMP=20
> [ 1422.011409] ACPI: Device does not support D3cold
> [ 1422.011961] Modules linked in: fuse nls_iso8859_1 nls_cp437 vfat fat l=
oop dm_mod coretemp mperf crc32c_intel ghash_clmulni_intel aesni_intel ablk=
_helper cryptd lrw gf128mul glue_helper aes_x86_64 pcspkr microcode igb dca=
 i2c_algo_bit ipv6 megaraid_sas iTCO_wdt i2c_i801 i2c_core iTCO_vendor_supp=
ort tg3 sg hwmon ptp lpc_ich pps_core mfd_core acpi_pad rtc_cmos button ext=
3 jbd mbcache sd_mod crc_t10dif scsi_dh_alua scsi_dh_rdac scsi_dh_hp_sw scs=
i_dh_emc scsi_dh ahci libahci libata scsi_mod [last unloaded: rasf]
> [ 1422.012006] CPU: 23 PID: 238 Comm: kworker/23:1 Tainted: G           O=
 3.10.15-5885-euler0302 #1
> [ 1422.012024] Hardware name: HUAWEI TECHNOLOGIES CO.,LTD. Huawei N1/Huaw=
ei N1, BIOS V100R001 03/02/2015
> [ 1422.012065] Workqueue: events vmstat_update
> [ 1422.012084] task: ffffa800d32c0000 ti: ffffa800d32ae000 task.ti: ffffa=
800d32ae000
> [ 1422.012165] RIP: 0010:[<ffffffff81126b91>]  [<ffffffff81126b91>] next_=
online_pgdat+0x1/0x50
> [ 1422.012205] RSP: 0018:ffffa800d32afce8  EFLAGS: 00010286
> [ 1422.012225] RAX: 0000000000001440 RBX: ffffffff81da53b8 RCX: 000000000=
0000082
> [ 1422.012226] RDX: 0000000000000000 RSI: 0000000000000082 RDI: 000000000=
0000000
> [ 1422.012254] RBP: ffffa800d32afd28 R08: ffffffff81c93bfc R09: ffffffff8=
1cbdc96
> [ 1422.012272] R10: 00000000000040ec R11: 00000000000000a0 R12: ffffa800f=
ffb3440
> [ 1422.012290] R13: ffffa800d32afd38 R14: 0000000000000017 R15: ffffa800e=
6616800
> [ 1422.012292] FS:  0000000000000000(0000) GS:ffffa800e6600000(0000) knlG=
S:0000000000000000
> [ 1422.012314] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 1422.012328] CR2: 0000000000025f60 CR3: 0000000001a0b000 CR4: 000000000=
01407e0
> [ 1422.012328] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000000=
0000000
> [ 1422.012328] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 000000000=
0000400
> [ 1422.012328] Stack:
> [ 1422.012328]  ffffa800d32afd28 ffffffff81126ca5 ffffa800ffffffff ffffff=
ff814b4314
> [ 1422.012328]  ffffa800d32ae010 0000000000000000 ffffa800e6616180 ffffa8=
00fffb3440
> [ 1422.012328]  ffffa800d32afde8 ffffffff81128220 ffffffff00000013 000000=
0000000038
> [ 1422.012328] Call Trace:
> [ 1422.012328]  [<ffffffff81126ca5>] ? next_zone+0xc5/0x150
> [ 1422.012328]  [<ffffffff814b4314>] ? __schedule+0x544/0x780
> [ 1422.012328]  [<ffffffff81128220>] refresh_cpu_vm_stats+0xd0/0x140
> [ 1422.012328]  [<ffffffff811282a1>] vmstat_update+0x11/0x50
> [ 1422.012328]  [<ffffffff81064c24>] process_one_work+0x194/0x3d0
> [ 1422.012328]  [<ffffffff810660bb>] worker_thread+0x12b/0x410
> [ 1422.012328]  [<ffffffff81065f90>] ? manage_workers+0x1a0/0x1a0
> [ 1422.012328]  [<ffffffff8106ba66>] kthread+0xc6/0xd0
> [ 1422.012328]  [<ffffffff8106b9a0>] ? kthread_freezable_should_stop+0x70=
/0x70
> [ 1422.012328]  [<ffffffff814be0ac>] ret_from_fork+0x7c/0xb0
> [ 1422.012328]  [<ffffffff8106b9a0>] ? kthread_freezable_should_stop+0x70=
/0x70
>=20
> Thanks,
> Xishi Qiu
>=20
>> Regards,
>> Gu
>>
>>>
>>> Thanks,
>>> Xishi Qiu
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>>>
>>
>>
>>
>> .
>>
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> .
>=20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
