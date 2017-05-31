Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8806B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 07:39:10 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a77so1977389wma.12
        for <linux-mm@kvack.org>; Wed, 31 May 2017 04:39:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r17si15315988edc.177.2017.05.31.04.39.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 04:39:09 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4VBcxrg078647
	for <linux-mm@kvack.org>; Wed, 31 May 2017 07:39:07 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2asvvurmu4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 May 2017 07:39:07 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 31 May 2017 12:39:05 +0100
Date: Wed, 31 May 2017 13:39:00 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH 2/6] mm: vmstat: move slab statistics from zone to node
 counters
References: <20170530181724.27197-1-hannes@cmpxchg.org>
 <20170530181724.27197-3-hannes@cmpxchg.org>
 <20170531091256.GA5914@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170531091256.GA5914@osiris>
Message-Id: <20170531113900.GB5914@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, linux-s390@vger.kernel.org

On Wed, May 31, 2017 at 11:12:56AM +0200, Heiko Carstens wrote:
> On Tue, May 30, 2017 at 02:17:20PM -0400, Johannes Weiner wrote:
> > To re-implement slab cache vs. page cache balancing, we'll need the
> > slab counters at the lruvec level, which, ever since lru reclaim was
> > moved from the zone to the node, is the intersection of the node, not
> > the zone, and the memcg.
> > 
> > We could retain the per-zone counters for when the page allocator
> > dumps its memory information on failures, and have counters on both
> > levels - which on all but NUMA node 0 is usually redundant. But let's
> > keep it simple for now and just move them. If anybody complains we can
> > restore the per-zone counters.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> This patch causes an early boot crash on s390 (linux-next as of today).
> CONFIG_NUMA on/off doesn't make any difference. I haven't looked any
> further into this yet, maybe you have an idea?
> 
> Kernel BUG at 00000000002b0362 [verbose debug info unavailable]
> addressing exception: 0005 ilc:3 [#1] SMP
> Modules linked in:
> CPU: 0 PID: 0 Comm: swapper Not tainted 4.12.0-rc3-00153-gb6bc6724488a #16
> Hardware name: IBM 2964 N96 702 (z/VM 6.4.0)
> task: 0000000000d75d00 task.stack: 0000000000d60000
> Krnl PSW : 0404200180000000 00000000002b0362 (mod_node_page_state+0x62/0x158)
>            R:0 T:1 IO:0 EX:0 Key:0 M:1 W:0 P:0 AS:0 CC:2 PM:0 RI:0 EA:3
> Krnl GPRS: 0000000000000001 000000003d81f000 0000000000000000 0000000000000006
>            0000000000000001 0000000000f29b52 0000000000000041 0000000000000000
>            0000000000000007 0000000000000040 000000003fe81000 000003d100ffa000
>            0000000000ee1cd0 0000000000979040 0000000000300abc 0000000000d63c90
> Krnl Code: 00000000002b0350: e31003900004 lg %r1,912
>            00000000002b0356: e320f0a80004 lg %r2,168(%r15)
>           #00000000002b035c: e31120000090 llgc %r1,0(%r1,%r2)
>           >00000000002b0362: b9060011  lgbr %r1,%r1
>            00000000002b0366: e32003900004 lg %r2,912
>            00000000002b036c: e3c280000090 llgc %r12,0(%r2,%r8)
>            00000000002b0372: b90600ac  lgbr %r10,%r12
>            00000000002b0376: b904002a  lgr %r2,%r10
> Call Trace:
> ([<0000000000000000>]           (null))
>  [<0000000000300abc>] new_slab+0x35c/0x628
>  [<000000000030740c>] __kmem_cache_create+0x33c/0x638
>  [<0000000000e99c0e>] create_boot_cache+0xae/0xe0
>  [<0000000000e9e12c>] kmem_cache_init+0x5c/0x138
>  [<0000000000e7999c>] start_kernel+0x24c/0x440
>  [<0000000000100020>] _stext+0x20/0x80
> Last Breaking-Event-Address:
>  [<0000000000300ab6>] new_slab+0x356/0x628

FWIW, it looks like your patch only triggers a bug that was introduced with
a different change that somehow messes around with the pages used to setup
the kernel page tables. I'll look into this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
