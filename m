Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 0F4C06B0078
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 21:01:26 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3B56D3EE0C1
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 10:01:23 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 11A4845DE6A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 10:01:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D33CF45DE63
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 10:01:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C0A9F1DB8050
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 10:01:22 +0900 (JST)
Received: from g01jpexchyt11.g01.fujitsu.local (g01jpexchyt11.g01.fujitsu.local [10.128.194.50])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 553B3E0800E
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 10:01:22 +0900 (JST)
Message-ID: <506E313B.5010303@jp.fujitsu.com>
Date: Fri, 5 Oct 2012 10:00:43 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] memory-hotplug: add node_device_release
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com> <1348724705-23779-3-git-send-email-wency@cn.fujitsu.com> <CAHGf_=rLMsmAxR5hrDVXjkHAxmupVrmtqE3iq2qu=O9Prp4nSg@mail.gmail.com> <5064EA5A.3080905@jp.fujitsu.com> <CAHGf_=qbBGjTL9oBHz7AM8BAosbzvn_WAGdAzJ8np-nDPN_KFQ@mail.gmail.com> <5064FDCA.1020504@jp.fujitsu.com> <CAHGf_=r+oz0GS137e81EySbN-3KVmQisF8sySiCUYUas1RZLtQ@mail.gmail.com> <5065740A.2000502@jp.fujitsu.com> <CAHGf_=o_FLsEULK3s1+zD-A0FL5QvKnX542Lz4vCwVVV2fYNRw@mail.gmail.com> <50693E30.3010006@jp.fujitsu.com> <CAHGf_=qZVe_KfThZa5yEm+4w3MMREs1xqya5HmKWsWjyTcjkzA@mail.gmail.com>
In-Reply-To: <CAHGf_=qZVe_KfThZa5yEm+4w3MMREs1xqya5HmKWsWjyTcjkzA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: wency@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org

Hi Kosaki-san,

2012/10/02 3:12, KOSAKI Motohiro wrote:
> On Mon, Oct 1, 2012 at 2:54 AM, Yasuaki Ishimatsu
> <isimatu.yasuaki@jp.fujitsu.com> wrote:
>> Hi Kosaki-san,
>>
>>
>> 2012/09/29 7:19, KOSAKI Motohiro wrote:
>>>>>>
>>>>>> I don't understand it. How can we get rid of the warning?
>>>>>
>>>>>
>>>>> See cpu_device_release() for example.
>>>>
>>>>
>>>> If we implement a function like cpu_device_release(), the warning
>>>> disappears. But the comment says in the function "Never copy this
>>>> way...".
>>>> So I think it is illegal way.
>>>
>>>
>>> What does "illegal" mean?
>>
>>
>> The "illegal" means the code should not be mimicked.
>>
>>
>>> You still haven't explain any benefit of your code. If there is zero
>>> benefit, just kill it.
>>> I believe everybody think so.
>>>
>>> Again, Which benefit do you have?
>>
>>
>> The patch has a benefit to delets a warning message.
>>
>>
>>>
>>>>>>> Why do we need this node_device_release() implementation?
>>>>>>
>>>>>>
>>>>>> I think that this is a manner of releasing object related kobject.
>>>>>
>>>>>
>>>>> No.  Usually we never call memset() from release callback.
>>>>
>>>>
>>>> What we want to release is a part of array, not a pointer.
>>>> Therefore, there is only this way instead of kfree().
>>>
>>>
>>> Why? Before your patch, we don't have memset() and did work it.
>>
>>
>> If we does not apply the patch, a warning message is shown.
>> So I think it did not work well.
>>
>>
>>> I can't understand what mean "only way".
>>
>>
>> For deleting a warning message, I created a node_device_release().
>> In the manner of releasing kobject, the function frees a object related
>> to the kobject. So most functions calls kfree() for releasing it.
>> In node_device_release(), we need to free a node struct. If the node
>> struct is pointer, I can free it by kfree. But the node struct is a part
>> of node_devices[] array. I cannot free it. So I filled the node struct
>> with 0.
>>
>> But you think it is not good. Do you have a good solution?
>
> Do nothing. just add empty release function and kill a warning.
> Obviously do nothing can't make any performance drop nor any
> side effect.
>
> meaningless memset() is just silly from point of cache pollution view.

