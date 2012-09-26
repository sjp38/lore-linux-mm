Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id D700A6B002B
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 13:40:08 -0400 (EDT)
Message-ID: <50633D24.6020002@parallels.com>
Date: Wed, 26 Sep 2012 21:36:36 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 04/13] kmem accounting basic infrastructure
References: <1347977050-29476-1-git-send-email-glommer@parallels.com> <1347977050-29476-5-git-send-email-glommer@parallels.com> <20120926140347.GD15801@dhcp22.suse.cz> <20120926163648.GO16296@google.com>
In-Reply-To: <20120926163648.GO16296@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On 09/26/2012 08:36 PM, Tejun Heo wrote:
> Hello, Michal, Glauber.
> 
> On Wed, Sep 26, 2012 at 04:03:47PM +0200, Michal Hocko wrote:
>> Haven't we already discussed that a new memcg should inherit kmem_accounted
>> from its parent for use_hierarchy?
>> Say we have
>> root
>> |
>> A (kmem_accounted = 1, use_hierachy = 1)
>>  \
>>   B (kmem_accounted = 0)
>>    \
>>     C (kmem_accounted = 1)
>>
>> B find's itself in an awkward situation becuase it doesn't want to
>> account u+k but it ends up doing so becuase C.
> 
> Do we really want this level of flexibility?  What's wrong with a
> global switch at the root?  I'm not even sure we want this to be
> optional at all.  The only reason I can think of is that it might
> screw up some configurations in use which are carefully crafted to
> suit userland-only usage but for that isn't what we need a transition
> plan rather than another ultra flexible config option that not many
> really understand the implication of?
> 
> In the same vein, do we really need both .kmem_accounted and config
> option?  If someone is turning on MEMCG, just include kmem accounting.
> 

Yes, we do.

This was discussed multiple times. Our interest is to preserve existing
deployed setup, that were tuned in a world where kmem didn't exist.
Because we also feed kmem to the user counter, this may very well
disrupt their setup.

User memory, unlike kernel memory, may very well be totally in control
of the userspace application, so it is not unreasonable to believe that
extra pages appearing in a new kernel version may break them.

It is actually a much worse compatibility problem than flipping
hierarchy, in comparison

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
