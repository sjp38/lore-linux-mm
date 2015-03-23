Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7FCB06B0038
	for <linux-mm@kvack.org>; Sun, 22 Mar 2015 20:03:08 -0400 (EDT)
Received: by pagj4 with SMTP id j4so81894305pag.2
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 17:03:08 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id vo4si7817502pbc.199.2015.03.22.17.03.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 17:03:07 -0700 (PDT)
Received: by pdbcz9 with SMTP id cz9so169048515pdb.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 17:03:07 -0700 (PDT)
Date: Sun, 22 Mar 2015 17:02:58 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 05/16] page-flags: define behavior of FS/IO-related flags
 on compound pages
In-Reply-To: <20150319200252.GA13348@node.dhcp.inet.fi>
Message-ID: <alpine.LSU.2.11.1503221613280.2680@eggly.anvils>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com> <1426784902-125149-6-git-send-email-kirill.shutemov@linux.intel.com> <550B15A0.9090308@intel.com> <20150319200252.GA13348@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>, alsa-devel@alsa-project.org

On Thu, 19 Mar 2015, Kirill A. Shutemov wrote:
> On Thu, Mar 19, 2015 at 11:29:52AM -0700, Dave Hansen wrote:
> > On 03/19/2015 10:08 AM, Kirill A. Shutemov wrote:
> > > The odd exception is PG_dirty: sound uses compound pages and maps them
> > > with PTEs. NO_COMPOUND triggers VM_BUG_ON() in set_page_dirty() on
> > > handling shared fault. Let's use HEAD for PG_dirty.

It really depends on what you do with PageDirty of the head, when you
get to support 4k pagecache with subpages of a huge compound page.

HEAD will be fine, so long as PageDirty on the head means the whole
huge page must be written back.  I expect that's what you will choose;
but one could consider that if a huge page is only mapped read-only,
but a few subpages of it writable, then only the few need be written
back, in which case ANY would be more appropriate.  NO_COMPOUND is
certainly wrong.

But that does illustrate that I consider this patch series premature:
it belongs with your huge pagecache implementation.  You seem to be
"tidying up" and adding overhead to things that are fine as they are.

> > 
> > Can we get the sound guys to look at this, btw?  It seems like an odd
> > thing that we probably don't want to keep around, right?
> 
> CC: +sound guys

I don't think this is peculiar to sound at all: there are other users
of __GFP_COMP in the tree, aren't there?  And although some of them
might turn out not to need it any more, I expect most of them still
need it for the same reason they did originally.

> 
> I'm not sure what is right fix here. At the time adding __GFP_COMP was a
> fix: see f3d48f0373c1.

The only thing special about this one, was that I failed to add
__GFP_COMP at first.

The purpose of __GFP_COMP is to allow a >0-order page (originally, just
a hugetlb page: see 2.5.60) to be mapped into userspace, and parts of it
then subjected to get_user_pages (ptrace, futex, direct I/O, infiniband
etc), and now even munmap, without destroying the integrity of the
underlying >0-order page.

We don't bother with __GFP_COMP when a >0-order page cannot be mapped
into userspace (except through /dev/mem or suchlike); we add __GFP_COMP
when it might be, to get the right reference counting.

It's normal for set_page_dirty() to be called in the course of
get_user_pages(), and it's normal for set_page_dirty() to be called
when releasing the get_user_pages() references, and it's normal for
set_page_dirty() to be called when munmap'ing a pte_dirty().

> 
> Other odd part about __GFP_COMP here is that we have ->_mapcount in tail
> pages to be used for both: mapcount of the individual page and for gup
> pins. __compound_tail_refcounted() doesn't recognize that we don't need
> tail page accounting for these pages.

So page->_mapcount of the tails is being used for both their mapcount
and their reference count: that's certainly funny, and further reason
to pursue your aim of simplifying the way THPs are refcounted.  But
not responsible for any actual bug, I think?

> 
> Hugh, I tried to ask you about the situation several times (last time on
> the summit). Any comments?

I do remember we began a curtailed conversation about this at LSF/MM.
I do not remember you asking about it earlier: when was that?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
