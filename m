Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA7116B000E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 07:19:30 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id x186-v6so9574670qkb.0
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 04:19:30 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d36-v6si976398qtk.281.2018.06.07.04.19.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 04:19:29 -0700 (PDT)
Subject: Re: [4.17 regression] Performance drop on kernel-4.17 visible on
 Stream, Linpack and NAS parallel benchmarks
References: <20180606122731.GB27707@jra-laptop.brq.redhat.com>
 <20180607110713.GJ32433@dhcp22.suse.cz>
From: =?UTF-8?Q?Jakub_Ra=c4=8dek?= <jracek@redhat.com>
Message-ID: <cd26794b-cb82-919c-053d-9bcb6e3d78d8@redhat.com>
Date: Thu, 7 Jun 2018 13:19:26 +0200
MIME-Version: 1.0
In-Reply-To: <20180607110713.GJ32433@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, linux-acpi@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

Hi,

On 06/07/2018 01:07 PM, Michal Hocko wrote:
> [CCing Mel and MM mailing list]
> 
> On Wed 06-06-18 14:27:32, Jakub Racek wrote:
>> Hi,
>>
>> There is a huge performance regression on the 2 and 4 NUMA node systems on
>> stream benchmark with 4.17 kernel compared to 4.16 kernel. Stream, Linpack
>> and NAS parallel benchmarks show upto 50% performance drop.
>>
>> When running for example 20 stream processes in parallel, we see the following behavior:
>>
>> * all processes are started at NODE #1
>> * memory is also allocated on NODE #1
>> * roughly half of the processes are moved to the NODE #0 very quickly. *
>> however, memory is not moved to NODE #0 and stays allocated on NODE #1
>>
>> As the result, half of the processes are running on NODE#0 with memory being
>> still allocated on NODE#1. This leads to non-local memory accesses
>> on the high Remote-To-Local Memory Access Ratio on the numatop charts.
>>
>> So it seems that 4.17 is not doing a good job to move the memory to the right NUMA
>> node after the process has been moved.
>>
>> ----8<----
>>
>> The above is an excerpt from performance testing on 4.16 and 4.17 kernels.
>>
>> For now I'm merely making sure the problem is reported.
> 
> Do you have numa balancing enabled?
> 

Yes. The relevant settings are:

kernel.numa_balancing = 1
kernel.numa_balancing_scan_delay_ms = 1000
kernel.numa_balancing_scan_period_max_ms = 60000
kernel.numa_balancing_scan_period_min_ms = 1000
kernel.numa_balancing_scan_size_mb = 256


-- 
Best regards,
Jakub Racek
FMK
