Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 94C9E6B004D
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 21:17:49 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CC7683EE0C2
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 10:17:47 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 107F245DE5A
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 10:17:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D84CE45DE5D
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 10:17:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CA2F41DB8051
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 10:17:43 +0900 (JST)
Received: from g01jpexchkw36.g01.fujitsu.local (g01jpexchkw36.g01.fujitsu.local [10.0.193.54])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 87FE21DB804D
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 10:17:43 +0900 (JST)
Message-ID: <51709B0D.9000900@jp.fujitsu.com>
Date: Fri, 19 Apr 2013 10:17:01 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Bug fix PATCH] numa, cpu hotplug: Change links of CPU and node
 when changing node number by onlining CPU
References: <516FA0B9.8080308@jp.fujitsu.com> <CAHGf_=qcV=R_O5fpjpRQh5Tu9=nz1jVR9r=55fYODds8TQm7vw@mail.gmail.com>
In-Reply-To: <CAHGf_=qcV=R_O5fpjpRQh5Tu9=nz1jVR9r=55fYODds8TQm7vw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, x86@kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

2013/04/19 1:32, KOSAKI Motohiro wrote:
>>   #ifdef CONFIG_HOTPLUG_CPU
>> +static void change_cpu_under_node(struct cpu *cpu,
>> +                       unsigned int from_nid, unsigned int to_nid)
>> +{
>> +       int cpuid = cpu->dev.id;
>> +       unregister_cpu_under_node(cpuid, from_nid);
>> +       register_cpu_under_node(cpuid, to_nid);
>> +       cpu->node_id = to_nid;
>> +}
>> +
>

> Where is stub for !CONFIG_HOTPLUG_CPU?

This function is called by only store_online(). And the store_online() is
defined only when CONFIG_HOTPLUG_CPU enables. Thus change_cpu_under_node()
is not necessary for !CONFIG_HOTPLUG_CPU.

>
>
>>   static ssize_t show_online(struct device *dev,
>>                             struct device_attribute *attr,
>>                             char *buf)
>> @@ -39,17 +48,23 @@ static ssize_t __ref store_online(struct device *dev,
>>                                    const char *buf, size_t count)
>>   {
>>          struct cpu *cpu = container_of(dev, struct cpu, dev);
>> +       int num = cpu->dev.id;
>

> "num" is wrong name. cpuid may be better.

I'll update it.

>
>
>> +       int from_nid, to_nid;
>>          ssize_t ret;
>>
>>          cpu_hotplug_driver_lock();
>>          switch (buf[0]) {
>>          case '0':
>> -               ret = cpu_down(cpu->dev.id);
>> +               ret = cpu_down(num);
>>                  if (!ret)
>>                          kobject_uevent(&dev->kobj, KOBJ_OFFLINE);
>>                  break;
>>          case '1':
>> -               ret = cpu_up(cpu->dev.id);
>> +               from_nid = cpu_to_node(num);
>> +               ret = cpu_up(num);
>> +               to_nid = cpu_to_node(num);
>> +               if (from_nid != to_nid)
>> +                       change_cpu_under_node(cpu, from_nid, to_nid);
>
> You need to add several comments. this code is not straightforward.

O.K. I'll update it.

Thanks,
Yasuaki Ishimatsu


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
