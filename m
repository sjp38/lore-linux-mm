Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id A96476B012A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 01:37:56 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4EE383EE0C1
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 14:37:55 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3514845DE4D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 14:37:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 00B4F45DD74
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 14:37:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E2D831DB803F
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 14:37:54 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9269F1DB802C
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 14:37:54 +0900 (JST)
Message-ID: <4FE94A26.5030706@jp.fujitsu.com>
Date: Tue, 26 Jun 2012 14:35:34 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 11/11] protect architectures where THREAD_SIZE >= PAGE_SIZE
 against fork bombs
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <1340633728-12785-12-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206252157000.30072@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206252157000.30072@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@redhat.com>

(2012/06/26 13:57), David Rientjes wrote:
> On Mon, 25 Jun 2012, Glauber Costa wrote:
>
>> diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
>> index ccc1899..914ec07 100644
>> --- a/include/linux/thread_info.h
>> +++ b/include/linux/thread_info.h
>> @@ -61,6 +61,12 @@ extern long do_no_restart_syscall(struct restart_block *parm);
>>   # define THREADINFO_GFP		(GFP_KERNEL | __GFP_NOTRACK)
>>   #endif
>>
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> +# define THREADINFO_GFP_ACCOUNTED (THREADINFO_GFP | __GFP_KMEMCG)
>> +#else
>> +# define THREADINFO_GFP_ACCOUNTED (THREADINFO_GFP)
>> +#endif
>> +
>
> This type of requirement is going to become nasty very quickly if nobody
> can use __GFP_KMEMCG without testing for CONFIG_CGROUP_MEM_RES_CTLR_KMEM.
> Perhaps define __GFP_KMEMCG to be 0x0 if it's not enabled, similar to how
> kmemcheck does?

I agree.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
