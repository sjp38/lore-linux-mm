Message-ID: <468439E8.4040606@redhat.com>
Date: Thu, 28 Jun 2007 18:44:56 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01 of 16] remove nr_scan_inactive/active
References: <8e38f7656968417dfee0.1181332979@v2.random>	<466C36AE.3000101@redhat.com>	<20070610181700.GC7443@v2.random>	<46814829.8090808@redhat.com> <20070626105541.cd82c940.akpm@linux-foundation.org>
In-Reply-To: <20070626105541.cd82c940.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> Where's the system time being spent?

OK, it turns out that there is quite a bit of variability
in where the system spends its time.  I did a number of
reaim runs and averaged the time the system spent in the
top functions.

This is with the Fedora rawhide kernel config, which has
quite a few debugging options enabled.

_raw_spin_lock		32.0%
page_check_address	12.7%
__delay			10.8%
mwait_idle		10.4%
anon_vma_unlink		5.7%
__anon_vma_link		5.3%
lockdep_reset_lock	3.5%
__kmalloc_node_track_caller 2.8%
security_port_sid	1.8%
kfree			1.6%
anon_vma_link		1.2%
page_referenced_one	1.1%

In short, the system is waiting on the anon_vma lock.

I wonder if Lee Schemmerhorn's patch to turn that
spinlock into an rwlock would help this workload,
or if we simply should scan fewer pages in the
pageout code.

Andrea, with your VM patches for some reason the
number of users where reaim has its crossover point
is also somewhat variable, between 4200 and 5100
users, with 9 out of 10 runs under 4500 on my system.

A kernel without your patches is not as variable,
but has visibly more unfairness between tasks, as
seen in the reaim "Std_dev" columns.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
