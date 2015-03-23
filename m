Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id C57996B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 08:17:43 -0400 (EDT)
Received: by wgdm6 with SMTP id m6so144384742wgd.2
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 05:17:43 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id je4si11511027wic.42.2015.03.23.05.17.41
        for <linux-mm@kvack.org>;
        Mon, 23 Mar 2015 05:17:42 -0700 (PDT)
Date: Mon, 23 Mar 2015 14:17:26 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 05/16] page-flags: define behavior of FS/IO-related flags
 on compound pages
Message-ID: <20150323121726.GB30088@node.dhcp.inet.fi>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1426784902-125149-6-git-send-email-kirill.shutemov@linux.intel.com>
 <550B15A0.9090308@intel.com>
 <20150319200252.GA13348@node.dhcp.inet.fi>
 <alpine.LSU.2.11.1503221613280.2680@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1503221613280.2680@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>, alsa-devel@alsa-project.org

On Sun, Mar 22, 2015 at 05:02:58PM -0700, Hugh Dickins wrote:
> On Thu, 19 Mar 2015, Kirill A. Shutemov wrote:
> > On Thu, Mar 19, 2015 at 11:29:52AM -0700, Dave Hansen wrote:
> > > On 03/19/2015 10:08 AM, Kirill A. Shutemov wrote:
> > > > The odd exception is PG_dirty: sound uses compound pages and maps them
> > > > with PTEs. NO_COMPOUND triggers VM_BUG_ON() in set_page_dirty() on
> > > > handling shared fault. Let's use HEAD for PG_dirty.
> 
> It really depends on what you do with PageDirty of the head, when you
> get to support 4k pagecache with subpages of a huge compound page.
> 
> HEAD will be fine, so long as PageDirty on the head means the whole
> huge page must be written back.  I expect that's what you will choose;
> but one could consider that if a huge page is only mapped read-only,
> but a few subpages of it writable, then only the few need be written
> back, in which case ANY would be more appropriate.  NO_COMPOUND is
> certainly wrong.
> 
> But that does illustrate that I consider this patch series premature:
> it belongs with your huge pagecache implementation.  You seem to be
> "tidying up" and adding overhead to things that are fine as they are.

I agree, it can be ANY too, since we don't use PG_dirty anywhere at the
moment. My first thought was that it's better to match PG_dirty behaviour
with LRU-related, but it's not necessary should be the case.

BTW, do we make any use of PG_dirty on pages with ->mapping == NULL?
Should we avoid dirtying them in the first place?

> > > Can we get the sound guys to look at this, btw?  It seems like an odd
> > > thing that we probably don't want to keep around, right?
> > 
> > CC: +sound guys
> 
> I don't think this is peculiar to sound at all: there are other users
> of __GFP_COMP in the tree, aren't there?  And although some of them
> might turn out not to need it any more, I expect most of them still
> need it for the same reason they did originally.

I haven't seen any other __GFP_COMP user which get it mapped to user-space
with PTEs. Do you? Probably I haven't just stepped on it.

... looking into code a bit more: at least one fb-drivers has compound
pages mapped with PTEs..

> > I'm not sure what is right fix here. At the time adding __GFP_COMP was a
> > fix: see f3d48f0373c1.
> 
> The only thing special about this one, was that I failed to add
> __GFP_COMP at first.
> 
> The purpose of __GFP_COMP is to allow a >0-order page (originally, just
> a hugetlb page: see 2.5.60) to be mapped into userspace, and parts of it
> then subjected to get_user_pages (ptrace, futex, direct I/O, infiniband
> etc), and now even munmap, without destroying the integrity of the
> underlying >0-order page.
> 
> We don't bother with __GFP_COMP when a >0-order page cannot be mapped
> into userspace (except through /dev/mem or suchlike); we add __GFP_COMP
> when it might be, to get the right reference counting.

Wouldn't non-compound >0-order page allocation + split_page() work too?

> It's normal for set_page_dirty() to be called in the course of
> get_user_pages(), and it's normal for set_page_dirty() to be called
> when releasing the get_user_pages() references, and it's normal for
> set_page_dirty() to be called when munmap'ing a pte_dirty().
> 
> > 
> > Other odd part about __GFP_COMP here is that we have ->_mapcount in tail
> > pages to be used for both: mapcount of the individual page and for gup
> > pins. __compound_tail_refcounted() doesn't recognize that we don't need
> > tail page accounting for these pages.
> 
> So page->_mapcount of the tails is being used for both their mapcount
> and their reference count: that's certainly funny, and further reason
> to pursue your aim of simplifying the way THPs are refcounted.  But
> not responsible for any actual bug, I think?

GUP pin would screw up page_mapcount() on these pages. It would affect
memory stats for the process and probably something else.

I think we can get __compound_tail_refcounted() ignore these pages by
checking if page->mapping is NULL.

> > Hugh, I tried to ask you about the situation several times (last time on
> > the summit). Any comments?
> 
> I do remember we began a curtailed conversation about this at LSF/MM.
> I do not remember you asking about it earlier: when was that?

http://lkml.kernel.org/g/20141217004734.GA23150@node.dhcp.inet.fi

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
