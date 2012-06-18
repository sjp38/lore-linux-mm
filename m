Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id AC7ED6B0072
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 08:13:01 -0400 (EDT)
Message-ID: <4FDF1AAE.4080209@parallels.com>
Date: Mon, 18 Jun 2012 16:10:22 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 05/25] memcg: Always free struct memcg through schedule_work()
References: <1340015298-14133-1-git-send-email-glommer@parallels.com> <1340015298-14133-6-git-send-email-glommer@parallels.com> <4FDF1A0D.6080204@jp.fujitsu.com>
In-Reply-To: <4FDF1A0D.6080204@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On 06/18/2012 04:07 PM, Kamezawa Hiroyuki wrote:
> (2012/06/18 19:27), Glauber Costa wrote:
>> Right now we free struct memcg with kfree right after a
>> rcu grace period, but defer it if we need to use vfree() to get
>> rid of that memory area. We do that by need, because we need vfree
>> to be called in a process context.
>>
>> This patch unifies this behavior, by ensuring that even kfree will
>> happen in a separate thread. The goal is to have a stable place to
>> call the upcoming jump label destruction function outside the realm
>> of the complicated and quite far-reaching cgroup lock (that can't be
>> held when calling neither the cpu_hotplug.lock nor the jump_label_mutex)
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>> CC: Tejun Heo<tj@kernel.org>
>> CC: Li Zefan<lizefan@huawei.com>
>> CC: Kamezawa Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Johannes Weiner<hannes@cmpxchg.org>
>> CC: Michal Hocko<mhocko@suse.cz>
> 
> How about cut out this patch and merge first as simple cleanu up and
> to reduce patch stack on your side ?
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I believe this is already in the -mm tree (from the sock memcg fixes)

But actually, my main trouble with this series here, is that I am basing
it on Pekka's tree, while some of the fixes are in -mm already.
If I'd base it on -mm I would lose some of the stuff as well.

Maybe Pekka can merge the current -mm with his tree?

So far I am happy with getting comments from people about the code, so I
did not get overly concerned about that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
