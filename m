Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5556B0092
	for <linux-mm@kvack.org>; Mon,  6 Oct 2014 13:01:09 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id d1so5294924wiv.2
        for <linux-mm@kvack.org>; Mon, 06 Oct 2014 10:01:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id db5si18001699wjb.19.2014.10.06.10.01.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Oct 2014 10:01:08 -0700 (PDT)
Date: Mon, 6 Oct 2014 19:00:48 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 12/17] mm: sys_remap_anon_pages
Message-ID: <20141006170048.GB31075@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
 <1412356087-16115-13-git-send-email-aarcange@redhat.com>
 <87iok0q8p4.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87iok0q8p4.fsf@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

Hi,

On Sat, Oct 04, 2014 at 06:13:27AM -0700, Andi Kleen wrote:
> Andrea Arcangeli <aarcange@redhat.com> writes:
> 
> > This new syscall will move anon pages across vmas, atomically and
> > without touching the vmas.
> >
> > It only works on non shared anonymous pages because those can be
> > relocated without generating non linear anon_vmas in the rmap code.
> 
> ...
> 
> > It is an alternative to mremap.
> 
> Why a new syscall? Couldn't mremap do this transparently?

The difference between remap_anon_pages and mremap is that mremap
fundamentally moves vmas and not pages (just the pages are moved too
because they remain attached to their respective vmas), while
remap_anon_pages move anonymous pages zerocopy across vmas but it
would never touch any vma.

mremap for example would also nuke the source vma, remap_anon_pages
just moves the pages inside the vmas instead so it doesn't require to
allocate new vmas in the area that receives the data.

We could certainly change mremap to try to detect when page_mapping of
anonymous page is 1 and downgrade the mmap_sem to down_read and then
behave like remap_anon_pages internally by updating the page->index if
all pages in the range can be updated. However to provide the same
strict checks that remap_anon_pages does and to leave the source vma
intact, mremap would need new flags that would need to alter the
normal mremap semantics that silently wipes out the destination range
and get rid of the source range and it would require to run a
remap_anon_pages-detection-routine that isn't zero cost.

Unless we add even more flags to mremap, we wouldn't have the absolute
guarantee that the vma tree is not altered in case userland is not
doing all things right (like if userland forgot MADV_DONTFORK).

Separating the two looked better, mremap was never meant to be
efficient at moving 1 page at time (or 1 THP at time).

Embedding remap_anon_pages inside mremap didn't look worthwhile
considering that as result, mremap would run slower when it cannot
behave like remap_anon_pages and it would also run slower than
remap_anon_pages when it could.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
