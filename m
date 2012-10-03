Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 25E706B007D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 17:47:43 -0400 (EDT)
Received: by iakh37 with SMTP id h37so1598331iak.14
        for <linux-mm@kvack.org>; Wed, 03 Oct 2012 14:47:42 -0700 (PDT)
Date: Wed, 3 Oct 2012 14:46:59 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch -mm] mm, thp: fix mlock statistics fix
In-Reply-To: <20121003142519.93375e01.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1210031430190.14479@eggly.anvils>
References: <alpine.DEB.2.00.1209191818490.7879@chino.kir.corp.google.com> <alpine.LSU.2.00.1209192021270.28543@eggly.anvils> <alpine.DEB.2.00.1209261821380.7745@chino.kir.corp.google.com> <alpine.DEB.2.00.1209261929270.8567@chino.kir.corp.google.com>
 <alpine.LSU.2.00.1209271814340.2107@eggly.anvils> <20121003131012.f88b0d66.akpm@linux-foundation.org> <alpine.DEB.2.00.1210031403270.4352@chino.kir.corp.google.com> <20121003142519.93375e01.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 3 Oct 2012, Andrew Morton wrote:
> On Wed, 3 Oct 2012 14:10:41 -0700 (PDT)
> David Rientjes <rientjes@google.com> wrote:
> 
> > > The free_page_mlock() hunk gets dropped because free_page_mlock() is
> > > removed.  And clear_page_mlock() doesn't need this treatment.  But
> > > please check my handiwork.
> > > 
> > 
> > I reviewed what was merged into -mm and clear_page_mlock() does need this 
> > fix as well.
> 
> argh, it got me *again*.  grr.

I've no objection to more documentation on PageHuge, but neither you nor
it were to blame for that "oversight".  It's simply that David's original
patch clearly did not need such a change in clear_page_mlock(), because
it could never be necessary from where it was then called; but I changed
where it's called, whereupon it becomes evident that the extra is needed.

"evident" puts it rather too strongly.  Most munlocking happens through
munlock_vma_page() instead, but the clear_page_mlock() path covers
truncation.  THPages cannot be file pages at present, but perhaps they
could be anonymous pages COWed from file pages (I've not checked the
exact criteria THP applies)?  In which case, subject to truncation too.

Hugh

> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm: document PageHuge somewhat
> 
> Cc: David Rientjes <rientjes@google.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/hugetlb.c |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff -puN mm/hugetlb.c~mm-document-pagehuge-somewhat mm/hugetlb.c
> --- a/mm/hugetlb.c~mm-document-pagehuge-somewhat
> +++ a/mm/hugetlb.c
> @@ -671,6 +671,11 @@ static void prep_compound_gigantic_page(
>  	}
>  }
>  
> +/*
> + * PageHuge() only returns true for hugetlbfs pages, but not for normal or
> + * transparent huge pages.  See the PageTransHuge() documentation for more
> + * details.
> + */
>  int PageHuge(struct page *page)
>  {
>  	compound_page_dtor *dtor;
> _

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
