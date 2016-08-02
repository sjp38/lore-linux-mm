Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B74656B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 03:31:51 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id i64so81800897ith.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 00:31:51 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id d24si601044otc.100.2016.08.02.00.31.46
        for <linux-mm@kvack.org>;
        Tue, 02 Aug 2016 00:31:50 -0700 (PDT)
Subject: Re: [PATCH v10 2/7] x86, acpi, cpu-hotplug: Enable acpi to register
 all possible cpus at boot time.
References: <1469513429-25464-1-git-send-email-douly.fnst@cn.fujitsu.com>
 <1469513429-25464-3-git-send-email-douly.fnst@cn.fujitsu.com>
 <alpine.DEB.2.11.1607291526210.19896@nanos>
From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Message-ID: <31882463-3647-15eb-1410-47bbb87a69d7@cn.fujitsu.com>
Date: Tue, 2 Aug 2016 15:30:38 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1607291526210.19896@nanos>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: cl@linux.com, tj@kernel.org, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, chen.tang@easystack.cn, rafael@kernel.org, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Zhu Guihua <zhugh.fnst@cn.fujitsu.com>

Hi tglx,

a?? 2016a1'07ae??29ae?JPY 21:36, Thomas Gleixner a??e??:
> On Tue, 26 Jul 2016, Dou Liyang wrote:
>
>> 1. Enable apic registeration flow to handle both enabled and disabled cpus.
>>    This is done by introducing an extra parameter to generic_processor_info to
>>    let the caller control if disabled cpus are ignored.
>
> If I'm reading the patch correctly then the 'enabled' argument controls more
> than the disabled cpus accounting. It also controls the modification of
> num_processors and the present mask.

In the patch, they both need mapping to a logic cpu.
As you said, the 'enabled' controls extra functions:

1. num_processors parameter
2. physid_set method
3. set_cpu_present method

>
>> -int generic_processor_info(int apicid, int version)
>> +static int __generic_processor_info(int apicid, int version, bool enabled)
>>  {
>>  	int cpu, max = nr_cpu_ids;
>>  	bool boot_cpu_detected = physid_isset(boot_cpu_physical_apicid,
>> @@ -2032,7 +2032,8 @@ int generic_processor_info(int apicid, int version)
>>  			   " Processor %d/0x%x ignored.\n",
>>  			   thiscpu, apicid);
>>
>> -		disabled_cpus++;
>> +		if (enabled)
>> +			disabled_cpus++;
>>  		return -ENODEV;
>>  	}
>>
>> @@ -2049,7 +2050,8 @@ int generic_processor_info(int apicid, int version)
>>  			" reached. Keeping one slot for boot cpu."
>>  			"  Processor %d/0x%x ignored.\n", max, thiscpu, apicid);
>>
>> -		disabled_cpus++;
>> +		if (enabled)
>> +			disabled_cpus++;
>
> This is utterly confusing. That code path cannot be reached when enabled is
> false, because num_processors is 0 as we never increment it when enabled is
> false.
>
> That said, I really do not like this 'slap some argument on it and make it
> work somehow' approach.
>
> The proper solution for this is to seperate out the functionality which you
> need for the preparation run (enabled = false) and make sure that the
> information you need for the real run (enabled = true) is properly cached
> somewhere so we don't have to evaluate the same thing over and over.

Thank you very much for your advice. That solution is very good for me.

I thought about the differences between them carefully. Firstly, I
intend to separate out the functionality in two functions. It's simple
but not good. Then, I try to put them together to judge just once.

After, considering the judgment statement independence and the order of
assignment. I remove all the "if (enabled)" code and do the unified
judgment like this:

@@ -2180,12 +2176,19 @@ int __generic_processor_info(int apicid, int
version, bool enabled)
                 apic->x86_32_early_logical_apicid(cpu);
  #endif
         set_cpu_possible(cpu, true);
-       if (enabled)
+
+       if (enabled){
+               num_processors++;
+               physid_set(apicid, phys_cpu_present_map);
                 set_cpu_present(cpu, true);
+       }else{
+               disabled_cpus++;
+       }

         return cpu;
  }

I hope that patch could consistent with your advice. And I will submit
the detailed modification in the next version patches.

Thanks,

Dou.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
