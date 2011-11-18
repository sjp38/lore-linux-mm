Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 74D396B002D
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 14:51:23 -0500 (EST)
Date: Fri, 18 Nov 2011 14:51:07 -0500 (EST)
Message-Id: <20111118.145107.1788849543768712319.davem@davemloft.net>
Subject: Re: [Devel] Re: [PATCH v5 00/10] per-cgroup tcp memory pressure
From: David Miller <davem@davemloft.net>
In-Reply-To: <4EC6B457.4010502@parallels.com>
References: <1321381632.3021.57.camel@dabdike.int.hansenpartnership.com>
	<20111117.163501.1963137869848419475.davem@davemloft.net>
	<4EC6B457.4010502@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: glommer@parallels.com
Cc: jbottomley@parallels.com, eric.dumazet@gmail.com, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, linux-mm@kvack.org, devel@openvz.org, kirill@shutemov.name, gthelen@google.com, kamezawa.hiroyu@jp.fujitsu.com

From: Glauber Costa <glommer@parallels.com>
Date: Fri, 18 Nov 2011 17:39:03 -0200

> On 11/17/2011 07:35 PM, David Miller wrote:
>> From: James Bottomley<jbottomley@parallels.com>
>> Date: Tue, 15 Nov 2011 18:27:12 +0000
>>
>>> Ping on this, please.  We're blocked on this patch set until we can
>>> get
>>> an ack that the approach is acceptable to network people.
>>
>> __sk_mem_schedule is now more expensive, because instead of
>> short-circuiting
>> the majority of the function's logic when "allocated<=
>> prot->sysctl_mem[0]"
>> and immediately returning 1, the whole rest of the function is run.
> 
> Not the whole rest of the function. Rather, just the other two
> tests. But that's the behavior we need since if your parent is on
> pressure, you should be as well. How do you feel if we'd also provide
> two versions for this:
> 1) non-cgroup, try to return 1 as fast as we can
> 2) cgroup, also check your parents.

Fair enough.

> How about we make the jump_label only used for sockets (which is basic
> what we have now, just need a clear name to indicate that), and then
> enable it not when the first non-root cgroup is created, but when the
> first one sets the limit to something different than unlimited?
> 
> Of course to that point, we'd be accounting only to the root
> structures,
> but I guess this is not a big deal.

This sounds good for now.

>> TCP specific stuff in mm/memcontrol.c, at best that's not nice at all.
> 
> How crucial is that?

It's a big deal.  We've been working for years to yank protocol specific
things even out of net/core/*.c, it simply doesn't belong there.

I'd even be happier if you had to create a net/ipv4/tcp_memcg.c and
include/net/tcp_memcg.h

> Thing is that as far as I am concerned, all the
> memcg people
 ...

What the memcg people want is entirely their problem, especially if it
involves crapping up non-networking files with protocol specific junk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
