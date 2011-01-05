Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D9AFD6B0092
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 06:37:46 -0500 (EST)
Date: Wed, 5 Jan 2011 06:36:45 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1727059678.136426.1294227405240.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <170350174.135335.1294212699514.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: Re: [PATCH] hugetlb: remove overcommit sysfs for 1GB pages
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-mm <linux-mm@kvack.org>, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>


> This caused the process hung.
> # echo ""
> >/sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
> # echo t >/proc/sysrq-trigger
> ...
> bash R running task 0 3189 3183 0x00000080
> ffff8804196bfe58 ffffffff8149fcab 00007f4ab98c1700 ffffffff81130a40
> ffff8804194495c0 0000000000014d80 0000000000000246 ffff8804196be010
> ffff8804196bffd8 0000000000000000 00007f4ab98c1700 0000000000000000
> Call Trace:
> [<ffffffff81130a40>] ? nr_overcommit_hugepages_store+0x0/0x70
> [<ffffffff8100c9ae>] ? apic_timer_interrupt+0xe/0x20
> [<ffffffff81130a40>] ? nr_overcommit_hugepages_store+0x0/0x70
> [<ffffffff81226236>] ? strict_strtoul+0x46/0x70
> [<ffffffff81130a7a>] ? nr_overcommit_hugepages_store+0x3a/0x70
> [<ffffffff811e047b>] ? selinux_file_permission+0xfb/0x150
> [<ffffffff811d9473>] ? security_file_permission+0x23/0x90
> [<ffffffff811b9ae5>] ? sysfs_write_file+0x115/0x180
> [<ffffffff811504f8>] ? vfs_write+0xc8/0x190
> [<ffffffff81150d61>] ? sys_write+0x51/0x90
> [<ffffffff8100c0f4>] ? sysret_audit+0x16/0x20
Looks like it is looping here...

...
audit_syscall_exit
sys_write
    vfs_write
        sysfs_write_file
            nr_overcommit_hugepages_store
audit_syscall_exit

audit_syscall_exit
sys_write
    vfs_write
        sysfs_write_file
            nr_overcommit_hugepages_store
audit_syscall_exit
...

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
