Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id C5CAE6B0074
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 05:34:04 -0400 (EDT)
Message-ID: <50584159.3020403@cn.fujitsu.com>
Date: Tue, 18 Sep 2012 17:39:37 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC v8 PATCH 00/20] memory-hotplug: hot-remove physical memory
References: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com> <20120831134956.fec0f681.akpm@linux-foundation.org> <504D467D.2080201@jp.fujitsu.com> <504D4A08.7090602@cn.fujitsu.com> <20120910135213.GA1550@dhcp-192-168-178-175.profitbricks.localdomain> <50501B9C.7000200@cn.fujitsu.com> <20120912171814.GB5253@dhcp-192-168-178-175.profitbricks.localdomain>
In-Reply-To: <20120912171814.GB5253@dhcp-192-168-178-175.profitbricks.localdomain>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com

At 09/13/2012 01:18 AM, Vasilis Liaskovitis Wrote:
> Hi,
> 
> On Wed, Sep 12, 2012 at 01:20:28PM +0800, Wen Congyang wrote:
>>>
>>> On Mon, Sep 10, 2012 at 10:01:44AM +0800, Wen Congyang wrote:
>>>> At 09/10/2012 09:46 AM, Yasuaki Ishimatsu Wrote:
>>>>> How do you test the patch? As Andrew says, for hot-removing memory,
>>>>> we need a particular hardware. I think so too. So many people may want
>>>>> to know how to test the patch.
>>>>> If we apply following patch to kvm guest, can we hot-remove memory on
>>>>> kvm guest?
>>>>>
>>>>> http://lists.gnu.org/archive/html/qemu-devel/2012-07/msg01389.html
>>>>
>>>> Yes, if we apply this patchset, we can test hot-remove memory on kvm guest.
>>>> But that patchset doesn't implement _PS3, so there is some restriction.
>>>
>>> the following repos contain the patchset above, plus 2 more patches that add
>>> PS3 support to the dimm devices in qemu/seabios:
>>>
>>> https://github.com/vliaskov/seabios/commits/memhp-v2
>>> https://github.com/vliaskov/qemu-kvm/commits/memhp-v2
>>>
>>> I have not posted the PS3 patches yet in the qemu list, but will post them
>>> soon for v3 of the memory hotplug series. If you have issues testing, let me
>>> know.
>>
>> Hmm, seabios doesn't support ACPI table SLIT. We can specify node it for dimm
>> device, so I think we should support SLIT in seabios. Otherwise we may meet
>> the following kernel messages:
>> [  325.016769] init_memory_mapping: [mem 0x40000000-0x5fffffff]
>> [  325.018060]  [mem 0x40000000-0x5fffffff] page 2M
>> [  325.019168] [ffffea0001000000-ffffea00011fffff] potential offnode page_structs
>> [  325.024172] [ffffea0001200000-ffffea00013fffff] potential offnode page_structs
>> [  325.028596]  [ffffea0001400000-ffffea00017fffff] PMD -> [ffff880035000000-ffff8800353fffff] on node 1
>> [  325.031775] [ffffea0001600000-ffffea00017fffff] potential offnode page_structs
>>
>> Do you have plan to do it?
> thanks for testing.
> 
> commit 5294828 from https://github.com/vliaskov/seabios/commits/memhp-v2
> implements a SLIT table for the given numa nodes.

Hmm, why do you set node_distance(i, j) to REMOTE_DISTANCE if i != j?

> 
> However I am not sure the SLIT is the problem. The kernel builds a default
> numa_distance table in arch/x86/mm/numa.c: numa_alloc_distance(). If the BIOS
> doesn't present a SLIT, this should take effect (numactl --hardware should
> report this table)

If the BIOS doesn't present a SLIT, numa_distance_cnt is set to 0 in the
function numa_reset_distance(). So node_distance(i, j) is REMOTE_DISTANCE(i != j).

> 
> Do you have more details on how to reproduce the warning? e.g. how many dimms
> are present in the system? Does this happen on the first dimm hot-plugged?
> Are all SRAT entries parsed correctly at boot-time or do you see any other
> warnings at boot-time?

I can't reproduce it again. IIRC, I only do the following things:
hotplug a memory device, online the pages, offline the pages and hot remove
the memory device.

Thanks
Wen Congyang

> 
> I 'll investigate a bit more and report back.
> 
> thanks,
> 
> - Vasilis
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
