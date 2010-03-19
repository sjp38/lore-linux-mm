Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3F7AA6B0047
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 09:31:30 -0400 (EDT)
Date: Fri, 19 Mar 2010 08:29:30 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 34] Transparent Hugepage support #14
In-Reply-To: <20100318234923.GV29874@random.random>
Message-ID: <alpine.DEB.2.00.1003190812560.10759@router.home>
References: <patchbomb.1268839142@v2.random> <alpine.DEB.2.00.1003171353240.27268@router.home> <20100318234923.GV29874@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri, 19 Mar 2010, Andrea Arcangeli wrote:

> There is no change at all to pte management related to this. Please
> stick to facts.

Look at the patches. They add synchronization to pte operations.

> What you're commenting is the "compound_lock" and the change to two
> functions only: get_page and put_page (put_page has to serialize
> against split_huge_page_refcount and it uses the "compound_lock"
> per-head-page bit spinlock to achieve it), and this change only
> applies to TailPages and won't add any overhead to the fast path for
> non-compound pages and no change for PageHead pages either.

These are bloating inline VM primitives and add new twists on
syncronization of pages. They add useless complexity at a very fundamental
layer of the VM.

> The only thing that tries to run get_page or put_page on a TailPage is
> gup and gup_fast. Nothing else. And it's mostly needed to avoid
> altering gup_fast/gup API while still preventing to split hugepages
> across GUP. The reason why I went to this extra-length to be backwards
> compatible with gup/gup-fast is to avoid the patch to escalate from
> <40 patches to maybe >100 or more.

What is wrong with gup and gup_fast? They mimick the traversal of the page
tables by the MMU. If you update in the right sequence then there wont be
an issue.

> It's troublesome enough already to merge this right now in this
> non-intrusive <40 patches fully backwards compatible form, you got to
> think how I could merge this if I went ahead and break everything in
> gup.

Its pretty bold to call this patchset non-intrusive. Not sure why you
think you have to break gup. Certainly works fine for page migration.

> > I would recommend that the conversion between 2M and 4K page work with
> > proper synchronization with all those handling references to the page.
>
> It's not doable without breaking every gup user, because the gup API
> allows them to run put_page on the tail page without adding any further
> synchronization at all! So the only way to avoid breaking every driver
> out there and most of kernel core, is to have the "proper
> synchronization with all those handling references to the page"
> _inside_ put_page itself, and this is what compound_lock achieves in a
> fully scalar way by implementing it as a bit spinlock on the PageHead.

This implies that the current page migration approaches are broken? The
simple solution here is not to convert the page if there is a unresolved
reference. You are only in this bind because you insists on an "atomic"
conversion between 2M and 4k pages instead of using the existing code that
tracks down references to pages etc.

> > Codepaths handling huge pages should not rely on on the fly conversion but
> > properly handle the various sizes. In most cases size does not matter
> > since the page state is contained in a single page struct regardless of
> > size. This patch here will cause future difficulties in making code handle
> > compound pages.
>
> This is definitely the long term plan, and in fact if we will
> eventually manage to remove split_huge_page _completely_, we could
> remove the compound_lock and return to the current get_page/put_page
> implementation of compound pages. The only point of compound_lock is
> to serialize put_page against split_huge_page_refcount so if the
> latter disappear, the compound_lock will disappear too and we won't
> have to take refcounts on tail pages in get_page either (which as said
> above is already zerocost for all regular pages and can't affect the
> fast path at all).

Then why introdoce the crap in the first place! Get rid of your
fixation on atomic splitting of huge pages.

> But while this suggestion of yours totally misses the point of why
> split_huge_page, that this to avoid sending a patchset that is hugely
> bigger in size and much harder to audit and merge without much risk,
> than what I sent.

Messing around with the basic refcounting and VM primitives is no risk?

> > Transparent huge page support better be introduced gradually starting f.e.
> > with the support of 2M pages for anonymous pages.
>
> "introduced gradually starting with the support of 2M pages for
> anonymous pages" is exactly what my patch does. What you're suggesting
> in the previous part of the email is the opposite!

That support is possible without refcounts on tail pages and all the other
syncronization twiddles.

> Handling hugepages natively everywhere and removing both compound_lock
> and split_huge_page would then require the swapcache to handle 2M
> pages. swapcache is sharing 100% of pagecache code so then pagecache
> would need to handle 2M pages natively too. Hence the moment we remove
> the split_huge_page and the moment we require swapcache to handle 2M
> natively without splitting the hugepage first like my patch does, the
> whole thing escalates way beyond anonymous pages, like you seem to
> agree that it's a good idea to start with.

You can convert a 2M page to 4k pages without messing up the
basic refcounting and synchronization by following the way things are done
in other parts of the kernel.

> I think it's a no brainer (and you also obviously agree above) that we
> need to "introduce gradually transparent hugepages by starting with
> anonymous memory", so it's hard to see how anyone could prefer
> something that will escalate and explode non gradually over the whole
> VM, compared to what I proposed that remains self contained and allows
> gradual extension of VM awareness of hugepages prioritizing on what is
> more important to achieve first for applications.

As far as I can tell there is no need for large scale patches as you
suggest. In fact it seems that the patches would be much smaller if
you would use the existing code that deals with page movement. Have a look
at Mel's defragmentation patches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
