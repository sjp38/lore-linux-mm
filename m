Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 426466B01B0
	for <linux-mm@kvack.org>; Tue, 25 May 2010 01:06:00 -0400 (EDT)
Message-ID: <4BFB5AAE.1060609@linux.intel.com>
Date: Tue, 25 May 2010 13:05:50 +0800
From: Haicheng Li <haicheng.li@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] cpu_up: hold zonelists_mutex when build_all_zonelists
References: <201005192322.o4JNMu5v012158@imap1.linux-foundation.org>	<4BF4AB24.7070107@linux.intel.com> <20100521130808.919ecb35.akpm@linux-foundation.org>
In-Reply-To: <20100521130808.919ecb35.akpm@linux-foundation.org>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, andi.kleen@intel.com, cl@linux-foundation.org, fengguang.wu@intel.com, mel@csn.ul.ie, tj@kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, minskey guo <chaohong.guo@intel.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 20 May 2010 11:23:16 +0800
> Haicheng Li <haicheng.li@linux.intel.com> wrote:
> 
>> Here is another issue, we should always hold zonelists_mutex when calling build_all_zonelists
>> unless system_state == SYSTEM_BOOTING.
> 
> Taking a global mutex in the cpu-hotplug code is worrisome.  Perhaps
> because of the two years spent weeding out strange deadlocks between
> cpu-hotplug and cpufreq.
> 
> Has this change been carefully and fully tested with lockdep enabled
> (please)?
Yes, Andrew. I've tested it with lockdep enabled, and there was *no*
issue found for this change in my testing.

My test box: CPUs on node 1~3 are all offlined (16 cpus per node).
Here are my test steps:
on tty0:
# cd /sys/devices/system/node/node1
# for i in cpu*; do echo 1 > $i/online; done

on tty1:
# cd /sys/devices/system/node/node2
# for i in cpu*; do echo 1 > $i/online; done

on tty2:
# cd /sys/devices/system/node/node3
# for i in cpu*; do echo 1 > $i/online; done

on tty3:
# cat zonelist

	#! /bin/bash
	set -x
	while ((1)); do
		echo n > /proc/sys/vm/numa_zonelist_order
		sleep 10
		echo z > /proc/sys/vm/numa_zonelist_order
		sleep 10
	done

# ./zonelist

Besides, I also ran some cpu online/offline tests from LTP/cpu_hotplug test suites.
They worked fine too.

>> --- a/kernel/cpu.c
>> +++ b/kernel/cpu.c
>> @@ -357,8 +357,11 @@ int __cpuinit cpu_up(unsigned int cpu)
>>                  return -ENOMEM;
>>          }
>>
>> -       if (pgdat->node_zonelists->_zonerefs->zone == NULL)
>> +       if (pgdat->node_zonelists->_zonerefs->zone == NULL) {
>> +               mutex_lock(&zonelists_mutex);
>>                  build_all_zonelists(NULL);
>> +               mutex_unlock(&zonelists_mutex);
>> +       }
> 
> Your email client is performing space-stuffing and it replaces tabs
> with spaces.  This requires me to edit the patches rather a lot,
> which is dull.

Really sorry for the inconvenience to you. I'll pay more attention
next time. thank you!

-haicheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
