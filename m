Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A40416B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 22:02:21 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r70so843888pfb.7
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 19:02:21 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id c24si1175711pfl.259.2017.06.14.19.02.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 19:02:20 -0700 (PDT)
Subject: Re: [Question or BUG] [NUMA]: I feel puzzled at the function
 cpumask_of_node
References: <5937C608.7010905@huawei.com>
 <20170608141214.GJ19866@dhcp22.suse.cz>
From: "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>
Message-ID: <5941EA39.8090501@huawei.com>
Date: Thu, 15 Jun 2017 10:00:25 +0800
MIME-Version: 1.0
In-Reply-To: <20170608141214.GJ19866@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, chenchunxiao <chenchunxiao@huawei.com>, x86l <x86@kernel.org>, linux-api@vger.kernel.org



On 2017/6/8 22:12, Michal Hocko wrote:
> [CC linux-api]
> 
> On Wed 07-06-17 17:23:20, Leizhen (ThunderTown) wrote:
>> When I executed numactl -H(print cpumask_of_node for each node), I got
>> different result on X86 and ARM64.  For each numa node, the former
>> only displayed online CPUs, and the latter displayed all possible
>> CPUs.  Actually, all other ARCHs is the same to ARM64.
>>
>> So, my question is: Which case(online or possible) should function
>> cpumask_of_node be? Or there is no matter about it?
> 
> Unfortunatelly the documentation is quite unclear
> What:		/sys/devices/system/node/nodeX/cpumap
> Date:		October 2002
> Contact:	Linux Memory Management list <linux-mm@kvack.org>
> Description:
> 		The node's cpumap.
> 
> not really helpeful, is it? Semantically I _think_ printing online cpus
> makes more sense because it doesn't really make much sense to bind
> anything on offline nodes. Generic implementtion of cpumask_of_node
> indeed provides only online cpus. I haven't checked specific
> implementations of arch specific code but listing offline cpus sounds
> confusing to me.
> 
OK, thank you very much. So, how about we directly add "cpumask_and with cpu_online_mask", as below:

diff --git a/drivers/base/node.c b/drivers/base/node.c
index b10479c..199723d 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -28,12 +28,14 @@ static struct bus_type node_subsys = {
 static ssize_t node_read_cpumap(struct device *dev, bool list, char *buf)
 {
        struct node *node_dev = to_node(dev);
-   const struct cpumask *mask = cpumask_of_node(node_dev->dev.id);
+ struct cpumask mask;
+
+ cpumask_and(&mask, cpumask_of_node(node_dev->dev.id), cpu_online_mask);

        /* 2008/04/07: buf currently PAGE_SIZE, need 9 chars per 32 bits. */
        BUILD_BUG_ON((NR_CPUS/32 * 9) > (PAGE_SIZE-1));

-   return cpumap_print_to_pagebuf(list, buf, mask);
+ return cpumap_print_to_pagebuf(list, buf, &mask);
 }

 static inline ssize_t node_read_cpumask(struct device *dev,


-- 
Thanks!
BestRegards

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
