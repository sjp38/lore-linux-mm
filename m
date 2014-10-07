Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 62D256B0069
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 11:10:31 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id i8so5978411qcq.14
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 08:10:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z32si24588214qge.13.2014.10.07.08.10.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Oct 2014 08:10:29 -0700 (PDT)
Date: Tue, 7 Oct 2014 16:19:13 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 10/17] mm: rmap preparation for remap_anon_pages
Message-ID: <20141007141913.GC2342@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
 <1412356087-16115-11-git-send-email-aarcange@redhat.com>
 <CA+55aFx++R42L75ooE=Fmaem73=V=q7f6pYTcALxgrA1y98G-A@mail.gmail.com>
 <20141006085540.GD2336@work-vm>
 <20141006164156.GA31075@redhat.com>
 <CA+55aFxAOYBny+QwXfkPy-P3rs-RPr5SLYLcPNBiFO3waBXtQA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxAOYBny+QwXfkPy-P3rs-RPr5SLYLcPNBiFO3waBXtQA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, qemu-devel@nongnu.org, KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

Hello,

On Tue, Oct 07, 2014 at 08:47:59AM -0400, Linus Torvalds wrote:
> On Mon, Oct 6, 2014 at 12:41 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> >
> > Of course if somebody has better ideas on how to resolve an anonymous
> > userfault they're welcome.
> 
> So I'd *much* rather have a "write()" style interface (ie _copying_
> bytes from user space into a newly allocated page that gets mapped)
> than a "remap page" style interface
> 
> remapping anonymous pages involves page table games that really aren't
> necessarily a good idea, and tlb invalidates for the old page etc.
> Just don't do it.

I see what you mean. The only cons I see is that we couldn't use then
recv(tmp_addr, PAGE_SIZE), remap_anon_pages(faultaddr, tmp_addr,
PAGE_SIZE, ..)  and retain the zerocopy behavior. Or how could we?
There's no recvfile(userfaultfd, socketfd, PAGE_SIZE).

Ideally if we could prevent the page data coming from the network to
ever become visible in the kernel we could avoid the TLB flush and
also be zerocopy but I can't see how we could achieve that.

The page data could come through a ssh pipe or anything (qemu supports
all kind of network transports for live migration), this is why
leaving the network protocol into userland is preferable.

As things stands now, I'm afraid with a write() syscall we couldn't do
it zerocopy. We'd still need to receive the memory in a temporary page
and then copy it to a kernel page (invisible to userland while we
write to it) to later map into the userfault address.

If it wasn't for the TLB flush of the old page, the remap_anon_pages
variant would be more optimal than doing a copy through a write
syscall. Is the copy cheaper than a TLB flush? I probably naively
assumed the TLB flush was always cheaper.

Now another idea that comes to mind to be able to add the ability to
switch between copy and TLB flush is using a RAP_FORCE_COPY flag, that
would then do a copy inside remap_anon_pages and leave the original
page mapped in place... (and such flag would also disable the -EBUSY
error if page_mapcount is > 1).

So then if the RAP_FORCE_COPY flag is set remap_anon_pages would
behave like you suggested (but with a mremap-like interface, instead
of a write syscall) and we could benchmark the difference between copy
and TLB flush too. We could even periodically benchmark it at runtime
and switch over the faster method (the more CPUs there are in the host
and the more threads the process has, the faster the copy will be
compared to the TLB flush).

Of course in terms of API I could implement the exact same mechanism
as described above for remap_anon_pages inside a write() to the
userfaultfd (it's a pseudo inode). It'd need two different commands to
prepare for the coming write (with a len multiple of PAGE_SIZE) to
know the address where the page should be mapped into and if to behave
zerocopy or if to skip the TLB flush and copy.

Because the copy vs TLB flush trade off is possible to achieve with
both interfaces, I think it really boils down to choosing between a
mremap like interface, or file+commands protocol interface. I tend to
like mremap more, that's why I opted for a remap_anon_pages syscall
kept orthogonal to the userfaultfd functionality (remap_anon_pages
could be also used standalone as an accelerated mremap in some
circumstances) but nothing prevents to just embed the same mechanism
inside userfaultfd if a file+commands API is preferable. Or we could
add a different syscall (separated from userfaultfd) that creates
another pseudofd to write a command plus the page data into it. Just I
wouldn't see the point of creating a pseudofd just to copy a page
atomically, the write() syscall would look more ideal if the
userfaultfd is already open for other reasons and the pseudofd
overhead is required anyway.

Last thing to keep in mind is that if using userfaults with SIGBUS and
without userfaultfd, remap_anon_pages would have been still useful, so
if we retain the SIGBUS behavior for volatile pages and we don't force
the usage for userfaultfd, it may be cleaner not to use userfaultfd
but a separate pseudofd to do the write() syscall though. Otherwise
the app would need to open the userfaultfd to resolve the fault even
though it's not using the userfaultfd protocol which doesn't look an
intuitive interface to me.

Comments welcome.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
