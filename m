Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 3AC726B0038
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 11:42:04 -0400 (EDT)
Date: Mon, 3 Jun 2013 17:42:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] hugetlbfs: support split page table lock
Message-ID: <20130603154200.GD18588@dhcp22.suse.cz>
References: <1369770771-8447-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1369770771-8447-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130603131932.GA18588@dhcp22.suse.cz>
 <1370270075-wtjoksqp-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1370270075-wtjoksqp-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org

On Mon 03-06-13 10:34:35, Naoya Horiguchi wrote:
> On Mon, Jun 03, 2013 at 03:19:32PM +0200, Michal Hocko wrote:
> > On Tue 28-05-13 15:52:50, Naoya Horiguchi wrote:
> > > Currently all of page table handling by hugetlbfs code are done under
> > > mm->page_table_lock. This is not optimal because there can be lock
> > > contentions between unrelated components using this lock.
> > 
> > While I agree with such a change in general I am a bit afraid of all
> > subtle tweaks in the mm code that make hugetlb special. Maybe there are
> > none for page_table_lock but I am not 100% sure. So this might be
> > really tricky and it is not necessary for your further patches, is it?
> 
> No, this page_table_lock patch is separable from migration stuff.
> As you said in another email, changes going to stable should be minimal,
> so it's better to make 2/2 patch not depend on this patch.

OK, so I do we go around this. Both patches are in the mm tree now.
Should Andrew just drop the current version and you repost a new
version? Sorry I didn't jump in sooner but I was quite busy last week.

> > How have you tested this?
> 
> Other than libhugetlbfs test (that contains many workloads, but I'm
> not sure it can detect the possible regression of this patch,)
> I did simple testing where:
>  - create a file on hugetlbfs,
>  - create 10 processes and make each of them iterate the following:
>    * mmap() the hugetlbfs file,
>    * memset() the mapped range (to cause hugetlb_fault), and
>    * munmap() the mapped range.
> I think that this can make racy situation which should be prevented
> by page table locks.

OK, but this still requires a deep inspection of all the subtle
dependencies on page_table_lock from the core mm. I might be wrong here
and should be more specific about the issues I have only suspicion for
but as this is "just" an scalability improvement (is this actually
measurable?) I would suggest to put it at the end of your hugetlbfs
enahcements for the migration. Just from the reviewability point of
view.

> > > This patch makes hugepage support split page table lock so that
> > > we use page->ptl of the leaf node of page table tree which is pte for
> > > normal pages but can be pmd and/or pud for hugepages of some architectures.
> > > 
> > > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > ---
> > >  arch/x86/mm/hugetlbpage.c |  6 ++--
> > >  include/linux/hugetlb.h   | 18 ++++++++++
> > >  mm/hugetlb.c              | 84 ++++++++++++++++++++++++++++-------------------
> > 
> > This doesn't seem to be the complete story. At least not from the
> > trivial:
> > $ find arch/ -name "*hugetlb*" | xargs git grep "page_table_lock" -- 
> > arch/powerpc/mm/hugetlbpage.c:  spin_lock(&mm->page_table_lock);
> > arch/powerpc/mm/hugetlbpage.c:  spin_unlock(&mm->page_table_lock);
> > arch/tile/mm/hugetlbpage.c:             spin_lock(&mm->page_table_lock);
> > arch/tile/mm/hugetlbpage.c:
> > spin_unlock(&mm->page_table_lock);
> > arch/x86/mm/hugetlbpage.c: * called with vma->vm_mm->page_table_lock held.
> 
> This trivials should be fixed. Sorry.

Other archs are often forgotten and cscope doesn't help exactly ;)

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
