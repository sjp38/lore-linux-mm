Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 517686B0062
	for <linux-mm@kvack.org>; Sat, 20 Oct 2012 00:56:45 -0400 (EDT)
Message-ID: <5082305A.2050108@cn.fujitsu.com>
Date: Sat, 20 Oct 2012 13:02:18 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] acpi,memory-hotplug : add memory offline code to
 acpi_memory_device_remove()
References: <506C0AE8.40702@jp.fujitsu.com> <506C0C53.60205@jp.fujitsu.com> <CAHGf_=p7PaQs-kpnyB8uC1MntHQfL-CXhhq4QQP54mYiqOswqQ@mail.gmail.com> <50727984.20401@cn.fujitsu.com> <CAHGf_=pCrx8AkL9eiSYVgwvT1v0SW2__P_DW-1Wwj_zskqcLXw@mail.gmail.com> <507E77D1.3030709@cn.fujitsu.com> <CAHGf_=rxGeb0RsgEFF2FRRfdX0wiE9cDyVaftsG3E8AgyzYi1g@mail.gmail.com> <508118A6.80804@cn.fujitsu.com> <CAHGf_=qfzEJ0VjeYkKFVtyew+wYM-rHS4nqmXU4t7HYGuv8k9w@mail.gmail.com>
In-Reply-To: <CAHGf_=qfzEJ0VjeYkKFVtyew+wYM-rHS4nqmXU4t7HYGuv8k9w@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org

At 10/20/2012 02:19 AM, KOSAKI Motohiro Wrote:
>> Hmm, IIRC, if the memory is recognized from kerenl before driver initialization,
>> the memory device is not managed by the driver acpi_memhotplug.
> 
> Yup.
> 
> 
>> I think we should also deal with REMOVAL_NORMAL here now. Otherwise it will cause
>> some critical problem: we unbind the device from the driver but we still use
>> it. If we eject it, we have no chance to offline and remove it. It is very dangerous.
> 
> ??
> If resource was not allocated a driver, a driver doesn't need to
> deallocate it when
> error path. I haven't caught your point.
> 

REMOVAL_NORMAL can be in 2 cases:
1. error path. If init call fails, we don't call it. We call this function
   only when something fails after init.

2. unbind the device from the driver.
   If we don't offline and remove memory when unbinding the device from the driver,
   the device may be out of control. When we eject this driver, we don't offline and
   remove it, but we will eject and poweroff the device. It is very dangerous because
   the kernel uses the memory but we poweroff it.

   acpi_bus_hot_remove_device()
       acpi_bus_trim() // this function successes because the device has no driver
       _PS3 // poweroff
       _EJ0 // eject

Thanks
Wen Congyang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
