Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 94A4D6B006E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 07:50:34 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id n3so24459367wiv.5
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 04:50:34 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id n6si30153067wjy.39.2014.12.01.04.50.33
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 04:50:33 -0800 (PST)
Date: Mon, 1 Dec 2014 14:50:24 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/5] mm: Refactor do_wp_page, extract the reuse case
Message-ID: <20141201125024.GC13856@node.dhcp.inet.fi>
References: <1417435485-24629-1-git-send-email-raindel@mellanox.com>
 <1417435485-24629-2-git-send-email-raindel@mellanox.com>
 <20141201123038.GA13856@node.dhcp.inet.fi>
 <297b07d8c87a4077a7140d39a68c1eb0@AM3PR05MB0935.eurprd05.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <297b07d8c87a4077a7140d39a68c1eb0@AM3PR05MB0935.eurprd05.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mgorman@suse.de" <mgorman@suse.de>, "riel@redhat.com" <riel@redhat.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "matthew.r.wilcox@intel.com" <matthew.r.wilcox@intel.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Haggai Eran <haggaie@mellanox.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "pfeiner@google.com" <pfeiner@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Sagi Grimberg <sagig@mellanox.com>, "walken@google.com" <walken@google.com>

On Mon, Dec 01, 2014 at 12:34:30PM +0000, Shachar Raindel wrote:
> 
> 
> > -----Original Message-----
> > From: Kirill A. Shutemov [mailto:kirill@shutemov.name]
> > Sent: Monday, December 01, 2014 2:31 PM
> > To: Shachar Raindel
> > Cc: linux-mm@kvack.org; kirill.shutemov@linux.intel.com;
> > mgorman@suse.de; riel@redhat.com; ak@linux.intel.com;
> > matthew.r.wilcox@intel.com; dave.hansen@linux.intel.com; n-
> > horiguchi@ah.jp.nec.com; akpm@linux-foundation.org; torvalds@linux-
> > foundation.org; Haggai Eran; aarcange@redhat.com; pfeiner@google.com;
> > hannes@cmpxchg.org; Sagi Grimberg; walken@google.com
> > Subject: Re: [PATCH 1/5] mm: Refactor do_wp_page, extract the reuse case
> > 
> > On Mon, Dec 01, 2014 at 02:04:41PM +0200, Shachar Raindel wrote:
> > > When do_wp_page is ending, in several cases it needs to reuse the
> > > existing page. This is achieved by making the page table writable,
> > > and possibly updating the page-cache state.
> > >
> > > Currently, this logic was "called" by using a goto jump. This makes
> > > following the control flow of the function harder. It is also
> > > against the coding style guidelines for using goto.
> > >
> > > As the code can easily be refactored into a specialized function,
> > > refactor it out and simplify the code flow in do_wp_page.
> > >
> > > Signed-off-by: Shachar Raindel <raindel@mellanox.com>
> > > ---
> > >  mm/memory.c | 136 ++++++++++++++++++++++++++++++++++-----------------
> > ---------
> > >  1 file changed, 78 insertions(+), 58 deletions(-)
> > >
> > > diff --git a/mm/memory.c b/mm/memory.c
> > > index 3e50383..61334e9 100644
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -2020,6 +2020,75 @@ static int do_page_mkwrite(struct
> > vm_area_struct *vma, struct page *page,
> > >  }
> > >
> > >  /*
> > > + * Handle write page faults for pages that can be reused in the
> > current vma
> > > + *
> > > + * This can happen either due to the mapping being with the VM_SHARED
> > flag,
> > > + * or due to us being the last reference standing to the page. In
> > either
> > > + * case, all we need to do here is to mark the page as writable and
> > update
> > > + * any related book-keeping.
> > > + */
> > > +static int wp_page_reuse(struct mm_struct *mm, struct vm_area_struct
> > *vma,
> > > +			 unsigned long address, pte_t *page_table,
> > > +			 spinlock_t *ptl, pte_t orig_pte,
> > > +			 struct page *recycled_page, int dirty_page,
> > 
> > recycled_page? what's wrong with old_page?
> > 
> 
> You are reusing the page in this function, so I was feeling that naming it
> "old" is less indicative than "recycled". However, if you prefer "old", I
> am happy with it.

Sinse it's the only page in the scope, call it simply -- 'page'.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
