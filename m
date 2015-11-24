Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id B3B436B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 02:16:42 -0500 (EST)
Received: by padhx2 with SMTP id hx2so13093804pad.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 23:16:42 -0800 (PST)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id gg6si943609pbd.161.2015.11.23.23.16.41
        for <linux-mm@kvack.org>;
        Mon, 23 Nov 2015 23:16:41 -0800 (PST)
Message-ID: <56540E18.3030109@cn.fujitsu.com>
Date: Tue, 24 Nov 2015 15:13:28 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 0/5] Make cpuid <-> nodeid mapping persistent.
References: <1447906935-31899-1-git-send-email-tangchen@cn.fujitsu.com> <20151123220451.GG19072@mtj.duckdns.org>
In-Reply-To: <20151123220451.GG19072@mtj.duckdns.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux.com, jiang.liu@linux.intel.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


On 11/24/2015 06:04 AM, Tejun Heo wrote:
> Hello,
>
> On Thu, Nov 19, 2015 at 12:22:10PM +0800, Tang Chen wrote:
>> [Solution]
>>
>> There are four mappings in the kernel:
>> 1. nodeid (logical node id)   <->   pxm
>> 2. apicid (physical cpu id)   <->   nodeid
>> 3. cpuid (logical cpu id)     <->   apicid
>> 4. cpuid (logical cpu id)     <->   nodeid
>>
>> 1. pxm (proximity domain) is provided by ACPI firmware in SRAT, and nodeid <-> pxm
>>     mapping is setup at boot time. This mapping is persistent, won't change.
>>
>> 2. apicid <-> nodeid mapping is setup using info in 1. The mapping is setup at boot
>>     time and CPU hotadd time, and cleared at CPU hotremove time. This mapping is also
>>     persistent.
>>
>> 3. cpuid <-> apicid mapping is setup at boot time and CPU hotadd time. cpuid is
>>     allocated, lower ids first, and released at CPU hotremove time, reused for other
>>     hotadded CPUs. So this mapping is not persistent.
>>
>> 4. cpuid <-> nodeid mapping is also setup at boot time and CPU hotadd time, and
>>     cleared at CPU hotremove time. As a result of 3, this mapping is not persistent.
>>
>> To fix this problem, we establish cpuid <-> nodeid mapping for all the possible
>> cpus at boot time, and make it persistent. And according to init_cpu_to_node(),
>> cpuid <-> nodeid mapping is based on apicid <-> nodeid mapping and cpuid <-> apicid
>> mapping. So the key point is obtaining all cpus' apicid.
> I don't know much about acpi so can't actually review the patches but
> the overall approach looks good to me.

Thank you, TJ. Will test it recently.

>
> Thanks.
>


-- 
This message has been scanned for viruses and
dangerous content by Fujitsu, and is believed to be clean.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
