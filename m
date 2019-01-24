Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 008A68E0068
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 20:03:13 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id t192so2220713ywe.4
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 17:03:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e128sor2707402ywf.58.2019.01.23.17.03.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 17:03:08 -0800 (PST)
Date: Wed, 23 Jan 2019 20:03:06 -0500
From: Chris Down <chris@chrisdown.name>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190124010306.GA9055@chrisdown.name>
References: <20190123223144.GA10798@chrisdown.name>
 <20190124002359.GB21563@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190124002359.GB21563@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Dennis Zhou <dennis@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Kernel Team <Kernel-team@fb.com>

Roman Gushchin writes:
>On Wed, Jan 23, 2019 at 05:31:44PM -0500, Chris Down wrote:
>> memory.stat and other files already consider subtrees in their output,
>> and we should too in order to not present an inconsistent interface.
>>
>> The current situation is fairly confusing, because people interacting
>> with cgroups expect hierarchical behaviour in the vein of memory.stat,
>> cgroup.events, and other files. For example, this causes confusion when
>> debugging reclaim events under low, as currently these always read "0"
>> at non-leaf memcg nodes, which frequently causes people to misdiagnose
>> breach behaviour. The same confusion applies to other counters in this
>> file when debugging issues.
>>
>> Aggregation is done at write time instead of at read-time since these
>> counters aren't hot (unlike memory.stat which is per-page, so it does it
>> at read time), and it makes sense to bundle this with the file
>> notifications.
>
>I agree with the consistency argument (matching cgroup.events, ...),
>and it's definitely looks better for oom* events, but at the same time it feels
>like a API break.
>
>Just for example, let's say you have a delegated sub-tree with memory.max
>set. Earlier, getting memory.high/max event meant that the whole sub-tree
>is tight on memory, and, for example, led to shutdown of some parts of the tree.
>After your change, it might mean that some sub-cgroup has reached its limit,
>and probably doesn't matter on the top level.

Yeah, this is something I was thinking about while writing it. I think there's 
an argument to be made either way, since functionally they can both represent 
the same feature set, just in different ways.

In the subtree-propagated version you can find the level of the hierarchy that 
the event fired at by checking parent events vs. their subtrees' events, and 
this also allows trivially setting up event watches per-subtree.

In the previous, non-propagated version, it's more trivial to work out the 
level as the event only appears in that memory.events file, but it's harder to 
actually find out about the existence of such an event because you need to keep 
a watch for each individual cgroup in the subtree at all times.

So I think there's a reasonable argument to be made in favour of considering 
subtrees.

1. I'm not aware of anyone major currently relying on using the individual 
subtree level to indicate only subtree-level events.
2. Also, being able to detect the level at which an event happened can be 
achieved in both versions by comparing event counters.
3. Having memory.events work like cgroup.events and others seems to fit with 
principle of least astonishment.

That said, I agree that there's a tradeoff here, but in my experience this 
behaviour more closely resembles user intuition and better matches the overall 
semantics around hierarchical behaviour we've generally established for cgroup 
v2.

>Maybe it's still ok, but we definitely need to document it better. It feels
>bad that different versions of the kernel will handle it differently, so
>the userspace has to workaround it to actually use these events.

That's perfectly reasonable. I'll update the documentation to match.

>Also, please, make sure that it doesn't break memcg kselftests.

For sure.

>We don't have memory.events file for the root cgroup, so we can stop earlier.

Oh yeah, I missed that when changing from a for loop to do/while. I'll fix that 
up, thanks.

Thanks for your feedback!
