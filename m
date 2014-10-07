Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f172.google.com (mail-vc0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id B44736B0069
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 12:56:20 -0400 (EDT)
Received: by mail-vc0-f172.google.com with SMTP id lf12so5217934vcb.3
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 09:56:20 -0700 (PDT)
Received: from mail-vc0-x22e.google.com (mail-vc0-x22e.google.com [2607:f8b0:400c:c03::22e])
        by mx.google.com with ESMTPS id 16si2042552vce.105.2014.10.07.09.56.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Oct 2014 09:56:19 -0700 (PDT)
Received: by mail-vc0-f174.google.com with SMTP id hq12so5064215vcb.5
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 09:56:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141007141913.GC2342@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
	<1412356087-16115-11-git-send-email-aarcange@redhat.com>
	<CA+55aFx++R42L75ooE=Fmaem73=V=q7f6pYTcALxgrA1y98G-A@mail.gmail.com>
	<20141006085540.GD2336@work-vm>
	<20141006164156.GA31075@redhat.com>
	<CA+55aFxAOYBny+QwXfkPy-P3rs-RPr5SLYLcPNBiFO3waBXtQA@mail.gmail.com>
	<20141007141913.GC2342@redhat.com>
Date: Tue, 7 Oct 2014 12:56:18 -0400
Message-ID: <CA+55aFwJP_suQWhgSp1NvYOPGB5QrBYS57LT14n7TWXqCEajdg@mail.gmail.com>
Subject: Re: [PATCH 10/17] mm: rmap preparation for remap_anon_pages
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, qemu-devel@nongnu.org, KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

On Tue, Oct 7, 2014 at 10:19 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
>
> I see what you mean. The only cons I see is that we couldn't use then
> recv(tmp_addr, PAGE_SIZE), remap_anon_pages(faultaddr, tmp_addr,
> PAGE_SIZE, ..)  and retain the zerocopy behavior. Or how could we?
> There's no recvfile(userfaultfd, socketfd, PAGE_SIZE).

You're doing completelt faulty math, and you haven't thought it through.

Your "zero-copy" case is no such thing. Who cares if some packet
receive is zero-copy, when you need to set up the anonymous page to
*receive* the zero copy into, which involves page allocation, page
zeroing, page table setup with VM and page table locking, etc etc.

The thing is, the whole concept of "zero-copy" is pure and utter
bullshit. Sun made a big deal about the whole concept back in the
nineties, and IT DOES NOT WORK. It's a scam. Don't buy into it. It's
crap. It's made-up and not real.

Then, once you've allocated and cleared the page, mapped it in, your
"zero-copy" model involves looking up the page in the page tables
again (locking etc), then doing that zero-copy to the page. Then, when
you remap it, you look it up in the page tables AGAIN, with locking,
move it around, have to clear the old page table entry (which involves
a locked cmpxchg64), a TLB flush with most likely a cross-CPU IPI -
since the people who do this are all threaded and want many CPU's, and
then you insert the page into the new place.

That's *insane*. It's crap. All just to try to avoid one page copy.

Don't do it. remapping games really are complete BS. They never beat
just copying the data. It's that simple.

> As things stands now, I'm afraid with a write() syscall we couldn't do
> it zerocopy.

Really, you need to rethink your whole "zerocopy" model. It's broken.
Nobody sane cares. You've bought into a model that Sun already showed
doesn't work.

The only time zero-copy works is in random benchmarks that are very
careful to not touch the data at all at any point, and also try to
make sure that the benchmark is very much single-threaded so that you
never have the whole cross-CPU IPI issue for the TLB invalidate. Then,
and only then, can zero-copy win. And it's just not a realistic
scenario.

> If it wasn't for the TLB flush of the old page, the remap_anon_pages
> variant would be more optimal than doing a copy through a write
> syscall. Is the copy cheaper than a TLB flush? I probably naively
> assumed the TLB flush was always cheaper.

A local TLB flush is cheap. That's not the problem. The problem is the
setup of the page, and the clearing of the page, and the cross-CPU TLB
flush. And the page table locking, etc etc.

So no, I'm not AT ALL worried about a single "invlpg" instruction.
That's nothing. Local CPU TLB flushes of single pages are basically
free. But that really isn't where the costs are.

Quite frankly, the *only* time page remapping has ever made sense is
when it is used for realloc() kind of purposes, where you need to
remap pages not because of zero-copy, but because you need to change
the virtual address space layout. And then you make sure it's not a
common operation, because you're not doing it as a performance win,
you're doing it because you're changing your virtual layout.

Really. Zerocopy is for benchmarks, and for things like "splice()"
when you can avoid the page tables *entirely*. But the notion that
page remapping of user pages is faster than a copy is pure and utter
garbage. It's simply not true.

So I really think you should aim for a "write()": kind of interface.

With write, you may not get the zero-copy, but on the other hand it
allows you to re-use the source buffer many times without having to
allocate new pages and map it in etc. So a "read()+write()" loop (or,
quite commonly a "generate data computationally from a compressed
source + write()" loop) is actually much more efficient than the
zero-copy remapping, because you don't have all the complexities and
overheads in creating the source page.

It is possible that that could involve "splice()" too, although I
don't really think the source data tends to be in page-aligned chunks.
But hey, splice() at least *can* be faster than copying (and then we
have vmsplice() not because it's magically faster, but because it can
under certain circumstances be worth it, and it kind of made sense to
allow the interface, but I really don't think it's used very much or
very useful).

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
