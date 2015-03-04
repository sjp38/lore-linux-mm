Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4B50F6B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 03:32:21 -0500 (EST)
Received: by obcuz6 with SMTP id uz6so5365329obc.9
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 00:32:21 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id e7si1748441obf.19.2015.03.04.00.32.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Mar 2015 00:32:20 -0800 (PST)
Message-ID: <54F6C2E6.4030500@huawei.com>
Date: Wed, 4 Mar 2015 16:31:34 +0800
From: Xie XiuQi <xiexiuqi@huawei.com>
MIME-Version: 1.0
Subject: Re: node-hotplug: is memset 0 safe in try_offline_node()?
References: <54F52ACF.4030103@huawei.com> <54F58AE3.50101@cn.fujitsu.com> <54F66C52.4070600@huawei.com> <54F681A7.4050203@cn.fujitsu.com>
In-Reply-To: <54F681A7.4050203@cn.fujitsu.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gu Zheng <guz.fnst@cn.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Toshi Kani <toshi.kani@hp.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Hanjun Guo <guohanjun@huawei.com>

On 2015/3/4 11:53, Gu Zheng wrote:
> Hi Xishi,
> 
> On 03/04/2015 10:22 AM, Xishi Qiu wrote:
> 
>> On 2015/3/3 18:20, Gu Zheng wrote:
>>
>>> Hi Xishi,
>>> On 03/03/2015 11:30 AM, Xishi Qiu wrote:
>>>
>>>> When hot-remove a numa node, we will clear pgdat,
>>>> but is memset 0 safe in try_offline_node()?
>>>
>>> It is not safe here. In fact, this is a temporary solution here.
>>> As you know, pgdat is accessed lock-less now, so protection
>>> mechanism (RCUi 1/4 ?) is needed to make it completely safe here,
>>> but it seems a bit over-kill.
>>>
>>>>
>>>> process A:			offline node XX:
>>>> for_each_populated_zone()
>>>> find online node XX
>>>> cond_resched()
>>>> 				offline cpu and memory, then try_offline_node()
>>>> 				node_set_offline(nid), and memset(pgdat, 0, sizeof(*pgdat))
>>>> access node XX's pgdat
>>>> NULL pointer access error
>>>
>>> It's possible, but I did not meet this condition, did you?
>>>
>>
>> Yes, we test hot-add/hot-remove node with stress, and meet the following
>> call trace several times.
> 
> Thanks.
> 
>>
>> 	next_online_pgdat()
>> 		int nid = next_online_node(pgdat->node_id);  // it's here, pgdat is NULL
> 
> 	memset(pgdat, 0, sizeof(*pgdat));
> This memset just sets the context of pgdat to 0, but it will not free pgdat, so the *pgdat is
> NULL* is strange here.

Hi Gu,

This pgdat isn't 0, but pgdat->zone[i]->zone_pgdat is 0.
So pgdat is 0 in next_zone().

--
/*
 * next_zone - helper magic for for_each_zone()
 */
struct zone *next_zone(struct zone *zone)
{
        pg_data_t *pgdat = zone->zone_pgdat;

        if (zone < pgdat->node_zones + MAX_NR_ZONES - 1)
                zone++;
        else {
                pgdat = next_online_pgdat(pgdat);
                if (pgdat)
                        zone = pgdat->node_zones;
                else
                        zone = NULL;
        }
        return zone;
}

