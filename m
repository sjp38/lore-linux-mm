Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8FC6D6B00C2
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 05:57:15 -0400 (EDT)
Date: Fri, 19 Mar 2010 00:49:23 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 34] Transparent Hugepage support #14
Message-ID: <20100318234923.GV29874@random.random>
References: <patchbomb.1268839142@v2.random>
 <alpine.DEB.2.00.1003171353240.27268@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003171353240.27268@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Wed, Mar 17, 2010 at 02:05:53PM -0500, Christoph Lameter wrote:
> 
> I am still opposed to this. The patchset results in compound pages be
> managed in 4k segments. The approach so far was that a compound
> page is simply a page struct referring to a larger linear memory
> segment. The compound state is exclusively modified in the first
> page struct which allows an easy conversion of code to deal with compound
> pages since the concept of handling a single page struct is preserved. The
> main difference between the handling of a 4K page and a compound pages
> page struct is that the compound flag is set.
> 
> Here compound pages have refcounts in each 4k segment. Critical VM path
> can no longer rely on the page to stay intact since there is this on the
> fly conversion. The on the fly "atomic" conversion requires various forms
> of synchronization and modifications to basic VM primitives like pte
> management and page refcounting.

There is no change at all to pte management related to this. Please
stick to facts.

What you're commenting is the "compound_lock" and the change to two
functions only: get_page and put_page (put_page has to serialize
against split_huge_page_refcount and it uses the "compound_lock"
per-head-page bit spinlock to achieve it), and this change only
applies to TailPages and won't add any overhead to the fast path for
non-compound pages and no change for PageHead pages either.

The only thing that tries to run get_page or put_page on a TailPage is
gup and gup_fast. Nothing else. And it's mostly needed to avoid
altering gup_fast/gup API while still preventing to split hugepages
across GUP. The reason why I went to this extra-length to be backwards
compatible with gup/gup-fast is to avoid the patch to escalate from
<40 patches to maybe >100 or more.

It's troublesome enough already to merge this right now in this
non-intrusive <40 patches fully backwards compatible form, you got to
think how I could merge this if I went ahead and break everything in
gup.

> I would recommend that the conversion between 2M and 4K page work with
> proper synchronization with all those handling references to the page.

It's not doable without breaking every gup user, because the gup API
allows them to run put_page on the tail page without adding any further
synchronization at all! So the only way to avoid breaking every driver
out there and most of kernel core, is to have the "proper
synchronization with all those handling references to the page"
_inside_ put_page itself, and this is what compound_lock achieves in a
fully scalar way by implementing it as a bit spinlock on the PageHead.

> Codepaths handling huge pages should not rely on on the fly conversion but
> properly handle the various sizes. In most cases size does not matter
> since the page state is contained in a single page struct regardless of
> size. This patch here will cause future difficulties in making code handle
> compound pages.

This is definitely the long term plan, and in fact if we will
eventually manage to remove split_huge_page _completely_, we could
remove the compound_lock and return to the current get_page/put_page
implementation of compound pages. The only point of compound_lock is
to serialize put_page against split_huge_page_refcount so if the
latter disappear, the compound_lock will disappear too and we won't
have to take refcounts on tail pages in get_page either (which as said
above is already zerocost for all regular pages and can't affect the
fast path at all).

But while this suggestion of yours totally misses the point of why
split_huge_page, that this to avoid sending a patchset that is hugely
bigger in size and much harder to audit and merge without much risk,
than what I sent.

My approach here is to allow incremental support for hugepages, just
like when SMP was first introduced and many paths started to call
lock_kernel() instead of being properly SMP threaded with spinlocks. I
know you disagree with this comparison but personally I think it's the
perfect comparison and it's an _identical_ scenario and I think it's
very appropriate to repeat it here.

> Transparent huge page support better be introduced gradually starting f.e.
> with the support of 2M pages for anonymous pages.

"introduced gradually starting with the support of 2M pages for
anonymous pages" is exactly what my patch does. What you're suggesting
in the previous part of the email is the opposite!

Handling hugepages natively everywhere and removing both compound_lock
and split_huge_page would then require the swapcache to handle 2M
pages. swapcache is sharing 100% of pagecache code so then pagecache
would need to handle 2M pages natively too. Hence the moment we remove
the split_huge_page and the moment we require swapcache to handle 2M
natively without splitting the hugepage first like my patch does, the
whole thing escalates way beyond anonymous pages, like you seem to
agree that it's a good idea to start with.

Last but not the least your design that you advocate for that will
escalate and explode everywhere all over the VM (like if the 2.0
kernel missed lock_kernel()) will perform exactly the same for KVM.
We already get 100% of the benefit with the first mostly self
contained <40 patches and as I shown in the benchmark I posted a few
days ago it's only NPT/EPT that absolutely requires hugepages, host
gets a speedup too of course, but orders of magnitude smaller than
virtualization. And things like transparent hugepages are really one
of the points where the KVM design shines boosting host and guest
cumulatively and avoiding reinventing a fairly complex wheel.

I think it's a no brainer (and you also obviously agree above) that we
need to "introduce gradually transparent hugepages by starting with
anonymous memory", so it's hard to see how anyone could prefer
something that will escalate and explode non gradually over the whole
VM, compared to what I proposed that remains self contained and allows
gradual extension of VM awareness of hugepages prioritizing on what is
more important to achieve first for applications.

Thanks a lot for the review and I welcome different opinions of
course.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
