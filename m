Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id D722582905
	for <linux-mm@kvack.org>; Thu, 12 Mar 2015 03:45:08 -0400 (EDT)
Received: by oigh136 with SMTP id h136so319985oig.2
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 00:45:08 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id ht4si3404908obb.23.2015.03.12.00.44.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Mar 2015 00:45:07 -0700 (PDT)
Message-ID: <5501431B.9050101@huawei.com>
Date: Thu, 12 Mar 2015 15:41:15 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/memory hotplog: postpone the reset of obsolete pgdat
References: <1426131384-5066-1-git-send-email-guz.fnst@cn.fujitsu.com> <alpine.DEB.2.10.1503112153580.8492@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1503112153580.8492@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Gu Zheng <guz.fnst@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, akpm@linux-foundation.org, tangchen@cn.fujitsu.com, xiexiuqi@huawei.com

On 2015/3/12 13:10, David Rientjes wrote:

> On Thu, 12 Mar 2015, Gu Zheng wrote:
> 
>> Qiu Xishi reported the following BUG when testing hot-add/hot-remove node under
>> stress condition.
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
> 
> So refresh_cpu_vm_stats() is doing for_each_populated_zone(), which calls 
> next_zone(), and we've iterated over all zones for a particular node.  We 
> call next_online_pgdat() with the pgdat of the previous zone's 
> zone->zone_pgdat, and that explodes on dereference, right?
> 
> I have to ask because 3.10 is an ancient kernel, a more recent example for 
> the changelog would be helpful if it's reproducible.
> 
>> [ 1422.012328]  [<ffffffff811282a1>] vmstat_update+0x11/0x50
>> [ 1422.012328]  [<ffffffff81064c24>] process_one_work+0x194/0x3d0
>> [ 1422.012328]  [<ffffffff810660bb>] worker_thread+0x12b/0x410
>> [ 1422.012328]  [<ffffffff81065f90>] ? manage_workers+0x1a0/0x1a0
>> [ 1422.012328]  [<ffffffff8106ba66>] kthread+0xc6/0xd0
>> [ 1422.012328]  [<ffffffff8106b9a0>] ? kthread_freezable_should_stop+0x70/0x70
>> [ 1422.012328]  [<ffffffff814be0ac>] ret_from_fork+0x7c/0xb0
>> [ 1422.012328]  [<ffffffff8106b9a0>] ? kthread_freezable_should_stop+0x70/0x70
>>
>> The cause is the "memset(pgdat, 0, sizeof(*pgdat))" at the end of try_offline_node,
>> which will reset the all content of pgdat to 0, as the pgdat is accessed lock-lee,
>> so that the users still using the pgdat will panic, such as the vmstat_update routine.
>>
> 
> Correct me if I'm wrong, but it's not accessing pgdat at all, it's 
> accessing zone->zone_pgdat->node_id and zone->zone_pgdat is invalid.  I 
> don't _think_ there's anything different with 3.10, but I'd be happy to be 
> shown wrong.
> 
>> So the solution here is postponing the reset of obsolete pgdat from try_offline_node()
>> to hotadd_new_pgdat(), and just resetting pgdat->nr_zones and pgdat->classzone_idx to
>> be 0 rather than the memset 0 to avoid breaking pointer information in pgdat.
>>
> 
> I don't see how memset(pgdat, 0, sizeof(*pgdat)) can cause the error 
> above, can you be more specific?  
> 

Hi David,

process A:				offline node XX:

vmstat_updat()
   refresh_cpu_vm_stats()
     for_each_populated_zone()
       find online node XX
     cond_resched()
					offline cpu and memory, then try_offline_node()
					node_set_offline(nid), and memset(pgdat, 0, sizeof(*pgdat))
       zone = next_zone(zone)
         pg_data_t *pgdat = zone->zone_pgdat;  // here pgdat is NULL now
           next_online_pgdat(pgdat)
             next_online_node(pgdat->node_id);  // NULL pointer access

>> Reported-by: Xishi Qiu <qiuxishi@huawei.com>
>> Suggested-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Cc: <stable@vger.kernel.org>
>> Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
>> ---
>>  mm/memory_hotplug.c |   13 ++++---------
>>  1 files changed, 4 insertions(+), 9 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 9fab107..65842d6 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1092,6 +1092,10 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>>  			return NULL;
>>  
>>  		arch_refresh_nodedata(nid, pgdat);
>> +	} else {
>> +		/* Reset the nr_zones and classzone_idx to 0 before reuse */
>> +		pgdat->nr_zones = 0;
>> +		pgdat->classzone_idx = 0;
>>  	}
>>  
>>  	/* we can use NODE_DATA(nid) from here */
> 
> This is a mysterious combination of fields to reset and will surely become 
> outdated when the struct is changed.
> 

It's just to avoid the warning in free_area_init_node()
WARN_ON(pgdat->nr_zones || pgdat->classzone_idx);

It will be called when hotadd a new node.

Thanks,
Xishi Qiu

>> @@ -1977,15 +1981,6 @@ void try_offline_node(int nid)
>>  		if (is_vmalloc_addr(zone->wait_table))
>>  			vfree(zone->wait_table);
>>  	}
>> -
>> -	/*
>> -	 * Since there is no way to guarentee the address of pgdat/zone is not
>> -	 * on stack of any kernel threads or used by other kernel objects
>> -	 * without reference counting or other symchronizing method, do not
>> -	 * reset node_data and free pgdat here. Just reset it to 0 and reuse
>> -	 * the memory when the node is online again.
>> -	 */
>> -	memset(pgdat, 0, sizeof(*pgdat));
>>  }
>>  EXPORT_SYMBOL(try_offline_node);
>>  
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
