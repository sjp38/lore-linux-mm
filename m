Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 695476B0005
	for <linux-mm@kvack.org>; Wed, 27 Feb 2013 09:57:37 -0500 (EST)
From: Roman Gushchin <klamm@yandex-team.ru>
In-Reply-To: <20130227094054.GC16719@dhcp22.suse.cz>
References: <8121361952156@webcorp1g.yandex-team.ru> <20130227094054.GC16719@dhcp22.suse.cz>
Subject: Re: [PATCH] memcg: implement low limits
MIME-Version: 1.0
Message-Id: <38951361977052@webcorp2g.yandex-team.ru>
Date: Wed, 27 Feb 2013 18:57:32 +0400
Content-Type: multipart/mixed;
	boundary="----==--bound.3896.webcorp2g.yandex-team.ru"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner-Arquette <hannes@cmpxchg.org>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>


------==--bound.3896.webcorp2g.yandex-team.ru
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=koi8-r

Please find my comments below.

> More comments on the code bellow.
>
> [...]
>
>> ?diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> ?index 53b8201..d8e6ee6 100644
>> ?--- a/mm/memcontrol.c
>> ?+++ b/mm/memcontrol.c
>> ?@@ -1743,6 +1743,53 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>> ???????????????????????????NULL, "Memory cgroup out of memory");
>> ??}
>>
>> ?+/*
>> ?+ * If a cgroup is under low limit or enough close to it,
>> ?+ * decrease speed of page scanning.
>> ?+ *
>> ?+ * mem_cgroup_low_limit_scale() returns a number
>> ?+ * from range [0, DEF_PRIORITY - 2], which is used
>> ?+ * in the reclaim code as a scanning priority modifier.
>> ?+ *
>> ?+ * If the low limit is not set, it returns 0;
>> ?+ *
>> ?+ * usage - low_limit > usage / 8 ?=> 0
>> ?+ * usage - low_limit > usage / 16 => 1
>> ?+ * usage - low_limit > usage / 32 => 2
>> ?+ * ...
>> ?+ * usage - low_limit > usage / (2 ^ DEF_PRIORITY - 3) => DEF_PRIORITY - 3
>> ?+ * usage < low_limit => DEF_PRIORITY - 2
>
> Could you clarify why you have used this calculation. The comment
> exlaims _what_ is done but not _why_ it is done.
>
> It is also strange (and unexplained) that the low limit will work
> differently depending on the memcg memory usage - bigger groups have a
> bigger chance to be reclaimed even if they are under the limit.

The idea is to decrease scanning speed smoothly.
It's hard to explain why I used exact these numbers. It' like why DEF_PRIORITY is 12?
Just because it works :). Of course, these numbers are an object for discussion/change.

There is a picture in attachment that illustrates how low limits work:
red line - memory usage of cgroup with low_limit set to 1Gb,
blue line - memory usage of another cgroup, where I ran cat <large file> > /dev/null.

>> ?+ *
>> ?+ */
>> ?+unsigned int mem_cgroup_low_limit_scale(struct lruvec *lruvec)
>> ?+{
>> ?+ struct mem_cgroup_per_zone *mz;
>> ?+ struct mem_cgroup *memcg;
>> ?+ unsigned long long low_limit;
>> ?+ unsigned long long usage;
>> ?+ unsigned int i;
>> ?+
>> ?+ mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
>> ?+ memcg = mz->memcg;
>> ?+ if (!memcg)
>> ?+ return 0;
>> ?+
>> ?+ low_limit = res_counter_read_u64(&memcg->res, RES_LOW_LIMIT);
>> ?+ if (!low_limit)
>> ?+ return 0;
>> ?+
>> ?+ usage = res_counter_read_u64(&memcg->res, RES_USAGE);
>> ?+
>> ?+ if (usage < low_limit)
>> ?+ return DEF_PRIORITY - 2;
>> ?+
>> ?+ for (i = 0; i < DEF_PRIORITY - 2; i++)
>> ?+ if (usage - low_limit > (usage >> (i + 3)))
>> ?+ break;
>
> why this doesn't depend in the current reclaim priority?

How do you want to use reclaim priority here?

I don't like an idea to start ignoring low limit on some priorities.

In my implementation low_limit_scale just "increases" scanning priority, 
but no more than for 10 (DEF_PRIORITY - 2). So, if priority is 0-2, 
the reclaim works as if the priority were 10-12, that means "normal" slow reclaim.

>
>> ?+
>> ?+ return i;
>> ?+}
>> ?+
>> ??static unsigned long mem_cgroup_reclaim(struct mem_cgroup *memcg,
>> ??????????????????????????????????????????gfp_t gfp_mask,
>> ??????????????????????????????????????????unsigned long flags)
>
> [...]
>
>> ?diff --git a/mm/vmscan.c b/mm/vmscan.c
>> ?index 88c5fed..9c1c702 100644
>> ?--- a/mm/vmscan.c
>> ?+++ b/mm/vmscan.c
>> ?@@ -1660,6 +1660,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>> ??????????bool force_scan = false;
>> ??????????unsigned long ap, fp;
>> ??????????enum lru_list lru;
>> ?+ unsigned int low_limit_scale = 0;
>>
>> ??????????/*
>> ???????????* If the zone or memcg is small, nr[l] can be 0. ?This
>> ?@@ -1779,6 +1780,9 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>> ??????????fraction[1] = fp;
>> ??????????denominator = ap + fp + 1;
>> ??out:
>> ?+ if (global_reclaim(sc))
>> ?+ low_limit_scale = mem_cgroup_low_limit_scale(lruvec);
>
> What if the group is reclaimed as a result from parent hitting its
> limit?

For now, low limits will work only for global reclaim. Enabling them for target reclaim will require some additional checks.
I plan to do this as a separate change.

Thank you for your comments!

--
Regards,
Roman

------==--bound.3896.webcorp2g.yandex-team.ru
Content-Disposition: attachment;
	filename="low_limit_memcg.gif"
Content-Transfer-Encoding: base64
Content-Type: image/gif;
	name="low_limit_memcg.gif"

R0lGODdhgAKQAef8AAABAAACAAEEAAIFAQQHAgUIBAcJBQgLBwoMCA0PCw8RDhIUERQVExYXFRkA
/xcZFxobGRscGgAN/x0eHAIQ/x4gHSAhHyEjICMkIisQ9iUnJCcoJhgZ/yosKh4b/wAk/ywtKy0u
LDAyLzIzMTQ1M5YSfy4k//8AAP8ABzY4Nf8CFCIt/zk7OTw+Oz5APT0t/zEz/+AUOUFDQDU1/yU7
/0RGQ0VHREdIRklKSD47//8bFDNB/0tNS/8dHU9QTv8hJkhC/0BI/1NVUlFJ/1dZVklO//8uLVpc
Wf8xNVxeW1lQ/1JV/2BhX/86NmNkYmBW/v88PWZnZf8+RFtc/2hqZ2dd/mpsaV9h//9GRWxua2Jj
//9ITG5wbWVn//9PTXN1cmlq/3V3dP9SVWxv/3h6d29x//9ZVnt9enly/v9bXX6AfXR3/4GDgP9h
X355/oOFgv9jZnp+/4aIhf9qaYSA/4qMif9scIuNin+F/42PjP9xcYmH/4+RjpGTkIWM//93dJOV
kv95e42O/5aYlZCQ/5ial/9/fZiR/pudmv+ChpOW/56gnf+HiJ2Z/6Cin6KkoZme/6Olov+Ni6Wn
pKGg/6aopf+Qk6Sj/6mrqKqk/f+Wlqyuq6ao/62vrK6wraiq//+bmbCyr/+doK+s/7S2s6yx//+k
pLa4tbKz/ri6t7m7uLW2//+qqLy4/r2/vP+tsL/Bvrm9/8HDv/+ys8LEwcC//sPFwsXHxMPC/8bI
xf+5uMnE/f+8u8nLyMbJ/8zOy/7Bw87QzM3M/s/Rzv/ExdDP/9LU0P7Ix9PV0tbQ/f/LytbY1dPW
///Qzf/R1Nrc2drZ/v/T1tze29zb/97g3f7Y2N/h3uPe/v/a2+Hk4N/i/+Pl4eTm4/7f3ufm/v/i
4efp5unr6Onp///n5Ovt6u/r/f7p7O3v6//r7u7x7ezw//Dy7+7y//3w8PL08PLz/f/y8vT28//z
9PX2//b49Pf59v349vv4/fn7+P/6+fr8+f/8+/78//z++/n///7//CwAAAAAgAKQAQAI/gD/CRxI
sKDBgwgTKlzIsKHDhxAjSpxIsaLFixgzatzIsaPHjyBDihxJsqTJkyhTqlzJsqXLlzBjypxJs6bN
mzhz6tzJs6fPn0CDCh1KtKjRo0iTKl3KtKnTp1CjSp1KtarVq1izat3KtavXr2DDih1LtqzZs2jT
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
------==--bound.3896.webcorp2g.yandex-team.ru--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
