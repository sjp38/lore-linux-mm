Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f51.google.com (mail-oa0-f51.google.com [209.85.219.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0D7E06B0036
	for <linux-mm@kvack.org>; Fri, 16 May 2014 18:00:19 -0400 (EDT)
Received: by mail-oa0-f51.google.com with SMTP id n16so3672114oag.38
        for <linux-mm@kvack.org>; Fri, 16 May 2014 15:00:18 -0700 (PDT)
Received: from mail-ob0-x249.google.com (mail-ob0-x249.google.com [2607:f8b0:4003:c01::249])
        by mx.google.com with ESMTPS id sc1si3968404oeb.82.2014.05.16.15.00.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 16 May 2014 15:00:18 -0700 (PDT)
Received: by mail-ob0-f201.google.com with SMTP id wn1so654511obc.0
        for <linux-mm@kvack.org>; Fri, 16 May 2014 15:00:18 -0700 (PDT)
References: <1399994956-3907-1-git-send-email-mhocko@suse.cz>
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH] memcg: deprecate memory.force_empty knob
In-reply-to: <1399994956-3907-1-git-send-email-mhocko@suse.cz>
Date: Fri, 16 May 2014 15:00:16 -0700
Message-ID: <xr9338g9o03z.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org


On Tue, May 13 2014, Michal Hocko <mhocko@suse.cz> wrote:

> force_empty has been introduced primarily to drop memory before it gets
> reparented on the group removal. This alone doesn't sound fully
> justified because reparented pages which are not in use can be reclaimed
> also later when there is a memory pressure on the parent level.
>
> Mark the knob CFTYPE_INSANE which tells the cgroup core that it
> shouldn't create the knob with the experimental sane_behavior. Other
> users will get informed about the deprecation and asked to tell us more
> because I do not expect most users will use sane_behavior cgroups mode
> very soon.
> Anyway I expect that most users will be simply cgroup remove handlers
> which do that since ever without having any good reason for it.
>
> If somebody really cares because reparented pages, which would be
> dropped otherwise, push out more important ones then we should fix the
> reparenting code and put pages to the tail.

I should mention a case where I've needed to use memory.force_empty: to
synchronously flush stats from child to parent.  Without force_empty
memory.stat is temporarily inconsistent until async css_offline
reparents charges.  Here is an example on v3.14 showing that
parent/memory.stat contents are in-flux immediately after rmdir of
parent/child.

$ cat /test
#!/bin/bash

# Create parent and child.  Add some non-reclaimable anon rss to child,
# then move running task to parent.
mkdir p p/c
(echo $BASHPID > p/c/cgroup.procs && exec sleep 1d) &
pid=$!
sleep 1
echo $pid > p/cgroup.procs 

grep 'rss ' {p,p/c}/memory.stat
if [[ $1 == force ]]; then
  echo 1 > p/c/memory.force_empty
fi
rmdir p/c

echo 'For a small time the p/c memory has not been reparented to p.'
grep 'rss ' {p,p/c}/memory.stat

sleep 1
echo 'After waiting all memory has been reparented'
grep 'rss ' {p,p/c}/memory.stat

kill $pid
rmdir p


-- First, demonstrate that just rmdir, without memory.force_empty,
   temporarily hides reparented child memory stats.

$ /test
p/memory.stat:rss 0
p/memory.stat:total_rss 69632
p/c/memory.stat:rss 69632
p/c/memory.stat:total_rss 69632
For a small time the p/c memory has not been reparented to p.
p/memory.stat:rss 0
p/memory.stat:total_rss 0
grep: p/c/memory.stat: No such file or directory
After waiting all memory has been reparented
p/memory.stat:rss 69632
p/memory.stat:total_rss 69632
grep: p/c/memory.stat: No such file or directory
/test: Terminated              ( echo $BASHPID > p/c/cgroup.procs && exec sleep 1d )

-- Demonstrate that using memory.force_empty before rmdir, behaves more
   sensibly.  Stats for reparented child memory are not hidden.

$ /test force
p/memory.stat:rss 0
p/memory.stat:total_rss 69632
p/c/memory.stat:rss 69632
p/c/memory.stat:total_rss 69632
For a small time the p/c memory has not been reparented to p.
p/memory.stat:rss 69632
p/memory.stat:total_rss 69632
grep: p/c/memory.stat: No such file or directory
After waiting all memory has been reparented
p/memory.stat:rss 69632
p/memory.stat:total_rss 69632
grep: p/c/memory.stat: No such file or directory
/test: Terminated              ( echo $BASHPID > p/c/cgroup.procs && exec sleep 1d )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
