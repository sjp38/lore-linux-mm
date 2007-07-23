Received: from agmgw2.us.oracle.com (agmgw2.us.oracle.com [152.68.180.213])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id l6NJ08gL008784
	for <linux-mm@kvack.org>; Mon, 23 Jul 2007 14:00:08 -0500
Received: from acsmt351.oracle.com (acsmt351.oracle.com [141.146.40.151])
	by agmgw2.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id l6N8ZA1p026123
	for <linux-mm@kvack.org>; Mon, 23 Jul 2007 13:00:08 -0600
Date: Mon, 23 Jul 2007 12:04:09 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: hugepage test failures
Message-Id: <20070723120409.477a1c31.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I'm a few hundred linux-mm emails behind, so maybe this has been
addressed already.  I hope so.

I run hugepage-mmap and hugepage-shm tests (from Doc/vm/hugetlbpage.txt)
on a regular basis.  Lately they have been failing, usually with -ENOMEM,
but sometimes the mmap() succeeds and hugepage-mmap gets a SIGBUS:

open("/mnt/hugetlbfs/hugepagefile", O_RDWR|O_CREAT, 0755) = 3
mmap(NULL, 268435456, PROT_READ|PROT_WRITE, MAP_SHARED, 3, 0) = 0x2af31d2c3000
fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 1), ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x2af32d2c3000
write(1, "Returned address is 0x2af31d2c30"..., 35) = 35
--- SIGBUS (Bus error) @ 0 (0) ---
+++ killed by SIGBUS +++


and:

# ./hugepage-shm
shmget: Cannot allocate memory


I added printk()s in many mm/mmap.c and mm/hugetlb.c error return
locations and got this:

hugetlb_reserve_pages: -ENOMEM

which comes from mm/hugetlb.c::hugetlb_reserve_pages():

        if (chg > cpuset_mems_nr(free_huge_pages_node)) {
                printk(KERN_DEBUG "%s: -ENOMEM\n", __func__);
                return -ENOMEM;
        }

I had CONFIG_CPUSETS=y so I disabled it, but the same error
still happens.


Suggestions?  Fixex?

Thanks.
---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
