Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8F57B8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 01:10:49 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id u20so23299773qtk.6
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 22:10:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u11si1798415qvl.90.2019.01.21.22.10.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 22:10:48 -0800 (PST)
Date: Tue, 22 Jan 2019 14:10:37 +0800
From: Peter Xu <peterx@redhat.com>
Subject: Re: [PATCH RFC 02/24] mm: userfault: return VM_FAULT_RETRY on signals
Message-ID: <20190122061037.GA14907@xz-x1>
References: <20190121075722.7945-1-peterx@redhat.com>
 <20190121075722.7945-3-peterx@redhat.com>
 <20190121154017.GA3711@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190121154017.GA3711@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Mike Kravetz <mike.kravetz@oracle.com>, Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>

On Mon, Jan 21, 2019 at 10:40:18AM -0500, Jerome Glisse wrote:
> On Mon, Jan 21, 2019 at 03:57:00PM +0800, Peter Xu wrote:
> > There was a special path in handle_userfault() in the past that we'll
> > return a VM_FAULT_NOPAGE when we detected non-fatal signals when waiting
> > for userfault handling.  We did that by reacquiring the mmap_sem before
> > returning.  However that brings a risk in that the vmas might have
> > changed when we retake the mmap_sem and even we could be holding an
> > invalid vma structure.  The problem was reported by syzbot.
> 
> This is confusing this should be a patch on its own ie changes to
> fs/userfaultfd.c where you remove that path.

Sure I will.

> 
> > 
> > This patch removes the special path and we'll return a VM_FAULT_RETRY
> > with the common path even if we have got such signals.  Then for all the
> > architectures that is passing in VM_FAULT_ALLOW_RETRY into
> > handle_mm_fault(), we check not only for SIGKILL but for all the rest of
> > userspace pending signals right after we returned from
> > handle_mm_fault().
> > 
> > The idea comes from the upstream discussion between Linus and Andrea:
> > 
> >   https://lkml.org/lkml/2017/10/30/560
> > 
> > (This patch contains a potential fix for a double-free of mmap_sem on
> >  ARC architecture; please see https://lkml.org/lkml/2018/11/1/723 for
> >  more information)
> 
> This patch should only be about changing the return to userspace rule.
> Before this patch the arch fault handler returned to userspace only
> for fatal signal, after this patch it returns to userspace for any
> signal.

Ok.  I'll make the first patch to do the signal changes, then the
second patch to remove the userfault path explicitly.

> 
> It would be a lot better to have a fix for arc as a separate patch so
> that we can focus on reviewing only one thing.

I just noticed that it was fixed just a few days ago in commit
4d447455e73b.  Then I'll just simply rebase to Linus master and use
the upstream fix, then I can drop this paragraph.

Thanks for the review!

-- 
Peter Xu
