Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id DC8976B0089
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 02:18:25 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id 63so12459087qgz.2
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 23:18:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id s95si20709953qge.69.2014.06.02.23.18.24
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 23:18:25 -0700 (PDT)
Message-ID: <538d68b1.e8648c0a.a45f.23f8SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm] mincore: apply page table walker on do_mincore() (Re: [PATCH 00/10] mm: pagewalk: huge page cleanups and VMA passing)
Date: Tue,  3 Jun 2014 02:18:16 -0400
In-Reply-To: <538CF25E.8070905@sr71.net>
References: <20140602213644.925A26D0@viggo.jf.intel.com> <1401745925-l651h3s9@n-horiguchi@ah.jp.nec.com> <538CF25E.8070905@sr71.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Jun 02, 2014 at 02:53:34PM -0700, Dave Hansen wrote:
> On 06/02/2014 02:52 PM, Naoya Horiguchi wrote:
> > What version is this patchset based on?
> > Recently I comprehensively rewrote page table walker (from the same motivation
> > as yours) and the patchset is now in linux-mm. I guess most of your patchset
> > (I've not read them yet) conflict with this patchset.
> > So could you take a look on it?
> 
> It's on top of a version of Linus's from the last week.  I'll take a
> look at how it sits on top of -mm.

I've looked over your series, but unfortunately most of works (patch 1, 2, 3,
5, 6, 7) were already done or we don't have to do it in current linux-mm code.
Problems you try to handle in these patches come from current code's poor
design of page table walker, worst thing is that we do vma-loop inside pgd loop.
I know you tried harder to make things better, but I don't think it make sense
to maintain current bad base code for long.

As for patch 4, yes, we can apply page table walker do_mincore() and I have
a patch applicable onto linux-mm code (attached). And for other potential
page walk users, I'm investigating whether we can really apply page table
walker (some caller doesn't hold mmap_sem, so can't simply apply it.)

And for patch 8, 9, and 10, I don't think it's good idea to add a new callback
which can handle both pmd and pte (because they are essentially differnt thing).
But the underneath idea of doing pmd_trans_huge_lock() in the common code in
walk_single_entry_locked() looks nice to me. So it would be great if we can do
the same thing in walk_pmd_range() (of linux-mm) to reduce code in callbacks.

Thanks,
Naoya Horiguchi
---
