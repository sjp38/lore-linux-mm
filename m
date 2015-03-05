Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id B73116B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 13:51:59 -0500 (EST)
Received: by wivr20 with SMTP id r20so9065091wiv.3
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 10:51:59 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e16si15729847wiv.97.2015.03.05.10.51.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 10:51:58 -0800 (PST)
Date: Thu, 5 Mar 2015 19:51:12 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 19/21] userfaultfd: remap_pages: UFFDIO_REMAP preparation
Message-ID: <20150305185112.GL4280@redhat.com>
References: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
 <1425575884-2574-20-git-send-email-aarcange@redhat.com>
 <CA+55aFzW=qaO0iKZWK9BWDNHu4eOgiKOJ-=0SvzsmZawuH5_3A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzW=qaO0iKZWK9BWDNHu4eOgiKOJ-=0SvzsmZawuH5_3A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: qemu-devel@nongnu.org, KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Android Kernel Team <kernel-team@android.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

On Thu, Mar 05, 2015 at 09:39:48AM -0800, Linus Torvalds wrote:
> Is this really worth it? On real loads? That people are expected to use?

I fully agree that it's not worth merging upstream UFFDIO_REMAP until
(and if) a real world usage for it will showup. To further clarify:
would this not have been an RFC, the patchset would have stopped at
patch number 15/21 included.

Merging UFFDIO_REMAP with no real life users, would just increase the
attack vector surface of the kernel for no good.

Thanks for your idea that the UFFDIO_COPY is faster, the userland code
we submitted for qemu only uses UFFDIO_COPY|ZEROPAGE, it never uses
UFFDIO_REMAP. I immediately agreed about UFFDIO_COPY being preferable
after you mentioned it during review of the previous RFC.

However this being a RFC with a large audience, and UFFDIO_REMAP
allowing to "remove" memory (think like externalizing memory into to
ceph with deduplication or such), I still added it just in case there
are real world use cases that may justify me keeping it around (even
if I would definitely not have submitted it for merging in the short
term regardless).

In addition of dropping the parts that aren't suitable for merging in
the short term like UFFDIO_REMAP, for any further submits that won't
substantially alter the API like it happened between the v2 to v3
RFCs, I'll also shrink the To/Cc list considerably.

> Considering how we just got rid of one special magic VM remapping
> thing that nobody actually used, I'd really hate to add a new one.

Having to define an API somehow, I tried to think at all possible
future usages and make sure the API would allow for those if needed.

> Quite frankly, *if* we ever merge userfaultfd, I would *strongly*
> argue for not merging the remap parts. I just don't see the point. It
> doesn't seem to add anything that is semantically very important -
> it's *potentially* a faster copy, but even that is
> 
>   (a) questionable in the first place

Yes, we already measured the UFFDIO_COPY is faster than UFFDIO_REMAP,
the userfault latency decreases -20%.

> 
> and
> 
>  (b) unclear why anybody would ever care about performance of
> infrastructure that nobody actually uses today, and future use isn't
> even clear or shown to be particualrly performance-sensitive.

The only potential _theoretical_ case that justify the existence of
UFFDIO_REMAP is about "removing" memory from the address space. To
"add" memory UFFDIO_COPY and UFFDIO_ZEROPAGE are always preferable
like you suggested.

> So basically I'd like to see better documentation, a few real use
> cases (and by real I very much do *not* mean "you can use it for
> this", but actual patches to actual projects that matter and that are
> expected to care and merge them), and a simplified series that doesn't
> do the remap thing.

So far I wrote some doc in 2/21 and in the cover letter, but certainly
more docs are necessary. Trinity is also needed (I got trinity running
on the v2 API but I haven't adapted to the new API yet).

About the real world usages, this is the primary one:

http://lists.gnu.org/archive/html/qemu-devel/2015-02/msg04873.html

And it actually cannot be merged in qemu until userfaultfd is merged
in the kernel. There's simply no safe way to implement postcopy live
migration without something equivalent to the userfaultfd if all Linux
VM features are intended to be retained in the destination node.

> Because *every* time we add a new clever interface, we end up with
> approximately zero users and just pain down the line. Examples:
> splice, mremap, yadda yadda.

Aside from mremap which I think is widely used, I totally agree in
principle.

For now I can quite comfortably guarantee the above real life user for
userfaultfd (qemu), but there are potential 5 of them. And none needs
UFFDIO_REMAP, which is again why I totally agree of not submitting it
for merging and it was intended it only for the initial RFC to share
the idea of "removing" the memory with a larger audience before I
shrink the Cc/To list for further updates.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