> But anyway, the bug is real, we must fix it.
> 
> Regards,
> Gu
> 
>>
>> I add some printk, it shows the above pgdat is just the offline node's pgdat.
>> The reason may be that for_each_zone() and for_each_populated_zone() are lock-less.
>> And stop machine could not resolve it, because cond_resched() maybe in cyclical code.
>>
>> [ 1422.011064] BUG: unable to handle kernel paging request at 0000000000025f60
>> [ 1422.011086] IP: [<ffffffff81126b91>] next_online_pgdat+0x1/0x50
>> [ 1422.011178] PGD 0 
>> [ 1422.011180] Oops: 0000 [#1] SMP 
>> [ 1422.011409] ACPI: Device does not support D3cold
>> [ 1422.011961] Modules linked in: fuse nls_iso8859_1 nls_cp437 vfat fat loop dm_mod coretemp mperf crc32c_intel ghash_clmulni_intel aesni_intel ablk_helper cryptd lrw gf128mul glue_helper aes_x86_64 pcspkr microcode igb dca i2c_algo_bit ipv6 megaraid_sas iTCO_wdt i2c_i801 i2c_core iTCO_vendor_support tg3 sg hwmon ptp lpc_ich pps_core mfd_core acpi_pad rtc_cmos button ext3 jbd mbcache sd_mod crc_t10dif scsi_dh_alua scsi_dh_rdac scsi_dh_hp_sw scsi_dh_emc scsi_dh ahci libahci libata scsi_mod [last unloaded: rasf]
>> [ 1422.012006] CPU: 23 PID: 238 Comm: kworker/23:1 Tainted: G           O 3.10.15-5885-euler0302 #1
>> [ 1422.012024] Hardware name: HUAWEI TECHNOLOGIES CO.,LTD. Huawei N1/Huawei N1, BIOS V100R001 03/02/2015
>> [ 1422.012065] Workqueue: events vmstat_update
>> [ 1422.012084] task: ffffa800d32c0000 ti: ffffa800d32ae000 task.ti: ffffa800d32ae000
>> [ 1422.012165] RIP: 0010:[<ffffffff81126b91>]  [<ffffffff81126b91>] next_online_pgdat+0x1/0x50
>> [ 1422.012205] RSP: 0018:ffffa800d32afce8  EFLAGS: 00010286
>> [ 1422.012225] RAX: 0000000000001440 RBX: ffffffff81da53b8 RCX: 0000000000000082
>> [ 1422.012226] RDX: 0000000000000000 RSI: 0000000000000082 RDI: 0000000000000000
>> [ 1422.012254] RBP: ffffa800d32afd28 R08: ffffffff81c93bfc R09: ffffffff81cbdc96
>> [ 1422.012272] R10: 00000000000040ec R11: 00000000000000a0 R12: ffffa800fffb3440
>> [ 1422.012290] R13: ffffa800d32afd38 R14: 0000000000000017 R15: ffffa800e6616800
>> [ 1422.012292] FS:  0000000000000000(0000) GS:ffffa800e6600000(0000) knlGS:0000000000000000
>> [ 1422.012314] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [ 1422.012328] CR2: 0000000000025f60 CR3: 0000000001a0b000 CR4: 00000000001407e0
>> [ 1422.012328] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> [ 1422.012328] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
>> [ 1422.012328] Stack:
>> [ 1422.012328]  ffffa800d32afd28 ffffffff81126ca5 ffffa800ffffffff ffffffff814b4314
>> [ 1422.012328]  ffffa800d32ae010 0000000000000000 ffffa800e6616180 ffffa800fffb3440
>> [ 1422.012328]  ffffa800d32afde8 ffffffff81128220 ffffffff00000013 0000000000000038
>> [ 1422.012328] Call Trace:
>> [ 1422.012328]  [<ffffffff81126ca5>] ? next_zone+0xc5/0x150
>> [ 1422.012328]  [<ffffffff814b4314>] ? __schedule+0x544/0x780
>> [ 1422.012328]  [<ffffffff81128220>] refresh_cpu_vm_stats+0xd0/0x140
>> [ 1422.012328]  [<ffffffff811282a1>] vmstat_update+0x11/0x50
>> [ 1422.012328]  [<ffffffff81064c24>] process_one_work+0x194/0x3d0
>> [ 1422.012328]  [<ffffffff810660bb>] worker_thread+0x12b/0x410
>> [ 1422.012328]  [<ffffffff81065f90>] ? manage_workers+0x1a0/0x1a0
>> [ 1422.012328]  [<ffffffff8106ba66>] kthread+0xc6/0xd0
>> [ 1422.012328]  [<ffffffff8106b9a0>] ? kthread_freezable_should_stop+0x70/0x70
>> [ 1422.012328]  [<ffffffff814be0ac>] ret_from_fork+0x7c/0xb0
>> [ 1422.012328]  [<ffffffff8106b9a0>] ? kthread_freezable_should_stop+0x70/0x70
>>
>> Thanks,
>> Xishi Qiu
>>
>>> Regards,
>>> Gu
>>>
>>>>
>>>> Thanks,
>>>> Xishi Qiu
>>>>
>>>> --
>>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>>> see: http://www.linux-mm.org/ .
>>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>>
>>>
>>>
>>>
>>> .
>>>
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>> .
>>
> 
> 
> 
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
