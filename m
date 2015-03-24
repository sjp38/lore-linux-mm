Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 614E06B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 18:54:17 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so7667344pdb.2
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 15:54:17 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id es1si864661pbb.37.2015.03.24.15.54.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 15:54:16 -0700 (PDT)
Received: by pdbni2 with SMTP id ni2so7717248pdb.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 15:54:16 -0700 (PDT)
Date: Tue, 24 Mar 2015 15:54:00 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 05/16] page-flags: define behavior of FS/IO-related flags
 on compound pages
In-Reply-To: <20150323121726.GB30088@node.dhcp.inet.fi>
Message-ID: <alpine.LSU.2.11.1503241406270.1591@eggly.anvils>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com> <1426784902-125149-6-git-send-email-kirill.shutemov@linux.intel.com> <550B15A0.9090308@intel.com> <20150319200252.GA13348@node.dhcp.inet.fi> <alpine.LSU.2.11.1503221613280.2680@eggly.anvils>
 <20150323121726.GB30088@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>, alsa-devel@alsa-project.org

On Mon, 23 Mar 2015, Kirill A. Shutemov wrote:
> On Sun, Mar 22, 2015 at 05:02:58PM -0700, Hugh Dickins wrote:
> > On Thu, 19 Mar 2015, Kirill A. Shutemov wrote:
> > > On Thu, Mar 19, 2015 at 11:29:52AM -0700, Dave Hansen wrote:
> > > > On 03/19/2015 10:08 AM, Kirill A. Shutemov wrote:
> > > > > The odd exception is PG_dirty: sound uses compound pages and maps them
> > > > > with PTEs. NO_COMPOUND triggers VM_BUG_ON() in set_page_dirty() on
> > > > > handling shared fault. Let's use HEAD for PG_dirty.
> > 
> > It really depends on what you do with PageDirty of the head, when you
> > get to support 4k pagecache with subpages of a huge compound page.
> > 
> > HEAD will be fine, so long as PageDirty on the head means the whole
> > huge page must be written back.  I expect that's what you will choose;
> > but one could consider that if a huge page is only mapped read-only,
> > but a few subpages of it writable, then only the few need be written
> > back, in which case ANY would be more appropriate.  NO_COMPOUND is
> > certainly wrong.
> > 
> > But that does illustrate that I consider this patch series premature:
> > it belongs with your huge pagecache implementation.  You seem to be
> > "tidying up" and adding overhead to things that are fine as they are.
> 
> I agree, it can be ANY too, since we don't use PG_dirty anywhere at the
> moment. My first thought was that it's better to match PG_dirty behaviour
> with LRU-related, but it's not necessary should be the case.

No, yes, we do treat Dirty differently from LRU.

> 
> BTW, do we make any use of PG_dirty on pages with ->mapping == NULL?

No use that I can recall; but I suppose it's possible there's some
driver which does make use of it (if so, then you should choose ANY).

> Should we avoid dirtying them in the first place?

I don't think so: to do so would add more branches in hot paths,
just to avoid a rare case which works fine without them; and
prevent a driver from using it, in the unlikely case that's so.

> 
> > > > Can we get the sound guys to look at this, btw?  It seems like an odd
> > > > thing that we probably don't want to keep around, right?
> > > 
> > > CC: +sound guys
> > 
> > I don't think this is peculiar to sound at all: there are other users
> > of __GFP_COMP in the tree, aren't there?  And although some of them
> > might turn out not to need it any more, I expect most of them still
> > need it for the same reason they did originally.
> 
> I haven't seen any other __GFP_COMP user which get it mapped to user-space
> with PTEs. Do you? Probably I haven't just stepped on it.

I don't know why a driver would use __GFP_COMP if it cannot get mapped
into user-space (except copy-and-paste from a driver that needed it to
a driver that did not): if there's no chance of mapping into userspace,
then an ordinary >0-order allocation is good enough, isn't it?

> 
> ... looking into code a bit more: at least one fb-drivers has compound
> pages mapped with PTEs..

