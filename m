Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 0BB366B0068
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 04:57:43 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 419D63EE0BD
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 17:57:42 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 296A445DE50
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 17:57:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 100D145DE52
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 17:57:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EF210EF8007
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 17:57:41 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A35A81DB803A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 17:57:41 +0900 (JST)
Message-ID: <4FEC1C06.70802@jp.fujitsu.com>
Date: Thu, 28 Jun 2012 17:55:34 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [rfc][patch 3/3] mm, memcg: introduce own oom handler to iterate
 only over its own threads
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com> <alpine.DEB.2.00.1206251847180.24838@chino.kir.corp.google.com> <4FE94968.6010500@jp.fujitsu.com> <alpine.DEB.2.00.1206261323260.8673@chino.kir.corp.google.com> <alpine.DEB.2.00.1206262229380.32567@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206262229380.32567@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

(2012/06/27 14:35), David Rientjes wrote:
> On Tue, 26 Jun 2012, David Rientjes wrote:
>
>> It's still not a perfect solution for the above reason.  We need
>> tasklist_lock for oom_kill_process() for a few reasons:
>>
>>   (1) if /proc/sys/vm/oom_dump_tasks is enabled, which is the default,
>>       to iterate the tasklist
>>
>>   (2) to iterate the selected process's children, and
>>
>>   (3) to iterate the tasklist to kill all other processes sharing the
>>       same memory.
>>
>> I'm hoping we can avoid taking tasklist_lock entirely for memcg ooms to
>> avoid the starvation problem at all.  We definitely still need to do (3)
>> to avoid mm->mmap_sem deadlock if another thread sharing the same memory
>> is holding the semaphore trying to allocate memory and waiting for current
>> to exit, which needs the semaphore itself.  That can be done with
>> rcu_read_lock(), however, and doesn't require tasklist_lock.
>>
>> (1) can be done with rcu_read_lock() as well but I'm wondering if there
>> would be a significant advantage doing this by a cgroup iterator as well.
>> It may not be worth it just for the sanity of the code.
>>
>> We can do (2) if we change to list_for_each_entry_rcu().
>>
>
> It turns out that task->children is not an rcu-protected list so this
> doesn't work.

Can't we use sighand->lock to iterate children ?


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
