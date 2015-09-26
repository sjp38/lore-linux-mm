Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 920266B0038
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 05:53:52 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so128263972pac.0
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 02:53:52 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id ut10si11536664pac.203.2015.09.26.02.53.51
        for <linux-mm@kvack.org>;
        Sat, 26 Sep 2015 02:53:51 -0700 (PDT)
Message-ID: <56066AC9.6020703@cn.fujitsu.com>
Date: Sat, 26 Sep 2015 17:52:09 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 5/7] x86, acpi, cpu-hotplug: Introduce apicid_to_cpuid[]
 array to store persistent cpuid <-> apicid mapping.
References: <1441859269-25831-1-git-send-email-tangchen@cn.fujitsu.com> <1441859269-25831-6-git-send-email-tangchen@cn.fujitsu.com> <20150910195532.GK8114@mtj.duckdns.org>
In-Reply-To: <20150910195532.GK8114@mtj.duckdns.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: jiang.liu@linux.intel.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, qiaonuohan@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tangchen@cn.fujitsu.com

Hi tj,

On 09/11/2015 03:55 AM, Tejun Heo wrote:
> Hello,
>
> So, overall, I think this is the right way to go although I have no
> idea whether the acpi part is okay.

Thank you very much for reviewing. :)

>
>> +/*
>> + * Current allocated max logical CPU ID plus 1.
>> + * All allocated CPU ID should be in [0, max_logical_cpuid),
>> + * so the maximum of max_logical_cpuid is nr_cpu_ids.
>> + *
>> + * NOTE: Reserve 0 for BSP.
>> + */
>> +static int max_logical_cpuid = 1;
> Rename it to nr_logical_cpuids and just mention that it's allocated
> contiguously?

OK.

>
>> +static int cpuid_to_apicid[] = {
>> +	[0 ... NR_CPUS - 1] = -1,
>> +};
> And maybe mention how the two variables are synchronized?

User should call allocate_logical_cpuid() to get a new logical cpuid.
This allocator will ensure the synchronization.

Will mention it in the comment.

>
>> +static int allocate_logical_cpuid(int apicid)
>> +{
>> +	int i;
>> +
>> +	/*
>> +	 * cpuid <-> apicid mapping is persistent, so when a cpu is up,
>> +	 * check if the kernel has allocated a cpuid for it.
>> +	 */
>> +	for (i = 0; i < max_logical_cpuid; i++) {
>> +		if (cpuid_to_apicid[i] == apicid)
>> +			return i;
>> +	}
>> +
>> +	/* Allocate a new cpuid. */
>> +	if (max_logical_cpuid >= nr_cpu_ids) {
>> +		WARN_ONCE(1, "Only %d processors supported."
>> +			     "Processor %d/0x%x and the rest are ignored.\n",
>> +			     nr_cpu_ids - 1, max_logical_cpuid, apicid);
>> +		return -1;
>> +	}
> So, the original code didn't have this failure mode, why is this
> different for the new code?

It is not different. Since max_logical_cpuid is new, this is ensure it 
won't
go beyond NR_CPUS.

Thanks.

>
> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
