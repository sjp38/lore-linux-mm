Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 1929C6B0044
	for <linux-mm@kvack.org>; Fri, 30 Mar 2012 06:46:27 -0400 (EDT)
Message-ID: <4F758EF9.5030008@parallels.com>
Date: Fri, 30 Mar 2012 12:46:17 +0200
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/7] Initial proposal for faster res_counter updates
References: <1333094685-5507-1-git-send-email-glommer@parallels.com> <4F756F86.8030906@jp.fujitsu.com>
In-Reply-To: <4F756F86.8030906@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Linux MM <linux-mm@kvack.org>, Pavel Emelyanov <xemul@parallels.com>

 > Note: Assume a big system which has many cpus, and user wants to devide
> the system into containers. Current memcg's percpu caching is done
> only when a task in memcg is on the cpu, running. So, it's not so dangerous
> as it looks.

Agree. I actually think it is pretty
> But yes, if we can drop memcg's code, it's good. Then, we can remove some
> amount of codes.
> 
>> But the cons:
>>
>> * percpu counters have signed quantities, so this would limit us 4G.
>>    We can add a shift and then count pages instead of bytes, but we
>>    are still in the 16T area here. Maybe we really need more than that.
>>
> 
> ....
> struct percpu_counter {
>          raw_spinlock_t lock;
>          s64 count;
> 
> s64 limtes us 4G ?
>
Yes, I actually explicitly mentioned that. We can go to 16T if we track
pages
instead of bytes (I considered having the res_counter initialization code to
specify a shift, so we could be generic).

But I believe that if we go this route, we'll need to either:
1) Have our own internal implementation of what percpu counters does
2) create u64 acessors that would cast that to u64 in the operations.
Since it
     is a 64 bit field anyway it should be doable. But being doable
doesn't mean we
     should do it....
3) Have a different percpu_counter structure, something like struct
percpu_positive_counter.

> 
>> * some of the additions here may slow down the percpu_counters for
>>    users that don't care about our usage. Things about min/max tracking
>>    enter in this category.
>>
> 
> 
> I think it's not very good to increase size of percpu counter. It's already
> very big...Hm. How about
> 
> 	struct percpu_counter_lazy {
> 		struct percpu_counter pcp;
> 		extra information
> 		s64 margin;
> 	}
> ?

Can work, but we need something that also solves the signedness problem.
Maybe we can use a union for that, and then stuff things in the end of a
different
structure just for the users that want it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
