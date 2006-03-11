Date: Sat, 11 Mar 2006 15:41:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH/RFC] AutoPage Migration - V0.1 - 0/8 Overview
Message-Id: <20060311154113.c4358e40.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1142019195.5204.12.camel@localhost.localdomain>
References: <1142019195.5204.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lee.schermerhorn@hp.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, a few comments.

On Fri, 10 Mar 2006 14:33:14 -0500
Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:
> Furthermore, to prevent thrashing, a second
> sysctl, sched_migrate_interval, has been implemented.  The load balancer
> will not move a task to a different node if it has move to a new node
> in the last sched_migrate_interval seconds.  [User interface is in
> seconds; internally it's in HZ.]  The idea is to give the task time to
> ammortize the cost of the migration by giving it time to benefit from
> local references to the page.
I think this HZ should be automatically estimated by the kernel. not by user.


> Kernel builds [after make mrproper+make defconfig]
> on 2.6.16-rc5-git11 on 16-cpu/4 node/32GB HP rx8620 [ia64].
> Times taken after a warm-up run.
> Entire kernel source likely held in page cache.
> This amplifies the effect of the patches because I
> can't hide behind disk IO time.

It looks you added check_internode_migration() in migrate_task().
migrate_task() is called by sched_migrate_task().
And....sched_migrate_task() is called by sched_exec().
(a process can be migrated when exec().)
In this case, migrate_task_memory() just wastes time..., I think.

BTW, what happens against shared pages ?
-- Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
