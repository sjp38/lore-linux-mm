Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id B46866B0031
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 12:01:27 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rp16so3833461pbb.3
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 09:01:27 -0800 (PST)
Received: from psmtp.com ([74.125.245.144])
        by mx.google.com with SMTP id ws5si2505728pab.267.2013.11.15.09.01.25
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 09:01:26 -0800 (PST)
Date: Fri, 15 Nov 2013 18:00:57 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: hugetlbfs: fix hugetlbfs optimization
Message-ID: <20131115170057.GE23559@redhat.com>
References: <20131105221017.GI3835@redhat.com>
 <CALnjE+prqCg2ZAMLQBQjY0OqmW2ofjioUoS25pa8Y93somc8Gg@mail.gmail.com>
 <20131113161022.GI15985@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131113161022.GI15985@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pravin Shelar <pshelar@nicira.com>
Cc: Khalid Aziz <khalid.aziz@oracle.com>, gregkh@linuxfoundation.org, Ben Hutchings <bhutchings@solarflare.com>, Christoph Lameter <cl@linux.com>, hannes@cmpxchg.org, mel@csn.ul.ie, riel@redhat.com, minchan@kernel.org, andi@firstfloor.org, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, linux-mm@kvack.org

Hi,

so while optimizing away the _mapcount tail page refcounting for slab
and hugetlbfs pages incremental with the fix for the hugetlbfs
optimization I just sent, I also noticed another bug in the current
code (already fixed by the patch). gup_fast is still increasing
_mapcount for hugetlbfs, but it's not decreased in put_page.

It's only noticeable if you do:

echo 0 >/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

On current upstream I get:

BUG: Bad page state in process bash  pfn:59a01
page:ffffea000139b038 count:0 mapcount:10 mapping:          (null) index:0x0
page flags: 0x1c00000000008000(tail)
Modules linked in:
CPU: 6 PID: 2018 Comm: bash Not tainted 3.12.0+ #25
Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
 0000000000000009 ffff880079cb5cc8 ffffffff81640e8b 0000000000000006
 ffffea000139b038 ffff880079cb5ce8 ffffffff8115bb15 00000000000002c1
 ffffea000139b038 ffff880079cb5d48 ffffffff8115bd83 ffff880079cb5de8
Call Trace:
 [<ffffffff81640e8b>] dump_stack+0x55/0x76
 [<ffffffff8115bb15>] bad_page+0xd5/0x130
 [<ffffffff8115bd83>] free_pages_prepare+0x213/0x280
 [<ffffffff8115df16>] __free_pages+0x36/0x80
 [<ffffffff8119b011>] update_and_free_page+0xc1/0xd0
 [<ffffffff8119b512>] free_pool_huge_page+0xc2/0xe0
 [<ffffffff8119b8cc>] set_max_huge_pages.part.58+0x14c/0x220
 [<ffffffff81308a8c>] ? _kstrtoull+0x2c/0x90
 [<ffffffff8119ba70>] nr_hugepages_store_common.isra.60+0xd0/0xf0
 [<ffffffff8119bac3>] nr_hugepages_store+0x13/0x20
 [<ffffffff812f763f>] kobj_attr_store+0xf/0x20
 [<ffffffff812354e9>] sysfs_write_file+0x189/0x1e0
 [<ffffffff811baff5>] vfs_write+0xc5/0x1f0
 [<ffffffff811bb505>] SyS_write+0x55/0xb0
 [<ffffffff81651712>] system_call_fastpath+0x16/0x1b

So good thing I stopped the hugetlbfs optimization from going into
stable.

I'll send a v2 of this work as a patchset of 3 patches where the first
is the same identical patch I already sent but incremental to upstream
and it contains all the fixes needed including for the above
problem.

Patch 1/3 should be applied more urgently as it fixes all those
various bugs. The 2/3 and 3/3 can be deferred.

The patch 3/3 especially should be benchmarked in the usual 8GB/sec
setup before being applied, unless it makes a real difference I
wouldn't apply it because it tends to slowdown the THP case a bit and
it complicates things a bit more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
