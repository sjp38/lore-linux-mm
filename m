Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id CC14C6B0031
	for <linux-mm@kvack.org>; Thu,  3 Oct 2013 20:34:39 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so3173245pbc.39
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 17:34:39 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20131003233800.8A003E0090@blue.fi.intel.com>
References: <1380287787-30252-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1380287787-30252-10-git-send-email-kirill.shutemov@linux.intel.com>
 <20131003161109.aa568784d6fc48e61dc1d33e@linux-foundation.org>
 <20131003233800.8A003E0090@blue.fi.intel.com>
Subject: Re: [PATCHv4 09/10] mm: implement split page table lock for PMD level
Content-Transfer-Encoding: 7bit
Message-Id: <20131004003428.E418EE0090@blue.fi.intel.com>
Date: Fri,  4 Oct 2013 03:34:28 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Kirill A. Shutemov wrote:
> Andrew Morton wrote:
> > On Fri, 27 Sep 2013 16:16:26 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > 
> > > The basic idea is the same as with PTE level: the lock is embedded into
> > > struct page of table's page.
> > > 
> > > We can't use mm->pmd_huge_pte to store pgtables for THP, since we don't
> > > take mm->page_table_lock anymore. Let's reuse page->lru of table's page
> > > for that.
> > > 
> > > pgtable_pmd_page_ctor() returns true, if initialization is successful
> > > and false otherwise. Current implementation never fails, but assumption
> > > that constructor can fail will help to port it to -rt where spinlock_t
> > > is rather huge and cannot be embedded into struct page -- dynamic
> > > allocation is required.
> > 
> > spinlock_t is rather large when lockdep is enabled.  What happens?
> 
> The same as with PTE split lock: CONFIG_SPLIT_PTLOCK_CPUS set to 999999
> if DEBUG_SPINLOCK || DEBUG_LOCK_ALLOC. It effectively blocks split locks
> usage if spinlock_t is too big.

Hm. It seems CONFIG_GENERIC_LOCKBREAK on 32bit systems is a problem too:
it makes sizeof(spinlock_t) 8 bythes and it increases sizeof(struct page)
by 4 bytes. I don't think it's a good idea.

Completely untested patch is below.
