Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 117AD6B000A
	for <linux-mm@kvack.org>; Thu, 14 Jun 2018 02:24:59 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id p41-v6so3145479oth.5
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 23:24:59 -0700 (PDT)
Received: from huawei.com ([45.249.212.32])
        by mx.google.com with ESMTPS id m30-v6si1745853otb.222.2018.06.13.23.24.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 23:24:57 -0700 (PDT)
Subject: Re: [PATCH 1/2] arm64: avoid alloc memory on offline node
References: <1527768879-88161-2-git-send-email-xiexiuqi@huawei.com>
 <20180606154516.GL6631@arm.com>
 <CAErSpo6S0qtR42tjGZrFu4aMFFyThx1hkHTSowTt6t3XerpHnA@mail.gmail.com>
 <20180607105514.GA13139@dhcp22.suse.cz>
 <5ed798a0-6c9c-086e-e5e8-906f593ca33e@huawei.com>
 <20180607122152.GP32433@dhcp22.suse.cz>
 <a880df29-b656-d98d-3037-b04761c7ed78@huawei.com>
 <20180611085237.GI13364@dhcp22.suse.cz>
 <16c4db2f-bc70-d0f2-fb38-341d9117ff66@huawei.com>
 <20180611134303.GC75679@bhelgaas-glaptop.roam.corp.google.com>
 <20180611145330.GO13364@dhcp22.suse.cz>
 <87lgbk59gs.fsf@e105922-lin.cambridge.arm.com>
 <87bmce60y3.fsf@e105922-lin.cambridge.arm.com>
From: Hanjun Guo <guohanjun@huawei.com>
Message-ID: <28ab6a17-dfb6-13d5-764c-d8255569c6bc@huawei.com>
Date: Thu, 14 Jun 2018 14:23:59 +0800
MIME-Version: 1.0
In-Reply-To: <87bmce60y3.fsf@e105922-lin.cambridge.arm.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>, Xie XiuQi <xiexiuqi@huawei.com>
Cc: Bjorn Helgaas <helgaas@kernel.org>, tnowicki@caviumnetworks.com, linux-pci@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Will Deacon <will.deacon@arm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>, linux-mm@kvack.org, wanghuiqiang@huawei.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, zhongjiang <zhongjiang@huawei.com>, linux-arm <linux-arm-kernel@lists.infradead.org>, Michal Hocko <mhocko@kernel.org>

Hi Punit,

On 2018/6/14 1:39, Punit Agrawal wrote:
> Punit Agrawal <punit.agrawal@arm.com> writes:
> 
> 
> [...]
> 
>>
>> CONFIG_HAVE_MEMORYLESS node is not enabled on arm64 which means we end
>> up returning the original node in the fallback path.
>>
>> Xie, does the below patch help? I can submit a proper patch if this
>> fixes the issue for you.
>>
>> -- >8 --
>> Subject: [PATCH] arm64/numa: Enable memoryless numa nodes
>>
>> Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
>> ---
>>  arch/arm64/Kconfig   | 4 ++++
>>  arch/arm64/mm/numa.c | 2 ++
>>  2 files changed, 6 insertions(+)
>>
>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>> index eb2cf4938f6d..5317e9aa93ab 100644
>> --- a/arch/arm64/Kconfig
>> +++ b/arch/arm64/Kconfig
>> @@ -756,6 +756,10 @@ config USE_PERCPU_NUMA_NODE_ID
>>  	def_bool y
>>  	depends on NUMA
>>  
>> +config HAVE_MEMORYLESS_NODES
>> +       def_bool y
>> +       depends on NUMA
>> +
>>  config HAVE_SETUP_PER_CPU_AREA
>>  	def_bool y
>>  	depends on NUMA
>> diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
>> index dad128ba98bf..c699dcfe93de 100644
>> --- a/arch/arm64/mm/numa.c
>> +++ b/arch/arm64/mm/numa.c
>> @@ -73,6 +73,8 @@ EXPORT_SYMBOL(cpumask_of_node);
>>  static void map_cpu_to_node(unsigned int cpu, int nid)
>>  {
>>  	set_cpu_numa_node(cpu, nid);
>> +	set_numa_mem(local_memory_node(nid));
> 
> Argh, this should be
> 
>         set_cpu_numa_mem(cpu, local_memory_node(nid));
> 
> There is not guarantee that map_cpu_to_node() will be called on the
> local cpu.
> 
> Hanjun, Xie - can you try with the update please?

Thanks for looking into this, we will try this tomorrow
(the hardware is occupied now) and update here.

Thanks
Hanjun
