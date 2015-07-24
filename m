Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 226E16B0254
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 13:00:41 -0400 (EDT)
Received: by iggf3 with SMTP id f3so21514439igg.1
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 10:00:41 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id c3si21975860pdj.114.2015.07.24.10.00.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 10:00:40 -0700 (PDT)
Received: by pachj5 with SMTP id hj5so17068472pac.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 10:00:40 -0700 (PDT)
Date: Fri, 24 Jul 2015 10:00:35 -0700
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH] mm: add resched points to
 remap_pmd_range/ioremap_pmd_range
Message-ID: <20150724170035.GB3458@Sligo.logfs.org>
References: <1437688476-3399-3-git-send-email-sbaugh@catern.com>
 <1437694323.3214.353.camel@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1437694323.3214.353.camel@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Spencer Baugh <sbaugh@catern.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Joern Engel <joern@logfs.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Shachar Raindel <raindel@mellanox.com>, Boaz Harrosh <boaz@plexistor.com>, Andy Lutomirski <luto@amacapital.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Roman Pen <r.peniaev@gmail.com>, Andrey Konovalov <adech.fo@gmail.com>, Eric Dumazet <edumazet@google.com>, Dmitry Vyukov <dvyukov@google.com>, Rob Jones <rob.jones@codethink.co.uk>, WANG Chao <chaowang@redhat.com>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Spencer Baugh <Spencer.baugh@purestorage.com>

On Thu, Jul 23, 2015 at 05:32:03PM -0600, Toshi Kani wrote:
> On Thu, 2015-07-23 at 14:54 -0700, Spencer Baugh wrote:
> > From: Joern Engel <joern@logfs.org>
> > 
> > Mapping large memory spaces can be slow and prevent high-priority
> > realtime threads from preempting lower-priority threads for a long time.
> 
> Yes, and one of the goals of large page ioremap support is to address such
> problem.

Nice!  Once we upgrade we should retest this one then.

> > ------------[ cut here ]------------
> > WARNING: at arch/x86/kernel/irq.c:182 do_IRQ+0x126/0x140()
> > Thread not rescheduled for 95 jiffies
> > CPU: 14 PID: 6684 Comm: foo Tainted: G        W  O 3.10.59+
> >  0000000000000009 ffff883f7fbc3ee0 ffffffff8163a12c ffff883f7fbc3f18
> >  ffffffff8103f131 ffff887f48275ac0 000000000000002f 000000000000007c
> >  0000000000000000 00007fadd1e00000 ffff883f7fbc3f78 ffffffff8103f19c
> > Call Trace:
> >  <IRQ>  [<ffffffff8163a12c>] dump_stack+0x19/0x1b
> >  [<ffffffff8103f131>] warn_slowpath_common+0x61/0x80
> >  [<ffffffff8103f19c>] warn_slowpath_fmt+0x4c/0x50
> >  [<ffffffff810bd917>] ? rcu_irq_exit+0x77/0xc0
> >  [<ffffffff8164a556>] do_IRQ+0x126/0x140
> >  [<ffffffff816407ef>] common_interrupt+0x6f/0x6f
> >  <EOI>  [<ffffffff81640483>] ? _raw_spin_lock+0x13/0x30
> >  [<ffffffff8111b621>] __pte_alloc+0x31/0xc0
> >  [<ffffffff8111feac>] remap_pfn_range+0x45c/0x470
> 
> remap_pfn_range() does not have large page mappings support yet.  So, yes,
> this can still take a long time at this point.  We can extend large page
> support for this interface if necessary.

A cond_resched() is enough to solve the latency impact.  But I suspect
large pages will perform better as well, so having that support would be
appreciated.

> >  [<ffffffffa007f1f8>] vfio_pci_mmap+0x148/0x210 [vfio_pci]
> >  [<ffffffffa0025173>] vfio_device_fops_mmap+0x23/0x30 [vfio]
> >  [<ffffffff81124ed8>] mmap_region+0x3d8/0x5e0
> >  [<ffffffff811253e5>] do_mmap_pgoff+0x305/0x3c0
> >  [<ffffffff8126f3f3>] ? call_rwsem_down_write_failed+0x13/0x20
> >  [<ffffffff81111677>] vm_mmap_pgoff+0x67/0xa0
> >  [<ffffffff811237e2>] SyS_mmap_pgoff+0x272/0x2e0
> >  [<ffffffff810067e2>] SyS_mmap+0x22/0x30
> >  [<ffffffff81648c59>] system_call_fastpath+0x16/0x1b
> > ---[ end trace 6b0a8d2341444bde ]---

Jorn

--
A defeated army first battles and then seeks victory.
-- Sun Tzu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
