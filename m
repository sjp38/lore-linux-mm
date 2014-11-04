Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 904806B00BF
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 07:31:43 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id q5so9240993wiv.10
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 04:31:43 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.234])
        by mx.google.com with ESMTP id e2si191714wjp.168.2014.11.04.04.31.42
        for <linux-mm@kvack.org>;
        Tue, 04 Nov 2014 04:31:42 -0800 (PST)
Date: Tue, 4 Nov 2014 14:29:01 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 08/10] mm/mremap: share the i_mmap_rwsem
Message-ID: <20141104122901.GA28274@node.dhcp.inet.fi>
References: <1414697657-1678-1-git-send-email-dave@stgolabs.net>
 <1414697657-1678-9-git-send-email-dave@stgolabs.net>
 <alpine.LSU.2.11.1411032148230.15596@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1411032148230.15596@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>, "Kirill A. Shutemov" <kirill.shutemov@intel.linux.com>, Michel Lespinasse <walken@google.com>, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, dbueso@suse.de, linux-mm@kvack.org

On Mon, Nov 03, 2014 at 10:04:24PM -0800, Hugh Dickins wrote:
> I'm glad to see this series back, and nicely presented: thank you.
> Not worth respinning them, but consider 1,2,3,4,5,6,7 and 9 as
> Acked-by: Hugh Dickins <hughd@google.com>
> 
> On Thu, 30 Oct 2014, Davidlohr Bueso wrote:
> 
> > As per the comment in move_ptes(), we only require taking the
> > anon vma and i_mmap locks to ensure that rmap will always observe
> > either the old or new ptes, in the case of need_rmap_lock=true.
> > No modifications to the tree itself, thus share the i_mmap_rwsem.
> > 
> > Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
> > Acked-by: Kirill A. Shutemov <kirill.shutemov@intel.linux.com>
> 
> But this one is Nacked by me.  I don't understand how you and Kirill
> could read Michel's painstaking comment on need_rmap_locks, then go
> go ahead and remove the exclusion of rmap_walk().
> 
> I agree the code here does not modify the interval tree, but the
> comment explains how we're moving a pte from one place in the tree
> to another, and in some cases there's a danger that the rmap walk
> might miss the pte from both places (which doesn't matter much to
> most of its uses, but is critical in page migration).
> 
> Or am I the one missing something?

You're completely right.

I've seen the comment (and I've added the missed need_rmap_locks case for
move_huge_pmd() before). What happened is I've over-extrapolated my
experience of rmap walk in case of split_huge_page(), which takes exclusive
anon_vma lock, to the rest of rmap use-cases. This of course was hugely
wrong.

I'm ashamed and feel really bad about the situation. Sorry.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
