Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id BC2AE6B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 09:37:57 -0400 (EDT)
Message-ID: <50338E74.9020507@parallels.com>
Date: Tue, 21 Aug 2012 17:34:44 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memcg: execute partial memcg freeing in mem_cgroup_destroy
References: <1345114903-20627-1-git-send-email-glommer@parallels.com> <xr93vcgiazok.fsf@gthelen.mtv.corp.google.com> <502DCDD0.3060502@parallels.com> <xr93a9xu9g7z.fsf@gthelen.mtv.corp.google.com>
In-Reply-To: <xr93a9xu9g7z.fsf@gthelen.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On 08/17/2012 10:37 AM, Greg Thelen wrote:
>> >
>> > Can we demonstrate that? I agree there might be a potential problem, and
>> > that is why I sent this separately. But the impression I got after
>> > testing and reading the code, was that the memcg information in
>> > pc->mem_cgroup would be updated to the parent.
>> >
>> > This means that any later call to uncharge or uncharge_swap would just
>> > uncharge from the parent memcg and we'd have no problem.
> I am by no means a swap expert, so I may be heading in the weeds.  But I
> think that a swapped out page is not necessarily in any memcg lru.  So
> the mem_cgroup_pre_destroy() call to mem_cgroup_force_empty() will not
> necessarily see swapped out pages.
> 
> I think this demonstrates the problem.

Ok, thanks Greg.
This seem to happen solely because we use the css_id in swap_cgroup
structure, and that needs to stay around. If we stored the memcg address
instead, we'd have no such problem. (I believe so atm, still need to go
dig deeper)

But this would lead to a 4 times bigger memory usage for that. Quite a
waste considering this tend to be sparsely used most of the time.






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
