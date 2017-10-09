Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 676E86B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 02:35:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e26so42088390pfd.4
        for <linux-mm@kvack.org>; Sun, 08 Oct 2017 23:35:54 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id l20si1951067pli.773.2017.10.08.23.35.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Oct 2017 23:35:53 -0700 (PDT)
Subject: Re: [PATCH v3] mm, sysctl: make NUMA stats configurable
References: <1506579101-5457-1-git-send-email-kemi.wang@intel.com>
 <20171003092352.2wh2jbtt2dudfi5a@dhcp22.suse.cz>
From: kemi <kemi.wang@intel.com>
Message-ID: <221a1e93-ee33-d598-67de-d6071f192040@intel.com>
Date: Mon, 9 Oct 2017 14:34:11 +0800
MIME-Version: 1.0
In-Reply-To: <20171003092352.2wh2jbtt2dudfi5a@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Dave <dave.hansen@linux.intel.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>



On 2017a1'10ae??03ae?JPY 17:23, Michal Hocko wrote:
> On Thu 28-09-17 14:11:41, Kemi Wang wrote:
>> This is the second step which introduces a tunable interface that allow
>> numa stats configurable for optimizing zone_statistics(), as suggested by
>> Dave Hansen and Ying Huang.
>>
>> =========================================================================
>> When page allocation performance becomes a bottleneck and you can tolerate
>> some possible tool breakage and decreased numa counter precision, you can
>> do:
>> 	echo [C|c]oarse > /proc/sys/vm/numa_stats_mode
>> In this case, numa counter update is ignored. We can see about
>> *4.8%*(185->176) drop of cpu cycles per single page allocation and reclaim
>> on Jesper's page_bench01 (single thread) and *8.1%*(343->315) drop of cpu
>> cycles per single page allocation and reclaim on Jesper's page_bench03 (88
>> threads) running on a 2-Socket Broadwell-based server (88 threads, 126G
>> memory).
>>
>> Benchmark link provided by Jesper D Brouer(increase loop times to
>> 10000000):
>> https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm/
>> bench
>>
>> =========================================================================
>> When page allocation performance is not a bottleneck and you want all
>> tooling to work, you can do:
>> 	echo [S|s]trict > /proc/sys/vm/numa_stats_mode
>>
>> =========================================================================
>> We recommend automatic detection of numa statistics by system, this is also
>> system default configuration, you can do:
>> 	echo [A|a]uto > /proc/sys/vm/numa_stats_mode
>> In this case, numa counter update is skipped unless it has been read by
>> users at least once, e.g. cat /proc/zoneinfo.
> 
> I am still not convinced the auto mode is worth all the additional code
> and a safe default to use. The whole thing could have been 0/1 with a
> simpler parsing and less code to catch readers.
> 

I understood your concern. 
Well, we may get rid of auto mode if there is some obvious disadvantage
here. Now, I tend to keep it because most people may not touch this interface,
and auto mode is helpful in such case.

> E.g. why do we have to do static_branch_enable on any read or even
> vmstat_stop? Wouldn't open be sufficient?
> 

NUMA stats is used in four files:
/proc/zoneinfo
/proc/vmstat
/sys/devices/system/node/node*/numastat
/sys/devices/system/node/node*/vmstat
In auto mode, each *read* will trigger the update of NUMA counter. 
So, we should make sure the target branch is jumped to the branch 
for NUMA counter update once the file is read from user space.
the intension of static_branch_enable in vmstat_stop(in the call site 
of file->file_ops.read) is for reading /proc/vmstat in case.  

I guess the *open* means file->file_op.open here, right?
Do you suggest to move static_branch_enable to file->file_op.open? Thanks.

>> @@ -153,6 +153,8 @@ static DEVICE_ATTR(meminfo, S_IRUGO, node_read_meminfo, NULL);
>>  static ssize_t node_read_numastat(struct device *dev,
>>  				struct device_attribute *attr, char *buf)
>>  {
>> +	if (vm_numa_stats_mode == VM_NUMA_STAT_AUTO_MODE)
>> +		static_branch_enable(&vm_numa_stats_mode_key);
>>  	return sprintf(buf,
>>  		       "numa_hit %lu\n"
>>  		       "numa_miss %lu\n"
>> @@ -186,6 +188,8 @@ static ssize_t node_read_vmstat(struct device *dev,
>>  		n += sprintf(buf+n, "%s %lu\n",
>>  			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
>>  			     sum_zone_numa_state(nid, i));
>> +	if (vm_numa_stats_mode == VM_NUMA_STAT_AUTO_MODE)
>> +		static_branch_enable(&vm_numa_stats_mode_key);
>>  #endif
>>  
>>  	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
> [...]
>> @@ -1582,6 +1703,10 @@ static int zoneinfo_show(struct seq_file *m, void *arg)
>>  {
>>  	pg_data_t *pgdat = (pg_data_t *)arg;
>>  	walk_zones_in_node(m, pgdat, false, false, zoneinfo_show_print);
>> +#ifdef CONFIG_NUMA
>> +	if (vm_numa_stats_mode == VM_NUMA_STAT_AUTO_MODE)
>> +		static_branch_enable(&vm_numa_stats_mode_key);
>> +#endif
>>  	return 0;
>>  }
>>  
>> @@ -1678,6 +1803,10 @@ static int vmstat_show(struct seq_file *m, void *arg)
>>  
>>  static void vmstat_stop(struct seq_file *m, void *arg)
>>  {
>> +#ifdef CONFIG_NUMA
>> +	if (vm_numa_stats_mode == VM_NUMA_STAT_AUTO_MODE)
>> +		static_branch_enable(&vm_numa_stats_mode_key);
>> +#endif
>>  	kfree(m->private);
>>  	m->private = NULL;
>>  }
>> -- 
>> 2.7.4
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
