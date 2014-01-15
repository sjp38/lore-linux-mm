Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4FCD56B0037
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 10:01:24 -0500 (EST)
Received: by mail-ee0-f51.google.com with SMTP id b57so937279eek.10
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 07:01:21 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i1si8242164eev.89.2014.01.15.07.01.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 07:01:18 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC PATCH 0/3] memcg OOM notifications and PF_EXITING checks
Date: Wed, 15 Jan 2014 16:01:05 +0100
Message-Id: <1389798068-19885-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

Hi,
this is an attempt to restart discussions regarding memcg OOM
notifications and break out conditions.

"memcg: do not hang on OOM when killed by userspace OOM access to memory
reserves" which was a first patch in the series was already merged to -mm
tree (http://www.ozlabs.org/~akpm/mmotm/broken-out/memcg-do-not-hang-on-oom-when-killed-by-userspace-oom-access-to-memory-reserves.patch)
but it didn't see ack from neither David nor Johannes. I would be happy
if we agreed on that one as well.

The first patch in this series implements and extends an idea proposed
by David to not notify userspace when the OOM killer might back out and
prevent from killing. Johannes was not fond of the idea because this
changes userspace interface in a subtle way because somebody might be
relying on notifications as a signal that the memcg is getting into
troubles. It has been argued that there are memory thresholds and
vmpressure notifications for such an use case.

I am in favor to make change the notification and draw the line when to
notify to "kernel or userspace has to perform an action". It makes sense
to me, it is still racy though. Something might have exiting millisecond
after notification fired but it at least is consistent.

The second patch is trivial and it removes PF_EXITING check for the
current in mem_cgroup_out_of_memory because it is no longer needed when
we have the check in the charging path.

The last patch is just an attempt and might be totally wrong. I've
noticed that we are not checking for the killed tasks in
mem_cgroup_out_of_memory which might break usecases where a task was
killed by vmpressure or thresholds handlers but the killed task cannot
terminate in time. We should rather not kill something else.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
