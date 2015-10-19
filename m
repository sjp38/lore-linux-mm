Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id CF92C82F7F
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 09:13:11 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so5123685wic.0
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 06:13:11 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id el1si4558915wid.66.2015.10.19.06.13.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 06:13:10 -0700 (PDT)
Received: by wijp11 with SMTP id p11so5396045wij.0
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 06:13:10 -0700 (PDT)
Date: Mon, 19 Oct 2015 16:13:08 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/12] mm: rmap use pte lock not mmap_sem to set
 PageMlocked
Message-ID: <20151019131308.GB15819@node.shutemov.name>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
 <alpine.LSU.2.11.1510182148040.2481@eggly.anvils>
 <56248C5B.3040505@suse.cz>
 <alpine.LSU.2.11.1510190341490.3809@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1510190341490.3809@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrey Konovalov <andreyknvl@google.com>, Dmitry Vyukov <dvyukov@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Mon, Oct 19, 2015 at 04:20:05AM -0700, Hugh Dickins wrote:
> > Note how munlock_vma_pages_range() via __munlock_pagevec() does
> > TestClearPageMlocked() without (or "between") pte or page lock. But the pte
> > lock is being taken after clearing VM_LOCKED, so perhaps it's safe against
> > try_to_unmap_one...
> 
> A mind-trick I found helpful for understanding the barriers here, is
> to imagine that the munlocker repeats its "vma->vm_flags &= ~VM_LOCKED"
> every time it takes the pte lock: it does not actually do that, it
> doesn't need to of course; but that does help show that ~VM_LOCKED
> must be visible to anyone getting that pte lock afterwards.

How can you make sure that any other codepath that changes vm_flags would
not make (vm_flags & VM_LOCKED) temporary true while dealing with other
flags?

Compiler can convert things like "vma->vm_flags &= ~VM_FOO;" to whatever
it wants as long as end result is the same. It's very unlikely that it
will generate code to set all bits to one and then clear all which should
be cleared, but it's theoretically possible.

I think we need to have at lease WRITE_ONCE() everywhere we update
vm_flags and READ_ONCE() where we read it without mmap_sem taken.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
