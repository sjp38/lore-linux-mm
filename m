Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6C88B8D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 05:15:57 -0400 (EDT)
Received: by iyf13 with SMTP id 13so3113494iyf.14
        for <linux-mm@kvack.org>; Thu, 31 Mar 2011 02:15:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110331110113.a01f7b8b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110331110113.a01f7b8b.kamezawa.hiroyu@jp.fujitsu.com>
From: Zhu Yanhai <zhu.yanhai@gmail.com>
Date: Thu, 31 Mar 2011 17:15:34 +0800
Message-ID: <AANLkTi=D8pfyxf3Vr33YZvuQm9fQv+bthyiLLeRjaJt6@mail.gmail.com>
Subject: Re: [LSF][MM] rough agenda for memcg.
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: lsf@lists.linux-foundation.org, linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, walken@google.com

Hi Kame,

2011/3/31 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
> =C2=A0c) Should we provide a auto memory cgroup for file caches ?
> =C2=A0 =C2=A0 (Then we can implement a file-cache-limit.)
> =C2=A0c) AFAIK, some other OSs have this kind of feature, a box for file-=
cache.
> =C2=A0 =C2=A0 Because file-cache is a shared object between all cgroups, =
it's difficult
> =C2=A0 =C2=A0 to handle. It may be better to have a auto cgroup for file =
caches and add knobs
> =C2=A0 =C2=A0 for memcg.

I have been thinking about this idea. It seems the root cause of
current difficult is
the whole cgroup infrastructure is based on process groups, so its counters
naturally center on process. However, this is not nature for counters
of file caches,
which center on inodes/devs actually. This brought many confusing
problems - e.g.
who should be charged for a (dirty)file page?  I think the answer is
no process but
the filesystem/block device it sits on.
How about we change the view, from centering on process to centering
on filesystem/device.
Let's call it 'pcgroup'. When it enables, we can set limits for each
filesystem/device,
and charge the filesystem/device for each page seat on it. This
'pcgroup' would be
orthogonal to cgroup.memcontroler. We could make cgroup.memcontroler only
account/control the anon pages they have, leave all file-backend pages
controlled
by the 'pcgroup'.
For the implementation, 'pcgroup' can reuse the struct page_cgroup -
and res_counter
maybe even the hierarchy reclaim code, and so on - it looks like a
cgroup very much -
which might make things easier.
One problem is this 'pcgroup' may not be able to be implemented inside
cgroup frame,
as the very core code of cgroup assumes that all its
controls/res_counters are per-process(group).

Is this doable?

Thanks,
Zhu Yanhai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
