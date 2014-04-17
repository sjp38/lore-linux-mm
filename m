Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 092466B008A
	for <linux-mm@kvack.org>; Thu, 17 Apr 2014 08:57:05 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so644372eei.19
        for <linux-mm@kvack.org>; Thu, 17 Apr 2014 05:57:05 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id m49si35254678eeo.71.2014.04.17.05.57.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 17 Apr 2014 05:57:04 -0700 (PDT)
Date: Thu, 17 Apr 2014 08:56:57 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcontrol: remove hierarchy restrictions for
 swappiness and oom_control
Message-ID: <20140417125657.GA23470@cmpxchg.org>
References: <1397682798-22906-1-git-send-email-hannes@cmpxchg.org>
 <20140416143425.c2b6f511cf4c6cd7336134b3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140416143425.c2b6f511cf4c6cd7336134b3@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Apr 16, 2014 at 02:34:25PM -0700, Andrew Morton wrote:
> On Wed, 16 Apr 2014 17:13:18 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > Per-memcg swappiness and oom killing can currently not be tweaked on a
> > memcg that is part of a hierarchy, but not the root of that hierarchy.
> > Users have complained that they can't configure this when they turned
> > on hierarchy mode.  In fact, with hierarchy mode becoming the default,
> > this restriction disables the tunables entirely.
> > 
> > But there is no good reason for this restriction.  The settings for
> > swappiness and OOM killing are taken from whatever memcg whose limit
> > triggered reclaim and OOM invocation, regardless of its position in
> > the hierarchy tree.
> > 
> > Allow setting swappiness on any group.  The knob on the root memcg
> > already reads the global VM swappiness, make it writable as well.
> > 
> > Allow disabling the OOM killer on any non-root memcg.
> 
> Documentation/cgroups/memory.txt needs updates?

Yes, that makes sense, thanks.  How about this?

---
Subject: [patch] mm: memcontrol: remove hierarchy restrictions for swappiness and oom_control fix

Update Documentation/cgroups/memory.txt

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 2622115276aa..1829c65f8371 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -535,17 +535,15 @@ Note:
 
 5.3 swappiness
 
-Similar to /proc/sys/vm/swappiness, but affecting a hierarchy of groups only.
+Similar to /proc/sys/vm/swappiness, but only affecting reclaim that is
+triggered by this cgroup's hard limit.  The tunable in the root cgroup
+corresponds to the global swappiness setting.
+
 Please note that unlike the global swappiness, memcg knob set to 0
 really prevents from any swapping even if there is a swap storage
 available. This might lead to memcg OOM killer if there are no file
 pages to reclaim.
 
-Following cgroups' swappiness can't be changed.
-- root cgroup (uses /proc/sys/vm/swappiness).
-- a cgroup which uses hierarchy and it has other cgroup(s) below it.
-- a cgroup which uses hierarchy and not the root of hierarchy.
-
 5.4 failcnt
 
 A memory cgroup provides memory.failcnt and memory.memsw.failcnt files.
@@ -754,7 +752,6 @@ You can disable the OOM-killer by writing "1" to memory.oom_control file, as:
 
 	#echo 1 > memory.oom_control
 
-This operation is only allowed to the top cgroup of a sub-hierarchy.
 If OOM-killer is disabled, tasks under cgroup will hang/sleep
 in memory cgroup's OOM-waitqueue when they request accountable memory.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
