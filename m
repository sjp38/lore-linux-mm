Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 3927B6B004D
	for <linux-mm@kvack.org>; Sun, 29 Jan 2012 21:34:50 -0500 (EST)
Message-ID: <4F2601C9.6000606@cn.fujitsu.com>
Date: Mon, 30 Jan 2012 10:34:49 +0800
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
> On Wed 28-12-11 17:23:04, Peng Haitao wrote:
>>
>> memory.memsw.failcnt shows the number of memory+Swap hits limits.
>> So I think when memory+swap usage is equal to limit, memsw.failcnt should be nonzero.
>>
>> I test as follows:
>>
>> # uname -a
>> Linux K-test 3.2.0-rc7-17-g371de6e #2 SMP Wed Dec 28 12:02:52 CST 2011 x86_64 x86_64 x86_64 GNU/Linux
>> # mkdir /cgroup/memory/group
>> # cd /cgroup/memory/group/
>> # echo 10M > memory.limit_in_bytes
>> # echo 10M > memory.memsw.limit_in_bytes
>> # echo $$ > tasks
>> # dd if=/dev/zero of=/tmp/temp_file count=20 bs=1M
>> Killed
>> # cat memory.memsw.failcnt
>> 0
>> # grep "failcnt" /var/log/messages | tail -2
>> Dec 28 17:05:52 K-test kernel: memory: usage 10240kB, limit 10240kB, failcnt 21
>> Dec 28 17:05:52 K-test kernel: memory+swap: usage 10240kB, limit 10240kB, failcnt 0
>>
>> memory+swap usage is equal to limit, but memsw.failcnt is zero.
>>
> Please note that memsw.limit_in_bytes is triggered only if we have
> consumed some swap space already (and the feature is primarily intended
> to stop extensive swap usage in fact).
> It goes like this: If we trigger hard limit (memory.limit_in_bytes) then
> we start the direct reclaim (with swap available). If we trigger memsw
> limit then we try to reclaim without swap available. We will OOM if we
> cannot reclaim enough to satisfy the respective limit.
> 
> The other part of the answer is, yes there is something wrong going
> on her because we definitely shouldn't OOM. The workload is a single
> threaded and we have a plenty of page cache that could be reclaimed
> easily. On the other hand we end up with:
> # echo $$ > tasks 
> /dev/memctl/a# echo 10M > memory.limit_in_bytes 
> /dev/memctl/a# echo 10M > memory.memsw.limit_in_bytes 
> /dev/memctl/a# dd if=/dev/zero of=/tmp/temp_file count=20 bs=1M
> Killed
> /dev/memctl/a# cat memory.stat 
> cache 9265152
> [...]
> 
> So there is almost 10M of page cache that we can simply reclaim. If we
> use 40M limit then we are OK. So this looks like the small limit somehow
> tricks our math in the reclaim path and we think there is nothing to
> reclaim.
> I will look into this.

Have any conclusion for this?
Thanks.

-- 
Best Regards,
Peng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
