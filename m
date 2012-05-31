Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id D955C6B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 20:44:45 -0400 (EDT)
Received: by dakp5 with SMTP id p5so628962dak.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 17:44:45 -0700 (PDT)
Date: Wed, 30 May 2012 17:44:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
In-Reply-To: <4FC6BC3E.5010807@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1205301737530.25774@chino.kir.corp.google.com>
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com> <alpine.DEB.2.00.1205301433490.9716@chino.kir.corp.google.com> <4FC6B68C.2070703@jp.fujitsu.com> <CAHGf_=pFbsy4FO_UNu6O1-KyTd6O=pkmR8=3EGuZB5Reu3Vb9w@mail.gmail.com>
 <4FC6BC3E.5010807@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Gao feng <gaofeng@cn.fujitsu.com>, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

On Thu, 31 May 2012, Kamezawa Hiroyuki wrote:

> My test with sysfs node's meminfo seems to work...
> 
> [root@rx100-1 qqm]# mount --bind /sys/devices/system/node/node0/meminfo
> /proc/meminfo
> [root@rx100-1 qqm]# cat /proc/meminfo
> 
> Node 0 MemTotal:        8379636 kB

This doesn't seem like a good idea unless the application supports the 
"Node 0" prefix in /proc/meminfo.

If any application really cares about the amount of memory available to 
it, it should be taught to be memcg aware.  Then do something like

cat $(grep memory /proc/mounts | cut -d " " -f 2)/$(grep memory /proc/self/cgroup | cut -d : -f 3)/memory.limit_in_bytes

but since that value can change all the time then it doesn't seem helpful 
unless we have a userspace notifier.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
