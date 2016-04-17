Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F79C6B007E
	for <linux-mm@kvack.org>; Sat, 16 Apr 2016 21:21:47 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id dx6so142736425pad.0
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 18:21:47 -0700 (PDT)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id yt2si4014051pab.188.2016.04.16.18.21.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Apr 2016 18:21:46 -0700 (PDT)
Received: by mail-pf0-x232.google.com with SMTP id 184so69099880pff.0
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 18:21:46 -0700 (PDT)
Date: Sat, 16 Apr 2016 18:21:37 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH mmotm 5/5] huge tmpfs: add shmem_pmd_fault()
In-Reply-To: <20160417004626.GA5169@node.shutemov.name>
Message-ID: <alpine.LSU.2.11.1604161801030.1675@eggly.anvils>
References: <alpine.LSU.2.11.1604161621310.1907@eggly.anvils> <alpine.LSU.2.11.1604161638230.1907@eggly.anvils> <20160417004626.GA5169@node.shutemov.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, kernel test robot <xiaolong.ye@intel.com>, Xiong Zhou <jencce.kernel@gmail.com>, Matthew Wilcox <willy@linux.intel.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 17 Apr 2016, Kirill A. Shutemov wrote:
> On Sat, Apr 16, 2016 at 04:41:33PM -0700, Hugh Dickins wrote:
> > The pmd_fault() method gives the filesystem an opportunity to place
> > a trans huge pmd entry at *pmd, before any pagetable is exposed (and
> > an opportunity to split it on COW fault): now use it for huge tmpfs.
> > 
> > This patch is a little raw: with more time before LSF/MM, I would
> > probably want to dress it up better - the shmem_mapping() calls look
> > a bit ugly; it's odd to want FAULT_FLAG_MAY_HUGE and VM_FAULT_HUGE just
> > for a private conversation between shmem_fault() and shmem_pmd_fault();
> > and there might be a better distribution of work between those two, but
> > prising apart that series of huge tests is not to be done in a hurry.
> > 
> > Good for now, presents the new way, but might be improved later.
> > 
> > This patch still leaves the huge tmpfs map_team_by_pmd() allocating a
> > pagetable while holding page lock, but other filesystems are no longer
> > doing so; and we've not yet settled whether huge tmpfs should (like anon
> > THP) or should not (like DAX) participate in deposit/withdraw protocol.
> > 
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> 
> Just for record: I don't like ->pmd_fault() approach because it results in
> two requests to file system (two shmem_fault() in this case) if we don't
> have a huge page to map: one for huge page (failed) and then one for small.
> I think this case should be rather common: all mounts without huge pages
> enabled. I expect performance regression from this too.

Yes, I did consider that when making the switchover.  But it's only
when pmd_none(*pmd), not the other 511 times; and the caches have been
primed for the pte fallback.  So I didn't expect it to matter, and to be
outweighed by having map_pages() back in its old position.  Ah, you'll
point out that map_pages() makes it a smaller ratio than 511:1.

But if someone speeds up pmd_fault(), or replaces it by a better strategy,
so much the better - I found it a little odd, doing two very different
things, one of which (splitting) must be done in a non-fault context too.

Anyway, I await judgement from the robot.

And note your point about regressing mounts without huge pages enabled:
maybe I should add an early VM_FAULT_FALLBACK for that case, or perhaps
it will end up in the vma flags instead of my shmem_mapping() check.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
