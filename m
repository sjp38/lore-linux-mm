Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A54F36B000C
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 04:08:05 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id m2-v6so824713plt.14
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 01:08:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z73-v6sor125790pgz.282.2018.07.03.01.08.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Jul 2018 01:08:04 -0700 (PDT)
Date: Tue, 3 Jul 2018 11:07:57 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v3 PATCH 4/5] mm: mmap: zap pages with read mmap_sem for
 large mapping
Message-ID: <20180703080757.jryyxefaehil3yt3@kshutemo-mobl1>
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
 <1530311985-31251-5-git-send-email-yang.shi@linux.alibaba.com>
 <20180702123350.dktmzlmztulmtrae@kshutemo-mobl1>
 <17c04c38-9569-9b02-2db2-7913a7debb46@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <17c04c38-9569-9b02-2db2-7913a7debb46@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Mon, Jul 02, 2018 at 10:19:32AM -0700, Yang Shi wrote:
> 
> 
> On 7/2/18 5:33 AM, Kirill A. Shutemov wrote:
> > On Sat, Jun 30, 2018 at 06:39:44AM +0800, Yang Shi wrote:
> > > When running some mmap/munmap scalability tests with large memory (i.e.
> > > > 300GB), the below hung task issue may happen occasionally.
> > > INFO: task ps:14018 blocked for more than 120 seconds.
> > >         Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
> > >   "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
> > > message.
> > >   ps              D    0 14018      1 0x00000004
> > >    ffff885582f84000 ffff885e8682f000 ffff880972943000 ffff885ebf499bc0
> > >    ffff8828ee120000 ffffc900349bfca8 ffffffff817154d0 0000000000000040
> > >    00ffffff812f872a ffff885ebf499bc0 024000d000948300 ffff880972943000
> > >   Call Trace:
> > >    [<ffffffff817154d0>] ? __schedule+0x250/0x730
> > >    [<ffffffff817159e6>] schedule+0x36/0x80
> > >    [<ffffffff81718560>] rwsem_down_read_failed+0xf0/0x150
> > >    [<ffffffff81390a28>] call_rwsem_down_read_failed+0x18/0x30
> > >    [<ffffffff81717db0>] down_read+0x20/0x40
> > >    [<ffffffff812b9439>] proc_pid_cmdline_read+0xd9/0x4e0
> > >    [<ffffffff81253c95>] ? do_filp_open+0xa5/0x100
> > >    [<ffffffff81241d87>] __vfs_read+0x37/0x150
> > >    [<ffffffff812f824b>] ? security_file_permission+0x9b/0xc0
> > >    [<ffffffff81242266>] vfs_read+0x96/0x130
> > >    [<ffffffff812437b5>] SyS_read+0x55/0xc0
> > >    [<ffffffff8171a6da>] entry_SYSCALL_64_fastpath+0x1a/0xc5
> > > 
> > > It is because munmap holds mmap_sem from very beginning to all the way
> > > down to the end, and doesn't release it in the middle. When unmapping
> > > large mapping, it may take long time (take ~18 seconds to unmap 320GB
> > > mapping with every single page mapped on an idle machine).
> > > 
> > > It is because munmap holds mmap_sem from very beginning to all the way
> > > down to the end, and doesn't release it in the middle. When unmapping
> > > large mapping, it may take long time (take ~18 seconds to unmap 320GB
> > > mapping with every single page mapped on an idle machine).
> > > 
> > > Zapping pages is the most time consuming part, according to the
> > > suggestion from Michal Hock [1], zapping pages can be done with holding
> > > read mmap_sem, like what MADV_DONTNEED does. Then re-acquire write
> > > mmap_sem to cleanup vmas. All zapped vmas will have VM_DEAD flag set,
> > > the page fault to VM_DEAD vma will trigger SIGSEGV.
> > > 
> > > Define large mapping size thresh as PUD size or 1GB, just zap pages with
> > > read mmap_sem for mappings which are >= thresh value.
> > > 
> > > If the vma has VM_LOCKED | VM_HUGETLB | VM_PFNMAP or uprobe, then just
> > > fallback to regular path since unmapping those mappings need acquire
> > > write mmap_sem.
> > > 
> > > For the time being, just do this in munmap syscall path. Other
> > > vm_munmap() or do_munmap() call sites remain intact for stability
> > > reason.
> > > 
> > > The below is some regression and performance data collected on a machine
> > > with 32 cores of E5-2680 @ 2.70GHz and 384GB memory.
> > > 
> > > With the patched kernel, write mmap_sem hold time is dropped to us level
> > > from second.
> > > 
> > > [1] https://lwn.net/Articles/753269/
> > > 
> > > Cc: Michal Hocko <mhocko@kernel.org>
> > > Cc: Matthew Wilcox <willy@infradead.org>
> > > Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> > > ---
> > >   mm/mmap.c | 136 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
> > >   1 file changed, 134 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/mm/mmap.c b/mm/mmap.c
> > > index 87dcf83..d61e08b 100644
> > > --- a/mm/mmap.c
> > > +++ b/mm/mmap.c
> > > @@ -2763,6 +2763,128 @@ static int munmap_lookup_vma(struct mm_struct *mm, struct vm_area_struct **vma,
> > >   	return 1;
> > >   }
> > > +/* Consider PUD size or 1GB mapping as large mapping */
> > > +#ifdef HPAGE_PUD_SIZE
> > > +#define LARGE_MAP_THRESH	HPAGE_PUD_SIZE
> > > +#else
> > > +#define LARGE_MAP_THRESH	(1 * 1024 * 1024 * 1024)
> > > +#endif
> > PUD_SIZE is defined everywhere.
> 
> If THP is defined, otherwise it is:
> 
> #define HPAGE_PUD_SIZE ({ BUILD_BUG(); 0; })

I'm talking about PUD_SIZE, not HPAGE_PUD_SIZE.

-- 
 Kirill A. Shutemov
