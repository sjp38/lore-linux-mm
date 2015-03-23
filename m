Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 827426B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 00:40:12 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so175101557pdb.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:40:12 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com. [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id vi4si8578103pbc.248.2015.03.22.21.40.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 21:40:11 -0700 (PDT)
Received: by pdnc3 with SMTP id c3so175358525pdn.0
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:40:11 -0700 (PDT)
Date: Sun, 22 Mar 2015 21:40:02 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 11/24] huge tmpfs: shrinker to migrate and free underused
 holes
In-Reply-To: <550AFFD5.40607@yandex-team.ru>
Message-ID: <alpine.LSU.2.11.1503222046510.5278@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils> <alpine.LSU.2.11.1502202008010.14414@eggly.anvils> <550AFFD5.40607@yandex-team.ru>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 19 Mar 2015, Konstantin Khlebnikov wrote:
> On 21.02.2015 07:09, Hugh Dickins wrote:
> > 
> > The "team_usage" field added to struct page (in union with "private")
> > is somewhat vaguely named: because while the huge page is sparsely
> > occupied, it counts the occupancy; but once the huge page is fully
> > occupied, it will come to be used differently in a later patch, as
> > the huge mapcount (offset by the HPAGE_PMD_NR occupancy) - it is
> > never possible to map a sparsely occupied huge page, because that
> > would expose stale data to the user.
> 
> That might be a problem if this approach is supposed to be used for
> normal filesystems.

Yes, most filesystems have their own use for page->private.
My concern at this stage has just been to have a good implementation
for tmpfs, but Kirill and others are certainly interested in looking
beyond that.

> Instead of adding dedicated counter shmem could
> detect partially occupied page by scanning though all tail pages and
> checking PageUptodate() and bump mapcount for all tail pages prevent
> races between mmap and truncate. Overhead shouldn't be that big, also
> we can add fastpath - mark completely uptodate page with one of unused
> page flag (PG_private or something).

I do already use PageChecked (PG_owner_priv_1) for just that purpose:
noting all subpages Uptodate (and marked Dirty) when first mapping by
pmd (in 12/24).

But don't bump mapcount on the subpages, just the head: I don't mind
doing a pass down the subpages when it's first hugely mapped, but prefer
to avoid such a pass on every huge map and unmap - seems unnecessary.

The team_usage (== private) field ends up with three or four separate
counts (and an mlocked flag) packed into it: I expect we could trade
some of those counts for scans down the 512 subpages when necessary,
but I doubt it's a good tradeoff; and keeping atomicity would be
difficult (I've never wanted to have to take page_lock or somesuch
on every page in zap_pte_range).  Without atomicity the stats go wrong
(I think Kirill has a problem of that kind in his page_remove_rmap scan).

It will be interesting to see what Kirill does to maintain the stats
for huge pagecache: but he will have no difficulty in finding fields
to store counts, because he's got lots of spare fields in those 511
tail pages - that's a useful benefit of the compound page, but does
prevent the tails from being used in ordinary ways.  (I did try using
team_head[1].team_usage for more, but atomicity needs prevented it.)

> 
> Another (strange) idea is adding separate array of struct huge_page
> into each zone. They will work as headers for huge pages and hold
> that kind of fields. Pageblock flags also could be stored here.

It's not such a strange idea, it is a definite possibility.  Though
I've tended to think of them more as a separate array of struct pages,
one for each of the hugepages.

It's a complication I'll keep away from as long as I can, but something
like that will probably have to come.  Consider the ambiguity of the
head page, whose flags and counts may represent the 4k page mapped
by pte and the 2M page mapped by pmd: there's an absurdity to that,
one that I can live with for now, but expect some nasty case to demand
a change (the way I have it at present, just mlocking the 4k head is
enough to hold the 2M hugepage in memory: that's not good, but should
be quite easily fixed without needing the hugepage array itself).

And I think ideas may emerge from the persistent memory struct page
discussions, which feed in here.  One reason to hold back for now.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
