Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DB26E6B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 08:14:06 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e201so74273061wme.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 05:14:06 -0700 (PDT)
Received: from mail-lf0-x22c.google.com (mail-lf0-x22c.google.com. [2a00:1450:4010:c07::22c])
        by mx.google.com with ESMTPS id l203si16965700lfd.171.2016.05.02.05.14.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 05:14:05 -0700 (PDT)
Received: by mail-lf0-x22c.google.com with SMTP id j8so53180162lfd.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 05:14:05 -0700 (PDT)
Date: Mon, 2 May 2016 15:14:02 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: GUP guarantees wrt to userspace mappings redesign
Message-ID: <20160502121402.GB23305@node.shutemov.name>
References: <20160428102051.17d1c728@t450s.home>
 <20160428181726.GA2847@node.shutemov.name>
 <20160428125808.29ad59e5@t450s.home>
 <20160428232127.GL11700@redhat.com>
 <20160429005106.GB2847@node.shutemov.name>
 <20160428204542.5f2053f7@ul30vt.home>
 <20160429070611.GA4990@node.shutemov.name>
 <20160429163444.GM11700@redhat.com>
 <20160502104119.GA23305@node.shutemov.name>
 <20160502111513.GA4079@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160502111513.GA4079@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Alex Williamson <alex.williamson@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, May 02, 2016 at 01:15:13PM +0200, Jerome Glisse wrote:
> On Mon, May 02, 2016 at 01:41:19PM +0300, Kirill A. Shutemov wrote:
> > Other thing I would like to discuss is if there's a problem on vfio side.
> > To me it looks like vfio expects guarantee from get_user_pages() which it
> > doesn't provide: obtaining pin on the page doesn't guarantee that the page
> > is going to remain mapped into userspace until the pin is gone.
> > 
> > Even with THP COW regressing fixed, vfio would stay fragile: any
> > MADV_DONTNEED/fork()/mremap()/whatever what would make vfio expectation
> > broken.
> > 
> 
> Well i don't think it is fair/accurate assessment of get_user_pages(), page
> must remain mapped to same virtual address until pin is gone. I am ignoring
> mremap() as it is a scient decision from userspace and while virtual address
> change in that case, the pined page behind should move with the mapping.
> Same of MADV_DONTNEED. I agree that get_user_pages() is broken after fork()
> but this have been the case since dawn of time, so it is something expected.
> 
> If not vfio, then direct-io, have been expecting this kind of behavior for
> long time, so i see this as part of get_user_pages() guarantee.
> 
> Concerning vfio, not providing this guarantee will break countless number of
> workload. Thing like qemu/kvm allocate anonymous memory and hand it over to
> the guest kernel which presents it as memory. Now a device driver inside the
> guest kernel need to get bus mapping for a given (guest) page, which from
> host point of view means a mapping from anonymous page to bus mapping but
> for guest to keep accessing the same page the anonymous mapping (ie a
> specific virtual address on the host side) must keep pointing to the same
> page. This have been the case with get_user_pages() until now, so whether
> we like it or not we must keep that guarantee.
> 
> This kind of workload knows that they can't do mremap()/fork()/... and keep
> that guarantee but they at expect existing guarantee and i don't think we
> can break that.

Quick look around:

 - I don't see any check page_count() around __replace_page() in uprobes,
   so it can easily replace pinned page.

 - KSM has the page_count() check, there's still race wrt GUP_fast: it can
   take the pin between the check and establishing new pte entry.

 - khugepaged: the same story as with KSM.

I don't see how we can deliver on the guarantee, especially with lockless
GUP_fast.

Or am I missing something important?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