I have the reason to have to fill the node struct with 0 by memset.
The node is a part of node struct array (node_devices[]).
If we add empty release function for suppressing warning,
some data remains in the node struct after hot removing memory.
So if we re-hot adds the memory, the node struct is reused by
register_onde_node(). But the node struct has some data, because
it was not initialized with 0. As a result, more waning is shown
by the remained data at hot addinig memory as follows:

[  374.037710] kobject (ffffffff82c15718): tried to init an initialized object, something is seriously wrong.
[  374.153169] Pid: 4, comm: kworker/0:0 Tainted: G        W    3.6.0 #5
[  374.230279] Call Trace:
[  374.259647]  [<ffffffff8133cf39>] kobject_init+0x89/0xa0
[  374.323286]  [<ffffffff8143632c>] device_initialize+0x2c/0xc0
[  374.392086]  [<ffffffff814376a6>] device_register+0x16/0x30
[  374.458856]  [<ffffffff81449b15>] register_node+0x25/0xe0
[  374.523434]  [<ffffffff8144a057>] register_one_node+0x67/0x140
[  374.593306]  [<ffffffff81652e40>] add_memory+0x100/0x1f0
[  374.656961]  [<ffffffffa00a31c6>] acpi_memory_enable_device+0x92/0xdf [acpi_memhotplug]
[  374.752811]  [<ffffffffa00a3753>] acpi_memory_device_add+0x10d/0x116 [acpi_memhotplug]
[  374.847622]  [<ffffffff813a4376>] acpi_device_probe+0x50/0x18a
[  374.917504]  [<ffffffff8124b053>] ? sysfs_create_link+0x13/0x20
[  374.988426]  [<ffffffff81439d7c>] really_probe+0x6c/0x320
[  375.053061]  [<ffffffff8143a077>] driver_probe_device+0x47/0xa0
[  375.123922]  [<ffffffff8143a180>] ? __driver_attach+0xb0/0xb0
[  375.192709]  [<ffffffff8143a180>] ? __driver_attach+0xb0/0xb0
[  375.261494]  [<ffffffff8143a1d3>] __device_attach+0x53/0x60
[  375.328206]  [<ffffffff81437dac>] bus_for_each_drv+0x6c/0xa0
[  375.395950]  [<ffffffff81439cf8>] device_attach+0xa8/0xc0
[  375.460578]  [<ffffffff814389d0>] bus_probe_device+0xb0/0xe0
[  375.528318]  [<ffffffff81437421>] device_add+0x301/0x570
[  375.591883]  [<ffffffff814376ae>] device_register+0x1e/0x30
[  375.658568]  [<ffffffff813a56bf>] acpi_device_register+0x1af/0x2bf
[  375.732590]  [<ffffffff813a59ae>] acpi_add_single_object+0x1df/0x2b9
[  375.808640]  [<ffffffff813ce320>] ? acpi_ut_release_mutex+0xac/0xb5
[  375.883646]  [<ffffffff813a5b93>] acpi_bus_check_add+0x10b/0x166
[  375.955529]  [<ffffffff810db4ad>] ? trace_hardirqs_on+0xd/0x10
[  376.025327]  [<ffffffff8109fa4f>] ? up+0x2f/0x50
[  376.080639]  [<ffffffff813a0cc1>] ? acpi_os_signal_semaphore+0x6b/0x74
[  376.158792]  [<ffffffff813c3f1d>] acpi_ns_walk_namespace+0xbe/0x17d
[  376.233854]  [<ffffffff813a5a88>] ? acpi_add_single_object+0x2b9/0x2b9
[  376.312012]  [<ffffffff813a5a88>] ? acpi_add_single_object+0x2b9/0x2b9
[  376.390162]  [<ffffffff813c43b3>] acpi_walk_namespace+0x8a/0xc4
[  376.461051]  [<ffffffff813a5c49>] acpi_bus_scan+0x5b/0x7c
[  376.525707]  [<ffffffff813a5cd6>] acpi_bus_add+0x2a/0x2c
[  376.589344]  [<ffffffff813d5dc6>] container_notify_cb+0x103/0x18d
[  376.662309]  [<ffffffff813b3946>] acpi_ev_notify_dispatch+0x41/0x5f
[  376.737386]  [<ffffffff813a0f47>] acpi_os_execute_deferred+0x27/0x34
[  376.813507]  [<ffffffff81090279>] process_one_work+0x219/0x680
[  376.883357]  [<ffffffff81090218>] ? process_one_work+0x1b8/0x680
[  376.955312]  [<ffffffff813a0f20>] ? acpi_os_wait_events_complete+0x23/0x23
[  377.037615]  [<ffffffff8109212e>] worker_thread+0x12e/0x320
[  377.104365]  [<ffffffff81092000>] ? manage_workers+0x190/0x190
[  377.174274]  [<ffffffff81098106>] kthread+0xc6/0xd0
[  377.232697]  [<ffffffff81678b04>] kernel_thread_helper+0x4/0x10
[  377.303588]  [<ffffffff8166e570>] ? retint_restore_args+0x13/0x13
[  377.376550]  [<ffffffff81098040>] ? __init_kthread_worker+0x70/0x70
[  377.451591]  [<ffffffff81678b00>] ? gs_change+0x13/0x13
[  377.514247] ------------[ cut here ]------------
[  377.569481] WARNING: at lib/kobject.c:166 kobject_add_internal+0x1b3/0x260()
[  377.653796] Hardware name: PRIMEQUEST 1800E
[  377.703865] kobject: (ffffffff82c15718): attempted to be registered with empty name!
[  377.796584] Modules linked in: bridge stp llc sunrpc ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 iptable_filter ip_tables ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables binfmt_misc vfat fat dm_mirror dm_region_hash dm_log dm_mod uinput iTCO_wdt iTCO_vendor_support coretemp kvm_intel kvm crc32c_intel microcode pcspkr lpc_ich mfd_core i2c_i801 i2c_core ioatdma i7core_edac edac_core sg acpi_memhotplug e1000e igb dca sd_mod crc_t10dif lpfc scsi_transport_fc scsi_tgt mptsas mptscsih mptbase scsi_transport_sas scsi_mod
[  378.400511] Pid: 4, comm: kworker/0:0 Tainted: G        W    3.6.0 #5
[  378.477614] Call Trace:
[  378.506916]  [<ffffffff8106c10f>] warn_slowpath_common+0x7f/0xc0
[  378.578843]  [<ffffffff8106c206>] warn_slowpath_fmt+0x46/0x50
[  378.647658]  [<ffffffff810db09d>] ? mark_held_locks+0x8d/0x140
[  378.717504]  [<ffffffff8133cda3>] kobject_add_internal+0x1b3/0x260
[  378.791507]  [<ffffffff8133cff8>] kobject_add_varg+0x38/0x60
[  378.859187]  [<ffffffff8133d0d4>] kobject_add+0x44/0x70
[  378.921769]  [<ffffffff81098d76>] ? __init_waitqueue_head+0x46/0x60
[  378.996747]  [<ffffffff814371f4>] device_add+0xd4/0x570
[  379.059342]  [<ffffffff814376ae>] device_register+0x1e/0x30
[  379.126042]  [<ffffffff81449b15>] register_node+0x25/0xe0
[  379.190652]  [<ffffffff8144a057>] register_one_node+0x67/0x140
[  379.260532]  [<ffffffff81652e40>] add_memory+0x100/0x1f0
[  379.324175]  [<ffffffffa00a31c6>] acpi_memory_enable_device+0x92/0xdf [acpi_memhotplug]
[  379.419903]  [<ffffffffa00a3753>] acpi_memory_device_add+0x10d/0x116 [acpi_memhotplug]
[  379.514628]  [<ffffffff813a4376>] acpi_device_probe+0x50/0x18a
[  379.584489]  [<ffffffff8124b053>] ? sysfs_create_link+0x13/0x20
[  379.655351]  [<ffffffff81439d7c>] really_probe+0x6c/0x320
[  379.720047]  [<ffffffff8143a077>] driver_probe_device+0x47/0xa0
[  379.790863]  [<ffffffff8143a180>] ? __driver_attach+0xb0/0xb0
[  379.859667]  [<ffffffff8143a180>] ? __driver_attach+0xb0/0xb0
[  379.928526]  [<ffffffff8143a1d3>] __device_attach+0x53/0x60
[  379.995218]  [<ffffffff81437dac>] bus_for_each_drv+0x6c/0xa0
[  380.063010]  [<ffffffff81439cf8>] device_attach+0xa8/0xc0
[  380.127664]  [<ffffffff814389d0>] bus_probe_device+0xb0/0xe0
[  380.195449]  [<ffffffff81437421>] device_add+0x301/0x570
[  380.259081]  [<ffffffff814376ae>] device_register+0x1e/0x30
[  380.325840]  [<ffffffff813a56bf>] acpi_device_register+0x1af/0x2bf
[  380.399852]  [<ffffffff813a59ae>] acpi_add_single_object+0x1df/0x2b9
[  380.475874]  [<ffffffff813ce320>] ? acpi_ut_release_mutex+0xac/0xb5
[  380.550884]  [<ffffffff813a5b93>] acpi_bus_check_add+0x10b/0x166
[  380.622761]  [<ffffffff810db4ad>] ? trace_hardirqs_on+0xd/0x10
[  380.692529]  [<ffffffff8109fa4f>] ? up+0x2f/0x50
[  380.747792]  [<ffffffff813a0cc1>] ? acpi_os_signal_semaphore+0x6b/0x74
[  380.825974]  [<ffffffff813c3f1d>] acpi_ns_walk_namespace+0xbe/0x17d
[  380.901027]  [<ffffffff813a5a88>] ? acpi_add_single_object+0x2b9/0x2b9
[  380.979208]  [<ffffffff813a5a88>] ? acpi_add_single_object+0x2b9/0x2b9
[  381.057328]  [<ffffffff813c43b3>] acpi_walk_namespace+0x8a/0xc4
[  381.128253]  [<ffffffff813a5c49>] acpi_bus_scan+0x5b/0x7c
[  381.192922]  [<ffffffff813a5cd6>] acpi_bus_add+0x2a/0x2c
[  381.256577]  [<ffffffff813d5dc6>] container_notify_cb+0x103/0x18d
[  381.329551]  [<ffffffff813b3946>] acpi_ev_notify_dispatch+0x41/0x5f
[  381.404612]  [<ffffffff813a0f47>] acpi_os_execute_deferred+0x27/0x34
[  381.480709]  [<ffffffff81090279>] process_one_work+0x219/0x680
[  381.550600]  [<ffffffff81090218>] ? process_one_work+0x1b8/0x680
[  381.622535]  [<ffffffff813a0f20>] ? acpi_os_wait_events_complete+0x23/0x23
[  381.704882]  [<ffffffff8109212e>] worker_thread+0x12e/0x320
[  381.771655]  [<ffffffff81092000>] ? manage_workers+0x190/0x190
[  381.841554]  [<ffffffff81098106>] kthread+0xc6/0xd0
[  381.899995]  [<ffffffff81678b04>] kernel_thread_helper+0x4/0x10
[  381.970815]  [<ffffffff8166e570>] ? retint_restore_args+0x13/0x13
[  382.043793]  [<ffffffff81098040>] ? __init_kthread_worker+0x70/0x70
[  382.118880]  [<ffffffff81678b00>] ? gs_change+0x13/0x13
[  382.181437] ---[ end trace a3ee526778d7b765 ]---

Thanks,
Yasuaki Ishimatsu

> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
