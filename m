Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id E851D6B006E
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 11:54:01 -0400 (EDT)
Received: by mail-qc0-f174.google.com with SMTP id m20so5939038qcx.5
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 08:54:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 88si30635731qgj.60.2014.10.07.08.53.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Oct 2014 08:53:59 -0700 (PDT)
Date: Tue, 7 Oct 2014 17:52:47 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 10/17] mm: rmap preparation for remap_anon_pages
Message-ID: <20141007155247.GD2342@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
 <1412356087-16115-11-git-send-email-aarcange@redhat.com>
 <CA+55aFx++R42L75ooE=Fmaem73=V=q7f6pYTcALxgrA1y98G-A@mail.gmail.com>
 <20141006085540.GD2336@work-vm>
 <20141006164156.GA31075@redhat.com>
 <CA+55aFxAOYBny+QwXfkPy-P3rs-RPr5SLYLcPNBiFO3waBXtQA@mail.gmail.com>
 <20141007141913.GC2342@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141007141913.GC2342@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, qemu-devel@nongnu.org, KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

On Tue, Oct 07, 2014 at 04:19:13PM +0200, Andrea Arcangeli wrote:
> mremap like interface, or file+commands protocol interface. I tend to
> like mremap more, that's why I opted for a remap_anon_pages syscall
> kept orthogonal to the userfaultfd functionality (remap_anon_pages
> could be also used standalone as an accelerated mremap in some
> circumstances) but nothing prevents to just embed the same mechanism

Sorry for the self followup, but something else comes to mind to
elaborate this further.

In term of interfaces, the most efficient I could think of to minimize
the enter/exit kernel, would be to append the "source address" of the
data received from the network transport, to the userfaultfd_write()
command (by appending 8 bytes to the wakeup command). Said that,
mixing the mechanism to be notified about userfaults with the
mechanism to resolve an userfault to me looks a complication. I kind
of liked to keep the userfaultfd protocol is very simple and doing
just its thing. The userfaultfd doesn't need to know how the userfault
was resolved, even mremap would work theoretically (until we run out
of vmas). I thought it was simpler to keep it that way. However if we
want to resolve the fault with a "write()" syscall this may be the
most efficient way to do it, as we're already doing a write() into the
pseudofd to wakeup the page fault that contains the destination
address, I just need to append the source address to the wakeup command.

I probably grossly overestimated the benefits of resolving the
userfault with a zerocopy page move, sorry. So if we entirely drop the
zerocopy behavior and the TLB flush of the old page like you
suggested, the way to keep the userfaultfd mechanism decoupled from
the userfault resolution mechanism would be to implement an
atomic-copy syscall. That would work for SIGBUS userfaults too without
requiring a pseudofd then. It would be enough then to call
mcopy_atomic(userfault_addr,tmp_addr,len) with the only constraints
that len must be a multiple of PAGE_SIZE. Of course mcopy_atomic
wouldn't page fault or call GUP into the destination address (it can't
otherwise the in-flight partial copy would be visible to the process,
breaking the atomicity of the copy), but it would fill in the
pte/trans_huge_pmd with the same strict behavior that remap_anon_pages
currently has (in turn it would by design bypass the VM_USERFAULT
check and be ideal for resolving userfaults).

mcopy_atomic could then be also extended to tmpfs and it would work
without requiring the source page to be a tmpfs page too without
having to convert page types on the fly.

If I add mcopy_atomic, the patch in subject (10/17) can be dropped of
course so it'd be even less intrusive than the current
remap_anon_pages and it would require zero TLB flush during its
runtime (it would just require an atomic copy).

So should I try to embed a mcopy_atomic inside userfault_write or can
I expose it to userland as a standalone new syscall? Or should I do
something different? Comments?

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
