Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB64A6B0003
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 18:40:23 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id r2-v6so17148934ybb.4
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 15:40:23 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id f7-v6si5089152yba.169.2018.07.11.15.40.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 15:40:22 -0700 (PDT)
Date: Wed, 11 Jul 2018 15:40:03 -0700
From: Roman Gushchin <guro@fb.com>
Subject: cgroup-aware OOM killer, how to move forward
Message-ID: <20180711223959.GA13981@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, rientjes@google.com, mhocko@kernel.org, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

Hello!

I was thinking on how to move forward with the cgroup-aware OOM killer.
It looks to me, that we all agree on the "cleanup" part of the patchset:
it's a nice feature to be able to kill all tasks in the cgroup
to guarantee the consistent state of the workload.
All our disagreements are related to the victim selection algorithm.

So, I wonder, if the right thing to do is to split the problem.
We can agree on the "cleanup" part, which is useful by itself,
merge it upstream, and then return to the victim selection
algorithm.

So, here is my proposal:
let's introduce the memory.group_oom knob with the following semantics:
if the knob is set, the OOM killer can kill either none, either all
tasks in the cgroup*.
It can perfectly work with the current OOM killer (as a "cleanup" option),
and allows _any_ further approach on the OOM victim selection.
It also doesn't require any mount/boot/tree-wide options.

How does it sound?

If we can agree on this, I will prepare the patchset.
It's quite small and straightforward in comparison to the current version.

Thanks!


* More precisely: if the OOM killer kills a task,
it will traverse the cgroup tree up to the OOM domain (OOMing memcg or root),
looking for the highest-level cgroup with group_oom set. Then it will
kill all tasks in such cgroup, if it does exist.
