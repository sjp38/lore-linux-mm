Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 113966B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 17:38:28 -0400 (EDT)
Received: by dakp5 with SMTP id p5so410713dak.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 14:38:27 -0700 (PDT)
Date: Wed, 30 May 2012 14:38:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
In-Reply-To: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1205301433490.9716@chino.kir.corp.google.com>
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gao feng <gaofeng@cn.fujitsu.com>
Cc: hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, bsingharora@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

On Tue, 29 May 2012, Gao feng wrote:

> cgroup and namespaces are used for creating containers but some of
> information is not isolated/virtualized. This patch is for isolating /proc/meminfo
> information per container, which uses memory cgroup. By this, top,free
> and other tools under container can work as expected(show container's
> usage) without changes.
> 
> This patch is a trial to show memcg's info in /proc/meminfo if 'current'
> is under a memcg other than root.
> 
> we show /proc/meminfo base on container's memory cgroup.
> because there are lots of info can't be provide by memcg, and
> the cmds such as top, free just use some entries of /proc/meminfo,
> we replace those entries by memory cgroup.
> 
> if container has no memcg, we will show host's /proc/meminfo
> as before.
> 
> there is no idea how to deal with Buffers,I just set it zero,
> It's strange if Buffers bigger than MemTotal.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Nack, this type of thing was initially tried with cpusets when a thread 
was bound to a subset of nodes, i.e. only show the total amount of memory 
spanned by those nodes.

For your particular interest, this information is already available 
elsewhere: memory.limit_in_bytes and memory.usage_in_bytes and that should 
be the interface where this is attained via /proc/cgroups.

Why?  Because the information exported by /proc/meminfo is considered by 
applications to be static whereas the limit of a memcg may change without 
any knowledge of the application.  Applications which need to know the 
amount of memory they are constrained to are assuming that there are no 
other consumers of memory on the system and thus they should be written to 
understand memcg limits just like they should understand cpusets (through 
either /proc/cgroups or /proc/cpuset).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
