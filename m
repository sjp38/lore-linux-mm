Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8E9A86B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 09:39:26 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id v81so421539956ywa.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 06:39:26 -0700 (PDT)
Received: from mail-qk0-x230.google.com (mail-qk0-x230.google.com. [2607:f8b0:400d:c09::230])
        by mx.google.com with ESMTPS id t67si6154020qkf.107.2016.05.02.06.39.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 06:39:25 -0700 (PDT)
Received: by mail-qk0-x230.google.com with SMTP id n63so73438630qkf.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 06:39:25 -0700 (PDT)
Date: Mon, 2 May 2016 15:39:20 +0200
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: GUP guarantees wrt to userspace mappings redesign
Message-ID: <20160502133919.GB4079@gmail.com>
References: <20160428181726.GA2847@node.shutemov.name>
 <20160428125808.29ad59e5@t450s.home>
 <20160428232127.GL11700@redhat.com>
 <20160429005106.GB2847@node.shutemov.name>
 <20160428204542.5f2053f7@ul30vt.home>
 <20160429070611.GA4990@node.shutemov.name>
 <20160429163444.GM11700@redhat.com>
 <20160502104119.GA23305@node.shutemov.name>
 <20160502111513.GA4079@gmail.com>
 <20160502121402.GB23305@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160502121402.GB23305@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Williamson <alex.williamson@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, May 02, 2016 at 03:14:02PM +0300, Kirill A. Shutemov wrote:
> On Mon, May 02, 2016 at 01:15:13PM +0200, Jerome Glisse wrote:
> > On Mon, May 02, 2016 at 01:41:19PM +0300, Kirill A. Shutemov wrote:
> > > Other thing I would like to discuss is if there's a problem on vfio side.
> > > To me it looks like vfio expects guarantee from get_user_pages() which it
> > > doesn't provide: obtaining pin on the page doesn't guarantee that the page
> > > is going to remain mapped into userspace until the pin is gone.
> > > 
> > > Even with THP COW regressing fixed, vfio would stay fragile: any
> > > MADV_DONTNEED/fork()/mremap()/whatever what would make vfio expectation
> > > broken.
> > > 
> > 
> > Well i don't think it is fair/accurate assessment of get_user_pages(), page
> > must remain mapped to same virtual address until pin is gone. I am ignoring
> > mremap() as it is a scient decision from userspace and while virtual address
> > change in that case, the pined page behind should move with the mapping.
> > Same of MADV_DONTNEED. I agree that get_user_pages() is broken after fork()
> > but this have been the case since dawn of time, so it is something expected.
> > 
> > If not vfio, then direct-io, have been expecting this kind of behavior for
> > long time, so i see this as part of get_user_pages() guarantee.
> > 
> > Concerning vfio, not providing this guarantee will break countless number of
> > workload. Thing like qemu/kvm allocate anonymous memory and hand it over to
> > the guest kernel which presents it as memory. Now a device driver inside the
> > guest kernel need to get bus mapping for a given (guest) page, which from
> > host point of view means a mapping from anonymous page to bus mapping but
> > for guest to keep accessing the same page the anonymous mapping (ie a
> > specific virtual address on the host side) must keep pointing to the same
> > page. This have been the case with get_user_pages() until now, so whether
> > we like it or not we must keep that guarantee.
> > 
> > This kind of workload knows that they can't do mremap()/fork()/... and keep
> > that guarantee but they at expect existing guarantee and i don't think we
> > can break that.
> 
> Quick look around:
> 
>  - I don't see any check page_count() around __replace_page() in uprobes,
>    so it can easily replace pinned page.

Not an issue for existing user as this is only use to instrument code, existing
user do not execute code from virtual address for which they have done a GUP.

> 
>  - KSM has the page_count() check, there's still race wrt GUP_fast: it can
>    take the pin between the check and establishing new pte entry.

KSM is not an issue for existing user as they all do get_user_pages() with
write = 1 and the KSM first map page read only before considering to replace
them and check page refcount. So there can be no race with gup_fast there.

> 
>  - khugepaged: the same story as with KSM.

I am assuming you are talking about collapse_huge_page() here, if you look in
that function there is a comment about GUP_fast. Noneless i believe the comment
is wrong as i believe there is an existing race window btw pmdp_collapse_flush()
and __collapse_huge_page_isolate() :

  get_user_pages_fast()          | collapse_huge_page()
   gup_pmd_range() -> valid pmd  | ...
                                 | pmdp_collapse_flush() clear pmd
                                 | ...
                                 | __collapse_huge_page_isolate()
                                 | [Above check page count and see no GUP]
   gup_pte_range() -> ref page   |

This is a very unlikely race because get_user_pages_fast() can not be preempted
while collapse_huge_page() can be preempted btw pmdp_collapse_flush() and
__collapse_huge_page_isolate(), more over collapse_huge_page() has lot more
instructions to chew on than get_user_pages_fast() btw gup_pmd_range() and
gup_pte_range().

So i think this is an unlikely race. I am not sure how to forbid it from
happening, except maybe in get_user_pages_fast() by checking pmd is still
valid after gup_pte_range().

> 
> I don't see how we can deliver on the guarantee, especially with lockless
> GUP_fast.
> 
> Or am I missing something important?

So as said above, i think existing user of get_user_pages() are not sensitive
to the races you pointed above. I am sure there are some corner case where
the guarantee that GUP pin a page against a virtual address is violated but
i do not think they apply to any existing user of GUP.

Note that i would personaly like that this existing assumption about GUP did
not exist. I hate it, but fact is that it does exist and nobody can remember
where the Doc did park the Delorean

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
