Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id m3JFn6lg013107
	for <linux-mm@kvack.org>; Sat, 19 Apr 2008 16:49:07 +0100
Received: from an-out-0708.google.com (andd33.prod.google.com [10.100.30.33])
	by zps36.corp.google.com with ESMTP id m3JFn3iN005452
	for <linux-mm@kvack.org>; Sat, 19 Apr 2008 08:49:04 -0700
Received: by an-out-0708.google.com with SMTP id d33so271523and.34
        for <linux-mm@kvack.org>; Sat, 19 Apr 2008 08:49:03 -0700 (PDT)
Message-ID: <6599ad830804190849u31f13191m4dcca4e471493c2b@mail.gmail.com>
Date: Sat, 19 Apr 2008 08:49:02 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][-mm] Memory controller hierarchy support (v1)
In-Reply-To: <20080419053551.10501.44302.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080419053551.10501.44302.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Pavel Emelianov <xemul@openvz.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 18, 2008 at 10:35 PM, Balbir Singh
<balbir@linux.vnet.ibm.com> wrote:
>
>  1. We need to hold cgroup_mutex while walking through the children
>    in reclaim. We need to figure out the best way to do so. Should
>    cgroups provide a helper function/macro for it?

There's already a function, cgroup_lock(). But it would be nice to
avoid such a heavy locking here, particularly since memory allocations
can occur with cgroup_mutex held, which could lead to a nasty deadlock
if the allocation triggered reclaim.

One of the things that I've been considering was to put the
parent/child/sibling hierarchy explicitly in cgroup_subsys_state. This
would give subsystems their own copy to refer to, and could use their
own internal locking to synchronize with callbacks from cgroups that
might change the hierarchy. Cpusets could make use of this too, since
it has to traverse hierarchies sometimes.

>  2. Do not allow children to have a limit greater than their parents.
>  3. Allow the user to select if hierarchial support is required

My thoughts on this would be:

1) Never attach a first-level child's counter to its parent. As
Yamamoto points out, otherwise we end up with extra global operations
whenever any cgroup allocates or frees memory. Limiting the total
system memory used by all user processes doesn't seem to be something
that people are going to generally want to do, and if they really do
want to they can just create a non-root child and move the whole
system into that.

The one big advantage that you currently get from having all
first-level children be attached to the root is that the reclaim logic
automatically scans other groups when it reaches the top-level - but I
think that can be provided as a special-case in the reclaim traversal,
avoiding the overhead of hitting the root cgroup that we have in this
patch.

2) Always attach other children's counters to their parents - if the
user didn't want a hierarchy, they could create a flat grouping rather
than nested groupings.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
