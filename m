Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1E45E6B007D
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 06:35:30 -0500 (EST)
Message-Id: <20081216113055.713856000@menage.corp.google.com>
Date: Tue, 16 Dec 2008 03:30:55 -0800
From: menage@google.com
Subject: [PATCH 0/3] CGroups: Hierarchy locking/refcount changes
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, lizf@cn.fujitsu.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

These patches introduce new locking/refcount support for cgroups to
reduce the need for subsystems to call cgroup_lock(). This will
ultimately allow the atomicity of cgroup_rmdir() (which was removed
recently) to be restored.

These three patches give:

1/3 - introduce a per-subsystem hierarchy_mutex which a subsystem can
     use to prevent changes to its own cgroup tree

2/3 - use hierarchy_mutex in place of calling cgroup_lock() in the
     memory controller

3/3 - introduce a css_tryget() function similar to the one recently
      proposed by Kamezawa, but avoiding spurious refcount failures in
      the event of a race between a css_tryget() and an unsuccessful
      cgroup_rmdir()

Future patches will likely involve:

- using hierarchy mutex in place of cgroup_lock() in more subsystems
 where appropriate

- restoring the atomicity of cgroup_rmdir() with respect to cgroup_create()

Signed-off-by: Paul Menage <menage@google.com>

--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
