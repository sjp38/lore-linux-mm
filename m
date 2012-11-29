Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id A45336B0068
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 10:48:06 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so6918115pad.14
        for <linux-mm@kvack.org>; Thu, 29 Nov 2012 07:48:06 -0800 (PST)
Message-ID: <50B78387.5070707@gmail.com>
Date: Thu, 29 Nov 2012 23:47:19 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] Add movablecore_map boot option
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <50B5CFAE.80103@huawei.com> <3908561D78D1C84285E8C5FCA982C28F1C95EDCE@ORSMSX108.amr.corp.intel.com> <50B73B22.90500@jp.fujitsu.com>
In-Reply-To: <50B73B22.90500@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, "hpa@zytor.com" <hpa@zytor.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rob@landley.net" <rob@landley.net>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Len Brown <lenb@kernel.org>, "Wang, Frank" <frank.wang@intel.com>

On 11/29/2012 06:38 PM, Yasuaki Ishimatsu wrote:
> Hi Tony,
> 
> 2012/11/29 6:34, Luck, Tony wrote:
>>> 1. use firmware information
>>>    According to ACPI spec 5.0, SRAT table has memory affinity structure
>>>    and the structure has Hot Pluggable Filed. See "5.2.16.2 Memory
>>>    Affinity Structure". If we use the information, we might be able to
>>>    specify movable memory by firmware. For example, if Hot Pluggable
>>>    Filed is enabled, Linux sets the memory as movable memory.
>>>
>>> 2. use boot option
>>>    This is our proposal. New boot option can specify memory range to use
>>>    as movable memory.
>>
>> Isn't this just moving the work to the user? To pick good values for the
> 
> Yes.
> 
>> movable areas, they need to know how the memory lines up across
>> node boundaries ... because they need to make sure to allow some
>> non-movable memory allocations on each node so that the kernel can
>> take advantage of node locality.
> 
> There is no problem.
> Linux has already two boot options, kernelcore= and movablecore=.
> So if we use them, non-movable memory is divided into each node evenly.
> 
> But there is no way to specify a node used as movable currently. So
> we proposed the new boot option.
> 
>> So the user would have to read at least the SRAT table, and perhaps
>> more, to figure out what to provide as arguments.
>>
> 
>> Since this is going to be used on a dynamic system where nodes might
>> be added an removed - the right values for these arguments might
>> change from one boot to the next. So even if the user gets them right
>> on day 1, a month later when a new node has been added, or a broken
>> node removed the values would be stale.
> 
> I don't think so. Even if we hot add/remove node, the memory range of
> each memory device is not changed. So we don't need to change the boot
> option.
Hi Yasuaki,
	Addresses assigned to each memory device may change under different 
hardware configurations.
	According to my experiences with some hotplug capable Xeon and Itanium
systems, a typical algorithm adopted by BIOS to support memory hotplug is:
1) For backward compatibility, BIOS assigns continuous addresses to memory
devices present at boot time. In other words, there are no holes in the memory
addresses except the hole just below 4G reserved for MMIO and other arch 
specific usage.
2) To support memory hotplug, BIOS reserves enough memory address ranges 
at the high end.
 
	Let's take a typical 4 sockets system as an example. Say we have four
sockets S0-S3, and each socket supports two memory devices(M0-M1) at maximum. 
Each memory device supports 128G memory at maximum. And at boot, all memory
slots are fully populated with 4GB memory. Then the address assignment looks
like:
0-2G: 		S0.M0
2-4G: 		MMIO
4-8G: 		S0.M1
8-12G: 		S1.M0
12-16G: 	S1.M1
16-20G: 	S2.M0
20-24G:		S2.M1
24-28G: 	S2.M0
28-32G:		S2.M1
32-34G:		S0.M0 (memory recovered from the MMIO hole)
1024-1152G:	reserved for S0.M0
1152-1280G:	reserved for S0.M1
1280-1408G:	reserved for S1.M0
1408-1536G:	reserved for S1.M1
1536-1664G:	reserved for S2.M0
1664-1792G:	reserved for S2.M1
1792-1920G:	reserved for S3.M0
1920-2048G:	reserved for S4.M1

If we hot-remove S2.M0 and add back a bigger memory device with 8G memory, it will
be assigned a new memory address range 1536-1544G.

Based on above algorithm, and we configure 16-24G(S2.M0 and S2.M1) as movable memory.
1) memory on S3 will be configured as movable if S2 isn't present at boot time. (the
same effect as "movable_node" in discussion at https://lkml.org/lkml/2012/11/27/154)
2) S2.M0 will be configured as non-movable and S3.M0 will be configured as movable
   if S1.M0 isn't present at boot.
3) And how about replace S1.M0 with a 8GB memory device?

To summarize, kernel parameter to configure movable memory for hotplug will easily
become invalid if hardware configuration changes, and that may confuse administrators.
I still think the most reliable way is to figure out movable memory for hotplug by
parsing hardware configuration information from BIOS.

Regards!
Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
