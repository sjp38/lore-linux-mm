Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 0847F6B0044
	for <linux-mm@kvack.org>; Sun,  8 Apr 2012 21:50:34 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B01B63EE081
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 10:50:32 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 979C945DE4D
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 10:50:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B0CE45DD73
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 10:50:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BA871DB803A
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 10:50:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 270C21DB802C
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 10:50:32 +0900 (JST)
Message-ID: <4F823FFA.8000401@jp.fujitsu.com>
Date: Mon, 09 Apr 2012 10:48:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC 5/7] use percpu_counters for res_counter usage
References: <1333094685-5507-1-git-send-email-glommer@parallels.com> <1333094685-5507-6-git-send-email-glommer@parallels.com> <4F757DEB.4030006@jp.fujitsu.com> <4F7583AB.3070304@jp.fujitsu.com> <4F75BACC.7050704@parallels.com>
In-Reply-To: <4F75BACC.7050704@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Linux MM <linux-mm@kvack.org>, Pavel Emelyanov <xemul@parallels.com>

(2012/03/30 22:53), Glauber Costa wrote:

> On 03/30/2012 11:58 AM, KAMEZAWA Hiroyuki wrote:
>> ==
>>
>> Now, we do consume 'reserved' usage, we can avoid css_get(), an heavy atomic
>> ops. You may need to move this code as
>>
>> 	rcu_read_lock()
>> 	....
>> 	res_counter_charge()
>> 	if (failure) {
>> 		css_tryget()
>> 		rcu_read_unlock()
>> 	} else {
>> 		rcu_read_unlock()
>> 		return success;
>> 	}
>>
>> to compare performance. This css_get() affects performance very very much.
> 
> thanks for the tip.
> 
> But one thing:
> 
> To be sure: it effectively mean that we are drawing from a dead memcg
> (because we pre-allocated, right?

Cached stock is consumed by the current task. It blocks removal of memcg.
It's not dead.

Thanks,
-Kame

 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
