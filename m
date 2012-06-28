Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 15FAD6B0068
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 04:36:12 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2CE613EE0B6
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 17:36:11 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BE3F45DE5C
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 17:36:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E266845DE55
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 17:36:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D0E461DB8057
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 17:36:10 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 87D271DB804D
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 17:36:10 +0900 (JST)
Message-ID: <4FEC16EF.40408@jp.fujitsu.com>
Date: Thu, 28 Jun 2012 17:33:51 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3][0/6] memcg: prevent -ENOMEM in pre_destroy()
References: <4FACDED0.3020400@jp.fujitsu.com> <20120621202043.GD4642@google.com> <4FE3ADDD.9060908@jp.fujitsu.com> <20120627175818.GM15811@google.com>
In-Reply-To: <20120627175818.GM15811@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

(2012/06/28 2:58), Tejun Heo wrote:
> Hello, KAME.
>
> On Fri, Jun 22, 2012 at 08:27:25AM +0900, Kamezawa Hiroyuki wrote:
>> Remaining 20% of work is based on a modification to cgroup layer
>>
>> How do you think this patch ? (This patch is not tested yet...so
>> may have troubles...) I think callers of pre_destory() is not so many...
>>
>> ==
>>  From a28db946f91f3509d25779e8c5db249506cc4b07 Mon Sep 17 00:00:00 2001
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Date: Fri, 22 Jun 2012 08:38:38 +0900
>> Subject: [PATCH] cgroup: keep cgroup_mutex() while calling ->pre_destroy()
>>
>> In past, memcg's pre_destroy() was verrry slow because of the possibility
>> of page reclaiming in it. So, cgroup_mutex() was released before calling
>> pre_destroy() callbacks. Now, it's enough fast. memcg just scans the list
>> and move pages to other cgroup, no memory reclaim happens.
>> Then, we can keep cgroup_mutex() there.
>>
>> By holding looks, we can avoid following cases
>>     1. new task is attached while rmdir().
>>     2. new child cgroup is created while rmdir()
>>     3. new task is attached to cgroup and removed from cgroup before
>>        checking css's count. So, ->destroy() will be called even if
>>        some trashes by the task remains
>>
>> (3. is terrible case...even if I think it will not happen in real world..)
>
> Ooh, once memcg drops the __DEPRECATED_clear_css_refs, cgroup_rmdir()
> will mark the cgroup dead before start calling pre_destroy() and none
> of the above will happen.
>

Hm, threads which touches memcg should hold memcg's reference count rather than css.
Right ? IIUC, one of reason is a reference from kswapd etc...hm. I'll check it.

Thanks,
-Kame










--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
