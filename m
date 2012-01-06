Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 15CB56B004D
	for <linux-mm@kvack.org>; Fri,  6 Jan 2012 04:47:19 -0500 (EST)
Message-ID: <4F06C31E.4010904@cn.fujitsu.com>
Date: Fri, 06 Jan 2012 17:47:10 +0800
From: Peng Haitao <penght@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: how to make memory.memsw.failcnt is nonzero
References: <4EFADFF8.5020703@cn.fujitsu.com> <20120103160411.GD3891@tiehlicka.suse.cz>
In-Reply-To: <20120103160411.GD3891@tiehlicka.suse.cz>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


Michal Hocko said the following on 2012-1-4 0:04:
>> # echo 15M > memory.memsw.limit_in_bytes
>> # dd if=/dev/zero of=/tmp/temp_file count=20 bs=1M
>> Killed
>> # grep "failcnt" /var/log/messages | tail -2
>> Dec 28 17:08:45 K-test kernel: memory: usage 10240kB, limit 10240kB, failcnt 86
>> Dec 28 17:08:45 K-test kernel: memory+swap: usage 10240kB, limit 15360kB, failcnt 0
>> # cat memory.memsw.failcnt
>> 0
>>
>> The limit is 15M, but memory+swap usage also is 10M.
>> I think memory+swap usage should be 15M and memsw.failcnt should be nonzero.
>>
> So there is almost 10M of page cache that we can simply reclaim. If we
> use 40M limit then we are OK. So this looks like the small limit somehow
> tricks our math in the reclaim path and we think there is nothing to
> reclaim.
> I will look into this.

Thanks for you reply.
If there is something wrong, I think the bug will be in mem_cgroup_do_charge()
of mm/memcontrol.c

2210         ret = res_counter_charge(&memcg->res, csize, &fail_res);
2211 
2212         if (likely(!ret)) {
2213                 if (!do_swap_account)
2214                         return CHARGE_OK;
2215                 ret = res_counter_charge(&memcg->memsw, csize, &fail_res);
2216                 if (likely(!ret))
2217                         return CHARGE_OK;
2218 
2219                 res_counter_uncharge(&memcg->res, csize);
2220                 mem_over_limit = mem_cgroup_from_res_counter(fail_res, memsw);
2221                 flags |= MEM_CGROUP_RECLAIM_NOSWAP;
2222         } else
2223                 mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);

When hit memory.limit_in_bytes, res_counter_charge() will return -ENOMEM,
this will execute line 2222: } else.
But I think when hit memory.limit_in_bytes, the function should determine further
to memory.memsw.limit_in_bytes.
This think is OK?

-- 
Best Regards,
Peng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
