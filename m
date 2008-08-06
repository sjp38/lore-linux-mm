Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id m76EhdDI214068
	for <linux-mm@kvack.org>; Wed, 6 Aug 2008 14:43:39 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m76EhdbC3903696
	for <linux-mm@kvack.org>; Wed, 6 Aug 2008 16:43:39 +0200
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m76EhcIa027209
	for <linux-mm@kvack.org>; Wed, 6 Aug 2008 16:43:39 +0200
Subject: [BUG] hugetlb: sleeping function called from invalid context
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Reply-To: gerald.schaefer@de.ibm.com
Content-Type: text/plain
Date: Wed, 06 Aug 2008 16:43:22 +0200
Message-Id: <1218033802.7764.31.camel@ubuntu>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hi,

running the libhugetlbfs test suite I met the following bug:

BUG: sleeping function called from invalid context at include/linux/pagemap.h:294
in_atomic():1, irqs_disabled():0
CPU: 0 Not tainted 2.6.27-rc1 #3
Process private (pid: 4531, task: 000000003f68e400, ksp: 000000002a7e3be8)
0700000033a00700 000000002a7e3bf0 0000000000000002 0000000000000000 
       000000002a7e3c90 000000002a7e3c08 000000002a7e3c08 0000000000016472 
       0000000000000000 000000002a7e3be8 0000000000000000 0000000000000000 
       000000002a7e3bf0 000000000000000c 000000002a7e3bf0 000000002a7e3c60 
       0000000000337798 0000000000016472 000000002a7e3bf0 000000002a7e3c40 
Call Trace:
([<00000000000163f4>] show_trace+0x130/0x140)
 [<00000000000164cc>] show_stack+0xc8/0xfc
 [<0000000000016c62>] dump_stack+0xb2/0xc0
 [<000000000003d64a>] __might_sleep+0x136/0x154
 [<000000000008badc>] find_lock_page+0x50/0xb8
 [<00000000000b9b08>] hugetlb_fault+0x4c4/0x684
 [<00000000000a3e3c>] handle_mm_fault+0x8ec/0xb54
 [<00000000003338aa>] do_protection_exception+0x32a/0x3b4
 [<00000000000256b2>] sysc_return+0x0/0x8
 [<0000000000400fba>] 0x400fba

While holding mm->page_table_lock, hugetlb_fault() calls hugetlbfs_pagecache_page(),
which calls find_lock_page(), which may sleep.

Thanks,
Gerald


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
