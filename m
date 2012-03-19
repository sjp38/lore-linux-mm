Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id A29F06B004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 03:35:57 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2F71D3EE0BD
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 16:35:56 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1595E45DE52
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 16:35:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F3FC245DE4D
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 16:35:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E556A1DB803A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 16:35:55 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E2D91DB8040
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 16:35:55 +0900 (JST)
Message-ID: <4F66E169.5000909@jp.fujitsu.com>
Date: Mon, 19 Mar 2012 16:34:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V4 07/10] hugetlbfs: Add memcg control files for hugetlbfs
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331919570-2264-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4F66A059.20801@jp.fujitsu.com> <87wr6hjc58.fsf@linux.vnet.ibm.com>
In-Reply-To: <87wr6hjc58.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>

(2012/03/19 16:14), Aneesh Kumar K.V wrote:

> On Mon, 19 Mar 2012 11:56:25 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> (2012/03/17 2:39), Aneesh Kumar K.V wrote:
>>
>>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>>>
>>> This add control files for hugetlbfs in memcg
>>>
>>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>>
>>
>> I have a question. When a user does
>>
>> 	1. create memory cgroup as
>> 		/cgroup/A
>> 	2. insmod hugetlb.ko
>> 	3. ls /cgroup/A
>>
>> and then, files can be shown ? Don't we have any problem at rmdir A ?
>>
>> I'm sorry if hugetlb never be used as module.
> 
> HUGETLBFS cannot be build as kernel module
> 
> 
>>
>> a comment below.
>>
>>> ---
>>>  include/linux/hugetlb.h    |   17 +++++++++++++++
>>>  include/linux/memcontrol.h |    7 ++++++
>>>  mm/hugetlb.c               |   25 ++++++++++++++++++++++-
>>>  mm/memcontrol.c            |   48 ++++++++++++++++++++++++++++++++++++++++++++
>>>  4 files changed, 96 insertions(+), 1 deletions(-)
> 
> 
> ......
> 
>>>
>>> +#ifdef CONFIG_MEM_RES_CTLR_HUGETLB
>>> +static char *mem_fmt(char *buf, unsigned long n)
>>> +{
>>> +	if (n >= (1UL << 30))
>>> +		sprintf(buf, "%luGB", n >> 30);
>>> +	else if (n >= (1UL << 20))
>>> +		sprintf(buf, "%luMB", n >> 20);
>>> +	else
>>> +		sprintf(buf, "%luKB", n >> 10);
>>> +	return buf;
>>> +}
>>> +
>>> +int mem_cgroup_hugetlb_file_init(int idx)
>>> +{
>>
>>
>> __init ? 
> 
> Added .
> 
>> And... do we have guarantee that this function is called before
>> creating root mem cgroup even if CONFIG_HUGETLBFS=y ?
>>
> 
> Yes. This should be called before creating root mem cgroup.
> 


O.K. BTW, please read Tejun's recent post..
 
https://lkml.org/lkml/2012/3/16/522

Can you use his methods ?

I guess you can write...

CGROUP_SUBSYS_CFTYLES_COND(mem_cgroup_subsys,
			hugetlb_cgroup_files,
			if XXXXMB hugetlb is allowed);

Hmm.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
