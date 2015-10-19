Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 51DB882F8A
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 16:10:06 -0400 (EDT)
Received: by qkcy65 with SMTP id y65so23336788qkc.0
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 13:10:06 -0700 (PDT)
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com. [209.85.220.169])
        by mx.google.com with ESMTPS id 199si31656107qhy.112.2015.10.19.13.10.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 13:10:05 -0700 (PDT)
Received: by qkca6 with SMTP id a6so16022558qkc.3
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 13:10:05 -0700 (PDT)
Date: Mon, 19 Oct 2015 23:10:03 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/12] mm: rmap use pte lock not mmap_sem to set
 PageMlocked
Message-ID: <20151019201003.GA18106@node.shutemov.name>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
 <alpine.LSU.2.11.1510182148040.2481@eggly.anvils>
 <56248C5B.3040505@suse.cz>
 <alpine.LSU.2.11.1510190341490.3809@eggly.anvils>
 <20151019131308.GB15819@node.shutemov.name>
 <alpine.LSU.2.11.1510191218070.4652@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1510191218070.4652@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrey Konovalov <andreyknvl@google.com>, Dmitry Vyukov <dvyukov@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, Oct 19, 2015 at 12:53:17PM -0700, Hugh Dickins wrote:
> On Mon, 19 Oct 2015, Kirill A. Shutemov wrote:
> > On Mon, Oct 19, 2015 at 04:20:05AM -0700, Hugh Dickins wrote:
> > > > Note how munlock_vma_pages_range() via __munlock_pagevec() does
> > > > TestClearPageMlocked() without (or "between") pte or page lock. But the pte
> > > > lock is being taken after clearing VM_LOCKED, so perhaps it's safe against
> > > > try_to_unmap_one...
> > > 
> > > A mind-trick I found helpful for understanding the barriers here, is
> > > to imagine that the munlocker repeats its "vma->vm_flags &= ~VM_LOCKED"
> > > every time it takes the pte lock: it does not actually do that, it
> > > doesn't need to of course; but that does help show that ~VM_LOCKED
> > > must be visible to anyone getting that pte lock afterwards.
> > 
> > How can you make sure that any other codepath that changes vm_flags would
> > not make (vm_flags & VM_LOCKED) temporary true while dealing with other
> > flags?
> > 
> > Compiler can convert things like "vma->vm_flags &= ~VM_FOO;" to whatever
> > it wants as long as end result is the same. It's very unlikely that it
> > will generate code to set all bits to one and then clear all which should
> > be cleared, but it's theoretically possible.
> 
> I think that's in the realm of the fanciful.  But yes, it quite often
> turns out that what I think is fanciful, is something that Paul has
> heard compiler writers say they want to do, even if he has managed
> to discourage them from doing it so far.
 
Paul always has links to pdfs with this kind of horror. ;)

> But more to the point, when you write of "end result", the compiler
> would have no idea that releasing mmap_sem is the point at which
> end result must be established: wouldn't it have to establish end
> result before the next unlock operation, and before the end of the
> compilation unit?  pte unlock being the relevant unlock operation
> in this case, at least with my patch if not without.
> 
> > 
> > I think we need to have at lease WRITE_ONCE() everywhere we update
> > vm_flags and READ_ONCE() where we read it without mmap_sem taken.
> 
> Not a series I'll embark upon myself,
> and the patch at hand doesn't make things worse.

I think it does.

The patch changes locking rules for ->vm_flags without proper preparation
and documentation. It will strike back one day.

I know we have few other cases when we access ->vm_flags without mmap_sem,
but this doesn't justify introducing one more potentially weak codepath.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
