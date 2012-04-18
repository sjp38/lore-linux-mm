Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 04C556B0083
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 03:02:05 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 0F3ED3EE0BD
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:02:04 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E4B1F45DEB5
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:02:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B4B6145DEAD
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:02:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A64D11DB8044
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:02:03 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C4711DB803C
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:02:03 +0900 (JST)
Message-ID: <4F8E665B.7050302@jp.fujitsu.com>
Date: Wed, 18 Apr 2012 15:59:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] res_counter: add a function res_counter_move_parent().
References: <4F86B9BE.8000105@jp.fujitsu.com> <4F86BA66.2010503@jp.fujitsu.com> <20120416221924.GB12421@google.com>
In-Reply-To: <20120416221924.GB12421@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

(2012/04/17 7:19), Tejun Heo wrote:

> On Thu, Apr 12, 2012 at 08:20:06PM +0900, KAMEZAWA Hiroyuki wrote:
>>
>> This function is used for moving accounting information to its
>> parent in the hierarchy of res_counter.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>>  include/linux/res_counter.h |    3 +++
>>  kernel/res_counter.c        |   13 +++++++++++++
>>  2 files changed, 16 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
>> index da81af0..8919d3c 100644
>> --- a/include/linux/res_counter.h
>> +++ b/include/linux/res_counter.h
>> @@ -135,6 +135,9 @@ int __must_check res_counter_charge_nofail(struct res_counter *counter,
>>  void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val);
>>  void res_counter_uncharge(struct res_counter *counter, unsigned long val);
>>  
>> +/* move resource to parent counter...i.e. just forget accounting in a child */
> 
> Can we drop this comment and
> 
>> +void res_counter_move_parent(struct res_counter *counter, unsigned long val);
>>  
>> +/*
>> + * In hierarchical accounting, child's usage is accounted into ancestors.
>> + * To move local usage to its parent, just forget current level usage.
>> + */
> 
> make this one proper docbook function comment?
> 

Sure. (I'll use Frederic's one.)

Thanks,
-Kame

>> +void res_counter_move_parent(struct res_counter *counter, unsigned long val)
>> +{
>> +	unsigned long flags;
>> +
>> +	BUG_ON(!counter->parent);
> 
> And let's please do "if (WARN_ON(!counter->parent)) return;" instead.
> 
> Thanks.
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
