Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 894536B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 12:05:04 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so564896pde.37
        for <linux-mm@kvack.org>; Tue, 20 Aug 2013 09:05:03 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 20 Aug 2013 12:05:03 -0400
Message-ID: <CAJLXCZTtJmQo5WnwsdQWnoMPYSxOjxU0x77J59qE-GKOL9tqbA@mail.gmail.com>
Subject: Transparent huge page collapse and NUMA
From: Andrew Davidoff <davidoff@qedmf.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi,

In an effort to learn more about transparent huge pages and NUMA, I
have written a very simple C snippet that malloc()s in a loop. I am
running this under numactl with an interleave policy across both the
NUMA nodes in the system. To make watching allocation progress easier,
I am malloc()ing 4k (1 page) at a time.

If I watch node usage for the process (numa_maps) allocation looks
correct (interleave), but then allocation will drop on one node and
increase on another, at the same time as I see an increase in
pages_collapsed. It appears as though pages are always migrating away
from and to the same nodes, resulting in allocation (again, by
examining numa_maps) being almost entirely on one node.

This leads me to believe that khugepaged's defrag is to blame, though
I am not certain. I tried to disable transparent huge page defrag
completely via the following under /sys:

/sys/kernel/mm/transparent_hugepage/defrag
/sys/kernel/mm/transparent_hugepage/khugepaged/defrag

but the same behavior persists. I am not sure if this is an indication
that I don't know how to control transparent huge page collapse, or or
that my issue isn't defrag/collapse related.

Do I understand what I am seeing? Does anyone have any thoughts on this?

The OS is CentOS5.8 running the Oracle Unbreakable Kernel 2,
2.6.39-400.109.4.el5uek.

Further questions:

The way I understand it, transparent_hugepage/defrag controls defrag
on page fault, and transparent_hugepage/khugepaged/defrag controls
maintenance defrag (time based). Is that correct?

Thanks.
Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
