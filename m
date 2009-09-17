Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4A38A6B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 23:07:51 -0400 (EDT)
Date: Thu, 17 Sep 2009 11:23:04 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC][EXPERIMENTAL][PATCH 0/8] memcg: migrate charge at task move
Message-Id: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi.

These are patches for migrating memcg's charge at task move.

I know we should fix res_counter's scalability problem first,
but this feature is also important for me, so I tried making patches
and they seem to work basically.
I post them(based on mmotm-2009-09-14-01-57) before going further to get some feedbacks.


Basic design:
- Add flag file "memory.migrate_charge" to determine whether charges should be
  migrated or not. Each bit of "memory.migrate_charge" has meaning(indicate the
  type of pages the charges of which should be migrated).
- At can_attach(), isolate pages of the task, call __mem_cgroup_try_charge,
  and move them to a private list.
- Call mem_cgroup_move_account() at attach() about all pages on the private list
  after necessary checks under page_cgroup lock, and put back them to LRU.
- Cancel charges about all pages remains on the private list on failure or at the end
  of charge migration, and put back them to LRU.


I think this design is simple but it has a problem when mounted on the same hierarchy
with cpuset. This design isolate pages of the task at can_attach(), but attach() of cpuset
also tries to isolate pages of the task and migrate them if cpuset.memory_migrate is set.
As a result, pages cannot be memory migrated by cpuset if we set memory.migrate_charge.
But I think this problem can be handled by user-space to some extent: for example,
move the task back and move it again with memory.migrate_charge unset.
So I went to this direction as a first step(I'm considering how to avoid this issue).


Any comments or suggestions would be welcome.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
