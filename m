Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 505C682F64
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 00:25:46 -0400 (EDT)
Received: by pasz6 with SMTP id z6so75082635pas.2
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 21:25:46 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id yq4si18132274pbb.236.2015.10.21.21.25.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 21:25:45 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so75214160pad.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 21:25:45 -0700 (PDT)
Date: Wed, 21 Oct 2015 21:25:26 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: kernel oops on mmotm-2015-10-15-15-20
In-Reply-To: <alpine.LSU.2.11.1510211908300.2949@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1510212052330.1094@eggly.anvils>
References: <20151021052836.GB6024@bbox> <alpine.LSU.2.11.1510211908300.2949@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

On Wed, 21 Oct 2015, Hugh Dickins wrote:
> On Thu, 22 Oct 2015, Minchan Kim wrote:
> > Hello Hugh,
> > 
> > On Wed, Oct 21, 2015 at 05:59:59PM -0700, Hugh Dickins wrote:
> > > On Thu, 22 Oct 2015, Minchan Kim wrote:
> > > > 
> > > > I added the code to check it and queued it again but I had another oops
> > > > in this time but symptom is related to anon_vma, too.
> > > > (kernel is based on recent mmotm + unconditional mkdirty for bug fix)
> > > > It seems page_get_anon_vma returns NULL since the page was not page_mapped
> > > > at that time but second check of page_mapped right before try_to_unmap seems
> > > > to be true.
> > > > 
> > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > page:ffffea0001cfbfc0 count:3 mapcount:1 mapping:ffff88007f1b5f51 index:0x600000aff
> > > > flags: 0x4000000000048019(locked|uptodate|dirty|swapcache|swapbacked)
> > > > page dumped because: VM_BUG_ON_PAGE(PageAnon(page) && !PageKsm(page) && !anon_vma)
> > > 
> > > That's interesting, that's one I added in my page migration series.
> > > Let me think on it, but it could well relate to the one you got before.

I think I have introduced a bug there; or rather, made more evident
a pre-existing bug.  But I'm not sure yet: the stacktrace was from
compaction (called by khugepaged, but that may not be relevant at all),
and thinking through the races with isolate_migratepages_block() is
never easy.

What's certain is that I was not giving any thought to
isolate_migratepages_block() when I added that VM_BUG_ON_PAGE():
I was thinking about "stable" anonymous pages, and how they get
faulted back in from swapcache while holding page lock.

It looks to me now as if a page might not yet be PageAnon when it's
first tested in __unmap_and_move(), when going to page_get_anon_vma();
but is page_mapped() and PageAnon() by time of calling try_to_unmap(),
where I inserted the VM_BUG_ON_PAGE().

If so, the code would always have been wrong (trying to unmap the
anonymous page, and later remap its replacement, without a hold on
the anon_vma needed to guide both lookups); but I'll have made it
more glaringly wrong with the VM_BUG_ON_PAGE() - let me pretend
that's a good step forward :)

There's a reference count check in isolated_migratepages_block()
before this, which would make it unlikely, but I doubt rules it out.

However... you did hit an anon_vma reference counting problem before
my migration changes went in, and Kirill had a vague suspicion that
he might be screwing up anon_vma refcounting in split_huge_page():
if he confirms that, I'd say it's more likely to be the cause of
your crash on this occasion.

Not hard to fix mine (though we'll probably have to lose the
VM_BUG_ON_PAGE on the way, so the real fix will be hidden by that
trivial fix), I just want to give the races more thought.

However it turns out, I think you have a very useful test there.

(And I've observed no PageDirty problems with your recent patchsets,
though I don't use MADV_FREE at all myself.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
