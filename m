Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id C3A546B00E7
	for <linux-mm@kvack.org>; Sun, 13 May 2012 21:09:34 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 84EE33EE0C3
	for <linux-mm@kvack.org>; Mon, 14 May 2012 10:09:32 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D59045DEB6
	for <linux-mm@kvack.org>; Mon, 14 May 2012 10:09:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 340BD45DEB4
	for <linux-mm@kvack.org>; Mon, 14 May 2012 10:09:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 22B291DB803F
	for <linux-mm@kvack.org>; Mon, 14 May 2012 10:09:32 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C0203E18004
	for <linux-mm@kvack.org>; Mon, 14 May 2012 10:09:31 +0900 (JST)
Message-ID: <4FB05AD6.1090400@jp.fujitsu.com>
Date: Mon, 14 May 2012 10:07:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 1/6] memcg: fix error code in hugetlb_force_memcg_empty()
References: <4FACDED0.3020400@jp.fujitsu.com> <4FACDFAE.5050808@jp.fujitsu.com> <20120511141754.e0719c26.akpm@linux-foundation.org>
In-Reply-To: <20120511141754.e0719c26.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

(2012/05/12 6:17), Andrew Morton wrote:

> On Fri, 11 May 2012 18:45:18 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
>> The conditions are handled as -EBUSY, _now_.
> 
> The changelog is poor.  I rewrote it to
> 
> : hugetlb_force_memcg_empty() incorrectly returns 0 (success) when the
> : cgroup is found to be busy.  Return -EBUSY instead.
> 
> But it still doesn't tell us the end-user-visible effects of the bug. 
> It should.
> 


Ah, sorry. How about this ?



The force_empty interface allows to make the memcg only when the cgroup
doesn't include any tasks.

	# echo 0 > /cgroup/xxxx/memory.force_empty

If cgroup isn't empty, force_empty does nothing and retruns -EBUSY in usual
memcg, memcontrol.c. But hugetlb implementation has inconsitency with
it and returns 0 and do nothing. Fix it to return -EBUSY.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
