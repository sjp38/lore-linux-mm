Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id F34D36B008A
	for <linux-mm@kvack.org>; Mon,  6 Oct 2014 12:42:41 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id cc10so5215446wib.13
        for <linux-mm@kvack.org>; Mon, 06 Oct 2014 09:42:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id xb6si17896795wjc.57.2014.10.06.09.42.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Oct 2014 09:42:41 -0700 (PDT)
Date: Mon, 6 Oct 2014 18:41:56 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 10/17] mm: rmap preparation for remap_anon_pages
Message-ID: <20141006164156.GA31075@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
 <1412356087-16115-11-git-send-email-aarcange@redhat.com>
 <CA+55aFx++R42L75ooE=Fmaem73=V=q7f6pYTcALxgrA1y98G-A@mail.gmail.com>
 <20141006085540.GD2336@work-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141006085540.GD2336@work-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, qemu-devel@nongnu.org, KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

Hello,

On Mon, Oct 06, 2014 at 09:55:41AM +0100, Dr. David Alan Gilbert wrote:
> * Linus Torvalds (torvalds@linux-foundation.org) wrote:
> > On Fri, Oct 3, 2014 at 10:08 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > >
> > > Overall this looks a fairly small change to the rmap code, notably
> > > less intrusive than the nonlinear vmas created by remap_file_pages.
> > 
> > Considering that remap_file_pages() was an unmitigated disaster, and
> > -mm has a patch to remove it entirely, I'm not at all convinced this
> > is a good argument.
> > 
> > We thought remap_file_pages() was a good idea, and it really really
> > really wasn't. Almost nobody used it, why would the anonymous page
> > case be any different?
> 
> I've posted code that uses this interface to qemu-devel and it works nicely;
> so chalk up at least one user.
> 
> For the postcopy case I'm using it for, we need to place a page, atomically
>   some thread might try and access it, and must either
>      1) get caught by userfault etc or
>      2) must succeed in it's access
> 
> and we'll have that happening somewhere between thousands and millions of times
> to pages in no particular order, so we need to avoid creating millions of mappings.

Yes, that's our current use case.

Of course if somebody has better ideas on how to resolve an anonymous
userfault they're welcome.

How to resolve an userfault is orthogonal on how to detect it and to
notify userland about it and to be notified when the userfault has
been resolved. The latter is what the userfault and userfaultfd
do. The former is what remap_anon_pages is used for but we could use
something else too if there are better ways. mremap would clearly work
too, but it would be less strict (it could lead to silent data
corruption if there are bugs in the userland code), it would be slower
and it would eventually a hit a -ENOMEM failure because there would be
too many vmas.

I could in theory drop remap_anon_pages from this patchset, but
without an optimal way to resolve an userfault, the rest isn't so
useful.

We're currently discussing on what would be the best way to resolve a
MAP_SHARED userfault on tmpfs in fact (that's not sorted yet), but so
far, it seems remap_anon_pages fits the bill for anonymous memory.

remap_anon_pages is not as problematic to maintain as remap_file_pages
for the reason explained in the commit header, but there are other
reasons: it doesn't require special pte_file and it changes nothing of
how anonymous page faults works. All it requires is a loop to catch a
changed page->index (previously page->index couldn't change, not it
can, that's the only thing it changes).

remap_file_pages complexity derives from not being allowed to change
page->index during a move because the page_mapping may be bigger than
1, while that is precisely what remap_anon_pages does.

As long as this "rmap preparation" is the only constraints that
remap_anon_pages introduces in terms of rmap, it looks a nice
not-too-intrusive solution to resolve anonymous userfaults
efficiently.

Introducing remap_anon_pages in fact doesn't reduce the
simplification derived from the removal of remap_file_pages.

As opposed removing remap_anon_pages later would only have the benefit
of removing this very patch 10/17 and no other benefit.

In short remap_anon_pages does this (heavily simplified):

   pte = *src_pte;
   *src_pte = 0;
   pte_page(pte)->index = adjusted according to src_vma/dst_vma->vm_pgoff
   *dst_pte = pte;

It guarantees not to modify the vmas and in turn it doesn't require to
take the mmap_sem for writing.

To use remap_anon_pages, each thread has to create its own temporary
vma with MADV_DONTFORK set on it (not formally required by the syscall
strict checks, but then the application must never fork if
MADV_DONTFORK isn't set or remap_anon_pages could return -EBUSY:
there's no risk of silent data corruption even if the thread forks
without setting MADV_DONTFORK) as source region where receive data
through the network. Then after the data is fully received
rmap_anon_pages moves the page from the temporary vma to the address
where the userfault triggered atomically (while other threads may be
attempting to access the userfault address too, thanks to
remap_anon_pages atomic behavior they won't risk to ever see partial
data coming from the network).

remap_anon_pages as side effect creates an hole in the temporary
(source) vma, so the next recv() syscall receiving data from the
network will fault-in a new anonymous page without requiring any
further malloc/free or other kind of vma mangling.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
