Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 39EA76B0253
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 04:05:28 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i196so931895pgd.2
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 01:05:28 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id h70si5505058pfd.491.2017.10.17.01.05.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Oct 2017 01:05:27 -0700 (PDT)
Subject: Re: [PATCH v4] mm, sysctl: make NUMA stats configurable
References: <1508203258-9444-1-git-send-email-kemi.wang@intel.com>
 <20171017075420.dege7aabzau5wrss@dhcp22.suse.cz>
From: kemi <kemi.wang@intel.com>
Message-ID: <7103ce83-358e-2dfb-7880-ac2faea158f1@intel.com>
Date: Tue, 17 Oct 2017 16:03:44 +0800
MIME-Version: 1.0
In-Reply-To: <20171017075420.dege7aabzau5wrss@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave <dave.hansen@linux.intel.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>



On 2017a1'10ae??17ae?JPY 15:54, Michal Hocko wrote:
> On Tue 17-10-17 09:20:58, Kemi Wang wrote:
> [...]
> 
> Other than two remarks below, it looks good to me and it also looks
> simpler.
> 
>> diff --git a/mm/vmstat.c b/mm/vmstat.c
>> index 4bb13e7..e746ed1 100644
>> --- a/mm/vmstat.c
>> +++ b/mm/vmstat.c
>> @@ -32,6 +32,76 @@
>>  
>>  #define NUMA_STATS_THRESHOLD (U16_MAX - 2)
>>  
>> +#ifdef CONFIG_NUMA
>> +int sysctl_vm_numa_stat = ENABLE_NUMA_STAT;
>> +static DEFINE_MUTEX(vm_numa_stat_lock);
> 
> You can scope this mutex to the sysctl handler function
> 

OK, thanks.

>> +int sysctl_vm_numa_stat_handler(struct ctl_table *table, int write,
>> +		void __user *buffer, size_t *length, loff_t *ppos)
>> +{
>> +	int ret, oldval;
>> +
>> +	mutex_lock(&vm_numa_stat_lock);
>> +	if (write)
>> +		oldval = sysctl_vm_numa_stat;
>> +	ret = proc_dointvec(table, write, buffer, length, ppos);
>> +	if (ret || !write)
>> +		goto out;
>> +
>> +	if (oldval == sysctl_vm_numa_stat)
>> +		goto out;
>> +	else if (oldval == DISABLE_NUMA_STAT) {
> 
> So basically any value will enable numa stats. This means that we would
> never be able to extend this interface to e.g. auto mode (say value 2).
> I guess you meant to check sysctl_vm_numa_stat == ENABLE_NUMA_STAT?
> 

I meant to make it more general other than ENABLE_NUMA_STAT(non 0 is enough), 
but it will make it hard to scale, as you said.
So, it would be like this:
0 -- disable
1 -- enable
other value is invalid.

May add option 2 later for auto if necessary:)

>> +		static_branch_enable(&vm_numa_stat_key);
>> +		pr_info("enable numa statistics\n");
>> +	} else if (sysctl_vm_numa_stat == DISABLE_NUMA_STAT) {
>> +		static_branch_disable(&vm_numa_stat_key);
>> +		invalid_numa_statistics();
>> +		pr_info("disable numa statistics, and clear numa counters\n");
>> +	}
>> +
>> +out:
>> +	mutex_unlock(&vm_numa_stat_lock);
>> +	return ret;
>> +}
>> +#endif
>> +
>>  #ifdef CONFIG_VM_EVENT_COUNTERS
>>  DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
>>  EXPORT_PER_CPU_SYMBOL(vm_event_states);
>> -- 
>> 2.7.4
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
