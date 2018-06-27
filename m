Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE5296B026D
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 09:37:14 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id j8-v6so1270637wrh.18
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 06:37:14 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b131-v6si3847686wmg.106.2018.06.27.06.37.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 06:37:12 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5RDY9tJ044948
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 09:37:11 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jvb5wsdkv-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 09:37:10 -0400
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <vrbagal1@linux.vnet.ibm.com>;
	Wed, 27 Jun 2018 09:37:10 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 8bit
Date: Wed, 27 Jun 2018 19:12:10 +0530
From: vrbagal1 <vrbagal1@linux.vnet.ibm.com>
Subject: Re: [powerpc/powervm]kernel BUG at mm/memory_hotplug.c:1864!
In-Reply-To: <345785ef-5da2-b2e8-78b8-2391b54c6141@linux.vnet.ibm.com>
References: <6826dab0e4382380db8d11b047272bda@linux.vnet.ibm.com>
 <20180608112823.GA20395@techadventures.net>
 <3d1e7740df56ed35c8b56941acdb7079@linux.vnet.ibm.com>
 <20180608121553.GA20774@techadventures.net>
 <0aac625ee724d877b87c69bba5ac9a0e@linux.vnet.ibm.com>
 <605b4df2-4cf1-2dda-3661-68b78845f8ec@gmail.com>
 <345785ef-5da2-b2e8-78b8-2391b54c6141@linux.vnet.ibm.com>
