Date: Mon, 25 Feb 2008 12:07:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] radix-tree based page_cgroup. [0/7] introduction
Message-Id: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
Cc: "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, taka@valinux.co.jp, Andi Kleen <ak@suse.de>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This patch series is for implementing radix-tree based page_cgroup.

This patch does
  - remove page_cgroup member from struct page.
  - add a lookup function get_page_cgroup(page).

And, by removing page_cgroup member, we'll have to change the whole lock rule.
In this patch, page_cgroup is allocated on demand but not freed. (see TODO).

This is first trial and I hope I get advices, comments.


Following is unix bench result under ia64/NUMA box, 8 cpu system. 
(Shell Script 8 concurrent result was not available from unknown reason.)
./Run fstime execl shell C hanoi

== rc2 + CONFIG_CGROUP_MEM_CONT ==
File Read 1024 bufsize 2000 maxblocks    937399.0 KBps  (30.0 secs, 3 samples)
File Write 1024 bufsize 2000 maxblocks   323117.0 KBps  (30.0 secs, 3 samples)
File Copy 1024 bufsize 2000 maxblocks    233737.0 KBps  (30.0 secs, 3 samples)
Execl Throughput                           2418.7 lps   (29.7 secs, 3 samples)
Shell Scripts (1 concurrent)               5506.0 lpm   (60.0 secs, 3 samples)
Shell Scripts (16 concurrent)               988.3 lpm   (60.0 secs, 3 samples)
C Compiler Throughput                       741.7 lpm   (60.0 secs, 3 samples)
Recursion Test--Tower of Hanoi            74555.8 lps   (20.0 secs, 3 samples)

== rc2 + CONFIG_CGROUP_MEM_CONT + radix-tree based page_cgroup ==
File Read 1024 bufsize 2000 maxblocks    966342.0 KBps  (30.0 secs, 2 samples)
File Write 1024 bufsize 2000 maxblocks   316999.0 KBps  (30.0 secs, 2 samples)
File Copy 1024 bufsize 2000 maxblocks    234167.0 KBps  (30.0 secs, 2 samples)
Execl Throughput                           2410.5 lps   (29.8 secs, 2 samples)
Shell Scripts (1 concurrent)               5505.0 lpm   (60.0 secs, 2 samples)
Shell Scripts (8 concurrent)               1824.5 lpm   (60.0 secs, 2 samples)
Shell Scripts (16 concurrent)               987.0 lpm   (60.0 secs, 2 samples)
C Compiler Throughput                       742.5 lpm   (60.0 secs, 2 samples)
Recursion Test--Tower of Hanoi            74335.6 lps   (20.0 secs, 2 samples)

looks good as first result.

Becaue today's my machine time is over, I post this now. I'll rebase this to
rc3 and reflect comments in the next trial.

series of patches
[1/8] --- defintions of header file. 
[2/8] --- changes in charge/uncharge path and remove locks.
[3/8] --- changes in page_cgroup_move_lists()
[4/8] --- changes in page migration with page_cgroup
[5/8] --- changes in force_empty
[6/8] --- radix-tree based page_cgroup
[7/8] --- (Optional) per-cpu fast lookup helper
[8/8] --- (Optional) Use vmalloc for 64bit machines.


TODO
 - Move to -rc3 or -mm ?
 - This patch series doesn't implement page_cgroup removal.
   I consider it's worth tring to remove page_cgroup when the page is used for
   HugePage or the page is offlined. But this will incease complexity. So, do later.
 - More perfomance measurement and brush codes up.
 - Check lock dependency...Do more test.
 - Should I add smaller chunk size for page_cgroup ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
