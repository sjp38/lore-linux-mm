From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <10499358.1212763411935.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 6 Jun 2008 23:43:31 +0900 (JST)
Subject: Re: memcg: bad page at page migration
In-Reply-To: <20080606221124.623847aa.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <20080606221124.623847aa.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, lizf@cn.fujitsu.com, yamamoto@valinux.co.jp, hugh@veritas.com, minchan.kim@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

----- Original Message -----
>Date: Fri, 6 Jun 2008 22:11:24 +0900
>From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>Cc: akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, xemul@openvz.org,
>   lizf@cn.fujitsu.com, yamamoto@valinux.co.jp, hugh@veritas.com,
>   minchan.kim@gmail.com, linux-mm@kvack.org
>Subject: memcg: bad page at page migration
>
>
>Hi, Kamezawa-san.
>
>I found a bad page problem with your performance improvement
>patch set v4(*1), which have been already in -mm queue.
>This problem doesn't happen on original 2.6.26-rc2-mm1.
>
Could you try this one ?
http://marc.info/?l=linux-mm-commits&m=121126615605729&w=2
Sorry for very easy bug.

Thanks,
-Kame



>It happens when trying to migrate pages(I used memory_migrate
>of cpuset).
>
>How to reproduce:
>  I tested on fake numa on x86_64 hvm guest of xen(4cpus, 2nodes
>  1GB/node).
>
>  - mount cgroups and set parameters
>
>      # mount -t cgroup -o memory memory /cgroup/memory
>      # mkdir /cgroup/memory/01
>      # echo 32M >/cgroup/memory/01/memory.limit_in_bytes
>
>      # mount -t cgroup -o cpuset cpuset /cgroup/cpuset
>      # mkdir /cgroup/cpuset/01
>      # echo 0-1 >/cgroup/cpuset/01/cpuset.cpus
>      # echo 0 >/cgroup/cpuset/01/cpuset.mems
>      # echo 1 >/cgroup/cpuset/01/cpuset.memory_migrate
>      # mkdir /cgroup/cpuset/02
>      # echo 2-3 >/cgroup/cpuset/02/cpuset.cpus
>      # echo 1 >/cgroup/cpuset/02/cpuset.mems
>      # echo 1 >/cgroup/cpuset/02/cpuset.memory_migrate
>
>  - echo pid
>
>      # echo $$ >/cgroup/memory/01/tasks
>      # echo $$ >/cgroup/cpuset/01/tasks
>
>  - run program
>    I used "page01" of LTP.
>
>      # while true; do ./testcases/bin/page01 4718592 1; done &
>
>    This allocate 18M memory, write to it, read from it, and exit.
>
>    This problem seems to happen easily when using enough memory
>    to cause some swap in/out.
>
>  - trigger memory migration
>    Run a easy script(on top cgroup) to echo pids in /cgroup/cpuset/01/tasks
>    to /cgroup/cpuset/02/tasks, and vice versa for several times.
>
>Log:
>  Many and many bad page logs like below are displayed in syslog.
>
>---
>Bad page state in process 'switch.sh'
>page:ffffe20001f89300 flags:0x050000000000000c mapping:0000000000000000 mapco
unt:0 count:0
>cgroup:ffff8100314c6528
>Trying to fix it up, but a reboot is needed
>Backtrace:
>Pid: 5542, comm: switch.sh Tainted: G    B     2.6.26-rc2-mm1-kame #2
>
>Call Trace:
> [<ffffffff80272b42>] bad_page+0x97/0x131
> [<ffffffff802738fa>] free_hot_cold_page+0x9f/0x156
> [<ffffffff802739d2>] __pagevec_free+0x21/0x2e
> [<ffffffff80277056>] release_pages+0x165/0x177
> [<ffffffff80297349>] remove_migration_ptes+0x4b/0xf0
> [<ffffffff80277204>] __pagevec_lru_add+0xbf/0xcf
> [<ffffffff80297a2e>] migrate_pages+0x326/0x465
> [<ffffffff8028c60a>] new_node_page+0x0/0x5e
> [<ffffffff8028d449>] do_migrate_pages+0x19b/0x1e7
> [<ffffffff8022fec9>] set_cpus_allowed_ptr+0xe6/0xf3
> [<ffffffff802a3567>] __link_path_walk+0x13b/0xd02
> [<ffffffff8025b03d>] cpuset_migrate_mm+0x58/0x90
> [<ffffffff8025b5aa>] cpuset_attach+0x8b/0x9e
> [<ffffffff8032aed8>] sscanf+0x49/0x51
> [<ffffffff80258a97>] cgroup_attach_task+0x3a3/0x3f5
> [<ffffffff802595ad>] cgroup_common_file_write+0x150/0x1dc
> [<ffffffff8025919c>] cgroup_file_write+0x54/0x150
> [<ffffffff8029b445>] vfs_write+0xad/0x136
> [<ffffffff8029b982>] sys_write+0x45/0x6e
> [<ffffffff8020bee2>] tracesys+0xd5/0xda
>---
>
>All the logs I've seen include the line "cgroup:*******", so it seems that
>page->page_cgroup is not cleared.
>
>Do you have any ideas?
>
>
>Thanks,
>Daisuke Nishimura.
>
>*1
>http://lkml.org/lkml/2008/5/15/73
>http://lkml.org/lkml/2008/5/20/30

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
