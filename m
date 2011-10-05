Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8118D900149
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 20:31:37 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 808A53EE0CB
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 09:31:33 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E73045DE54
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 09:31:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B82945DE55
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 09:31:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 270F91DB8057
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 09:31:33 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D62B41DB804D
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 09:31:32 +0900 (JST)
Date: Wed, 5 Oct 2011 09:29:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 0/8] per-cgroup tcp buffer pressure settings
Message-Id: <20111005092954.718a0c29.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1317730680-24352-1-git-send-email-glommer@parallels.com>
References: <1317730680-24352-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org

On Tue,  4 Oct 2011 16:17:52 +0400
Glauber Costa <glommer@parallels.com> wrote:

> [[ v3: merge Kirill's suggestions, + a destroy-related bugfix ]]
> [[ v4: Fix a bug with non-mounted cgroups + disallow task movement ]]
> [[ v5: Compile bug with modular ipv6 + tcp files in bytes ]]
> 
> Kame, Kirill,
> 
> I am submitting this again merging most of your comments. I've decided to
> leave some of them out:
>  * I am not using res_counters for allocated_memory. Besides being more
>    expensive than what we need, to make it work in a nice way, we'd have
>    to change the !cgroup code, including other protocols than tcp. Also,
>    
>  * I am not using failcnt and max_usage_in_bytes for it. I believe the value
>    of those lies more in the allocation than in the pressure control. Besides,
>    fail conditions lie mostly outside of the memory cgroup's control. (Actually,
>    a soft_limit makes a lot of sense, and I do plan to introduce it in a follow
>    up series)
> 
> If you agree with the above, and there are any other pressing issues, let me
> know and I will address them ASAP. Otherwise, let's discuss it. I'm always open.
> 

I'm not familar with reuqirements of users. So, I appreciate your choices.
What I adivse you here is taking a deep breath. Making new version every day
is not good for reviewing process ;)
(It's now -rc8 and merge will not be so quick, anyway.)

At this stage, my concern is view of interfaces and documenation, and future plans.

Let me give  a try explanation by myself. (Correct me ;)
I added some questions but I'm sorry you've already answered.

New interfaces are 5 files. All files exists only for non-root memory cgroup.

1. memory.independent_kmem_limit
2. memory.kmem.usage_in_bytes
3. memory.kmem.limit_in_bytes
4. memory.kmem.tcp.limit_in_bytes
5. memory.kmem.tcp.usage_in_bytes

* memory.independent_kmem_limit
 If 1, kmem_limit_in_bytes/kmem_usage_in_bytes works.
 If 0, kmem_limit_in_bytes/kmem_usage_in_bytes doesn't work and all kmem
    usages are controlled under memory.limit_in_bytes.

Question:
 - What happens when parent/chidlren cgroup has different indepedent_kmem_limit ?
 - What happens at creating a new cgroup with use_hierarchy==1.

* memory.kmem_limit_in_bytes/memory.kmem.tcp.limit_in_bytes

 Both files works independently for _Now_. And memory.kmem_usage_in_bytes and
 memory.kmem_tcp.usage_in_bytes has no relationships.

 In future plan, kmem.usage_in_bytes should includes tcp.kmem_usage_in_bytes.
 And kmem.limit_in_bytes should be the limiation of sum of all kmem.xxxx.limit_in_bytes.

Question:
 - Why this integration is difficult ?
   Can't tcp-limit-code borrows some amount of charges in batch from kmem_limit 
   and use it ?
 
 - Don't you need a stat file to indicate "tcp memory pressure works!" ?
   It can be obtained already ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
