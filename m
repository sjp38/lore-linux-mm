Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F00F26B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 05:14:49 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id a141so6700245wma.8
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 02:14:49 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y8sor7730970edk.41.2017.12.18.02.14.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Dec 2017 02:14:48 -0800 (PST)
Date: Mon, 18 Dec 2017 13:14:46 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: thp: use down_read_trylock in khugepaged to avoid
 long block
Message-ID: <20171218101446.prbrutyom2ya47by@node.shutemov.name>
References: <1513281203-54878-1-git-send-email-yang.s@alibaba-inc.com>
 <20171215102753.GY16951@dhcp22.suse.cz>
 <13f935a9-42af-98f4-1813-456a25200d9d@alibaba-inc.com>
 <20171216114525.GH16951@dhcp22.suse.cz>
 <20171216200925.kxvkuqoyhkonj7m6@node.shutemov.name>
 <20171218084119.GJ16951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171218084119.GJ16951@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.s@alibaba-inc.com>, kirill.shutemov@linux.intel.com, hughd@google.com, aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 18, 2017 at 09:41:19AM +0100, Michal Hocko wrote:
> On Sat 16-12-17 23:09:25, Kirill A. Shutemov wrote:
> > On Sat, Dec 16, 2017 at 12:45:25PM +0100, Michal Hocko wrote:
> > > On Sat 16-12-17 04:04:10, Yang Shi wrote:
> [...]
> > > > Shall we add "cond_resched()" in unmap_vmas(), i.e for every 100 vmas? It
> > > > may improve the responsiveness a little bit for non-preempt kernel, although
> > > > it still can't release the semaphore.
> > > 
> > > We already do, once per pmd (see zap_pmd_range).
> > 
> > It doesn't help. We would need to find a way to drop mmap_sem, if we're
> > holding it way too long. And doing it on per-vma count basis is not right
> > call. It won't address issue with single huge vma.
> 
> Absolutely agreed. I just wanted to point out that a new cond_resched is
> not really needed. One way to reduce the lock starvation is to use range
> locking.
> 
> > Do we have any instrumentation that would help detect starvation on a
> > rw_semaphore?
> 
> I am afraid we don't.

I guess we have enough info in mmu_gather to decide if we are doing munmap way
too long. Although, getting everything right would be tricky...

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
