Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7169B6B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 10:08:54 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p52so24337700wrc.8
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 07:08:54 -0700 (PDT)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id w10si4139191wrb.207.2017.04.03.07.08.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 07:08:52 -0700 (PDT)
Received: by mail-wr0-x243.google.com with SMTP id k6so32594899wre.3
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 07:08:52 -0700 (PDT)
Date: Mon, 3 Apr 2017 17:08:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: ksmd lockup - kernel 4.11-rc series
Message-ID: <20170403140850.twnkdiglzqlsfecy@node.shutemov.name>
References: <003401d2a750$19f98190$4dec84b0$@net>
 <20170327233617.353obb3m4wz7n5kv@node.shutemov.name>
 <alpine.LSU.2.11.1703280008020.2599@eggly.anvils>
 <alpine.LSU.2.11.1704021651230.1618@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1704021651230.1618@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Doug Smythies <dsmythies@telus.net>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org

On Sun, Apr 02, 2017 at 05:03:00PM -0700, Hugh Dickins wrote:
> On Tue, 28 Mar 2017, Hugh Dickins wrote:
> > On Tue, 28 Mar 2017, Kirill A. Shutemov wrote:
> > > On Mon, Mar 27, 2017 at 04:16:00PM -0700, Doug Smythies wrote:
> > > > Hi,
> > > > 
> > > > Note: I am not sure I have the correct e-mail list for this.
> > > > 
> > > > As of kernel 4.11-rc1 I have a very infrequent issue (only four times
> > > > so far, once with -rc1 and three times with -rc2 (I never used -rc3,
> > > > and am now running -rc4)) where ksmd becomes stuck, the load average
> > > > goes way up and one CPU keeps hitting the NMI watchdog. I have not
> > > > been able to figure out a way to recover and end up hitting the reset
> > > > button on the computer. I am running 2 VM guests on this host server at
> > > > the time.
> > > > 
> > > > Note: these events have always been preceded by some other event, and
> > > > so something else might be the root issue here. However, the preceding
> > > > event also seems to be ksm related, not sure.
> > > > 
> > > > Since the issue is so infrequent, and the event requires a hard reset,
> > > > it would be almost impossible to bi-sect the kernel to isolate it.
> > > > 
> > > > I am willing to do the work to isolate the issue, I just don't know
> > > > what to do. While I never had this issue before kernel 4.11-rc1, I also
> > > > do not run VM guests on this test computer all the time.
> > > > 
> > > > Doug Smythies
> > > > 
> > > > Log segment for one occurrence:
> > > > 
> > > > Mar 27 15:17:07 s15 kernel: [92420.587173] BUG: unable to handle kernel paging request at ffff88e680000000
> > > > Mar 27 15:17:07 s15 kernel: [92420.587203] IP: page_vma_mapped_walk+0xe6/0x5b0
> > > > Mar 27 15:17:07 s15 kernel: [92420.587217] PGD ac80a067
> > > > Mar 27 15:17:07 s15 kernel: [92420.587217] PUD 41f5ff067
> > > > Mar 27 15:17:07 s15 kernel: [92420.587226] PMD 0
> > > 
> > > +Hugh.
> > > 
> > > Thanks for report.
> > > 
> > > It's likely I've screwed something up with my page_vma_mapped_walk()
> > > transition. I don't see anything yet. And it's 2:30 AM. I'll look more
> > > into it tomorrow.
> > 
> > I've known for a while that there's something quite wrong with KSM in
> > v4.11-rc, but haven't taken out the time to investigate yet (and was
> > curious to see whether anyone else noticed - thank you Doug).
> > 
> > I've rather supposed that it comes from your walk changes; but that's
> > nothing more than a guess so far, and I haven't looked to see if what
> > I hit is the same thing as Doug reports.
> > 
> > I'll look back into it later today, or tomorrow.
> 
> Worked out what it was yesterday, but my first patch failed overnight:
> I'd missed the placement of the next_pte label.  It had a similar fix
> to mm/migrate.c in it, that hit me too in testing; but this morning I
> find Naoya's 4b0ece6fa016 in git, which fixes that.  Same issue here.
> 
> 
> [PATCH] mm: fix page_vma_mapped_walk() for ksm pages
> 
> Doug Smythies reports oops with KSM in this backtrace,
> I've been seeing the same:
> 
> page_vma_mapped_walk+0xe6/0x5b0
> page_referenced_one+0x91/0x1a0
> rmap_walk_ksm+0x100/0x190
> rmap_walk+0x4f/0x60
> page_referenced+0x149/0x170
> shrink_active_list+0x1c2/0x430
> shrink_node_memcg+0x67a/0x7a0
> shrink_node+0xe1/0x320
> kswapd+0x34b/0x720
> 
> Just as 4b0ece6fa016 ("mm: migrate: fix remove_migration_pte() for ksm
> pages") observed, you cannot use page->index calculations on ksm pages.
> page_vma_mapped_walk() is relying on __vma_address(), where a ksm page
> can lead it off the end of the page table, and into whatever nonsense
> is in the next page, ending as an oops inside check_pte()'s pte_page().
> 
> KSM tells page_vma_mapped_walk() exactly where to look for the page,
> it does not need any page->index calculation: and that's so also for
> all the normal and file and anon pages - just not for THPs and their
> subpages.  Get out early in most cases: I've used a not-THP-page test,
> which I think is clearer; but a PageKsm test would be enough to fix it.
> 
> I'm also slightly worried that this loop can stray into other vmas,
> so added a vm_end test to prevent surprises; though I have not imagined
> anything worse than a very contrived case, in which a page mlocked in
> the next vma might be reclaimed because it is not mlocked in this vma.
> 
> Fixes: ace71a19cec5 ("mm: introduce page_vma_mapped_walk()")
> Reported-by: Doug Smythies <dsmythies@telus.net>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> 
>  mm/page_vma_mapped.c |    8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> --- 4.11-rc4/mm/page_vma_mapped.c	2017-03-13 09:04:37.792808451 -0700
> +++ linux/mm/page_vma_mapped.c	2017-04-02 09:31:55.718482184 -0700
> @@ -165,9 +165,13 @@ restart:
>  	while (1) {
>  		if (check_pte(pvmw))
>  			return true;
> -next_pte:	do {
> +next_pte:
> +		if (!PageTransHuge(pvmw->page) || PageHuge(pvmw->page))
> +			return not_found(pvmw);

I guess it makes sense to drop the same check from the beginning of the
function and move the comment here.

Otherwise looks good. Thanks for tracking this down.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
