Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 797266B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 13:48:06 -0400 (EDT)
Date: Wed, 11 Jul 2012 18:48:02 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] mm: hugetlb: flush dcache before returning zeroed huge
 page to userspace
Message-ID: <20120711174802.GG13498@mudshark.cambridge.arm.com>
References: <1341412376-6272-1-git-send-email-will.deacon@arm.com>
 <20120709122523.GC4627@tiehlicka.suse.cz>
 <20120709141324.GK7315@mudshark.cambridge.arm.com>
 <alpine.LSU.2.00.1207091622470.2261@eggly.anvils>
 <20120710094513.GB9108@mudshark.cambridge.arm.com>
 <20120710104234.GI9108@mudshark.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120710104234.GI9108@mudshark.cambridge.arm.com>
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jul 10, 2012 at 11:42:34AM +0100, Will Deacon wrote:
> On Tue, Jul 10, 2012 at 10:45:13AM +0100, Will Deacon wrote:
> > On Tue, Jul 10, 2012 at 12:57:14AM +0100, Hugh Dickins wrote:
> > > If I start to grep the architectures for non-empty flush_dcache_page(),
> > > I soon find things in arch/arm such as v4_mc_copy_user_highpage() doing
> > > if (!test_and_set_bit(PG_dcache_clean,)) __flush_dcache_page() - where
> > > the naming suggests that I'm right, it's the architecture's responsibility
> > > to arrange whatever flushing is needed in its copy and clear page functions.

[...]

> Ok, so this is exactly the problem. The hugetlb allocator uses its own
> pool of huge pages, so free_huge_page followed by a later alloc_huge_page
> will give you something where the page flags of the compound head do not
> guarantee that PG_arch_1 is clear.

Just to confirm, the following quick hack at least results in the correct
flushing for me (on ARM):


diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e198831..7a7c9d3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1141,6 +1141,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
        }
 
        set_page_private(page, (unsigned long)spool);
+       clear_bit(PG_arch_1, &page->flags);
 
        vma_commit_reservation(h, vma, addr);
 


The question is whether we should tidy that up for the core code or get
architectures to clear the bit in arch_make_huge_pte (which also seems to
work).

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
