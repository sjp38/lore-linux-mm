Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id DBF946B0083
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 02:29:06 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/6] thp: optimize away unnecessary page table locking
Date: Mon, 20 Feb 2012 02:28:47 -0500
Message-Id: <1329722927-12108-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <alpine.LSU.2.00.1202191316320.1466@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Sun, Feb 19, 2012 at 01:21:02PM -0800, Hugh Dickins wrote:
> On Wed, 8 Feb 2012, Naoya Horiguchi wrote:
> > Currently when we check if we can handle thp as it is or we need to
> > split it into regular sized pages, we hold page table lock prior to
> > check whether a given pmd is mapping thp or not. Because of this,
> > when it's not "huge pmd" we suffer from unnecessary lock/unlock overhead.
> > To remove it, this patch introduces a optimized check function and
> > replace several similar logics with it.
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: David Rientjes <rientjes@google.com>
> > 
> > Changes since v4:
> >   - Rethink returned value of __pmd_trans_huge_lock()
> 
> [snip]
> 
> > --- 3.3-rc2.orig/mm/mremap.c
> > +++ 3.3-rc2/mm/mremap.c
> > @@ -155,8 +155,6 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
> >  			if (err > 0) {
> >  				need_flush = true;
> >  				continue;
> > -			} else if (!err) {
> > -				split_huge_page_pmd(vma->vm_mm, old_pmd);
> >  			}
> >  			VM_BUG_ON(pmd_trans_huge(*old_pmd));
> >  		}

Thanks for reporting, 

> Is that what you intended to do there?

No. This is a bug.

> I just hit that VM_BUG_ON on rc3-next-20120217.

I found that when extend != HPAGE_PMD_SIZE, thp is not split so
it hits the VM_BUG_ON.
The following patch cancels the change in returned value in v4->v5
and I confirmed this fixes the problem in my simple test.
Andrew, could you add it on top of this optimization patch?

Naoya
----------------------------------------------------
