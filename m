Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 60CDE6B0083
	for <linux-mm@kvack.org>; Mon, 14 May 2012 21:12:38 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B27E13EE0C3
	for <linux-mm@kvack.org>; Tue, 15 May 2012 10:12:36 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CF2645DEB3
	for <linux-mm@kvack.org>; Tue, 15 May 2012 10:12:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 80DDC45DE7E
	for <linux-mm@kvack.org>; Tue, 15 May 2012 10:12:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FFEB1DB803B
	for <linux-mm@kvack.org>; Tue, 15 May 2012 10:12:36 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DA2601DB8040
	for <linux-mm@kvack.org>; Tue, 15 May 2012 10:12:35 +0900 (JST)
Message-ID: <4FB1AD0A.50901@jp.fujitsu.com>
Date: Tue, 15 May 2012 10:10:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 1/6] memcg: fix error code in hugetlb_force_memcg_empty()
References: <4FACDED0.3020400@jp.fujitsu.com> <4FACDFAE.5050808@jp.fujitsu.com> <20120514181556.GE2366@google.com> <20120514183219.GG2366@google.com>
In-Reply-To: <20120514183219.GG2366@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

(2012/05/15 3:32), Tejun Heo wrote:

> On Mon, May 14, 2012 at 11:15:56AM -0700, Tejun Heo wrote:
>> On Fri, May 11, 2012 at 06:45:18PM +0900, KAMEZAWA Hiroyuki wrote:
>>> -		if (cgroup_task_count(cgroup) || !list_empty(&cgroup->children))
>>> +		if (cgroup_task_count(cgroup)
>>> +			|| !list_empty(&cgroup->children)) {
>>> +			ret = -EBUSY;
>>>  			goto out;
>>
>> Why break the line?  It doesn't go over 80 col.
> 
> Ooh, it does.  Sorry, my bad.  But still, isn't it more usual to leave
> the operator in the preceding line and align the start of the second
> line with the first?  ie.
> 
> 		if (cgroup_task_count(cgroup) ||
> 		    !list_empty(&cgroup->children)) {
> 


How about this ?
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 27 Apr 2012 13:19:19 +0900
Subject: [PATCH] memcg: fix error code in hugetlb_force_memcg_empty()

Changelog:
 - clean up.
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/hugetlb.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1d3c8ea9..82ec623 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1922,8 +1922,11 @@ int hugetlb_force_memcg_empty(struct cgroup *cgroup)
 	int ret = 0, idx = 0;
 
 	do {
-		if (cgroup_task_count(cgroup) || !list_empty(&cgroup->children))
+		if (cgroup_task_count(cgroup) ||
+		    !list_empty(&cgroup->children)){
+			ret = -EBUSY;
 			goto out;
+		}
 		/*
 		 * If the task doing the cgroup_rmdir got a signal
 		 * we don't really need to loop till the hugetlb resource
-- 
1.7.4.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
