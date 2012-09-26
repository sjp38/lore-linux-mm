Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 265E16B002B
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 16:05:43 -0400 (EDT)
Message-ID: <50635F46.7000700@parallels.com>
Date: Thu, 27 Sep 2012 00:02:14 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 04/13] kmem accounting basic infrastructure
References: <1347977050-29476-5-git-send-email-glommer@parallels.com> <20120926140347.GD15801@dhcp22.suse.cz> <20120926163648.GO16296@google.com> <50633D24.6020002@parallels.com> <CAOS58YNj-L4ocwn-c27ho4WPW41MKOeJbnLZ8N8r4eUkoxC7GA@mail.gmail.com> <50634105.8060302@parallels.com> <20120926180124.GA12544@google.com> <50634FC9.4090609@parallels.com> <20120926193417.GJ12544@google.com> <50635B9D.8020205@parallels.com> <20120926195648.GA20342@google.com>
In-Reply-To: <20120926195648.GA20342@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On 09/26/2012 11:56 PM, Tejun Heo wrote:
> Hello,
> 
> On Wed, Sep 26, 2012 at 11:46:37PM +0400, Glauber Costa wrote:
>> Besides not being part of cgroup core, and respecting very much both
>> cgroups' and basic sanity properties, kmem is an actual feature that
>> some people want, and some people don't. There is no reason to believe
>> that applications that want will live in the same environment with ones
>> that don't want.
> 
> I don't know.  It definitely is less crazy than .use_hierarchy but I
> wouldn't say it's an inherently different thing.  I mean, what does it
> even mean to have u+k limit on one subtree and not on another branch?
> And we worry about things like what if parent doesn't enable it but
> its chlidren do.
> 

It is inherently different. To begin with, it actually contemplates two
use cases. It is not a work around.

The meaning is also very well defined. The meaning of having this
enabled in one subtree and not in other is: Subtree A wants to track
kernel memory. Subtree B does not. It's that, and never more than that.
There is no maybes and no buts, no magic knobs that makes it behave in a
crazy way.

If a children enables it but the parent does not, this does what every
tree does: enable it from that point downwards.

> This is a feature which adds complexity.  If the feature is necessary
> and justified, sure.  If not, let's please not and let's err on the
> side of conservativeness.  We can always add it later but the other
> direction is much harder.
> 

I disagree. Having kmem tracking adds complexity. Having to cope with
the use case where we turn it on dynamically to cope with the "user page
only" use case adds complexity. But I see no significant complexity
being added by having it per subtree. Really.

You have the use_hierarchy fiasco in mind, and I do understand that you
are raising the flag and all that.

But think in terms of functionality: This thing here is a lot more
similar to swap than use_hierarchy. Would you argue that memsw should be
per-root ?

The reason why it shouldn't: Some people want to limit memory
consumption all the way to the swap, some people don't. Same with kmem.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
