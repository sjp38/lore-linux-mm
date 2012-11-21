Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 340076B0080
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 20:02:58 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A28763EE0B6
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 10:02:54 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8578845DE60
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 10:02:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A62A45DE5B
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 10:02:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A1DB1DB8044
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 10:02:54 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 103D31DB802C
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 10:02:54 +0900 (JST)
Message-ID: <50AC282A.4070309@jp.fujitsu.com>
Date: Wed, 21 Nov 2012 10:02:34 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, memcg: avoid unnecessary function call when memcg
 is disabled
References: <alpine.DEB.2.00.1211191741060.24618@chino.kir.corp.google.com> <20121120134932.055bc192.akpm@linux-foundation.org>
In-Reply-To: <20121120134932.055bc192.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

(2012/11/21 6:49), Andrew Morton wrote:
> On Mon, 19 Nov 2012 17:44:34 -0800 (PST)
> David Rientjes <rientjes@google.com> wrote:
>
>> While profiling numa/core v16 with cgroup_disable=memory on the command
>> line, I noticed mem_cgroup_count_vm_event() still showed up as high as
>> 0.60% in perftop.
>>
>> This occurs because the function is called extremely often even when memcg
>> is disabled.
>>
>> To fix this, inline the check for mem_cgroup_disabled() so we avoid the
>> unnecessary function call if memcg is disabled.
>>
>> ...
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -181,7 +181,14 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>>   						gfp_t gfp_mask,
>>   						unsigned long *total_scanned);
>>
>> -void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
>> +void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
>> +static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
>> +					     enum vm_event_item idx)
>> +{
>> +	if (mem_cgroup_disabled() || !mm)
>> +		return;
>> +	__mem_cgroup_count_vm_event(mm, idx);
>> +}
>
> Does the !mm case occur frequently enough to justify inlining it, or
> should that test remain out-of-line?
>
I think this should be out-of-line.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
