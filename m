Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 689DF6B0038
	for <linux-mm@kvack.org>; Sun, 27 Sep 2015 21:58:59 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so61856901pab.3
        for <linux-mm@kvack.org>; Sun, 27 Sep 2015 18:58:59 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id b9si8531317pas.200.2015.09.27.18.58.57
        for <linux-mm@kvack.org>;
        Sun, 27 Sep 2015 18:58:58 -0700 (PDT)
Message-ID: <56089E7A.7040400@cn.fujitsu.com>
Date: Mon, 28 Sep 2015 09:57:14 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 5/7] x86, acpi, cpu-hotplug: Introduce apicid_to_cpuid[]
 array to store persistent cpuid <-> apicid mapping.
References: <1441859269-25831-1-git-send-email-tangchen@cn.fujitsu.com> <1441859269-25831-6-git-send-email-tangchen@cn.fujitsu.com> <20150910195532.GK8114@mtj.duckdns.org> <56066AC9.6020703@cn.fujitsu.com> <20150926175622.GC3572@htj.duckdns.org>
In-Reply-To: <20150926175622.GC3572@htj.duckdns.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: jiang.liu@linux.intel.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, qiaonuohan@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tangchen@cn.fujitsu.com


On 09/27/2015 01:56 AM, Tejun Heo wrote:
> On Sat, Sep 26, 2015 at 05:52:09PM +0800, Tang Chen wrote:
>>>> +static int allocate_logical_cpuid(int apicid)
>>>> +{
>>>> +	int i;
>>>> +
>>>> +	/*
>>>> +	 * cpuid <-> apicid mapping is persistent, so when a cpu is up,
>>>> +	 * check if the kernel has allocated a cpuid for it.
>>>> +	 */
>>>> +	for (i = 0; i < max_logical_cpuid; i++) {
>>>> +		if (cpuid_to_apicid[i] == apicid)
>>>> +			return i;
>>>> +	}
>>>> +
>>>> +	/* Allocate a new cpuid. */
>>>> +	if (max_logical_cpuid >= nr_cpu_ids) {
>>>> +		WARN_ONCE(1, "Only %d processors supported."
>>>> +			     "Processor %d/0x%x and the rest are ignored.\n",
>>>> +			     nr_cpu_ids - 1, max_logical_cpuid, apicid);
>>>> +		return -1;
>>>> +	}
>>> So, the original code didn't have this failure mode, why is this
>>> different for the new code?
>> It is not different. Since max_logical_cpuid is new, this is ensure it won't
>> go beyond NR_CPUS.
> If the above condition can happen, the original code should have had a
> similar check as above, right?  Sure, max_logical_cpuid is a new thing
> but that doesn't seem to change whether the above condition can happen
> or not, no?

Right, indeed. It is in

generic_processor_info()
|--> if (num_processors >= nr_cpu_ids)

Will remove my new added check.

Thanks.

>
> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