Good, you've saved me from looking for them.  I would expect every
__GFP_COMP allocation to be mappable into user-space, with silly
exceptions.

> 
> > > I'm not sure what is right fix here. At the time adding __GFP_COMP was a
> > > fix: see f3d48f0373c1.
> > 
> > The only thing special about this one, was that I failed to add
> > __GFP_COMP at first.
> > 
> > The purpose of __GFP_COMP is to allow a >0-order page (originally, just
> > a hugetlb page: see 2.5.60) to be mapped into userspace, and parts of it
> > then subjected to get_user_pages (ptrace, futex, direct I/O, infiniband
> > etc), and now even munmap, without destroying the integrity of the
> > underlying >0-order page.
> > 
> > We don't bother with __GFP_COMP when a >0-order page cannot be mapped
> > into userspace (except through /dev/mem or suchlike); we add __GFP_COMP
> > when it might be, to get the right reference counting.
> 
> Wouldn't non-compound >0-order page allocation + split_page() work too?

That works very well for me in huge tmpfs, yes :)

But I think the typical __GFP_COMP-using driver wants one large
contiguous area that it holds as a single piece, without worrying
about the ref-counting implications of when it's mapped into
user-space, then partially unmapped, or accessed via get_user_pages.
It can't risk losing parts of its buffer at the whim of its users.

I expect you're right that drivers could be converted over to
manage their buffers differently, without __GFP_COMP.  But __GFP_COMP
existed already for hugetlbfs, and was easy for drivers to use safely:
the whole being held until the head is freed.  (And split_page() was
added later in history - I think so the surplus tail end of a high
order page could be freed immediately.)

> 
> > It's normal for set_page_dirty() to be called in the course of
> > get_user_pages(), and it's normal for set_page_dirty() to be called
> > when releasing the get_user_pages() references, and it's normal for
> > set_page_dirty() to be called when munmap'ing a pte_dirty().
> > 
> > > 
> > > Other odd part about __GFP_COMP here is that we have ->_mapcount in tail
> > > pages to be used for both: mapcount of the individual page and for gup
> > > pins. __compound_tail_refcounted() doesn't recognize that we don't need
> > > tail page accounting for these pages.
> > 
> > So page->_mapcount of the tails is being used for both their mapcount
> > and their reference count: that's certainly funny, and further reason
> > to pursue your aim of simplifying the way THPs are refcounted.  But
> > not responsible for any actual bug, I think?
> 
> GUP pin would screw up page_mapcount() on these pages. It would affect
> memory stats for the process and probably something else.

Yes, the GUP pin would increment page_mapcount() without an additional
mapping - but can only happen once the page has already been mapped,
so FILE_MAPPED stats unaffected?  I'm not sure; but surely it wouldn't
work as well when unmapped before unpinned, since the unmapping will
see "still mapped" and the unpinning won't do anything with FILE_MAPPED.

Unmapping before unpinning is an uncommon path; but it can't be ignored,
it is the path which demanded __GFP_COMP in the first place.

Looks like extending THP by-mapcount refcounting to other compound pages
was not such a good idea.  But since nobody has noticed, we may not need
a more urgent fix than your simplification of THP refcounting.

> 
> I think we can get __compound_tail_refcounted() ignore these pages by
> checking if page->mapping is NULL.

I forget what's in page->mapping on the THP tails.  Or do you mean
page->mapping of head?  It would be better not to rely on that, I'm
not certain that no driver could set page->mapping of compound head.
There's probably some field or flag on the tails that you could use;
but I don't know that it's needed in a hurry.

> 
> > > Hugh, I tried to ask you about the situation several times (last time on
> > > the summit). Any comments?
> > 
> > I do remember we began a curtailed conversation about this at LSF/MM.
> > I do not remember you asking about it earlier: when was that?
> 
> http://lkml.kernel.org/g/20141217004734.GA23150@node.dhcp.inet.fi

Hmm, curious: never reached me (and I should have seen that on linux-mm
even if not Cc'ed); unless I deleted it by accident, that's not unknown.

And in that you explain as I've said above, so you didn't really need
me anyway.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
