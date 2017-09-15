Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8402E6B0038
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 13:31:30 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id u48so3335144qtc.3
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 10:31:30 -0700 (PDT)
Received: from rcdn-iport-1.cisco.com (rcdn-iport-1.cisco.com. [173.37.86.72])
        by mx.google.com with ESMTPS id l40si1450193qta.160.2017.09.15.10.31.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Sep 2017 10:31:29 -0700 (PDT)
Subject: Re: Detecting page cache trashing state
References: <150543458765.3781.10192373650821598320@takondra-t460s>
 <a5232e66-e05a-e89c-a7ba-2d3572b609d9@cisco.com>
 <150549350270.4512.4357187826510021894@takondra-t460s>
From: Daniel Walker <danielwa@cisco.com>
Message-ID: <35118dbb-6a03-aa84-a005-aafa4b9929c7@cisco.com>
Date: Fri, 15 Sep 2017 10:31:27 -0700
MIME-Version: 1.0
In-Reply-To: <150549350270.4512.4357187826510021894@takondra-t460s>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Taras Kondratiuk <takondra@cisco.com>, linux-mm@kvack.org
Cc: xe-linux-external@cisco.com, Ruslan Ruslichenko <rruslich@cisco.com>, linux-kernel@vger.kernel.org

On 09/15/2017 09:38 AM, Taras Kondratiuk wrote:
> Quoting Daniel Walker (2017-09-15 07:22:27)
>> On 09/14/2017 05:16 PM, Taras Kondratiuk wrote:
>>> Hi
>>>
>>> In our devices under low memory conditions we often get into a trashing
>>> state when system spends most of the time re-reading pages of .text
>>> sections from a file system (squashfs in our case). Working set doesn't
>>> fit into available page cache, so it is expected. The issue is that
>>> OOM killer doesn't get triggered because there is still memory for
>>> reclaiming. System may stuck in this state for a quite some time and
>>> usually dies because of watchdogs.
>>>
>>> We are trying to detect such trashing state early to take some
>>> preventive actions. It should be a pretty common issue, but for now we
>>> haven't find any existing VM/IO statistics that can reliably detect such
>>> state.
>>>
>>> Most of metrics provide absolute values: number/rate of page faults,
>>> rate of IO operations, number of stolen pages, etc. For a specific
>>> device configuration we can determine threshold values for those
>>> parameters that will detect trashing state, but it is not feasible for
>>> hundreds of device configurations.
>>>
>>> We are looking for some relative metric like "percent of CPU time spent
>>> handling major page faults". With such relative metric we could use a
>>> common threshold across all devices. For now we have added such metric
>>> to /proc/stat in our kernel, but we would like to find some mechanism
>>> available in upstream kernel.
>>>
>>> Has somebody faced similar issue? How are you solving it?
>>
>> Did you make any attempt to tune swappiness ?
>>
>> Documentation/sysctl/vm.txt
>>
>> swappiness
>>
>> This control is used to define how aggressive the kernel will swap
>> memory pages.  Higher values will increase agressiveness, lower values
>> decrease the amount of swap.
>>
>> The default value is 60.
>> =======================================================
>>
>> Since your using squashfs I would guess that's going to act like swap.
>> The default tune of 60 is most likely for x86 servers which may not be a
>> good value for some other device.
> Swap is disabled in our systems, so anonymous pages can't be evicted.
> As per my understanding swappiness tune is irrelevant.
>
> Even with enabled swap swappiness tune can't help much in this case. If
> working set doesn't fit into available page cache we will hit the same
> trashing state.


I think it's our lack of understanding of how the VM works. If the 
system has no swap, then the system shouldn't start evicting pages 
unless you have %100 memory utilization, then the only place for those 
pages to go is back into the backing store, squashfs in this case.

What your suggesting is that there is still free memory, which means 
something must be evicting page more aggressively then waiting till %100 
utilization. Maybe someone more knownlegable about the VM subsystem can 
clear this up.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
