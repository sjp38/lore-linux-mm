Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 80D846B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 21:09:07 -0400 (EDT)
Received: by wibhm2 with SMTP id hm2so13467wib.2
        for <linux-mm@kvack.org>; Tue, 21 Aug 2012 18:09:05 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v2 09/11] memcg: propagate kmem limiting information to children
References: <1344517279-30646-1-git-send-email-glommer@parallels.com>
	<1344517279-30646-10-git-send-email-glommer@parallels.com>
	<20120817090005.GC18600@dhcp22.suse.cz>
	<502E0BC3.8090204@parallels.com>
	<20120817093504.GE18600@dhcp22.suse.cz>
	<502E17C4.7060204@parallels.com>
	<20120817103550.GF18600@dhcp22.suse.cz>
	<502E1E90.1080805@parallels.com>
	<20120821075430.GA19797@dhcp22.suse.cz>
	<50335341.6010400@parallels.com>
	<20120821100007.GE19797@dhcp22.suse.cz>
Date: Tue, 21 Aug 2012 18:09:03 -0700
Message-ID: <xr93fw7fbumo.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Tue, Aug 21 2012, Michal Hocko wrote:

> On Tue 21-08-12 13:22:09, Glauber Costa wrote:
>> On 08/21/2012 11:54 AM, Michal Hocko wrote:
> [...]
>> > But maybe you have a good use case for that?
>> > 
>> Honestly, I don't. For my particular use case, this would be always on,
>> and end of story. I was operating under the belief that being able to
>> say "Oh, I regret", and then turning it off would be beneficial, even at
>> the expense of the - self contained - complication.
>> 
>> For the general sanity of the interface, it is also a bit simpler to say
>> "if kmem is unlimited, x happens", which is a verifiable statement, than
>> to have a statement that is dependent on past history. 
>
> OK, fair point. We shouldn't rely on the history. Maybe
> memory.kmem.limit_in_bytes could return some special value like -1 in
> such a case?
>
>> But all of those need of course, as you pointed out, to be traded off
>> by the code complexity.
>> 
>> I am fine with either, I just need a clear sign from you guys so I don't
>> keep deimplementing and reimplementing this forever.
>
> I would be for make it simple now and go with additional features later
> when there is a demand for them. Maybe we will have runtimg switch for
> user memory accounting as well one day.
>
> But let's see what others think?

In my use case memcg will either be disable or (enabled and kmem
limiting enabled).

I'm not sure I follow the discussion about history.  Are we saying that
once a kmem limit is set then kmem will be accounted/charged to memcg.
Is this discussion about the static branches/etc that are autotuned the
first time is enabled?  The first time its set there parts of the system
will be adjusted in such a way that may impose a performance overhead
(static branches, etc).  Thereafter the performance cannot be regained
without a reboot.  This makes sense to me.  Are we saying that
kmem.limit_in_bytes will have three states?
- kmem never enabled on machine therefore kmem has never been enabled
- kmem has been enabled in past but is not effective is this cgroup
  (limit=infinity)
- kmem is effective in this mem (limit=not-infinity)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