Message-Id: <120957da29cd4b6adffb726522726b7a@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Cc: Balbir Singh <bsingharora@gmail.com>, Oscar Salvador <osalvador@techadventures.net>, sachinp <sachinp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-next <linux-next@vger.kernel.org>, Linuxppc-dev <linuxppc-dev-bounces+vrbagal1=linux.vnet.ibm.com@lists.ozlabs.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On 2018-06-26 20:24, Nathan Fontenot wrote:
> On 06/12/2018 05:28 AM, Balbir Singh wrote:
>> 
>> 
>> On 11/06/18 17:41, vrbagal1 wrote:
>>> On 2018-06-08 17:45, Oscar Salvador wrote:
>>>> On Fri, Jun 08, 2018 at 05:11:24PM +0530, vrbagal1 wrote:
>>>>> On 2018-06-08 16:58, Oscar Salvador wrote:
>>>>>> On Fri, Jun 08, 2018 at 04:44:24PM +0530, vrbagal1 wrote:
>>>>>>> Greetings!!!
>>>>>>> 
>>>>>>> I am seeing kernel bug followed by oops message and system 
>>>>>>> reboots,
>>>>>>> while
>>>>>>> running dlpar memory hotplug test.
>>>>>>> 
>>>>>>> Machine Details: Power6 PowerVM Platform
>>>>>>> GCC version: (gcc version 4.8.3 20140911 (Red Hat 4.8.3-7) (GCC))
>>>>>>> Test case: dlpar memory hotplug test 
>>>>>>> (https://github.com/avocado-framework-tests/avocado-misc-tests/blob/master/memory/memhotplug.py)
>>>>>>> Kernel Version: Linux version 4.17.0-autotest
>>>>>>> 
>>>>>>> I am seeing this bug on rc7 as well.
>>> 
>>> Observing similar traces on linux next kernel: 
>>> 4.17.0-next-20180608-autotest
>>> 
>>> A Block size [0x4000000] unaligned hotplug range: start 0x220000000, 
>>> size 0x1000000
>> 
>> size < block_size in this case, why? how? Could you confirm that the 
>> block size is 64MB and your trying to remove 16MB
>> 
> 
> I was not able to re-create this failure exactly ( I don't have a 
> Power6 system)
> but was able to get a similar re-create on a Power 9 with a few 
> modifications.
> 
> I think the issue you're seeing is due to a change in the validation of 
> memory
> done in remove_memory to ensure the amount of memory being removed 
> spans
> entire memory block. The pseries memory remove code, see
> pseries_remove_memblock,
> tries to remove each section of a memory block instead of the entire
> memory block.
> 
> Could you try the patch below that updates the pseries code to remove 
> the entire
> memory block instead of doing it one section at a time.
> 
> -Nathan


Hi Nathan,

With below patch applied on 4.18.0-rc2 I am seeing below oops message.

------------[ cut here ]------------
kernel BUG at mm/memory_hotplug.c:150!
Oops: Exception in kernel mode, sig: 5 [#1]
BE SMP NR_CPUS=1024 NUMA pSeries
Modules linked in: rpadlpar_io rpaphp nf_conntrack_netbios_ns 
nf_conntrack_broadcast ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 
nf_defrag_ipv6 ipt_REJECT cfg80211 nf_reject_ipv4 nf_conntrack_ipv4 
nf_defrag_ipv4 rfkill xt_conntrack nf_conntrack libcrc32c ebtable_nat 
ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle 
ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_mangle 
iptable_security iptable_raw iptable_filter ip_tables ses osst enclosure 
scsi_transport_sas ehea st uio_pdrv_genirq uio nfsd auth_rpcgss nfs_acl 
lockd grace sunrpc ipv6 crc_ccitt ext4 mbcache jbd2 sd_mod sr_mod cdrom 
dm_mirror dm_region_hash dm_log dm_mod dax
CPU: 5 PID: 2925 Comm: drmgr Tainted: G        W         
4.18.0-rc2-00045-g671afc8 #2
NIP:  c0000000002cf278 LR: c0000000002c0c38 CTR: 0000000000000400
REGS: c0000002ac4ab150 TRAP: 0700   Tainted: G        W          
(4.18.0-rc2-00045-g671afc8)
MSR:  8000000000029032 <SF,EE,ME,IR,DR,RI>  CR: 28002884  XER: 00000000
CFAR: c0000000002c0c00 IRQMASK: 0
GPR00: c0000000002c0c38 c0000002ac4ab3d0 c000000001159b00 
c0000002b1091810
GPR04: 0000000000000000 0000000000000000 0000000000000000 
0000000000002b10
GPR08: c0000002b3fd0600 0000000000000001 0000000000000000 
0000000000000220
GPR12: 0000000088002884 c00000000eeaa000 000000000002b400 
0000000000024d00
GPR16: c0000002b3f8ca00 0000000000024c00 c0000000d3fc89c0 
0000000000024d00
GPR20: 0000000000000003 0000000000000004 c0000002b3f7ca8c 
0000000000000000
GPR24: 0000000000000000 0000000000000000 0000000000000000 
0000000000000000
GPR28: c0000002b3fd0600 c0000002b1f7c6c0 c0000002b3f86224 
c0000002b1091810
NIP [c0000000002cf278] .put_page_bootmem+0x28/0xf0
LR [c0000000002c0c38] .sparse_remove_one_section+0x228/0x2c0
Call Trace:
[c0000002ac4ab3d0] [c0000002ac4ab450] 0xc0000002ac4ab450 (unreliable)
[c0000002ac4ab450] [c0000000002c0c38] 
.sparse_remove_one_section+0x228/0x2c0
[c0000002ac4ab4f0] [c0000000002cf6f8] .__remove_pages+0x3b8/0x550
[c0000002ac4ab600] [c0000000008d32a4] .arch_remove_memory+0xb4/0x128
[c0000002ac4ab680] [c0000000002d1cd0] .remove_memory+0xb0/0x100
[c0000002ac4ab710] [c0000000000bc7b4] .pseries_remove_memblock+0x94/0xe0
[c0000002ac4ab790] [c0000000000bd3f8] 
.pseries_memory_notifier+0x248/0x260
[c0000002ac4ab820] [c000000000116ee8] .notifier_call_chain+0x78/0xf0
[c0000002ac4ab8c0] [c000000000117358] 
.__blocking_notifier_call_chain+0x58/0x90
[c0000002ac4ab960] [c000000000743e30] .of_property_notify+0x90/0xd0
[c0000002ac4aba10] [c00000000073ed04] .of_update_property+0x104/0x150
[c0000002ac4abac0] [c0000000000b045c] .ofdt_write+0x3bc/0x6f0
[c0000002ac4abb90] [c0000000003735b8] .proc_reg_write+0x78/0xc0
[c0000002ac4abc10] [c0000000002deaac] .__vfs_write+0x3c/0x200
[c0000002ac4abcf0] [c0000000002deeb0] .vfs_write+0xc0/0x230
[c0000002ac4abd90] [c0000000002df214] .ksys_write+0x54/0x100
[c0000002ac4abe30] [c00000000000b9dc] system_call+0x5c/0x70
Instruction dump:
60000000 60000000 7c0802a6 fbe1fff8 7c7f1b78 f8010010 f821ff81 e9230020
3929fff4 21290002 7d294910 7d2900d0 <0b090000> 7c0004ac 39230034 
7d404828
---[ end trace 85b846899f1bdbb7 ]---


Regards,
Venkat.


> ---
> 
>  arch/powerpc/platforms/pseries/hotplug-memory.c |   18 
> ++++++------------
>  1 file changed, 6 insertions(+), 12 deletions(-)
> 
> diff --git a/arch/powerpc/platforms/pseries/hotplug-memory.c
> b/arch/powerpc/platforms/pseries/hotplug-memory.c
> index c1578f54c626..6072efc793e1 100644
> --- a/arch/powerpc/platforms/pseries/hotplug-memory.c
> +++ b/arch/powerpc/platforms/pseries/hotplug-memory.c
> @@ -316,11 +316,11 @@ static int dlpar_offline_lmb(struct drmem_lmb 
> *lmb)
>  	return dlpar_change_lmb_state(lmb, false);
>  }
> 
> -static int pseries_remove_memblock(unsigned long base, unsigned int
> memblock_size)
> +static int pseries_remove_memblock(unsigned long base,
> +				   unsigned int memblock_sz)
>  {
> -	unsigned long block_sz, start_pfn;
> -	int sections_per_block;
> -	int i, nid;
> +	unsigned long start_pfn;
> +	int nid;
> 
>  	start_pfn = base >> PAGE_SHIFT;
> 
> @@ -329,18 +329,12 @@ static int pseries_remove_memblock(unsigned long
> base, unsigned int memblock_siz
>  	if (!pfn_valid(start_pfn))
>  		goto out;
> 
> -	block_sz = pseries_memory_block_size();
> -	sections_per_block = block_sz / MIN_MEMORY_BLOCK_SIZE;
>  	nid = memory_add_physaddr_to_nid(base);
> -
> -	for (i = 0; i < sections_per_block; i++) {
> -		remove_memory(nid, base, MIN_MEMORY_BLOCK_SIZE);
> -		base += MIN_MEMORY_BLOCK_SIZE;
> -	}
> +	remove_memory(nid, base, memblock_sz);
> 
>  out:
>  	/* Update memory regions for memory remove */
> -	memblock_remove(base, memblock_size);
> +	memblock_remove(base, memblock_sz);
>  	unlock_device_hotplug();
>  	return 0;
>  }
